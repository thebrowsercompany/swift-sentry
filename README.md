# swift-sentry

A Swift library that wraps the [Sentry native SDK](https://github.com/getsentry/sentry-native)

## Setup

1. Build the application with `swift build`
2. Copy the needed files into the build directory (see [copying required files section](#copying-required-files))
3. run `swift run`

## Requirements

### Sentry Native Artifacts

In order to successfully build and deploy this code, you must supply the built artifacts from the [sentry-native](https://github.com/getsentry/sentry-native) repository into a folder structure that looks like this:

```text
vendor/
├─ include/
│  ├─ sentry.h
├─ lib/
│  ├─ macOS/
│  ├─ win64/
│  ├─ linux64/
├─ bin/
│  ├─ win64/
```

the `lib` and `bin` folders are platform specific. Depending on which options you choose when compiling the sentry-native repository you will end up with an install folder for a specific platform which includes `lib` and `bin`, simply copy those items in the structure above.

### Copying Required Files

Due to a [limitation](https://github.com/apple/swift-package-manager/issues/6982) of Swift Package Manager you can't copy files from outside of a given target's folder. So we must manually move the required files into the build directory before we execute `swift run`. Here are a few examples of how that could look depending on your platform:

#### Windows

1. Run `cp vendor\sentry-native\lib\win64\* "$(swift build -c debug --show-bin-path)"`
1. Run `cp vendor\sentry-native\bin\win64\* "$(swift build -c debug --show-bin-path)"`
1. Run `cp Examples\SentryExampleWin\Info.plist "$(swift build -c debug --show-bin-path)"`
1. Run `cp Examples\SentryExampleWin\SentryExampleWin.exe.manifest "$(swift build -c debug --show-bin-path)"`

#### macOS / Linux

1. Run `cp vendor/sentry-native/lib/<platform>/* "$(swift build -c debug --show-bin-path)"` (adjust config as needed for build configuration)

### Sentry Release Naming

The swift-sentry SDK automatically attempts to look up your release name information. To do this is will read the following keys out of your Info.plist.

- `CFBundleIdentifier`
- `CFBundleShortVersionString`
- `CFBundleVersion`

If you are building a project without an `Info.plist` the release value in Sentry will be empty. Setting one is good practice to be able to more easily track your deployments and regressions across time.

## Producing Artifacts From The Sentry Native Repo

1. Clone `https://github.com/getsentry/sentry-native`
1. Run the build command
    - On Windows you will need to run something like `cmake -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION="10.0.19041.0"` as it seems that sometimes the right target platform version isn't picked up which will turn off WER support.
    - On macOS you can simply run `cmake -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo`
1. Run `cmake --build build --parallel --config RelWithDebInfo` to actually build the project
1. Run `cmake --install build --prefix install --config RelWithDebInfo` to copy the built products into the `install` directory within sentry-native
1. Copy the contents of the `install` directory into your `vendor/sentry-native` folder in the required structure as outlined in the [artifacts](#sentry-native-artifacts) section.

## Supported Platforms

This library is still very much a work in progress, but basic functional testing has been preformed on the following platforms:

- Window 11 Pro (`x86_64`-only)
- macOS 14.0 (`ARM`-only)
