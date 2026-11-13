param([string]$Destination = 'C:\Users\HP\Documents\gm-rts-to-godot-template')
$ErrorActionPreference = 'Stop'
$portSource = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
if (-not (Test-Path -LiteralPath $Destination -PathType Container)) {
    throw "Destination must be the existing empty Godot project folder: $Destination"
}
$portTarget = (Resolve-Path -LiteralPath $Destination).Path
if ($portTarget -eq $portSource -or $portTarget.StartsWith($portSource + '\', [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Destination must be separate from the staged port.'
}
$permitted = @('.godot', '.git', '.editorconfig', '.gitattributes', '.gitignore', 'project.godot', 'icon.svg', 'icon.svg.import')
$unexpected = @(Get-ChildItem -LiteralPath $portTarget -Force | Where-Object { $_.Name -notin $permitted })
if ($unexpected.Count -gt 0) {
    throw ('Destination contains existing project content; choose an empty folder. Found: ' + ($unexpected.Name -join ', '))
}
$initialConfig = Join-Path $portTarget 'project.godot'
if (Test-Path -LiteralPath $initialConfig) {
    Copy-Item -LiteralPath $initialConfig -Destination (Join-Path $portTarget 'project.godot.before-port')
}
foreach ($entry in @('project.godot', 'export_presets.cfg', 'README.md', 'scripts', 'scenes', 'mods', 'assets', 'tests', 'tools', 'docs')) {
    Copy-Item -LiteralPath (Join-Path $portSource $entry) -Destination $portTarget -Recurse -Force
}
$ignoreFile = Join-Path $portTarget '.gitignore'
if (-not (Test-Path -LiteralPath $ignoreFile)) {
    Set-Content -LiteralPath $ignoreFile -Value '.godot/'
}
Write-Output "Port installed. Open $initialConfig in Godot and press F5."
