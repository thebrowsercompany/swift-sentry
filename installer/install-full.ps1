#Requires -RunAsAdministrator
$MsixLayoutLocation = Join-Path $PSScriptRoot "LayoutRoot"

& $PSScriptRoot/setup-layout.ps1 -MsixLayoutLocation $MsixLayoutLocation

Copy-Item -Path $PSScriptRoot\AppxManifestUnsigned.xml $MsixLayoutLocation\AppxManifest.xml

& makeappx.exe pack /d $MsixLayoutLocation /p $PSScriptRoot/SwiftSentry.msix /o
Add-AppPackage -Path $PSScriptRoot/SwiftSentry.msix -AllowUnsigned
Write-Host "Sentry Example installed." -ForegroundColor Green
