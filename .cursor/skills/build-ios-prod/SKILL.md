---
name: build-ios-prod
description: Build signed iOS IPA (release) for App Store or TestFlight. Invoke explicitly for production iOS builds.
disable-model-invocation: true
---

# Production build — iOS (signed IPA)

Run from project root (`partner_check/`):

```bash
./scripts/build_ios_prod.sh
```

## Prerequisites

- macOS with Xcode
- Valid Apple Developer signing (automatic signing configured in `ios/Runner.xcodeproj`)
- Bundle ID: `cz.shadowHub.partnerCheck`
- Export/upload via Xcode Organizer or `xcrun altool` / App Store Connect API

## Output

`build/ios/ipa/*.ipa`

## Troubleshooting

If pods or module errors occur:

```bash
./fix_ios_build.sh
```

Then re-run the prod build script.
