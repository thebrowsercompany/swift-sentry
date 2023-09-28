# swift-sentry

A Swift library that wraps the [Sentry native SDK](https://github.com/getsentry/sentry-native)

## Setup

1. Build the application with `swift build`
2. run `.\Copy-Files.ps1` to copy the files that need to be installed manually
3. run `swift run`

## Producing Artifacts From The Sentry Native Repo
1. Clone `https://github.com/getsentry/sentry-native`
2. Run `cmake -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo` this wil generate the needed `.lib`, `.h`, and various `.dll` and `.exe` required for installation
3. Run `cmake --build build --parallel` to actually build the project
4. Run `cmake --install build --prefix install --config RelWithDebInfo` to copy the built products into the `install` directory within sentry-native
5. Copy the contents of the `install` directory into the `vendor/sentry-native` directory.

Note: you may have to run the configure from `cmake-gui` to find ZLIB.