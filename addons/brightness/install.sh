#!/usr/bin/env bash
# Build and install Brightness, then grant the overlay permission it needs.
# Usage: TV_HOST=<tv-ip> addons/brightness/install.sh
set -euo pipefail
: "${TV_HOST:?set TV_HOST to the TV IP address}"
command -v adb >/dev/null 2>&1 || { echo "ERROR: adb is required" >&2; exit 1; }
ADB_TARGET="$TV_HOST"
[[ "$ADB_TARGET" == *:* ]] || ADB_TARGET="$ADB_TARGET:5555"
PKG=io.github.maxhayim.brightness
if [ -n "${JAVA_HOME:-}" ]; then export PATH="$JAVA_HOME/bin:$PATH"; fi
cd "$(dirname "$0")"
adb connect "$ADB_TARGET" >/dev/null
adb -s "$ADB_TARGET" get-state >/dev/null
./gradlew --no-daemon assembleRelease -q --console=plain
adb -s "$ADB_TARGET" install -r app/build/outputs/apk/release/app-release.apk
adb -s "$ADB_TARGET" shell appops set "$PKG" SYSTEM_ALERT_WINDOW allow
adb -s "$ADB_TARGET" shell cmd appops set "$PKG" APP_AUTO_START allow >/dev/null 2>&1 || true
adb -s "$ADB_TARGET" shell am start -n "$PKG/.MainActivity" >/dev/null
echo "Installed. Open Brightness from the TV app launcher."
