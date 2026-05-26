param([switch]$KeepClassicMenu)

$regBase = 'HKCU:\Software\Classes\Directory\shell'

Write-Host "Removing Folder Organizer context menu entries..."

# Remove both submenu top-level entries
foreach ($name in @('ZOrganizeFolder','ZOrganizePictures','OrganizeFolder','OrganizePictures')) {
  $p = "$regBase\$name"
  if (Test-Path $p) {
    Remove-Item $p -Recurse -Force
    Write-Host "  Removed: $name"
  }
}

# Remove profile functions
if (Test-Path $PROFILE) {
  $content = Get-Content $PROFILE -Raw
  if ($content -match 'Folder Organizer Commands') {
    # Strip the block between markers
    $updated = $content -replace '(?s)\r?\n# Folder Organizer Commands\r?\n.*?# End Folder Organizer Commands\r?\n?', ''
    Set-Content -Path $PROFILE -Value $updated -NoNewline
    Write-Host "  Removed profile functions from: $PROFILE"
  } else {
    Write-Host "  Profile functions not found (already removed or never added)"
  }
}

# Optionally remove the Win11 classic menu restore key
if (-not $KeepClassicMenu) {
  $clsid   = '{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}'
  $clsPath = "HKCU:\Software\Classes\CLSID\$clsid"
  if (Test-Path $clsPath) {
    Remove-Item $clsPath -Recurse -Force
    Write-Host "  Restored Win11 new context menu style"
  }
}

Write-Host ""
Write-Host "Uninstall complete."
Write-Host "Restart Explorer or sign out/in to apply."
Write-Host ""
Write-Host "To reinstall: pnpm install -g folder-organizer"
