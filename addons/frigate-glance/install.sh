#!/usr/bin/env bash
# Build Frigate Glance, install it on an Android TV, import its config, and verify both connections.
# Usage: TV_HOST=<tv-ip> addons/frigate-glance/install.sh <config.json>
# Requires: JDK 17, Android SDK, adb, and Python 3. Keep config.json outside the repository.
set -euo pipefail

CONFIG="${1:?usage: TV_HOST=<tv-ip> $0 <config.json>}"
: "${TV_HOST:?set TV_HOST to the TV IP address}"
command -v adb >/dev/null 2>&1 || { echo "ERROR: adb is required" >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "ERROR: python3 is required for config validation" >&2; exit 1; }
[ -f "$CONFIG" ] || { echo "ERROR: config file not found" >&2; exit 1; }
CONFIG="$(cd "$(dirname "$CONFIG")" && pwd)/$(basename "$CONFIG")"

python3 - "$CONFIG" <<'PY'
import json, sys
from urllib.parse import urlsplit

try:
    with open(sys.argv[1], encoding="utf-8") as f:
        config = json.load(f)
except Exception:
    sys.exit("ERROR: config file is not valid JSON")

for key in ("mqtt", "frigateUrl"):
    if not isinstance(config.get(key), str) or not config[key].strip():
        sys.exit("ERROR: config needs " + key)

try:
    mqtt = urlsplit(config["mqtt"])
    frigate = urlsplit(config["frigateUrl"])
    mqtt_ok = mqtt.scheme in ("mqtt", "mqtts") and bool(mqtt.hostname)
    frigate_ok = frigate.scheme in ("http", "https") and bool(frigate.hostname)
except ValueError:
    mqtt_ok = frigate_ok = False

if not mqtt_ok:
    sys.exit('ERROR: "mqtt" must use mqtt:// or mqtts:// and include a host')
if not frigate_ok:
    sys.exit('ERROR: "frigateUrl" must use http:// or https:// and include a host')
PY

PKG=io.github.nickld.frigateglance
SVC="$PKG/.KeyService"
if [[ "$TV_HOST" == *:* ]]; then
    ADB_TARGET="$TV_HOST"
else
    ADB_TARGET="$TV_HOST:5555"
fi
adb connect "$ADB_TARGET" >/dev/null
adb -s "$ADB_TARGET" get-state >/dev/null

if [ -n "${JAVA_HOME:-}" ]; then export PATH="$JAVA_HOME/bin:$PATH"; fi
cd "$(dirname "$0")"
./gradlew --no-daemon assembleRelease -q --console=plain
APK=app/build/outputs/apk/release/app-release.apk
[ -f "$APK" ] || { echo "ERROR: release APK was not generated" >&2; exit 1; }
adb -s "$ADB_TARGET" install -r "$APK"

# Allow the overlay and, on TCL firmware, automatic start after reboot.
adb -s "$ADB_TARGET" shell appops set "$PKG" SYSTEM_ALERT_WINDOW allow
adb -s "$ADB_TARGET" shell cmd appops set "$PKG" APP_AUTO_START allow >/dev/null 2>&1 || true

# Import through the app-owned provider. The external-files fallback supports older Android releases
# where the content command is unavailable.
adb -s "$ADB_TARGET" shell logcat -c
adb -s "$ADB_TARGET" push "$CONFIG" /data/local/tmp/fg-config.json >/dev/null
if ! adb -s "$ADB_TARGET" shell "content write --uri content://$PKG.config/config.json < /data/local/tmp/fg-config.json" >/dev/null 2>&1; then
    adb -s "$ADB_TARGET" shell "mkdir -p /sdcard/Android/data/$PKG/files && cp /data/local/tmp/fg-config.json /sdcard/Android/data/$PKG/files/config.json"
fi
adb -s "$ADB_TARGET" shell rm -f /data/local/tmp/fg-config.json

# Enable the key service without replacing any accessibility services already enabled by the user.
SERVICES="$(adb -s "$ADB_TARGET" shell settings get secure enabled_accessibility_services | tr -d '\r')"
case "$SERVICES" in
    *"$SVC"*) ;;
    null|"") SERVICES="$SVC" ;;
    *) SERVICES="$SERVICES:$SVC" ;;
esac
adb -s "$ADB_TARGET" shell settings put secure enabled_accessibility_services "$SERVICES"
adb -s "$ADB_TARGET" shell settings put secure accessibility_enabled 1

adb -s "$ADB_TARGET" shell am start -n "$PKG/.SettingsActivity" >/dev/null

LOG=""
for _ in $(seq 1 10); do
    sleep 2
    LOG="$(adb -s "$ADB_TARGET" logcat -d -s FrigateGlance:* | tr -d '\r')"
    case "$LOG" in
        *"mqtt connected"*) case "$LOG" in *"frigate ok"*|*"frigate error"*) break ;; esac ;;
    esac
done

config_status="$(printf '%s\n' "$LOG" | grep -o 'config imported\|pushed config rejected\|pushed config unreadable' | tail -n 1 || true)"
mqtt_status="$(printf '%s\n' "$LOG" | grep -o 'mqtt connected\|mqtt error: .*' | tail -n 1 || true)"
frigate_status="$(printf '%s\n' "$LOG" | grep -o 'frigate ok\|frigate error: .*' | tail -n 1 || true)"

case "$config_status" in
    "config imported") echo "Config: read by the app" ;;
    "pushed config rejected") echo "Config: rejected by the app; inspect device logcat for details" ;;
    *) echo "Config: not confirmed; inspect device logcat" ;;
esac
case "$mqtt_status" in
    "mqtt connected") echo "MQTT: connected" ;;
    *) echo "MQTT: connection not confirmed; inspect device logcat" ;;
esac
case "$frigate_status" in
    "frigate ok") echo "Frigate: connected" ;;
    *) echo "Frigate: connection not confirmed; inspect device logcat" ;;
esac

[ "$config_status" = "config imported" ] && [ "$mqtt_status" = "mqtt connected" ] && [ "$frigate_status" = "frigate ok" ] || exit 1
adb -s "$ADB_TARGET" shell am broadcast -n "$PKG/.TestCardReceiver" >/dev/null
echo "Installed. Frigate Glance is configured and a test card was requested."
