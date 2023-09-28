import SwiftWin32
import SwiftSentry

extension Button {
  internal convenience init(frame: Rect, title: String) {
    self.init(frame: frame)
    self.setTitle(title, forState: .normal)
  }
}

final class SentryExampleViewController: ViewController {
  let button = Button(frame: .init(x: 0, y: 0, width: 200, height: 200), title: "Crash")
  override init() {
    super.init()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Sentry Example"
    view.addSubview(button)

    button.addTarget(self, action: SentryExampleViewController.crash,
                        for: .primaryActionTriggered)

    LayoutConstraint.activate([
      .init(item: button, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0),
      .init(item: button, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
    ])
  }

  func crash() {
    [0][1]
  }
}