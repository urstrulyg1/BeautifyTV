# Digital Rain

A lightweight Android TV screensaver. Columns of mirrored half-width katakana and digits fall across a black screen, with a bright head and a fading green trail. The animation is drawn locally; no images, fonts, or network resources are downloaded.

- Package: `io.github.dennisoleary.digitalrain`
- Author: [@dennis-oleary](https://github.com/dennis-oleary)
- Reported test device: NVIDIA SHIELD Android TV Pro 2019 (Android TV 11)

## Permissions and privacy

No permissions are requested. The app has no `INTERNET` permission and starts no persistent background service. Animation runs only while its screen is active.

## Build and install

Requires JDK 17 and Android SDK Platform 34.

```sh
./gradlew --no-daemon testReleaseUnitTest lintRelease assembleRelease
adb install -r app/build/outputs/apk/release/app-release.apk
```

The release APK is written to `app/build/outputs/apk/release/app-release.apk`. Open the app from the TV's app launcher. To use it as the system screensaver, select **Digital Rain** under the TV's Screen saver settings if the firmware lists it.

## Customization

The animation constants in `app/src/main/java` control frame timing, drop density, and trail/head colors. Review the source before changing values to avoid excessive rendering work on lower-powered TVs.
