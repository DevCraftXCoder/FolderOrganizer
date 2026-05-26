param(
  [string]$TargetPath = (Get-Location).Path,
  [switch]$Apply,
  [string]$Mode = 'content'  # 'content' (default) or 'extension'
)

# .ts removed from videoExts — TypeScript is far more common than MPEG transport streams
$imageExts  = @('.jpg','.jpeg','.png','.gif','.webp','.bmp','.tiff','.svg','.ico','.heic','.avif')
$videoExts  = @('.mp4','.mov','.avi','.mkv','.wmv','.flv','.webm','.m4v','.vob')
$audioExts  = @('.mp3','.wav','.flac','.aac','.ogg','.m4a','.wma','.opus','.aiff')
$docExts    = @('.pdf','.doc','.docx','.txt','.rtf','.odt','.pages')
$codeDocExt = @('.md')   # treated as code-doc, checked before general docs
$sheetExts  = @('.xls','.xlsx','.csv','.ods','.numbers')
$slideExts  = @('.ppt','.pptx','.odp','.key')
$codeExts   = @('.py','.js','.ts','.jsx','.tsx','.html','.css','.json','.cs','.java','.cpp','.c','.go','.rs','.rb','.php','.sql','.sh','.bash','.yaml','.yml','.toml','.xml','.env','.ini','.cfg','.conf','.ipynb','.r','.swift','.kt','.dart','.lua','.pl','.ex','.exs','.hs','.scala','.clj','.vim','.ps1')
$archiveExts= @('.zip','.rar','.7z','.tar','.gz','.bz2','.xz','.tgz','.cab','.iso','.bak')
$exeExts    = @('.exe','.msi','.bat','.cmd','.vbs','.app','.pkg','.deb','.rpm')
$designExts = @('.psd','.ai','.xd','.sketch','.fig','.afdesign','.afphoto','.afpub','.indd','.eps','.cdr')
$fontExts   = @('.ttf','.otf','.woff','.woff2','.eot')
$threeDExts = @('.fbx','.obj','.blend','.stl','.3ds','.dae','.ply','.glb','.gltf')

function Get-FileGroup($ext) {
  if ($imageExts  -contains $ext) { return 'image' }
  if ($videoExts  -contains $ext) { return 'video' }
  if ($audioExts  -contains $ext) { return 'audio' }
  if ($docExts    -contains $ext) { return 'doc' }
  if ($codeDocExt -contains $ext) { return 'codedoc' }
  if ($sheetExts  -contains $ext) { return 'sheet' }
  if ($slideExts  -contains $ext) { return 'slide' }
  if ($codeExts   -contains $ext) { return 'code' }
  if ($archiveExts-contains $ext) { return 'archive' }
  if ($exeExts    -contains $ext) { return 'exe' }
  if ($designExts -contains $ext) { return 'design' }
  if ($fontExts   -contains $ext) { return 'font' }
  if ($threeDExts -contains $ext) { return 'threed' }
  return 'other'
}

