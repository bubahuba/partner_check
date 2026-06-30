#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
flutter build web --base-href=/app/ "$@"
