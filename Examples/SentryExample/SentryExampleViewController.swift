// SPDX-License-Identifier: BSD-3-Clause

import SwiftSentry
import SwiftWin32

final class SentryExampleViewController: ViewController {
  let abortButton = Button(frame: .zero, title: "abort()")
  let fatalErrorButton = Button(frame: .zero, title: "fatalError()")
  let badIndexButton = Button(frame: .zero, title: "[0][1]")

  override init() {
    super.init()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Sentry Example"
    view.addSubview(abortButton)
    view.addSubview(fatalErrorButton)
    view.addSubview(badIndexButton)

    abortButton.addTarget(self, action: SentryExampleViewController.abortAction,
                          for: .primaryActionTriggered)
    fatalErrorButton.addTarget(self, action: SentryExampleViewController.fatalErrorAction,
                               for: .primaryActionTriggered)
    badIndexButton.addTarget(self, action: SentryExampleViewController.badIndexAction,
                             for: .primaryActionTriggered)

    layoutViews()
  }

  private func layoutViews() {
    let buttonWidth = view.bounds.width / 3
    let buttonHeight = 40.0

    abortButton.frame = .init(x: 0, y: 0, width: buttonWidth, height: buttonHeight)
    fatalErrorButton.frame = .init(x: abortButton.frame.maxX, y: 0, width: buttonWidth, height: buttonHeight)
    badIndexButton.frame = .init(x: fatalErrorButton.frame.maxX, y: 0, width: buttonWidth, height: buttonHeight)
  }

  private func abortAction() {
    abort()
  }

  private func fatalErrorAction() {
    fatalError("Boom goes the dynamite!")
  }

  private func badIndexAction() {
    [0][1]
  }
}
