// SPDX-License-Identifier: BSD-3-Clause

@_exported
import sentry

import Foundation

#if os(Windows)
import stowedExceptions
import WinSDK
#endif

public enum SentrySDK {
    /// Whether or not the application crashed during it's last run.
    /// - note: This value is only accurate after the SDK have been initialized.
    public static var crashedLastRun: Bool {
        switch sentry_get_crashed_last_run() {
            case 0:
            return false
            case 1:
            return true
            case -1:
            // Since the Cocoa SDK expects a boolean value, and tri-bools aren't available
            // we default to returning false if the SDK hasn't been initialized yet.
            return false
            default:
            return false
        }
    }
    /// Starts the SDK after passing in a closure to configure the options in the SDK.
    /// - note: This should be called on the main thread/actor, but the annotation is
    /// specifically not present to preserve cross-platform compatibility.
    public static func start(_ configureOptions: (inout Options) -> Void) {
        var options = Options()
        configureOptions(&options)
        start(options)
    }

    static let fatalErrorMessageHandle = getFatalErrorMessageHandle()

    /// Starts the SDK after passing in a closure to configure the options in the SDK.
    /// - note: This should be called on the main thread/actor, but the annotation is
    /// specifically not present to preserve cross-platform compatibility.
    public static func start(_ options: Options) {
        guard !options.dsn.isEmpty else {
            fatalError("Sentry DSN must not be empty!")
        }

        let o = sentry_options_new()

        sentry_options_set_dsn(o, options.dsn.cString(using: .utf8))
        sentry_options_set_symbolize_stacktraces(o, options.attachStacktrace ? 1 : 0)
        sentry_options_set_environment(o, options.environment.cString(using: .utf8))

        let sentryCachePath = getCachePath(for: options)

        sentry_options_set_database_path(o, sentryCachePath.cString(using: .utf8))

        if options.debug {
            sentry_options_set_debug(o, 1)
        }

        if let handlerPath = options.crashHandlerPath {
          sentry_options_set_handler_path(o, handlerPath.withUnsafeFileSystemRepresentation { String(cString: $0!) }.cString(using: .utf8))
        }

        if let release = options.releaseName {
            sentry_options_set_release(o, release.cString(using: .utf8))
        }

        if let beforeHandler = options.beforeSend {
            sentry_options_set_before_send(o, { event, _, _ -> sentry_value_t in
                // eventually call before handler...
                event
            }, nil)
        }

        #if os(Windows)
        if let fatalErrorMessageHandle {
            sentry_options_set_on_crash(o, { uctx, event, _ -> sentry_value_t in
                if let msg = loadFatalErrorMessageBuffer(SentrySDK.fatalErrorMessageHandle) {
                    sentry_value_set_by_key(event, "message",
                                            sentry_value_new_string(msg))
                }
                return event
            }, nil)
        }
        #endif

        if let shutdownTimeout = options.shutdownTimeout {
            sentry_options_set_shutdown_timeout(o, UInt64(shutdownTimeout))
        }

        sentry_init(o)

        /* Disable child crash reporting temporarily, see PERF-810.
        #if os(Windows)
            let path = sentry_options_get_handler_ipc_pipew(o)

            // It has to be this name rather than "SENTRY..." or "ARC..."
            // because the Chromium sandbox is specially set up to allow this
            // environment variable through to child processes.
            "CHROME_CRASHPAD_PIPE_NAME".withCString(encodedAs: UTF16.self) {
                SetEnvironmentVariableW($0, path)
            }
        #endif
        */
    }

    public static func setUser(_ user: User?) {
        guard let user else {
            // If a nil user is set, we clear out the user on Sentry.
            sentry_remove_user()
            return
        }

        sentry_set_user(user.serialized())
    }

    public static func addBreadcrumb(_ breadcrumb: Breadcrumb) {
        sentry_add_breadcrumb(breadcrumb.serialized())
    }

    public static func setTag(key: String, value: String) {
        sentry_set_tag(key, value)
    }

    public static func capture(event: Event) -> SentryId {
        let eventSerialized = event.serialized()
        let id = sentry_capture_event(eventSerialized)

        return SentryId(value: id)
    }

