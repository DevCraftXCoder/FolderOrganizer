param([string]$ScriptDir = $PSScriptRoot)

$generalScript  = Join-Path $ScriptDir 'organize.ps1'
$picturesScript = Join-Path $ScriptDir 'organize-pictures.ps1'

# 1. Add functions to PowerShell profile
$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir | Out-Null }
if (-not (Test-Path $PROFILE))    { New-Item -ItemType File -Path $PROFILE | Out-Null }

$generalScriptEsc  = $generalScript  -replace "'", "''"
$picturesScriptEsc = $picturesScript -replace "'", "''"

$snippet = @"

# Folder Organizer Commands
function organize {
  param([string]`$Path = (Get-Location).Path, [switch]`$apply, [string]`$mode = 'content')
  if (`$apply) {
    & powershell -File '$generalScriptEsc' -TargetPath `$Path -Mode `$mode -Apply
  } else {
    & powershell -File '$generalScriptEsc' -TargetPath `$Path -Mode `$mode
  }
}

function organize-pictures {
  param([string]`$Path = (Get-Location).Path, [switch]`$apply)
  if (`$apply) {
    & powershell -File '$picturesScriptEsc' -TargetPath `$Path -Apply
  } else {
    & powershell -File '$picturesScriptEsc' -TargetPath `$Path
  }
}
# End Folder Organizer Commands
"@

$existing = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($existing -notmatch 'Folder Organizer Commands') {
  Add-Content -Path $PROFILE -Value $snippet
  Write-Host "[1/2] Functions added to: $PROFILE"
} else {
  Write-Host "[1/2] Already in profile -- skipped"
}

# 2. Right-click context menu (HKCU, no admin required)
$regBase = 'HKCU:\Software\Classes\Directory\shell'

# Remove old flat entries if present
foreach ($old in @('OrganizeFolder', 'OrganizePictures')) {
  $p = "$regBase\$old"
  if (Test-Path $p) { Remove-Item $p -Recurse -Force }
}

# Helper: create a submenu child entry
function New-SubEntry($parentShell, $order, $label, $command, $icon) {
  $key = "$parentShell\${order}_$(($label -replace '[^a-zA-Z0-9]',''))"
  New-Item  -Path $key           -Force | Out-Null
  New-Item  -Path "$key\command" -Force | Out-Null
  Set-ItemProperty -Path $key           -Name '(Default)' -Value $label
  Set-ItemProperty -Path "$key\command" -Name '(Default)' -Value $command
  if ($icon) { Set-ItemProperty -Path $key -Name 'Icon' -Value $icon }
}

# Organize Folder submenu (4 options)
$p1 = "$regBase\ZOrganizeFolder"
New-Item -Path $p1 -Force | Out-Null
Set-ItemProperty -Path $p1 -Name '(Default)'   -Value 'Organize Folder'
Set-ItemProperty -Path $p1 -Name 'MUIVerb'     -Value 'Organize Folder'
Set-ItemProperty -Path $p1 -Name 'SubCommands' -Value ''
Set-ItemProperty -Path $p1 -Name 'Icon'        -Value 'shell32.dll,4'
New-Item -Path "$p1\Shell" -Force | Out-Null

$sh1 = "$p1\Shell"
$ps  = "powershell.exe -NoExit -ExecutionPolicy Bypass -File `"$generalScript`" -TargetPath `"%V`""

New-SubEntry $sh1 '01' 'Preview (Smart Sort)'            "$ps"                          'shell32.dll,134'
New-SubEntry $sh1 '02' 'Apply - Move Files (Smart)'      "$ps -Apply"                   'shell32.dll,16814'
New-SubEntry $sh1 '03' 'Preview (By Extension)'          "$ps -Mode extension"          'shell32.dll,3'
New-SubEntry $sh1 '04' 'Apply - Move Files (Extension)'  "$ps -Mode extension -Apply"   'shell32.dll,16814'

# Organize Pictures submenu (2 options)
$p2 = "$regBase\ZOrganizePictures"
New-Item -Path $p2 -Force | Out-Null
Set-ItemProperty -Path $p2 -Name '(Default)'   -Value 'Organize Pictures'
Set-ItemProperty -Path $p2 -Name 'MUIVerb'     -Value 'Organize Pictures'
Set-ItemProperty -Path $p2 -Name 'SubCommands' -Value ''
Set-ItemProperty -Path $p2 -Name 'Icon'        -Value 'shell32.dll,325'
New-Item -Path "$p2\Shell" -Force | Out-Null

$sh2 = "$p2\Shell"
$ps2 = "powershell.exe -NoExit -ExecutionPolicy Bypass -File `"$picturesScript`" -TargetPath `"%V`""

New-SubEntry $sh2 '01' 'Preview'            "$ps2"        'shell32.dll,134'
New-SubEntry $sh2 '02' 'Apply - Move Files' "$ps2 -Apply" 'shell32.dll,16814'

Write-Host "[2/2] Right-click menu entries added"
Write-Host ""
Write-Host "DONE. Open a new terminal to use 'organize' and 'organize-pictures'."
Write-Host ""
Write-Host "Right-click any folder to see:"
Write-Host "  Organize Folder >"
Write-Host "    Preview (Smart Sort)"
Write-Host "    Apply - Move Files (Smart)"
Write-Host "    Preview (By Extension)"
Write-Host "    Apply - Move Files (Extension)"
Write-Host "  Organize Pictures >"
Write-Host "    Preview"
Write-Host "    Apply - Move Files"
