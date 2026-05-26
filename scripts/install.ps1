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

$key1 = "$regBase\OrganizeFolder"
New-Item -Path $key1 -Force | Out-Null
Set-ItemProperty -Path $key1 -Name '(Default)' -Value 'Organize Folder'
Set-ItemProperty -Path $key1 -Name 'Icon'       -Value 'shell32.dll,4'
New-Item -Path "$key1\command" -Force | Out-Null
Set-ItemProperty -Path "$key1\command" -Name '(Default)' `
  -Value "powershell.exe -NoExit -File `"$generalScript`" -TargetPath `"%V`""

$key2 = "$regBase\OrganizePictures"
New-Item -Path $key2 -Force | Out-Null
Set-ItemProperty -Path $key2 -Name '(Default)' -Value 'Organize Pictures'
Set-ItemProperty -Path $key2 -Name 'Icon'       -Value 'shell32.dll,325'
New-Item -Path "$key2\command" -Force | Out-Null
Set-ItemProperty -Path "$key2\command" -Name '(Default)' `
  -Value "powershell.exe -NoExit -File `"$picturesScript`" -TargetPath `"%V`""

Write-Host "[2/2] Right-click menu entries added"
Write-Host ""
Write-Host "DONE. Open a new terminal to use 'organize' and 'organize-pictures'."
