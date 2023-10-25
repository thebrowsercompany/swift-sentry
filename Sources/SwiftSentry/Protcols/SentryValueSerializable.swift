// SPDX-License-Identifier: BSD-3-Clause
import Foundation
import sentry

// A protocol that allows for Sentry objects
// to easily produce their serialized value.
internal protocol SentryValueSerializable {
    // Creates a sentry_value_t describing the object.
    func serialized() -> sentry_value_t
}

internal extension SentryValueSerializable {
    func parse(value: inout sentry_value_t, object: [String: Any]) {
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

    func parse(value: inout sentry_value_t, list: [Any], key: String) {
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

    func parse(value: inout sentry_value_t, primitive: Any, key: String) {
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
