#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

KEY_PROPS="android/key.properties"
if [[ ! -f "$KEY_PROPS" ]]; then
  echo "Missing $KEY_PROPS — copy android/key.properties.example and fill in release keystore paths." >&2
  exit 1
fi

flutter pub get
flutter build appbundle --release "$@"
echo "Output: build/app/outputs/bundle/release/app-release.aab"
