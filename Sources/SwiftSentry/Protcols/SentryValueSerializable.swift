// SPDX-License-Identifier: BSD-3-Clause
import sentry

// A protocol that allows for Sentry objects
// to easily produce their serialized value.
internal protocol SentryValueSerializable {
    // Creates a sentry_value_t describing the object.
    func serialized() -> sentry_value_t
}
