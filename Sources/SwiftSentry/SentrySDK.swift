// SPDX-License-Identifier: BSD-3-Clause

@_exported
import sentry

import Foundation

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

        sentry_init(o)
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

    public static func capture(event: Event) -> SentryId {
        let id = sentry_capture_event(event.serialized())

        return SentryId(value: id)
    }

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
