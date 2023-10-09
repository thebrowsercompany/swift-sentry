# swift-sentry

A Swift library that wraps the [Sentry native SDK](https://github.com/getsentry/sentry-native)

## Setup

1. Build the application with `swift build`
2. run `.\Copy-Files.ps1` to copy the files that need to be installed manually
3. run `swift run`

## Requirements

The swift-sentry SDK automatically attempts to look up your release name information. To do this is will read the following keys out of your Info.plist. If they are not present a fatal error will be presented.

- `CFBundleIdentifier`
- `CFBundleShortVersionString`
- `CFBundleVersion`

## Producing Artifacts From The Sentry Native Repo

1. Clone `https://github.com/getsentry/sentry-native`
2. Run `cmake -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION="10.0.19041.0"` this wil generate the needed `.lib`, `.h`, and various `.dll` and `.exe` required for installation
  a. The `CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION` seems required as CMake isn't correctly detecting the Windows version all of the time which can flag off WER support
3. Run `cmake --build build --parallel --config RelWithDebInfo` to actually build the project
4. Run `cmake --install build --prefix install --config RelWithDebInfo` to copy the built products into the `install` directory within sentry-native
5. Copy the contents of the `install` directory into the `vendor/sentry-native` directory.
