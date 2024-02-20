param(
    [switch]$Full
)

if ($Full) {
    & $PSScriptRoot\installer\install-full.ps1
} else {
    & $PSScriptRoot\installer\install-loose.ps1
}
