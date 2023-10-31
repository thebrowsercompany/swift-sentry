// SPDX-License-Identifier: BSD-3-Clause
@testable import SwiftSentry
import XCTest

final class EventTests: XCTestCase {
  func testBasicEventGetsSerialized() throws {
    var event = Event(level: .info)
    event.message = "(❁´◡`❁)"
    event.eventType = "message"

    let deserialized =  try JSONDecoder().decode(EventTestBasicEventSerialization.self, from: event.jsonData())

    XCTAssertEqual(deserialized.eventId.length, 32, "Serialized UUIDs should be 32 characters in length.")
    XCTAssertEqual(deserialized.level, "info", "Levels should be correctly serialized to strings.")
    XCTAssertEqual(try XCTUnwrap(deserialized.message), "(❁´◡`❁)", "Messages should be serialized properly.")
    #if os(macOS) || os(iOS)
    XCTAssertEqual(deserialized.platform, "cocoa")
    #elseif os(Windows)
    XCTAssertEqual(deserialized.platform, "native")
    #else
    XCTAssertEqual(deserialized.platform, "other")
    #endif
  }

  func testEventWithTagsGetsSerialized() throws {
    var event = Event(level: .warning)
    event.tags = [
      "one": "valueOne",
      "two": "valueTwo"
    ]

    let deserialized =  try JSONDecoder().decode(EventTestTagsSerialization.self, from: event.jsonData())
    XCTAssertEqual(deserialized.tags.count, 2, "Two tags should be serialized.")
    XCTAssertEqual(deserialized.level, "warning", "Non-tag values should be serialized as well.")
  }
}