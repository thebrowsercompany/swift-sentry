// SPDX-License-Identifier: BSD-3-Clause
/// The representation of a user which should be attached to subsequent events.
public final class User {
    public var userId: String?
    public var email: String?
    public var username: String?

    public init(
        userId: String? = nil,
        email: String? = nil,
        username: String? = nil
    ) {
      self.userId = userId
      self.email = email
      self.username = username
    }
}

extension User: SentryValueSerializable {
    internal func serialized() -> sentry_value_t {
        let sentryUser = sentry_value_new_object()
        if let id = userId {
            sentry_value_set_by_key(sentryUser, "id", sentry_value_new_string(id.cString(using: .utf8)))
        }

        if let email = email {
            sentry_value_set_by_key(sentryUser, "email", sentry_value_new_string(email.cString(using: .utf8)))
        }

        if let username = username {
            sentry_value_set_by_key(sentryUser, "username", sentry_value_new_string(username.cString(using: .utf8)))
        }

        return sentryUser
    }
}
