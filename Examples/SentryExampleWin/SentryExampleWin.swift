// SPDX-License-Identifier: BSD-3-Clause

import Foundation
import SwiftSentry
import SwiftWin32

@main
final class SentryExampleWin: ApplicationDelegate {
  func application(_: Application, didFinishLaunchingWithOptions _: [Application.LaunchOptionsKey: Any]?) -> Bool {
    print("We're launching!")
    startSentry()
    return true
  }

  func applicationWillTerminate(_: Application) {
    Sentry.close()
  }

  func startSentry() {
      print("Spinning up task to start Sentry")
      Task {
        await MainActor.run {
          Sentry.start { options in
            options.dsn = SentryConfiguration.dsn
            options.environment = "Debug"
            options.debug = true

            print("Release: \(String(describing: options.releaseName))")
          }
        }
      }
  }
}
