function Copy-Manifest {
    param(
        [string]$AppToInstall
    )
    $ManifestPath = "$PSScriptRoot\Examples\$AppToInstall\$AppToInstall.exe.manifest"
    if (Test-Path $ManifestPath) {
        Copy-Item -Path $PSScriptRoot\Examples\SentryExampleWin\SentryExampleWin.exe.manifest $PSScriptRoot\installer
    }

    $InfoPlist = "$PSScriptRoot\Examples\$AppToInstall\Info.plist"
    if (Test-Path $InfoPlist) {
        Copy-Item -Path $InfoPlist $PSScriptRoot\installer
    }
}

Copy-Item -Path $PSScriptRoot\.build\debug\*.exe $PSScriptRoot\installer
Copy-Item -Path $PSScriptRoot\.build\debug\*.dll $PSScriptRoot\installer

Copy-Manifest -AppToInstall SentryExampleWin
Copy-Manifest -AppToInstall SentryExampleWinUI

if ((Get-AppxPackage -Name "*SwiftRuntime") -eq $null) {
    Write-Host "installing swift runtime"
    Add-AppxPackage $PSScriptRoot\installer\Swift.Runtime.x64.msix
}

Get-AppxPackage -Name "SwiftSentry.SentryExampleWin"| Remove-AppxPackage
Add-AppPackage -Register $PSScriptRoot\installer\AppxManifest.xml
