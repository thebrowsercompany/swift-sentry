// SPDX-License-Identifier: BSD-3-Clause

import Foundation
import SwiftSentry
import SwiftWin32

@main
final class SentryExample: ApplicationDelegate {
  func application(_: Application, didFinishLaunchingWithOptions _: [Application.LaunchOptionsKey: Any]?) -> Bool { 
    print("We're launching!")
    startSentry()
    return true
  }

  func applicationWillTerminate(_: Application) { 
    Sentry.close()
  }

  func startSentry() {
    Task {
      await MainActor.run {
        print("Spinning up task to start Sentry")
        Sentry.start(with: SentryConfiguration.dsn)
      }
    }
  }
}
