---
name: dev-web
description: Run Partner Check in Chrome for local web development. Invoke explicitly when the user wants to dev-run on web.
disable-model-invocation: true
---

# Dev — Web

Run from project root (`partner_check/`):

```bash
./scripts/dev_web.sh
```

## Prerequisites

- Chrome (or pass `-d web-server` / another browser via script args)

## Notes

- Runs `flutter pub get` then `flutter run -d chrome`
- Dev uses default base href `/` (unlike production web build at `/app/`)
