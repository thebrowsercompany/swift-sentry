// SPDX-License-Identifier: BSD-3-Clause

struct EventTestBasicEventSerialization: Codable {
  let eventId: String
  let timestamp: Double
  let platform: String
  let level: String
  let message: String?

  enum CodingKeys: String, CodingKey {
    case eventId = "event_id"
    case timestamp
    case platform
    case level
    case message
  }
}

struct EventTestTagsSerialization: Codable {
  let eventId: String
  let timestamp: Double
  let platform: String
  let level: String
  let message: String?
  let tags: [String: String]

  enum CodingKeys: String, CodingKey {
    case eventId = "event_id"
    case timestamp
    case platform
    case level
    case message
    case tags
  }
}