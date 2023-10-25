// SPDX-License-Identifier: BSD-3-Clause
import Foundation

public struct Event {
  let eventId = SentryId()
  var message: String?
  let timestamp: Date = Date()
  let level: SentryLevel
  let platform: String = Event.platform()
  var tags: [String: String]?

  public init(level: SentryLevel) {
    self.level = level
  }
}

extension Event: SentryValueSerializable {
  internal func serialized() -> sentry_value_t {
    guard let id = eventId.sentryIdString().cString(using: .utf8) else { return sentry_value_new_null() }

    let event = sentry_value_new_event()
    sentry_value_set_by_key(event, "event_id", sentry_value_new_string(id))
    sentry_value_set_by_key(event, "timestamp", sentry_value_new_double(timestamp.timeIntervalSince1970))
    sentry_value_set_by_key(event, "platform", sentry_value_new_string(platform))
    sentry_value_set_by_key(event, "level", sentry_value_new_string(level.description))

    if let tags {
      var tagObject = sentry_value_new_object()
      parse(value: &tagObject, object: tags)
      sentry_value_set_by_key(event, "tags", tagObject)
    }

    if let message {
      sentry_value_set_by_key(event, "message", sentry_value_new_string(message.cString(using: .utf8)))
    }

    return event
  }
}

private extension Event {
  static func platform() -> String {
    // These values are a limitation of what Sentry will accept.
    // A full list is here, https://develop.sentry.dev/sdk/event-payloads/
    #if os(macOS) || os(iOS)
    return "cocoa"
    #elseif os(Windows) || os(Linux)
    return "native"
    #else
    return "other"
    #endif
  }
}