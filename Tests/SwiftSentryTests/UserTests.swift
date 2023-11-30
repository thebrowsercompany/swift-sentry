// SPDX-License-Identifier: BSD-3-Clause
@testable import SwiftSentry
import XCTest

final class SwiftSentryTests: XCTestCase {
    func testUserWithPartialDataGetsSerialized() throws {
        let user = User(email: "archie@arc.net")

        let serialized = user.serialized()

        let serializedEmail = try XCTUnwrap(sentry_value_as_string(sentry_value_get_by_key(serialized, "email")))

        XCTAssertEqual(String(cString: serializedEmail), "archie@arc.net", "Email should be the same through the serialization")
    }

    func testUserWithFullDataGetsSerialized() throws {
        let user = User(userId: "1", email: "archie@arc.net", username: "Archie")
        let serialized = user.serialized()

        try zip(["id", "email", "username"], ["1", "archie@arc.net", "Archie"]).forEach { group in
            let deserialized = try XCTUnwrap(sentry_value_as_string(sentry_value_get_by_key(serialized, group.0.cString(using: .utf8))))
            let value = String(cString: deserialized)
            XCTAssertEqual(value, group.1, "Expected value of '\(group.0)' to be '\(group.1)'; got '\(value)'")
        }
    }

    func testCanMutateValuesAfterInitialization() throws {
      let user = User()

      XCTAssertNil(user.email)

      user.email = "gritty@arc.net"

      XCTAssertEqual(user.email, "gritty@arc.net")
    }
}
