#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
flutter build ipa --release "$@"
echo "Output: build/ios/ipa/*.ipa"
