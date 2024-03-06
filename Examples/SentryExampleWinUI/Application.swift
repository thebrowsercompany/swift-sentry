// SPDX-License-Identifier: BSD-3-Clause

import Foundation
import SwiftSentry
import UWP
import WinSDK
import WinUI
import WindowsFoundation

@main
public class SentryApplication: SwiftApplication {
    lazy var m_window: Window = .init()

    required public init() {
        super.init()
        unhandledException.addHandler { (_, args:UnhandledExceptionEventArgs!) in
            print("Unhandled exception: \(args.message)")
        }
    }

    private var failAsync: Bool = false

    private func failWith(_ failWith: @escaping @autoclosure() -> Void) {
        if failAsync {
            DispatchQueue.main.async {
                failWith()
            }
        } else {
            failWith()
        }
    }

    private func setupUnhandledExceptionReporting() {
        Application.current.unhandledException.addHandler { (sender, args:UnhandledExceptionEventArgs!) in
            let message = "Unhandled exception in \(String(describing: sender)): \(args.message)"
            print("XYZ Unhandled Application exception: \(message)")
            fflush(stdout)

            _ = SentrySDK.captureException(type: "UnhandledException", description: message)

            if !args.handled {
                // The app will crash right after, we need to flush the Sentry event queue synchronously.
                _ = SentrySDK.flush(timeout: 20 * 1000) // wait up for Sentry to flush events before crashing
            }
        }
    }

    class StowedExceptionButton: Button {
        override func onPointerPressed(_: PointerRoutedEventArgs!) throws {
            throw Error(hr: HRESULT(E_FAIL))
        }
    }

    private lazy var stowedExceptionButton: Button = {
        let button = StowedExceptionButton()
        button.horizontalAlignment = .stretch
        button.content = "Stowed Exception"
        return button
    }()

    override public func onLaunched(_ args: WinUI.LaunchActivatedEventArgs) {
        m_window.title = "SwiftSentry Example WinUI App"
        startSentry()

        try! m_window.activate()

        m_window.closed.addHandler { _, _ in
            SentrySDK.close()
        }

        let panel = StackPanel()
        panel.orientation = .vertical
        panel.spacing = 10
        panel.horizontalAlignment = .center
        panel.verticalAlignment = .center

        let checkBox = CheckBox()
        checkBox.content = "Fail in Async callback"
        checkBox.checked.addHandler { [weak self] _, _ in self?.failAsync = true }
        checkBox.unchecked.addHandler { [weak self] _, _ in self?.failAsync = false }

        panel.children.append(checkBox)
        panel.children.append(makeButton("abort()") { abort() })
        panel.children.append(makeButton("fatalError()") { fatalError("Boom goes the dynamite!") })
        panel.children.append(makeButton("[0][1]") { _ = [0][1] })
        panel.children.append(makeButton("RaiseFailFastException()") { RaiseFailFastException(nil, nil, 0) })
        panel.children.append(stowedExceptionButton)
        panel.children.append(makeButton("Report custom exception", onClick: { _ = SentrySDK.captureException(type: "CustomException", description: "exception created from an example") }))

        m_window.content = panel
    }

    private func makeButton(_ content: String, onClick: @escaping () -> Void) -> Button {
        let button = Button()
        button.content = content
        button.click.addHandler { [weak self] _, _ in
            self?.failWith(onClick())
        }
        return button
    }

    func startSentry() {
        print("Spinning up task to start Sentry")
        Task { @MainActor in
            SentrySDK.start { options in
                options.dsn = SentryConfiguration.dsn
                options.environment = "Debug"
                options.debug = true

                print("Release: \(String(describing: options.releaseName))")
            }
        }
    }
}
