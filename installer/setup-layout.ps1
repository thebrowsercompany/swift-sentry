param(
    [String]$MsixLayoutLocation
)
function Copy-Manifest {
    param(
        [string]$AppToInstall
    )
    $ManifestPath = "$PSScriptRoot\..\Examples\$AppToInstall\$AppToInstall.exe.manifest"
    if (Test-Path $ManifestPath) {
        Copy-Item -Path $ManifestPath $MsixLayoutLocation
    }

    $InfoPlist = "$PSScriptRoot\..\Examples\$AppToInstall\Info.plist"
    if (Test-Path $InfoPlist) {
        Copy-Item -Path $InfoPlist $MsixLayoutLocation
    }
}

if (Test-Path $MsixLayoutLocation) {
    Remove-Item -Recurse -Force $MsixLayoutLocation
}

New-Item -ItemType Directory -Path $MsixLayoutLocation
Copy-Item -Path $PSScriptRoot\..\.build\debug\*.exe $MsixLayoutLocation -Exclude "crashpad_handler.exe"
Copy-Item -Path $PSScriptRoot\..\.build\debug\*.dll $MsixLayoutLocation -Exclude @("crashpad_wer.dll", "sentry.dll")
Copy-Item -Path $PSScriptRoot\AppxManifest.xml $MsixLayoutLocation
Copy-Item -Path $PSScriptRoot\resources.pri $MsixLayoutLocation
Copy-Item -Path $PSScriptRoot\StoreLogo.png $MsixLayoutLocation

Copy-Manifest -AppToInstall SentryExampleWin
Copy-Manifest -AppToInstall SentryExampleWinUI

if ((Get-AppxPackage -Name "*SwiftRuntime") -eq $null) {
    Write-Host "installing swift runtime"
    Add-AppxPackage $PSScriptRoot\Swift.Runtime.x64.msix
}

if ((Get-AppxPackage -Name "*SwiftSentry") -eq $null) {
    Write-Host "installing swift runtime"
    Add-AppxPackage $PSScriptRoot\SentryNative.x64.msix
}

Get-AppxPackage -Name "SwiftSentry.SentryExampleWin"| Remove-AppxPackage