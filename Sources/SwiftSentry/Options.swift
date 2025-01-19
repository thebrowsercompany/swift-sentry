// SPDX-License-Identifier: BSD-3-Clause
import Foundation

public final class Options {
  public var dsn: String = ""
  public var attachStacktrace: Bool = false
  public var environment: String = "production"
  public var enableCrashHandler: Bool = true
  /// Override the path to the preferred crash handler executable
  /// - note: If this path doesn't resolve correctly, the crash backend
  /// will fail to load. You can debug this by turning on the ``debug``
  /// value and inspecting the logs.
  public var crashHandlerPath: URL?
  public var beforeSend: ((AnyObject) -> AnyObject)?
  public var debug: Bool = false
  public var shutdownTimeout: TimeInterval?

  /// Overrides `releaseName`. Useful if your executable doesn't 
  /// have an associated Info.plist or you just want to hardcode a value.
  public var customReleaseName: String? = nil

  /// Returns a string computed by the main bundle's info dictionary if present.
  /// "`CFBundleIdentifier`@`CFBundleShortVersionString`+`CFBundleVersion`"
  ///
  /// If `customReleaseName` is set, that value will always be used instead.
  public var releaseName: String? = {
    if let customReleaseName {
      return customReleaseName
    }

    guard let info = Bundle.main.infoDictionary else {
      return nil
    }

    guard let bundle = info["CFBundleIdentifier"],
          let version = info["CFBundleShortVersionString"],
          let build = info["CFBundleVersion"] else {
      return nil
    }

    return "\(bundle)@\(version)+\(build)"
  }()

  public init() {}
}
