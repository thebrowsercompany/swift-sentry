// SPDX-License-Identifier: BSD-3-Clause
import sentry

struct Exception {
    let type: String
    let description: string
    let value: sentry_value_t

    init(type: String, description: String) {
        self.type = type
        self.description = description
        self.value = sentry_value_new_exception(type, description)
    }


    func setMechanism(_ mechanism: Mechanism) {
        sentry_value_set_by_key(value, "mechanism", mechanism.value)
    }
}
