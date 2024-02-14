// swift-tools-version: 5.9

import PackageDescription

let currentDirectory = Context.packageDirectory
let swiftSettings: [SwiftSetting] =  [
    .unsafeFlags(["-I\(currentDirectory)/vendor/sentry-native/include"])
]
var clientLinkerSettings: [LinkerSetting] = []

// Generate the linker paths that are required on different platforms
let linkerBase = "-L\(currentDirectory)/vendor/sentry-native/lib"
let platforms: [(String, Platform)] = [
    ("macOS", .macOS),
    ("linux64", .linux),
    ("win64", .windows)
]

clientLinkerSettings += platforms.map {
    .unsafeFlags(["\(linkerBase)/\($0.0)"], .when(platforms: [$0.1]))
}

let guiLinkerSettings: [LinkerSetting] = [
    .unsafeFlags(["-Xlinker", "/SUBSYSTEM:WINDOWS"], .when(configuration: .release)),
    // Update the entry point to point to the generated swift function, this lets us keep the same main method
    // for debug/release
    .unsafeFlags(["-Xlinker", "/ENTRY:mainCRTStartup"], .when(configuration: .release)),
]

let package = Package(
    name: "swift-sentry",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "swift-sentry",
            targets: ["SwiftSentry"]
        )
    ],
    targets: [
        .target(
            name: "sentry",
            publicHeadersPath: "include",
            swiftSettings: swiftSettings,
            linkerSettings: clientLinkerSettings
        ),
        .target(
            name: "SwiftSentry",
            dependencies: ["sentry"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "SwiftSentryTests",
            dependencies: ["SwiftSentry"],
            swiftSettings: swiftSettings
        ),
    ]
)

#if os(macOS)
package.products += [
    .executable(
        name: "SentryExampleMacOS",
        targets: ["SentryExampleMacOS"]
    )
]
package.targets += [
    .executableTarget(
        name: "SentryExampleMacOS",
        dependencies: ["SwiftSentry"],
        path: "Examples/SentryExampleMacOS",
        swiftSettings: swiftSettings + [.unsafeFlags(["-parse-as-library"])]
    )
]
#endif

#if os(Windows)
package.products += [
    .executable(
        name: "SentryExampleWin",
        targets: ["SentryExampleWin"]
    )
]
package.dependencies += [
    // This revision is important since it's the first one before the swift-win32 repo moved to versioned symlinks
    // for different swift-tools-versions.
    .package(url: "https://github.com/compnerd/swift-win32", revision: "07e91e67e86f173743329c6753d9e66ac4727830"),
    .package(url: "https://github.com/thebrowsercompany/swift-winui", branch: "main"),
    .package(url: "https://github.com/thebrowsercompany/swift-windowsappsdk", branch: "main"),
]
package.targets += [
    .executableTarget(
        name: "SentryExampleWin",
        dependencies: [
            "SwiftSentry",
            .product(name: "SwiftWin32", package: "swift-win32"),
        ],
        path: "Examples/SentryExampleWin",
        swiftSettings: swiftSettings + [.unsafeFlags(["-parse-as-library"])]
    ),
    .executableTarget(
        name: "SentryExampleWinUI",
        dependencies: [
            "SwiftSentry",
            .product(name: "WinUI", package: "swift-winui"),
            .product(name: "WinUIExt", package: "swift-winui"),
        ],
        path: "Examples/SentryExampleWinUI",
        swiftSettings: swiftSettings + [.unsafeFlags(["-parse-as-library"])],
        linkerSettings: guiLinkerSettings
    ),
]
#endif
