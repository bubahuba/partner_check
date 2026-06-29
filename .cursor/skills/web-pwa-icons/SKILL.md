---
name: web-pwa-icons
description: Regenerates Partner Check web PWA icons and favicon from appIcon.png using macOS sips. Use when appIcon.png changes, updating web/icons, favicon.png, PWA manifest icons, or apple-touch-icon for the Flutter web build.
---

# Web PWA Icons

Regenerate all web PWA icon assets from the project root `appIcon.png`.

## When to run

- `appIcon.png` was updated
- PWA / favicon / `web/icons/` assets are missing or stale
- Before `flutter build web` after an icon change

## Command

From project root (`partner_check/`):

```bash
mkdir -p web/icons && \
sips -z 32 32 appIcon.png --out web/favicon.png && \
sips -z 180 180 appIcon.png --out web/icons/apple-touch-icon.png && \
sips -z 192 192 appIcon.png --out web/icons/Icon-192.png && \
sips -z 512 512 appIcon.png --out web/icons/Icon-512.png && \
cp web/icons/Icon-192.png web/icons/Icon-maskable-192.png && \
cp web/icons/Icon-512.png web/icons/Icon-maskable-512.png
```

## Outputs

| File | Size |
|------|------|
| `web/favicon.png` | 32×32 |
| `web/icons/apple-touch-icon.png` | 180×180 |
| `web/icons/Icon-192.png` | 192×192 |
| `web/icons/Icon-512.png` | 512×512 |
| `web/icons/Icon-maskable-192.png` | copy of 192 |
| `web/icons/Icon-maskable-512.png` | copy of 512 |

## After regenerating

Run `flutter build web` so `build/web/` picks up the new assets. `web/manifest.json` and `web/index.html` already reference these paths.

## Requirements

- Source: `appIcon.png` at project root (1024×1024 PNG recommended)
- macOS `sips` (built in)
