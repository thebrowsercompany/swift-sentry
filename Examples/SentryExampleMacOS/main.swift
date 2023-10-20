import SwiftSentry
import Foundation

@main
struct MacOSExample {
  static func main() -> Void {
    startSentry()
    defer { Sentry.close() }

    print("Hello macOS")
  }

  static func startSentry() {
    Task {
      await MainActor.run {
        print("A")
        Sentry.start { options in
          options.dsn = "your-dsn-goes-here"
          options.debug = true
        }
      }
    }
  }
}
