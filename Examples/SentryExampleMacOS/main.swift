// SPDX-License-Identifier: BSD-3-Clause

import Foundation
import SwiftSentry

@main
enum MacOSExample {
    static func main() {
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

            let user = User(userId: "1", email: "archie@arc.net")
            Sentry.setUser(user)
        }
    }
}
