#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get
./build_web.sh "$@"
echo "Output: build/web/ (deploy with base href /app/)"
