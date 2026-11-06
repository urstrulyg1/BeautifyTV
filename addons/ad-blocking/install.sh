#!/usr/bin/env bash
# Build and install Ad Blocking. Optional config: { "kind": "pihole", "url": "...", "password": "..." }.
# Usage: TV_HOST=<tv-ip> addons/ad-blocking/install.sh [config.json]
set -euo pipefail
CONFIG="${1:-}"
: "${TV_HOST:?set TV_HOST to the TV IP address}"
command -v adb >/dev/null 2>&1 || { echo "ERROR: adb is required" >&2; exit 1; }
if [ -n "$CONFIG" ]; then
    [ -f "$CONFIG" ] || { echo "ERROR: config file not found" >&2; exit 1; }
    CONFIG="$(cd "$(dirname "$CONFIG")" && pwd)/$(basename "$CONFIG")"
fi
ADB_TARGET="$TV_HOST"
[[ "$ADB_TARGET" == *:* ]] || ADB_TARGET="$ADB_TARGET:5555"
PKG=io.github.maxhayim.adblocking
if [ -n "${JAVA_HOME:-}" ]; then export PATH="$JAVA_HOME/bin:$PATH"; fi
cd "$(dirname "$0")"
adb connect "$ADB_TARGET" >/dev/null
adb -s "$ADB_TARGET" get-state >/dev/null
./gradlew --no-daemon assembleRelease -q --console=plain
adb -s "$ADB_TARGET" install -r app/build/outputs/apk/release/app-release.apk
if [ -n "$CONFIG" ]; then
    python3 -m json.tool "$CONFIG" >/dev/null
    adb -s "$ADB_TARGET" push "$CONFIG" /data/local/tmp/ad-blocking-config.json >/dev/null
    if ! adb -s "$ADB_TARGET" shell "content write --uri content://$PKG.config/config.json < /data/local/tmp/ad-blocking-config.json" >/dev/null 2>&1; then
        adb -s "$ADB_TARGET" shell "mkdir -p /sdcard/Android/data/$PKG/files && cp /data/local/tmp/ad-blocking-config.json /sdcard/Android/data/$PKG/files/config.json"
    fi
    adb -s "$ADB_TARGET" shell rm -f /data/local/tmp/ad-blocking-config.json
fi
adb -s "$ADB_TARGET" shell am start -n "$PKG/.MainActivity" >/dev/null
echo "Installed. Open Ad Blocking from the TV app launcher."
