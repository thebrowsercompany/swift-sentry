// SPDX-License-Identifier: BSD-3-Clause

import SwiftWin32

final class SceneDelegate: WindowSceneDelegate {
  var window: Window?

  func scene(_ scene: Scene, willConnectTo _: SceneSession,
             options _: Scene.ConnectionOptions)
  { 
    guard let windowScene = scene as? WindowScene else { return }

    window = Window(windowScene: windowScene)
    window?.rootViewController = SentryExampleViewController()
    window?.makeKeyAndVisible()
  }
}
