# Folder Organizer CLI

Content-aware Windows folder organizer. Sorts files by **what they ARE** — not just their extension.

A `.mp4` named `ranked_gameplay.mp4` goes to `Gaming/`. A `.pdf` named `invoice_april.pdf` goes to `Documents-Invoice/`. A `.ts` file goes to `Code/`, not `Videos/`.

**46+ smart categories** across images, videos, audio, documents, code, design, and more.

---

## Install

```bash
pnpm add -g folder-organizer-cli
```

After install, the `postinstall` script automatically:
- Adds `organize` and `organize-pictures` functions to your PowerShell profile
- Adds **Organize Folder** and **Organize Pictures** submenus to Windows Explorer right-click (no admin required)

> Open a new terminal after install for the profile functions to activate.

---

## Usage

### Terminal

```powershell
# Dry-run (preview only — nothing moves)
organize 'C:\Users\You\Downloads'

# Execute moves
organize 'C:\Users\You\Downloads' -apply

# Sort by extension only (simple grouping)
organize 'C:\Users\You\Downloads' -mode extension

# Pictures — content-aware (what the image IS)
organize-pictures 'C:\Users\You\Pictures'
organize-pictures 'C:\Users\You\Pictures' -apply
```

### Windows Explorer

Right-click any folder:

**Organize Folder >**
- **Preview (Smart Sort)** — dry-run, content-aware categories
- **Apply — Move Files (Smart)** — execute smart sort
- **Preview (By Extension)** — dry-run, grouped by file type only
- **Apply — Move Files (Extension)** — execute extension sort

**Organize Pictures >**
- **Preview** — dry-run, picture-specific content categories
- **Apply — Move Files** — execute picture sort

All preview options open a terminal window showing exactly what would move and where — nothing is touched until you choose an Apply option.

---

## Categories

### General Organizer (`organize`)

| Category | What goes there |
|---|---|
| `Gaming` | Any gaming file — clips, screenshots, docs |
| `Screenshots` | `screenshot_*`, `screen_cap_*` |
| `AI-Generated` | ChatGPT, DALL-E, Midjourney, Stable Diffusion exports |
| `Logos` | `*logo*`, `*lgoo*` |
| `Banners` | `*banner*` |
| `Thumbnails` | `*thumbnail*`, `*thumb*` |
| `Social-Posts` | LinkedIn posts, Twitter posts, Instagram posts |
| `Avatars-PFPs` | `*pfp*`, `*avatar*`, `*pngtuber*` |
| `Brand-Marketing` | Brand assets, ad creatives, campaign images |
| `Game-Art` | Tile guides, encounter cards, dialogue cards, item cards |
| `Project-Dev` | Architecture diagrams, wireframes, DB schemas |
| `GIFs` | All `.gif` files |
| `Documents-Resume` | Resume, CV, cover letter |
| `Documents-Invoice` | Invoice, receipt, bill, payment |
| `Documents-Contract` | Contract, agreement, NDA, TOS |
| `Documents-Finance` | Budget, expense, tax, income |
| `Documents-Notes` | Notes, journal, memo, draft, scratch |
| `Documents-Guides` | Tutorial, guide, how-to, manual, readme, spec |
| `Documents-Templates` | Template, form |
| `Documents-Report` | Report, analysis, summary, audit, review |
| `Documents-Presentation` | Pitch deck, proposal, slides |
| `Spreadsheets` | `.xlsx`, `.csv`, `.ods` with no financial keywords |
| `Videos-Music` | Music video, lyric video |
| `Videos-Tutorial` | Tutorial, guide, how-to videos |
| `Videos-Stream` | Stream recording, OBS, live session |
| `Videos-Shorts` | Short, reel, TikTok |
| `Videos-Marketing` | Promo, commercial, campaign |
| `Videos` | Everything else video |
| `Audio-Beats` | Beat, instrumental, loop, sample, drum, 808 |
| `Audio-Vocals` | Vocal, verse, hook, chorus, acapella |
| `Audio-Mix` | Mix, master, stem, export, bounce |
| `Audio-SFX` | SFX, sound effect, foley, ambient |
| `Audio-Podcast` | Podcast, interview, episode |
| `Audio` | Everything else audio |
| `Code` | Source code files |
| `Code-Tests` | `*.test.*`, `*.spec.*` |
| `Code-Config` | `.env`, `*.toml`, `*.yaml`, `*.ini`, `docker-compose.*` |
| `Code-Database` | Migration, schema, seed, `.sql` |
| `Code-Docs` | `CHANGELOG`, `CONTRIBUTING`, `LICENSE` |
| `Code-DevOps` | Dockerfile, nginx, deploy, workflow |
| `Design` | PSD, AI, Figma, Sketch, Affinity |
| `Archives` | ZIP, RAR, 7z, TAR (no keyword match) |
| `Archives-Backup` | `*backup*`, `.bak` |
| `Archives-Projects` | `*source*`, `*release*`, `*dist*`, `*build*` |
| `Installers` | `setup_*`, `install_*` executables |
| `Executables` | Other `.exe`, `.bat`, `.cmd` |
| `Fonts` | TTF, OTF, WOFF, WOFF2 |
| `3D-Models` | FBX, OBJ, Blend, STL, GLB |
| `Downloaded` | Hash/UUID/timestamp named files |
| `Other` | Unrecognized file types |

### Picture Organizer (`organize-pictures`)

Same content-aware logic but tuned specifically for image folders with more granular social/creator categories.

---

## How It Works

1. **Filename pattern matching** — reads the filename, not the file contents
2. **Extension-as-context** — extension determines the file *type*, filename determines the *category*
3. **Priority order** — early patterns (Gaming, Screenshots) take precedence over generic type-based buckets
4. **Collision-safe** — files that would collide get `_1`, `_2` suffixes, never overwritten
5. **Dry-run by default** — always shows the plan before moving anything

---

## Modes

| Mode | Flag | Behavior |
|---|---|---|
| Content (default) | `organize path` | Reads filename, assigns smart category |
| Extension | `organize path -mode extension` | Groups by file type only (Pictures, Videos, Documents, etc.) |

---

## Requirements

- Windows 10 or 11
- PowerShell 5.1+ (built into Windows)
- Node.js 18+

---

## License

MIT
