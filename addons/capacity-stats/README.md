# Capacity Stats

A standalone Android TV app that displays available/total RAM and used/total storage. It is maintained by [lionlev21](https://github.com/lionlev21).

## Build

Requires JDK 17 and Android SDK Platform 34.

```sh
./gradlew --no-daemon testReleaseUnitTest lintRelease assembleRelease
adb install -r app/build/outputs/apk/release/app-release.apk
```

The project uses the repository's shared Gradle 8.9 wrapper through its local `gradlew` scripts. No launcher source or wrapper JAR is required inside this add-on.

## Permissions and privacy

No permissions are requested. No network, telemetry, ads, or persistent background service. The app reads local `/proc/meminfo` and the data filesystem's capacity. “Used” RAM is total minus available, not process RSS. Missing or invalid readings are omitted.

## Validation

The upstream add-on README records testing on a Sony KD-50X85J running Android TV 12. Validate the app on your own device and Android version before relying on its readings.
