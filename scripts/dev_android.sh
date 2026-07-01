#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
flutter pub get

# Android emulators spam D/EGL_emulation app_time_stats frame-timing logs.
if command -v adb >/dev/null 2>&1; then
  adb_args=()
  if [[ -n "${ANDROID_SERIAL:-}" ]]; then
    adb_args=(-s "$ANDROID_SERIAL")
  fi
  adb "${adb_args[@]}" shell setprop log.tag.EGL_emulation SUPPRESS >/dev/null 2>&1 || true
fi

flutter run -d android "$@"
