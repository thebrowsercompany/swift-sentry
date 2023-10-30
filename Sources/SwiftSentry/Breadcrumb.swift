// SPDX-License-Identifier: BSD-3-Clause
import sentry

import Foundation

/// A small piece of timestamped textual information that will accompany subsequent events.
public struct Breadcrumb {
    public var level: SentryLevel
    public var category: String
    public var timestamp: Date = .init()
    public var type: String?
    public var message: String?
    public var data: [String: Any]?

    public init(withLevel level: SentryLevel = .info, category: String = "default") {
        self.level = level
        self.category = category
    }
}

extension Breadcrumb: SentryValueSerializable {
    internal func serialized() -> sentry_value_t {
        guard let message else {
            return sentry_value_new_null()
        }

        let crumb = sentry_value_new_breadcrumb(type?.cString(using: .utf8), message.cString(using: .utf8))

        sentry_value_set_by_key(crumb, "category", sentry_value_new_string(category.cString(using: .utf8)))
        sentry_value_set_by_key(crumb, "level", sentry_value_new_string(level.description.cString(using: .utf8)))
        sentry_value_set_by_key(crumb, "timestamp", sentry_value_new_double(timestamp.timeIntervalSince1970))

        if let data {
            var object = sentry_value_new_object()
            parse(value: &object, object: data)
            sentry_value_set_by_key(crumb, "data", object)
        }

        return crumb
    }
}
