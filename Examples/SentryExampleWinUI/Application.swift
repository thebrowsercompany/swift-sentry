import Foundation
import SwiftSentry
import UWP
import WinSDK
import WinUI
import WinUIExt

@main
public class SentryApplication: SwiftApplication {
    lazy var m_window: Window = .init()

    override required public init() {
        super.init()
        m_window.title = "SwiftSentry Example WinUI App"
        unhandledException.addHandler { (_, args:UnhandledExceptionEventArgs!) in
            print("Unhandled exception: \(args.message)")
        }
    }

    private func makeButton(_ content: String, onClick: @escaping () -> Void) -> Button {
        let button = Button()
        button.content = content
        button.click.addHandler { _, _ in
            onClick()
        }
        return button
    }

    func startSentry() {
        print("Spinning up task to start Sentry")
        Task { @MainActor in
            SentrySDK.start { options in
                options.dsn = SentryConfiguration.dsn
                options.path = "SentryExampleWin"
                options.environment = "Debug"
                options.debug = true

                print("Release: \(String(describing: options.releaseName))")
            }
        }
    }

    override public func onLaunched(_ args: WinUI.LaunchActivatedEventArgs?) throws {
        startSentry()
        resources.mergedDictionaries.append(XamlControlsResources())

        try m_window.activate()

        m_window.closed.addHandler { _, _ in
            SentrySDK.close()
        }

        let panel = StackPanel()
        panel.orientation = .vertical
        panel.spacing = 10
        panel.horizontalAlignment = .center
        panel.verticalAlignment = .center

        panel.children.append(makeButton("abort()") { abort() })
        panel.children.append(makeButton("fatalError()") { fatalError("Boom goes the dynamite!") })
        panel.children.append(makeButton("[0][1]") { _ = [0][1] })
        panel.children.append(makeButton("RaiseFailFastException()") { RaiseFailFastException(nil, nil, 0) })

        m_window.content = panel
    }
}
