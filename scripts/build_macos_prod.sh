#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
flutter build macos --release "$@"
echo "Output: build/macos/Build/Products/Release/partner_check.app"
