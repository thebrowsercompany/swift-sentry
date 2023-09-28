// SPDX-License-Identifier: BSD-3-Clause

@_exported
import sentry

import Foundation

public enum Sentry {
  @MainActor
  public static func start(with dsn: String) {
    let options = sentry_options_new()!
    defer {
      sentry_options_free(options)
    }

    sentry_options_set_dsn(options, dsn.cString(using: .utf8))
    sentry_options_set_symbolize_stacktraces(options, 1)
    sentry_options_set_database_path(options, ".sentry-native")
    sentry_options_set_release(options, "browser-win@0.0.0")
    sentry_options_set_on_crash(options, { _, event, _ in
      print("Crash handler triggered!")
      return event
    }, nil)
    sentry_options_set_debug(options, 1)
    sentry_options_set_shutdown_timeout(options, 20000)
    sentry_init(options)

    test()
  }

  private static func test() {
    sentry_capture_event(sentry_value_new_message_event(SENTRY_LEVEL_INFO, "custom", "It works!"))
  }

  public static func close() {
    sentry_close()
  }
}
