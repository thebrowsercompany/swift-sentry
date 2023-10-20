# SPDX-License-Identifier: BSD-3-Clause

$SwiftBinFolder = swift build -c debug --show-bin-path

Copy-Item .\Examples\SentryExampleWin\SentryExampleWin.exe.manifest $SwiftBinFolder
Copy-Item .\Examples\SentryExampleWin\Info.plist $SwiftBinFolder
Copy-Item .\vendor\sentry-native\bin\win64\* $SwiftBinFolder