    public static func captureException(type: String, description: String) -> SentryId {
        let event = Event(level: SentryLevel.fatal)
        event.message = description

        let eventSerialized = event.serialized()

        let exception = sentry_value_new_exception(type, description)
        sentry_event_add_exception(eventSerialized, exception)

        // Create a thread for the current thread, attach an stacktrace and add it to the event
        let thread = sentry_value_new_thread(UInt64(GetCurrentThreadId()),  Thread.current.name)
        sentry_value_set_stacktrace(thread, nil, 0)
        sentry_event_add_thread(eventSerialized, thread)

        let id = sentry_capture_event(eventSerialized)

        return SentryId(value: id)
    }

#if os(Windows)
    // Report an exception record to Sentry. This is a Windows specific function as
    // it relies on the EXCEPTION_POINTERS type to get the crash stack of the exception.
    //
    // It differs from captureException by the fact that it captures the stacktrace of the
    // exception instead of the current stacktrace.
    //
    // From the sentry documentation:
    // This is safe to be called from a crashing thread and may not return.
    public static func captureExceptionRecord(exceptionRecord: UnsafeMutablePointer<EXCEPTION_POINTERS>) {
        var exceptionContext = sentry_ucontext_s()
        // Use the custom `captureStowedExceptions` reporter if the exception code is the stowed exception code. This
        // will include more information about the crash.
        guard let record = exceptionRecord.pointee.ExceptionRecord else {
            let breadcrumb = sentry_value_new_breadcrumb("Empty exception record", "ERROR: The exception record is empty")
            sentry_add_breadcrumb(breadcrumb)
            return
        }

        let stowedExceptionCode = 0xC000027B
        if record.pointee.ExceptionCode == stowedExceptionCode {
            captureStowedExceptions(exceptionRecord: record.pointee)
        } else {
            // Crashpad will not be able to report the exception if the context record is nil, this can happen if the exception
            // is coming from RaiseFailFastException as the "contextRecord" argument of this function is optional. In this case,
            // it's necessary to capture the context manually here.
            var context = CONTEXT()
            if exceptionRecord.pointee.ContextRecord == nil {
                RtlCaptureContext(&context)
                exceptionRecord.pointee.ContextRecord = withUnsafePointer(to: &context) { ptr -> PCONTEXT? in
                    return UnsafeMutablePointer(mutating: ptr)
                }
            }

            exceptionContext.exception_ptrs = exceptionRecord.pointee
            withUnsafePointer(to: &exceptionContext) { exceptionContextPtr in
                sentry_handle_exception(exceptionContextPtr)
            }
        }
    }

    private static func captureStowedExceptions(exceptionRecord: EXCEPTION_RECORD) {
        let event = Event(level: SentryLevel.fatal)
        event.message = "This is a crash with stowed exceptions. The events are grouped by the stack trace of the latest stowed exception.\n" +
                        "You can find the crash stack of the other stowed exceptions and of the outer crash by scrolling down."
        let eventSerialized = event.serialized()
        // The list of loaded modules is cached and might not contain the modules that were loaded after initializing Sentry (e.g. the WinApp runtimes).
        // Clearing the module cache will force Sentry to re-fetch the list of loaded modules.
        sentry_clear_modulecache()

        // Log the outer crash stack trace and all the stowed exceptions as distinct exception events.
        // The events will be displayed in the Sentry UI as a single event with multiple stack traces.
        let exceptions = sentry_value_new_list()
        let exception = sentry_value_new_exception("Outer crash", "Outer crash with stowed exceptions")

        setTag(key: "handled", value: "no")

        sentry_value_set_stacktrace(exception, nil, 0)
        sentry_value_append(exceptions, exception)
        sentry_value_set_by_key(eventSerialized, "exception", exceptions);

        let exceptionInfo = exceptionRecord.ExceptionInformation
        // For stowed exceptions, the first element in `ExceptionInformation` is a pointer to an array of `STOWED_EXCEPTION_INFORMATION_V2`
        // and the second element is the total number of stowed exceptions in this array
        var hresult: String?
        if let arrayPointer = UnsafeMutablePointer<UnsafeMutablePointer<STOWED_EXCEPTION_INFORMATION_V2>?>(bitPattern: UInt(exceptionInfo.0)) {
            let totalExceptions = Int(exceptionInfo.1)
            for index in (0..<totalExceptions).reversed() {
                if let stowedExceptionPointer = arrayPointer.advanced(by: index).pointee {
                    hresult = addStowedExceptionToList(
                        stowedException: stowedExceptionPointer.pointee,
                        index: totalExceptions - index - 1,
                        exceptions: exceptions,
                        isMostRecent: index == 0)
                }
            }
        }
        // Add a few fingerprints to the event to improve the clustering of the stowed exceptions. They sometime all get reported as individual crashes,
        // these few fingerprints should help cluster them. Using the HRESULT of the last stowed exception as well as the number of stowed exceptions.
        // seems like a good starting point.
        let fingerprint = sentry_value_new_list()
        sentry_value_append(fingerprint, sentry_value_new_string("StowedException"))
        if hresult != nil {
            sentry_value_append(fingerprint, sentry_value_new_string(hresult))
        }
        sentry_value_append(fingerprint, sentry_value_new_string(String(exceptionInfo.1)))
        sentry_value_set_by_key(eventSerialized, "fingerprint", fingerprint)

        sentry_capture_event(eventSerialized)
        close()
    }

