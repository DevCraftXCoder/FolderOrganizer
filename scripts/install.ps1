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

# 2. Convert logo PNG to ICO for context menu icon (Vista+ PNG-embedded format)
$icoPath = Join-Path $ScriptDir 'organize.ico'
$pngPath = Join-Path $ScriptDir '..\assets\logo.png'
if ((Test-Path $pngPath) -and -not (Test-Path $icoPath)) {
  try {
    Add-Type -AssemblyName System.Drawing
    $source = [System.Drawing.Image]::FromFile((Resolve-Path $pngPath).Path)
    $bmp    = New-Object System.Drawing.Bitmap 256, 256
    $g      = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($source, 0, 0, 256, 256)
    $g.Dispose()
    $source.Dispose()

    # Save bitmap as PNG into memory stream
    $pngStream = New-Object System.IO.MemoryStream
    $bmp.Save($pngStream, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    $pngBytes = $pngStream.ToArray()
    $pngStream.Dispose()

    # Build Vista+ PNG-embedded ICO manually
    # ICO header: reserved(2) + type=1(2) + count=1(2)
    $header = [byte[]](0x00,0x00, 0x01,0x00, 0x01,0x00)
    # Directory entry: width=0(256), height=0(256), colorCount=0, reserved=0,
    #   planes=1(2), bitCount=32(2), dataSize(4), dataOffset=22(4)
    $pngSize   = [System.BitConverter]::GetBytes([uint32]$pngBytes.Length)
    $pngOffset = [System.BitConverter]::GetBytes([uint32]22)
    $dirEntry  = [byte[]](0x00,0x00, 0x00,0x00, 0x01,0x00, 0x20,0x00) + $pngSize + $pngOffset

    $icoBytes = $header + $dirEntry + $pngBytes
    [System.IO.File]::WriteAllBytes($icoPath, $icoBytes)
    Write-Host "[2/3] ICO created: $icoPath"
  } catch {
    Write-Host "[2/3] ICO creation failed: $_  (using shell32 fallback icon)"
    $icoPath = $null
  }
}

# 3. Right-click context menu (HKCU, no admin required)
$regBase = 'HKCU:\Software\Classes\Directory\shell'

# Remove old flat entries if present
foreach ($old in @('OrganizeFolder', 'OrganizePictures')) {
  $p = "$regBase\$old"
  if (Test-Path $p) { Remove-Item $p -Recurse -Force }
}

# Helper: create a submenu child entry
# MUIVerb required on children for Win11 new context menu renderer
function New-SubEntry($parentShell, $order, $label, $command, $icon) {
  $key = "$parentShell\${order}_$(($label -replace '[^a-zA-Z0-9]',''))"
  New-Item  -Path $key           -Force | Out-Null
  New-Item  -Path "$key\command" -Force | Out-Null
  Set-ItemProperty -Path $key           -Name '(Default)' -Value $label
  Set-ItemProperty -Path $key           -Name 'MUIVerb'   -Value $label
  Set-ItemProperty -Path "$key\command" -Name '(Default)' -Value $command
  if ($icon) { Set-ItemProperty -Path $key -Name 'Icon' -Value $icon }
}

# Organize Folder submenu (4 options)
$p1 = "$regBase\ZOrganizeFolder"
New-Item -Path $p1 -Force | Out-Null
Set-ItemProperty -Path $p1 -Name 'MUIVerb'     -Value 'Organize Folder'
Set-ItemProperty -Path $p1 -Name 'SubCommands' -Value ''
Set-ItemProperty -Path $p1 -Name 'Icon'        -Value $(if ($icoPath) { $icoPath } else { 'shell32.dll,4' })
New-Item -Path "$p1\Shell" -Force | Out-Null

$sh1 = "$p1\Shell"
$pw  = 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
$ps  = "cmd /c start `"`" `"$pw`" -NoExit -ExecutionPolicy Bypass -File `"$generalScript`" -TargetPath `"%1`""

New-SubEntry $sh1 '01' 'Preview - Smart Sort'         "$ps"                                                                                                                                'shell32.dll,134'
New-SubEntry $sh1 '02' 'Apply - Move Files Smart'     "$ps -Apply"                                                                                                                         'shell32.dll,16814'
New-SubEntry $sh1 '03' 'Preview - By Extension'       "cmd /c start `"`" `"$pw`" -NoExit -ExecutionPolicy Bypass -File `"$generalScript`" -TargetPath `"%1`" -Mode extension"             'shell32.dll,3'
New-SubEntry $sh1 '04' 'Apply - Move Files Extension' "cmd /c start `"`" `"$pw`" -NoExit -ExecutionPolicy Bypass -File `"$generalScript`" -TargetPath `"%1`" -Mode extension -Apply"      'shell32.dll,16814'

# Organize Pictures submenu (2 options)
$p2 = "$regBase\ZOrganizePictures"
New-Item -Path $p2 -Force | Out-Null
Set-ItemProperty -Path $p2 -Name 'MUIVerb'     -Value 'Organize Pictures'
Set-ItemProperty -Path $p2 -Name 'SubCommands' -Value ''
Set-ItemProperty -Path $p2 -Name 'Icon'        -Value $(if ($icoPath) { $icoPath } else { 'shell32.dll,325' })
New-Item -Path "$p2\Shell" -Force | Out-Null

$sh2 = "$p2\Shell"
$ps2 = "cmd /c start `"`" `"$pw`" -NoExit -ExecutionPolicy Bypass -File `"$picturesScript`" -TargetPath `"%1`""

New-SubEntry $sh2 '01' 'Preview'            "$ps2"        'shell32.dll,134'
New-SubEntry $sh2 '02' 'Apply - Move Files' "$ps2 -Apply" 'shell32.dll,16814'

# Win11 compatibility: restore classic context menu so SubCommands submenus expand on click
# (HKCU only, reversible — does not affect other user accounts)
$clsid   = '{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'
$clsPath = "HKCU:\Software\Classes\CLSID\$clsid\InprocServer32"
New-Item -Path $clsPath -Force | Out-Null
Set-ItemProperty -Path $clsPath -Name '(Default)' -Value '' -Force

Write-Host "[3/3] Right-click menu entries added (Win11 classic menu enabled)"
Write-Host ""
Write-Host "DONE. Open a new terminal to use 'organize' and 'organize-pictures'."
Write-Host ""
Write-Host "Right-click any folder to see:"
Write-Host "  Organize Folder >"
Write-Host "    Preview - Smart Sort"
Write-Host "    Apply - Move Files Smart"
Write-Host "    Preview - By Extension"
Write-Host "    Apply - Move Files Extension"
Write-Host "  Organize Pictures >"
Write-Host "    Preview"
Write-Host "    Apply - Move Files"
Write-Host ""
Write-Host "NOTE: If submenus don't appear, restart Explorer or sign out/in."
