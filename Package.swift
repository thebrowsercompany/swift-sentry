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
    .package(url: "https://github.com/compnerd/swift-win32", branch: "main"),
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
]
#endif
