// SPDX-License-Identifier: BSD-3-Clause
@testable import SwiftSentry
import XCTest

final class SentryIdTests: XCTestCase {
  func testCreatingIdFromSentryValueWorks() {
    let uuid = "12c2d058d58442709aa2eca08bf20986"
    let value = sentry_uuid_from_string(uuid.cString(using: .utf8))

    let id = SentryId(value: value)

    XCTAssertEqual(id.sentryIdString(), uuid, "We should never have a nil SentryId")
  }

  func testCreatingInvalidIdYieldsEmpty() {
    let tooLong = "12c2d058d58442709aa2eca08bf2098612c2d058d58442709aa2eca08bf20986"
    let tooShort = "1233"
    let empty = "00000000000000000000000000000000"

    let id = SentryId(UUIDString: tooLong)
    let id2 = SentryId(UUIDString: tooShort)

    XCTAssertEqual(id.sentryIdString(), empty, "ids that are too long should yield a SentryId with all zeroes.")
    XCTAssertEqual(id2.sentryIdString(), empty, "Ids that are too short should yield a SentryId with all zeroes.")
  }

  func testDashesAreHandledCorrectly() {
    let uuid = "12c2d058-d584-4270-9aa2-eca08bf20986"
    let id = SentryId(UUIDString: uuid)

    XCTAssertEqual(id.sentryIdString(), uuid, "UUID strings with dashes should be handled correctly.")
  }
}