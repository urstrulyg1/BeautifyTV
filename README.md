# BeautifyTV

BeautifyTV is a collection of lightweight, independently buildable Android TV add-ons. Each project lives under `addons/<name>/` and produces its own APK.

> **Repository scope:** this repository currently contains the add-on applications only. It does not include the CleanYourTV launcher, TV debloating utilities, or the `tools/` directory referenced by some inherited add-on documentation. A compatible launcher may consume the add-ons' module-card metadata, but that launcher is maintained separately.

## Add-ons

| Add-on | Purpose |
|---|---|
| [Ad Blocking](addons/ad-blocking/README.md) | View and control Pi-hole or AdGuard Home |
| [AirPlay Status](addons/airplay-status/README.md) | Inspect AirPlay and mDNS announcements |
| [Bluetooth Connect](addons/bluetooth-connect/README.md) | Connect or disconnect paired Bluetooth audio devices |
| [Bluetooth Toggle](addons/bluetooth-toggle/README.md) | Toggle Bluetooth on supported Android versions |
| [Brightness](addons/brightness/README.md) | Adjust display brightness and night mode |
| [Capacity Stats](addons/capacity-stats/README.md) | View RAM and storage capacity |
| [Digital Rain](addons/digital-rain/README.md) | Lightweight animated screensaver |
| [Flock](addons/flock/README.md) | Interactive flocking simulation |
| [Frigate Glance](addons/frigate-glance/README.md) | Show Frigate camera event cards |

See the [add-ons index](addons/README.md) for the complete catalogue.

## Build requirements

- JDK 17
- Android SDK Platform 34 and corresponding build tools
- Internet access for Gradle and Android dependency resolution

Each add-on is an independent Gradle project. The checked-in wrapper scripts share the pinned Gradle 8.9 wrapper from `addons/ad-blocking`, while passing the selected add-on directory as the project directory.

## Build and test one add-on

From the repository root:

```sh
cd addons/frigate-glance
./gradlew --no-daemon testReleaseUnitTest lintRelease assembleRelease
```

Replace `frigate-glance` with any directory under `addons/`. The release APK is written to:

```
addons/<name>/app/build/outputs/apk/release/app-release.apk
```

Install an APK on a connected Android TV using Android Debug Bridge:

```sh
adb install -r app/build/outputs/apk/release/app-release.apk
```

Open the installed app from the TV's app launcher. Some add-ons expose module-card metadata for compatible third-party launchers.

## Continuous integration

GitHub Actions builds, runs JVM unit tests, and runs Android lint for every add-on on pushes and pull requests. Build outputs and reports are attached to each workflow run.

## Contributing

- Keep each add-on independently buildable.
- Prefer Android platform APIs and keep runtime dependencies small.
- Do not commit credentials, local configuration, signing keys, or generated APKs.
- Add or update unit tests when changing parsing, state, networking, or other testable logic.
- Document required permissions, network access, setup steps, and tested hardware clearly.
- Run the same checks as CI before opening a pull request.

## Attribution

BeautifyTV includes community add-ons. Individual add-on READMEs identify their respective authors and upstream projects where known. BeautifyTV is not affiliated with Google, Android, Frigate, Apple, Pi-hole, or AdGuard.
