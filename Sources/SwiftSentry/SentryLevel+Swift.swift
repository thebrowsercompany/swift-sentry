// SPDX-License-Identifier: BSD-3-Clause
import sentry

public typealias SentryLevel = sentry_level_t

/// A mapping of the ``sentry_level_t`` type to a Swiftier type
///
/// - note: The Cocoa SDK offers an additional level called `none`
/// which will cause the SDK to not serialize any item marked with
/// this level. The native SDK does not support this level, so it
/// is notably missing here.
extension SentryLevel {
    public static let debug = SENTRY_LEVEL_DEBUG
    public static let info = SENTRY_LEVEL_INFO
    public static let warning = SENTRY_LEVEL_WARNING
    public static let error = SENTRY_LEVEL_ERROR
    public static let fatal = SENTRY_LEVEL_FATAL
}

extension SentryLevel: CustomStringConvertible {
    public var description: String {
        switch self {
        case SENTRY_LEVEL_DEBUG:
            return "debug"
        case SENTRY_LEVEL_INFO:
            return "info"
        case SENTRY_LEVEL_WARNING:
            return "warning"
        case SENTRY_LEVEL_ERROR:
            return "error"
        case SENTRY_LEVEL_FATAL:
            return "fatal"
        default:
            return "unknown"
        }
    }
}
