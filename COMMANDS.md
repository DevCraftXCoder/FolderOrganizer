# Commands Guide

## organize

Sorts any folder by **what files are** — not just their extension.

```
organize [path] [-apply] [-mode content|extension]
```

| Argument | Default | Description |
|---|---|---|
| `path` | current folder | Folder to organize |
| `-apply` | off | Actually move files (omit for dry-run) |
| `-mode` | `content` | `content` = smart categories, `extension` = group by type |

---

### Examples

```powershell
# Preview smart sort on current folder
organize

# Preview smart sort on a specific folder
organize 'C:\Users\You\Downloads'

# Execute smart sort
organize 'C:\Users\You\Downloads' -apply

# Preview extension-only sort (Pictures/, Videos/, Documents/, etc.)
organize 'C:\Users\You\Downloads' -mode extension

# Execute extension-only sort
organize 'C:\Users\You\Downloads' -mode extension -apply
```

---

## organize-pictures

Same as `organize` but tuned for image folders with more granular creator/social categories.

```
organize-pictures [path] [-apply]
```

| Argument | Default | Description |
|---|---|---|
| `path` | current folder | Folder to organize |
| `-apply` | off | Actually move files (omit for dry-run) |

---

### Examples

```powershell
# Preview picture sort on current folder
organize-pictures

# Preview picture sort on a specific folder
organize-pictures 'C:\Users\You\Pictures'

# Execute picture sort
organize-pictures 'C:\Users\You\Pictures' -apply
```

---

## Windows Explorer (Right-Click)

Right-click any folder in File Explorer:

```
Organize Folder >
  ├── Preview (Smart Sort)            ← dry-run, content-aware
  ├── Apply — Move Files (Smart)      ← execute smart sort
  ├── Preview (By Extension)          ← dry-run, type groups only
  └── Apply — Move Files (Extension)  ← execute extension sort

Organize Pictures >
  ├── Preview                         ← dry-run
  └── Apply — Move Files              ← execute
```

Preview options always open a terminal showing the plan first. Nothing moves until you choose an Apply option.

---

## How Dry-Run Works

Running without `-apply` prints a table like:

```
[MOVE] invoice_april.pdf  →  Documents-Invoice\invoice_april.pdf
[MOVE] ranked_clip.mp4    →  Gaming\ranked_clip.mp4
[MOVE] logo_v2.png        →  Logos\logo_v2.png
[SKIP] already_sorted.jpg    (destination exists)

Total: 3 files would move, 1 skipped
Run with -apply to execute.
```

No files are touched. Review the plan, then run again with `-apply`.

---

## Collision Handling

If a file with the same name already exists in the destination, the tool appends a number — it never overwrites:

```
invoice.pdf         → Documents-Invoice\invoice.pdf
invoice.pdf (2nd)   → Documents-Invoice\invoice_1.pdf
invoice.pdf (3rd)   → Documents-Invoice\invoice_2.pdf
```

---

## Tips

- **Always preview first** before running `-apply` on a folder you haven't organized before.
- **Subfolders are not touched** — only files directly inside the target folder are moved.
- **Use `-mode extension`** for quick grouping when you just want Pictures/Videos/Documents buckets with no smart logic.
- **Right-click is the fastest path** — no need to type a path, just right-click the folder.
