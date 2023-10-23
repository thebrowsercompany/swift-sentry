// SPDX-License-Identifier: BSD-3-Clause

import SwiftSentry
import Foundation

@main
struct MacOSExample {
  static func main() -> Void {
    startSentry()
    defer { Sentry.close() }

    print("Hello macOS")

    RunLoop.current.run()
  }

  static func startSentry() {
    Task { @MainActor in
      Sentry.start { options in
        options.dsn = "your-dsn-goes-here"
        options.debug = true
      }
    }
  }
}
