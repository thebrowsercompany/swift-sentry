// SPDX-License-Identifier: BSD-3-Clause
import Foundation

public final class Options {
  public var dsn: String = ""
  public var attachStacktrace: Bool = false
  public var environment: String = "production"
  public var enableCrashHandler: Bool = true
  public var beforeSend: ((AnyObject) -> AnyObject)?
  public var debug: Bool = false
  public var releaseName: String? = {
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
