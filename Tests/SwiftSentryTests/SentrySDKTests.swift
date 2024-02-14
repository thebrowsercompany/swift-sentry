import XCTest

@testable import SwiftSentry

final class SentrySDKTests: XCTestCase {
  func testOptionsHashingIsConsistent() throws {
    let options = Options()
    options.dsn = "https://hello@world.com"
    options.environment = "testing"

    let path = SentrySDK.getCachePath(for: options)

    for _ in 0..<10 {
      let newPath = SentrySDK.getCachePath(for: options)

      XCTAssertEqual(path, newPath)
    }

    options.environment = "debug"
    let debugPath = SentrySDK.getCachePath(for: options)

    XCTAssertNotEqual(path, debugPath)
  }

  func testTwoOptionsWithSameValuesProduceSamePath() throws {
    let optionsOne = Options()
    optionsOne.dsn = "https://hello@world.com"

    let optionsTwo = Options()
    optionsTwo.dsn = "https://hello@world.com"

    XCTAssertEqual(SentrySDK.getCachePath(for: optionsOne), SentrySDK.getCachePath(for: optionsTwo))
  }
}
