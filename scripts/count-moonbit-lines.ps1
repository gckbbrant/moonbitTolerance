$files = Get-ChildItem -File -Filter '*.mbt' | Sort-Object FullName
$lines = ($files | Get-Content | Measure-Object -Line).Lines
Write-Output "MoonBit source files: $($files.Count)"
Write-Output "MoonBit source lines: $lines"
