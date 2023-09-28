// SPDX-License-Identifier: BSD-3-Clause

@_exported
import sentry

import Foundation

public final class SentryEvent {
  var fingerpring: [String]?
  var level: SentryLevel?
}

public typealias SentryBeforeSendEventCallback = (SentryEvent?) -> SentryEvent?

public final class Options {
  public var dsn: String = ""
  public var enableAppHangTracking: Bool = false
  public var enableMetricKit = false
  public var enableNetworkTracking: Bool = false
  public var enableNetworkBreadCrumbs: Bool = false
  public var enableCaptureFailedRequests: Bool = false
  public var attachStackTrace: Bool = false
  public var environment: String = ""
  public var beforeSend: SentryBeforeSendEventCallback?
}