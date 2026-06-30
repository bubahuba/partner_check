---
name: build-web-prod
description: Build release Flutter web for production (base href /app/). Invoke explicitly for production web deploys.
disable-model-invocation: true
---

# Production build — Web

Run from project root (`partner_check/`):

```bash
./scripts/build_web_prod.sh
```

Equivalent:

```bash
./build_web.sh
```

## Output

`build/web/` — deploy to your host with the app served at **`/app/`** (see `web/index.html` base href).

## Optional args

Pass through to `flutter build web`:

```bash
./scripts/build_web_prod.sh --wasm
```

## Icons

If `appIcon.png` changed, regenerate PWA icons first (see `web-pwa-icons` skill).
