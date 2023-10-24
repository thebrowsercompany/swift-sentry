// SPDX-License-Identifier: BSD-3-Clause

@_exported
import sentry

import Foundation

public enum Sentry {
    @MainActor
    public static func start(_ configureOptions: (inout Options) -> Void) {
        var options = Options()
        configureOptions(&options)
        start(options)
    }

    @MainActor
    public static func start(_ options: Options) {
        guard !options.dsn.isEmpty else {
            fatalError("Sentry DSN must not be empty!")
        }

        let o = sentry_options_new()

        sentry_options_set_dsn(o, options.dsn.cString(using: .utf8))
        sentry_options_set_symbolize_stacktraces(o, options.attachStacktrace ? 1 : 0)
        sentry_options_set_environment(o, options.environment.cString(using: .utf8))

        guard let cachePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("Unable to find caches directory for storing Sentry reports!")
        }

        let sentryCachePath = cachePath
            .appendingPathComponent("io.sentry")
            .appendingPathComponent(String(options.dsn.hash))
            .path

        sentry_options_set_database_path(o, sentryCachePath.cString(using: .utf8))

        if options.debug {
            sentry_options_set_debug(o, 1)
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
            sentry_set_user(sentry_value_new_null())
            return
        }

        sentry_set_user(user.serialized())
    }

    public static func close() {
        sentry_close()
    }
}
