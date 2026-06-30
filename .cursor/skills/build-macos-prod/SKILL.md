---
name: build-macos-prod
description: Build signed macOS release app. Invoke explicitly for production macOS desktop builds.
disable-model-invocation: true
---

# Production build — macOS (signed)

Run from project root (`partner_check/`):

```bash
./scripts/build_macos_prod.sh
```

## Prerequisites

- macOS with Xcode
- Developer ID or Mac App Store signing configured in `macos/Runner.xcodeproj`
- Bundle ID: `cz.shadowHub.partnerCheck`

## Output

`build/macos/Build/Products/Release/partner_check.app`

## Notarize (App Store outside Mac App Store)

After build, notarize and staple the `.app` per Apple docs before distribution.
