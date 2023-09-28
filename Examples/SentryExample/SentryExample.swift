// SPDX-License-Identifier: BSD-3-Clause

import Foundation
import SwiftSentry
import SwiftWin32
import WinSDK
import testing

@_cdecl("DllMain")
func DllMain(
     hinstDLL: HINSTANCE,  // handle to DLL module
     fdwReason: DWORD,     // reason for calling function
     lpvReserved: LPVOID) -> WindowsBool {
      print("wow")
      return true
}

@main
final class SentryExample: ApplicationDelegate {
  func application(_: Application, didFinishLaunchingWithOptions _: [Application.LaunchOptionsKey: Any]?) -> Bool {
    print("We're launching!")
    startSentry()
    Testing().doit()
    return true
  }

  func applicationWillTerminate(_: Application) {
    Task {
      await MainActor.run {
        SentrySDK.close()
      }
    }
  }

  func startSentry() {
    Task {
      await MainActor.run {
        SentrySDK.start { options in
          options.dsn = SentryConfiguration.dsn
        }

        signal(SIGABRT, { _ in
          print("We're dead")
        })

        signal(SIGSEGV, { _ in
          print("We're dead")
          SentrySDK.close()
        })
      }
    }
  }
}