function Get-ContentCategory($filename) {
  $n   = $filename.ToLower()
  $ext = [System.IO.Path]::GetExtension($filename).ToLower()
  $grp = Get-FileGroup $ext

  # GIFs always go to GIFs
  if ($ext -eq '.gif') { return 'GIFs' }

  # Dotfiles / env / config files (before group checks)
  if ($n -match '^\.env') { return 'Code-Config' }

  # Code documentation files (before doc group check — .md sits in codedoc group)
  if ($n -match 'changelog|contributing|license|authors|codeowners|maintainers') { return 'Code-Docs' }

  # Backup files with .bak extension
  if ($ext -eq '.bak') { return 'Archives-Backup' }

  # Gaming (any file type) — checked early, high priority
  if ($n -match 'ranked|pvp|solo.?que|bot.?lobby|hardpoint|zombies|arc.?raiders|warzone|the.?finals|dont.?shoot|quick.?cash|getting.?smoked|solo.?ranked|gameplay') { return 'Gaming' }

  # Screenshots (any type) — use prefix/infix pattern, no \b (underscore is word char)
  if ($n -match 'screenshot|screen.?cap') { return 'Screenshots' }

  # AI-Generated images
  if ($grp -eq 'image' -and $n -match 'chatgpt.?image|masterpiece|hailuo|lucid.?origin|seed\d|_seed|s-\d{7,}') { return 'AI-Generated' }

  # Logos — image/codedoc only so logo_vector.ai stays in Design
  if ($grp -eq 'image' -and $n -match 'logo|lgoo') { return 'Logos' }

  # Banners — image only
  if ($grp -eq 'image' -and $n -match 'banner') { return 'Banners' }

  # Thumbnails — image only
  if ($grp -eq 'image' -and $n -match 'thumbnail') { return 'Thumbnails' }

  # LinkedIn / Social
  if ($n -match 'linkedin|linkedpost|linkein|devxcoder|devxocder|cybertools.?post') { return 'LinkedIn-Social' }

  # Avatars / PFPs — pfp often after _ (profile_pfp)
  if ($n -match 'pfp|avatar|trans_bear|pngtuber|biggest.?bro|mizzy.?pfp') { return 'Avatars-PFPs' }

  # Brand / Marketing
  if ($n -match '^360co|^360mizzy|3sixty|mizzy.?360|gpt.?mizzy|ad.?for.?mizzy') { return 'Brand-Marketing' }

  # Game Art
  if ($n -match 'tile.?guide|encounter.?card|wanted.?poster|dialogue|jinzey.?and.?clara|old.?western|old.?vintage|outlaw') { return 'Game-Art' }

  # Project / Dev screenshots (any type)
  if ($n -match '^finos|hermes|^sic\b|autodeploy|^francois.?arch|^ops\b|^paste\b|hook.?recovery|focus.?app|growth.?report|learn.?logo|learn.?app|prompt.?library') { return 'Project-Dev' }

  # === CODE DOCS (.md files) ===
  if ($grp -eq 'codedoc') {
    if ($n -match 'readme|spec\b|blueprint|playbook|guide|howto|how.to|manual|tutorial') { return 'Documents-Guides' }
    if ($n -match 'notes?|journal|diary|memo|draft|scratch|ideas?') { return 'Documents-Notes' }
    return 'Code-Docs'
  }

  # === DOCUMENTS ===
  if ($grp -eq 'doc') {
    if ($n -match 'resume|curriculum.?vitae|cover.?letter') { return 'Documents-Resume' }
    if ($n -match '\bcv\b') { return 'Documents-Resume' }
    if ($n -match 'template|form') { return 'Documents-Templates' }
    if ($n -match 'invoice|receipt|bill\b|payment|order\b|transaction|purchase') { return 'Documents-Invoice' }
    if ($n -match 'contract|agreement|nda|terms|tos|eula') { return 'Documents-Contract' }
    if ($n -match 'report|analysis|summary|audit|review|assessment') { return 'Documents-Report' }
    if ($n -match 'notes?|journal|diary|memo|draft|scratch|ideas?') { return 'Documents-Notes' }
    if ($n -match 'budget|expense|financial|finance|tax|income|profit|loss|balance') { return 'Documents-Finance' }
    if ($n -match 'proposal|pitch|presentation|deck') { return 'Documents-Presentation' }
    if ($n -match 'tutorial|guide|howto|how.to|manual|readme|spec\b|blueprint|playbook') { return 'Documents-Guides' }
    return 'Documents'
  }

  if ($grp -eq 'sheet') {
    if ($n -match 'budget|expense|financial|finance|tax|income|profit|balance') { return 'Documents-Finance' }
    return 'Spreadsheets'
  }

  if ($grp -eq 'slide') { return 'Documents-Presentation' }

  # === VIDEOS ===
  if ($grp -eq 'video') {
    if ($n -match 'music.?video|lyric|mv\b|music.vid') { return 'Videos-Music' }
    if ($n -match 'tutorial|howto|how.to|guide|learn') { return 'Videos-Tutorial' }
    if ($n -match 'stream|live|obs|recording|session') { return 'Videos-Stream' }
    if ($n -match 'short|reel|tiktok') { return 'Videos-Shorts' }
    if ($n -match '\bad\b|promo|commercial|campaign') { return 'Videos-Marketing' }
    return 'Videos'
  }

  # === AUDIO ===
  if ($grp -eq 'audio') {
    if ($n -match 'sfx|sound.?effect|foley|ambient') { return 'Audio-SFX' }
    if ($n -match 'beat|instrumental|loop|sample|drum|bass|synth|808') { return 'Audio-Beats' }
    if ($n -match 'vocal|verse|hook|chorus|bridge|acapella') { return 'Audio-Vocals' }
    if ($n -match 'mix|master|stem|export|bounce') { return 'Audio-Mix' }
    if ($n -match 'podcast|interview|episode|ep\d') { return 'Audio-Podcast' }
    return 'Audio'
  }

  # === CODE ===
  if ($grp -eq 'code') {
    if ($n -match '\.test\.|\.spec\.|_test\.|_spec\.') { return 'Code-Tests' }
    # Pure config extensions always win over devops keyword match
    if ($ext -in @('.conf','.ini','.cfg','.toml','.env')) { return 'Code-Config' }
    if ($n -match 'docker|compose|nginx|caddy|deploy|workflow|\.github') { return 'Code-DevOps' }
    if ($n -match '\.env|settings\.|\.toml|\.yaml|\.yml|\.ini|\.cfg|\.conf') { return 'Code-Config' }
    if ($n -match 'migration|schema|seed\b|\.sql') { return 'Code-Database' }
    if ($n -match 'readme|changelog|contributing|license') { return 'Code-Docs' }
    return 'Code'
  }

  # === DESIGN ===
  if ($grp -eq 'design') { return 'Design' }

  # === ARCHIVES ===
  if ($grp -eq 'archive') {
    if ($n -match 'backup|\.bak') { return 'Archives-Backup' }
    if ($n -match 'source|src\b|project|release|dist\b|build') { return 'Archives-Projects' }
    return 'Archives'
  }

  # === EXECUTABLES ===
  if ($grp -eq 'exe') {
    if ($n -match 'setup|install') { return 'Installers' }
    return 'Executables'
  }

  if ($grp -eq 'font')   { return 'Fonts' }
  if ($grp -eq 'threed') { return '3D-Models' }

  # Downloaded (hash/UUID/timestamp names)
  if ($n -match '^[0-9a-f]{8}-[0-9a-f]{4}|^[0-9a-f]{32}|^\d{13}\.(jpg|jpeg|png|gif|webp|mp4|mov)$') { return 'Downloaded' }

  # Remaining images
  if ($grp -eq 'image') { return 'Pictures' }

  return 'Other'
}

