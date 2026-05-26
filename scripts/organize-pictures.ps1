param(
  [string]$TargetPath = (Get-Location).Path,
  [switch]$Apply
)

function Get-PictureCategory($filename) {
  $n   = $filename.ToLower()
  $ext = [System.IO.Path]::GetExtension($filename).ToLower()

  if ($ext -eq '.gif') { return 'GIFs' }
  if ($ext -eq '.svg') { return 'Logos' }

  # AI-Generated — common AI image export patterns
  if ($n -match 'chatgpt.?image|dall.?e|midjourney|stable.?diffusion|masterpiece|best.?quality|hailuo|lucid.?origin|seed\d|_seed|s-\d{7,}') { return 'AI-Generated' }

  # Screenshots
  if ($n -match 'screenshot|screen.?cap') { return 'Screenshots' }

  # Gaming
  if ($n -match 'ranked|pvp|solo.?que|bot.?lobby|hardpoint|zombies|warzone|gameplay|killcam|clutch|victory.?royale|game.?clip') { return 'Gaming' }

  # Logos
  if ($n -match 'logo|lgoo') { return 'Logos' }

  # Banners
  if ($n -match 'banner') { return 'Banners' }

  # Social media posts
  if ($n -match 'linkedin|linkedpost|twitter.?post|ig.?post|instagram.?post|social.?post|post\d') { return 'Social-Posts' }

  # Avatars / PFPs
  if ($n -match 'pfp|avatar|pngtuber|profile.?pic') { return 'Avatars-PFPs' }

  # Brand / Marketing
  if ($n -match 'brand|promo.?banner|marketing.?asset|ad.?creative|campaign.?image') { return 'Brand-Marketing' }

  # Project / Dev
  if ($n -match 'architecture|arch.?diagram|db.?schema|er.?diagram|wireframe|system.?design|deploy.?diagram|api.?diagram') { return 'Project-Dev' }

  # Game Art
  if ($n -match 'tile.?guide|encounter.?card|wanted.?poster|dialogue.?card|game.?card|npc.?card|ability.?card|item.?card|character.?card') { return 'Game-Art' }

  # Thumbnails
  if ($n -match 'thumbnail|thumb') { return 'Thumbnails' }

  # Long hash filenames (downloaded/API images)
  if ($n -match '^[0-9a-f]{8}-[0-9a-f]{4}|^[0-9a-f]{32}|^h4kw|^huu|^lzu') { return 'Downloaded' }

  # Timestamp filenames (Discord/Telegram/WhatsApp)
  if ($n -match '^\d{13}\.(jpg|jpeg|png|gif|webp)$') { return 'Downloaded' }

  return 'Other'
}

$files = Get-ChildItem -Path $TargetPath -File
$knownCategories = @('AI-Generated','Screenshots','Gaming','Logos','Banners','Social-Posts','Avatars-PFPs','Brand-Marketing','Project-Dev','Game-Art','Thumbnails','GIFs','Downloaded','Other')

$plan = @{}
foreach ($f in $files) {
  $cat = Get-PictureCategory $f.Name
  if (-not $plan.ContainsKey($cat)) { $plan[$cat] = @() }
  $plan[$cat] += $f
}

$modeLabel = if ($Apply) { 'APPLY' } else { 'DRY RUN' }
Write-Host ""
Write-Host "PICTURE ORGANIZER -- $modeLabel"
Write-Host "Target : $TargetPath"
Write-Host ""

$total = 0
foreach ($cat in ($plan.Keys | Sort-Object)) {
  $count = $plan[$cat].Count
  $total += $count
  Write-Host "  $cat/  ($count files)"
  foreach ($f in ($plan[$cat] | Sort-Object Name)) {
    Write-Host "    $($f.Name)"
  }
  Write-Host ""
}

Write-Host "Total: $total files across $($plan.Keys.Count) categories"

if (-not $Apply) {
  Write-Host ""
  Write-Host "  --> Dry run. Re-run with -Apply to execute."
  exit 0
}

Write-Host ""
Write-Host "Executing moves..."
$moved = 0; $errors = 0

foreach ($cat in $plan.Keys) {
  $destDir = Join-Path $TargetPath $cat
  if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }
  foreach ($f in $plan[$cat]) {
    $dest = Join-Path $destDir $f.Name
    $counter = 1
    while (Test-Path $dest) {
      $base = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
      $extv = $f.Extension
      $dest = Join-Path $destDir "${base}_${counter}${extv}"
      $counter++
    }
    try {
      Move-Item -Path $f.FullName -Destination $dest -ErrorAction Stop
      $moved++
    } catch {
      Write-Host "  ERROR: $($f.Name) -- $_"
      $errors++
    }
  }
}

Write-Host "  Moved : $moved"
Write-Host "  Errors: $errors"
Write-Host "Done."
