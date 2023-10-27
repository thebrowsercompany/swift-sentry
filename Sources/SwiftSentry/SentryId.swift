// SPDX-License-Identifier: BSD-3-Clause
import Foundation

/// A wrapper around UUID
/// UUIDs are declared as either 32 character hexidecimal strings without dashes
/// "12c2d058d58442709aa2eca08bf20986" or 36 character strings with dashes
/// "12c2d058-d584-4270-9aa2-eca08bf20986".
/// - note: It is recommended to omit dashes and use UUID v4 in cases.
public struct SentryId {
  private let uuid: Foundation.UUID

  public init() {
    uuid = Foundation.UUID()
  }

  public init(UUID uuid: Foundation.UUID) {
    self.uuid = uuid
  }

  public init(UUIDString string: String) {
    var uuid: Foundation.UUID = .empty

    if string.length == 36 {
      uuid = Foundation.UUID(uuidString: string) ?? .empty
    } else if string.length == 32 {
      var mutableString = string

      mutableString.insert("-", at: 8)
      mutableString.insert("-", at: 13)
      mutableString.insert("-", at: 18)
      mutableString.insert("-", at: 23)

      uuid = Foundation.UUID(uuidString: mutableString) ?? .empty
    }

    self.uuid = uuid
  }

  func sentryIdString() -> String {
    return uuid.uuidString.lowercased().replacingOccurrences(of: "-", with: "")
  }
}

private extension Foundation.UUID {
  static var empty = Foundation.UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
}

private extension String {
  mutating func insert(_ newElement: Character, at i: Int) {
    insert(newElement, at: self.index(startIndex, offsetBy: i))
  }
}

internal extension SentryId {
  init(value: sentry_uuid_t) {
    var mutableSentryUUID = value
    var cString = [CChar].init(repeating: .zero, count: 37)
    sentry_uuid_as_string(&mutableSentryUUID, &cString)
    self.uuid = UUID(uuidString: String(cString: cString)) ?? .empty
  }
}