function Get-ExtensionCategory($filename) {
  $ext = [System.IO.Path]::GetExtension($filename).ToLower()
  $grp = Get-FileGroup $ext
  switch ($grp) {
    'image'   { return 'Pictures' }
    'video'   { return 'Videos' }
    'audio'   { return 'Audio' }
    'doc'     { return 'Documents' }
    'codedoc' { return 'Documents' }
    'sheet'   { return 'Spreadsheets' }
    'slide'   { return 'Presentations' }
    'code'    { return 'Code' }
    'archive' { return 'Archives' }
    'exe'     { return 'Executables' }
    'design'  { return 'Design' }
    'font'    { return 'Fonts' }
    'threed'  { return '3D-Models' }
    default   { return 'Other' }
  }
}

$files = Get-ChildItem -Path $TargetPath -File

$plan = @{}
foreach ($f in $files) {
  $cat = if ($Mode -eq 'extension') { Get-ExtensionCategory $f.Name } else { Get-ContentCategory $f.Name }
  if (-not $plan.ContainsKey($cat)) { $plan[$cat] = @() }
  $plan[$cat] += $f
}

$modeLabel = if ($Apply) { 'APPLY' } else { 'DRY RUN' }
Write-Host ""
Write-Host "FOLDER ORGANIZER -- $modeLabel  ($Mode mode)"
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
