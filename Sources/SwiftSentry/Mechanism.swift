// SPDX-License-Identifier: BSD-3-Clause

import sentry

internal struct Mechanism {
    let value: sentry_value_t
    let type: String
    let handled: Bool
    init(type: String, handled: Bool) {
        self.value = sentry_value_new_object()
        self.type = type
        self.handled = handled
        sentry_value_set_by_key(value, "type", sentry_value_new_string(type))
        sentry_value_set_by_key(value, "handled", sentry_value_new_bool(Int32(handled ? 1 : 0)))
    }
}
