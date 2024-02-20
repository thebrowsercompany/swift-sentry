$MsixLayoutLocation = Join-Path $PSScriptRoot "LayoutRoot"
& $PSScriptRoot/setup-layout.ps1 -MsixLayoutLocation $MsixLayoutLocation
Add-AppPackage -Register $MsixLayoutLocation\AppxManifest.xml

Write-Host "Sentry Example installed." -ForegroundColor Green