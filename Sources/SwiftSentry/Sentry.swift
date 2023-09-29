// SPDX-License-Identifier: BSD-3-Clause

@_exported
import sentry

import Foundation

public enum Sentry {
  public static func start(with dsn: String) {
    DispatchQueue.main.async {
      let options = sentry_options_new()!

      sentry_options_set_dsn(options, dsn.cString(using: .utf8))
      sentry_options_set_symbolize_stacktraces(options, 1)
      sentry_options_set_environment(options, "development");
      sentry_options_set_database_path(options, ".sentry-native")
      sentry_options_set_release(options, "browser-win@0.0.0")
      sentry_options_set_debug(options, 1)
      sentry_init(options)
      _installAbortCatcherWorkaround()
    }
  }

  // Required to get around issues with https://github.com/getsentry/sentry-native/issues/591
  private static func _installAbortCatcherWorkaround() {
    signal(SIGINT) { code in
      print("Caught SIGINT: \(code)")
    }
    signal(SIGILL) { code in
      print("Caught SIGILL: \(code)")
    }
    signal(SIGFPE) { code in
      print("Caught SIGFPE: \(code)")
    }
    signal(SIGSEGV) { code in
      print("Caught SIGSEGV: \(code)")
    }
    signal(SIGTERM) { code in
      print("Caught SIGTERM: \(code)")
    }
    signal(SIGBREAK) { code in
      print("Caught SIGBREAK: \(code)")
    }
    signal(SIGABRT) { code in
      print("Caught SIGABRT: \(code)")
    }
  }

  private static func test() {
    sentry_capture_event(sentry_value_new_message_event(SENTRY_LEVEL_INFO, "custom", "It works!"))
  }

  public static func close() {
    sentry_close()
  }
}