    private static func succeeded(result: HRESULT) -> Bool {
        return result >= 0
    }

    private static func addStowedExceptionToList(stowedException: STOWED_EXCEPTION_INFORMATION_V2, index: Int, exceptions: sentry_value_t, isMostRecent: Bool = false) -> String?{
        // The stowed exception form should always be 1, let's still check it and log a breadcrumb if it's not.
        if stowedException.exceptionForm != 1 {
            let breadcrumb = sentry_value_new_breadcrumb("Unexpected stowed exception form", "ERROR: The stowed exception form is not 1, it's \(stowedException.exceptionForm)")
            sentry_add_breadcrumb(breadcrumb)
            return nil
        }

        guard !succeeded(result: stowedException.resultCode) else {
            return nil
        }

        if let stackTrace = stowedException.stackTrace {
            let ips = UnsafeMutablePointer<UnsafeMutableRawPointer?>.allocate(capacity: Int(stowedException.stackTraceCount))
            let sourceIps = stackTrace.assumingMemoryBound(to: UnsafeMutableRawPointer?.self)
            for i in 0..<Int(stowedException.stackTraceCount) {
                ips[i] = sourceIps[i]
            }
            let hresult = String(UInt32(bitPattern: stowedException.resultCode), radix: 16)
            let exception = sentry_value_new_exception("StowedException", "Stowed exception #\(index + 1) - HRESULT: 0x\(hresult)")
            sentry_value_set_stacktrace(exception, ips, Int(stowedException.stackTraceCount))

            if isMostRecent {
              let mechanism = sentry_value_new_object()
              sentry_value_set_by_key(mechanism, "type", sentry_value_new_string("generic"))
              sentry_value_set_by_key(mechanism, "handled", sentry_value_new_bool(Int32(false)))
              sentry_value_set_by_key(exception, "mechanism", mechanism)
            }
            sentry_value_append(exceptions, exception)
            ips.deallocate()
            return hresult
        }

        // TODO: Check if it's worth including the nested exception in the reports. Local testing shows that the nested exception
        // type is often `XAML` and the nested exception itself contains a repeat of the stack trace from the stowed exception, so
        // it's not clear if it's worth adding this to the event.

        return nil
    }
#endif

    /**
    * Instructs the transport to flush its send queue.
    *
    * The `timeout` parameter is in milliseconds.
    *
    * Returns 0 on success, or a non-zero return value in case the timeout is hit.
    *
    * Note that this function will block the thread it was called from until the
    * sentry background worker has finished its work or it timed out, whichever
    * comes first.
    */
    public static func flush(timeout: UInt64) -> Int32 {
        return sentry_flush(timeout)
    }

    public static func close() {
        sentry_close()
    }

    internal static func getCachePath(for options: Options) -> String {
      guard let basePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
        fatalError("Unable to find caches directory for storing Sentry reports!")
      }

      // Use the dsn + environment to create some variability in the hash
      // to put the same app running in different environments in different
      // places on disk to avoid any potential contention. We can't use a
      // simple `Hasher` since it's values are not stable across launches.
      let hashed = Data("\(options.dsn)\(options.environment)".utf8).SHA1.hexString

      let cachePath = basePath
          .appendingPathComponent("io.sentry")
          .appendingPathComponent(hashed)
          .path

      return cachePath
    }
}
