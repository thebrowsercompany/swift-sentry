// SPDX-License-Identifier: BSD-3-Clause
@testable import SwiftSentry
import XCTest

extension SentryValueSerializable {
    func jsonData() throws -> Data {
        let serialized = serialized()
        let jsonData = try XCTUnwrap(String(cString: sentry_value_to_json(serialized)).data(using: .utf8))

        return jsonData
    }
}
