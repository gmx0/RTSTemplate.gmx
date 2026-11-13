param(
    [ValidateSet('Play','Editor','Test')][string]$Mode = 'Play',
    [string]$GodotPath = 'C:\Users\HP\Documents\Godot_v4.7.2-stable_mono_win64\Godot_v4.7.2-stable_mono_win64_console.exe'
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $GodotPath)) {
    $GodotPath = (Get-Command godot -ErrorAction Stop).Source
}
if ($Mode -ne 'Editor') {
    # Import resources before direct execution of a fresh extracted project.
    & $GodotPath --headless --path $PSScriptRoot --editor --import
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
if ($Mode -eq 'Test') {
    & $GodotPath --headless --path $PSScriptRoot -- --smoke-test
} elseif ($Mode -eq 'Editor') {
    & $GodotPath --editor --path $PSScriptRoot
} else {
    & $GodotPath --path $PSScriptRoot
}
exit $LASTEXITCODE
