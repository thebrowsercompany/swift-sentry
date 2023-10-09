// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "swift-sentry",
    products: [
        .library(
            name: "swift-sentry",
            targets: ["SwiftSentry"]
        ),
        .executable(
            name: "SentryExample",
            targets: ["SentryExample"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/compnerd/swift-win32", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "SentryExample",
            dependencies: [
                "SwiftSentry",
                .product(name: "SwiftWin32", package: "swift-win32"),
            ],
            path: "Examples/SentryExample",
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"]),
            ]
        ),
        .target(
            name: "sentry",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("../../vendor/sentry-native/include"),
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-Lvendor/sentry-native/lib",
                ]),
            ]
        ),
        .target(
            name: "SwiftSentry",
            dependencies: ["sentry"],
            resources: [
                .copy("../../vendor/sentry-native/bin/crashpad_handler.exe"),
                .copy("../../vendor/sentry-native/bin/crashpad_wer.dll"),
                .copy("../../vendor/sentry-native/bin/sentry.dll"),
            ],
            cSettings: [
                .headerSearchPath("../../vendor/sentry-native/include"),
            ]
        ),
        .testTarget(
            name: "SwiftSentryTests",
            dependencies: ["SwiftSentry"]
        ),
    ]
)
