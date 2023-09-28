// SPDX-License-Identifier: BSD-3-Clause

@_exported
import sentry

import Foundation

enum SentryLevel: Int {
  case debug = -1
  case info = 0
  case warning = 1
  case error = 2
  case fatal = 3
}

public enum SentrySDK {
  static var crashedLastRun: Bool {
    sentry_get_crashed_last_run() == 0 ? false : true
  }

  @MainActor
  public static func close() {
    sentry_close()
  }

  @MainActor
  public static func start(_ configurationOptions: (inout Options) -> Void) {
    var options = Options()
    configurationOptions(&options)
    start(with: options)
  }

  private static func start(with options: Options) {
    let o = sentry_options_new()
    defer { sentry_options_free(o) }

    sentry_options_set_dsn(o, options.dsn.cString(using: .utf8))
    sentry_options_set_symbolize_stacktraces(o, 1)
    sentry_options_set_database_path(o, ".sentry-native")
    sentry_options_set_release(o, "browser-win@0.0.0")
    sentry_options_set_on_crash(o, { _, event, _ in
      print("Crash handler triggered!")
      return event
    }, nil)
    sentry_options_set_debug(o, 1)
    sentry_options_set_shutdown_timeout(o, 20000)

    sentry_init(o)
  }

  private static func test() {
    sentry_capture_event(sentry_value_new_message_event(SENTRY_LEVEL_INFO, "custom", "It works!"))
  }
}
