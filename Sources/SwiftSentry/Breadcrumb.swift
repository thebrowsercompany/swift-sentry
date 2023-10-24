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

    public init(withLevel level: SentryLevel, category: String) {
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
        sentry_value_set_by_key(crumb, "message", sentry_value_new_string(message.cString(using: .utf8)))

        if let data {
            var object = sentry_value_new_object()
            parse(value: &object, object: data)
            sentry_value_set_by_key(crumb, "data", object)
        }

        return crumb
    }

    private func parse(value: inout sentry_value_t, object: [String: Any]) {
        for (key, item) in object {
            if let subDictionary = item as? [String: Any] {
                var object = sentry_value_new_object()
                parse(value: &object, object: subDictionary)
                sentry_value_set_by_key(value, key.cString(using: .utf8), object)
            } else if let subArray = item as? [Any] {
                var list = sentry_value_new_list()
                parse(value: &list, list: subArray, key: key)
                sentry_value_set_by_key(value, key.cString(using: .utf8), list)
            } else {
                parse(value: &value, primitive: item, key: key)
            }
        }
    }

    private func parse(value: inout sentry_value_t, list: [Any], key: String) {
        for item in list {
            if let subArrayDictionary = item as? [String: Any] {
                var object = sentry_value_new_object()
                parse(value: &object, object: subArrayDictionary)
                sentry_value_append(value, object)
            } else if let subArrayArray = item as? [Any] {
                var newList = sentry_value_new_list()
                parse(value: &newList, list: subArrayArray, key: key)
                sentry_value_append(value, newList)
            } else {
                parse(value: &value, primitive: item, key: key)
            }
        }
    }

    private func parse(value: inout sentry_value_t, primitive: Any, key: String) {
        let cKey = key.cString(using: .utf8)
        let isArray = sentry_value_get_type(value) == SENTRY_VALUE_TYPE_LIST

        func convert(primitive: Any) -> sentry_value_t? {
            switch primitive {
            case is Int32:
                return sentry_value_new_int32(primitive as! Int32)
            case is Double:
                return sentry_value_new_double(primitive as! Double)
            case is Bool:
                let bool = primitive as! Bool
                return sentry_value_new_bool(bool ? 1 : 0)
            case is String:
                let cString = (primitive as! String).cString(using: .utf8)
                return sentry_value_new_string(cString)
            case is NSNull:
                return sentry_value_new_null()
            default:
                return nil
            }
        }

        guard let converted: sentry_value_t = convert(primitive: primitive) else { return }

        if isArray {
            sentry_value_append(value, converted)
        } else {
            sentry_value_set_by_key(value, cKey, converted)
        }
    }
}
