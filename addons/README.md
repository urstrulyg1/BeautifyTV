# Android TV add-ons

This directory contains the nine Android TV applications currently maintained in this repository. Each folder is a separate Gradle project with its own application ID, source, README, and APK output.

| Add-on | Description |
|---|---|
| [Ad Blocking](ad-blocking/) | Dashboard and controls for Pi-hole and AdGuard Home |
| [AirPlay Status](airplay-status/) | Shows this TV's AirPlay announcements and nearby receivers |
| [Bluetooth Connect](bluetooth-connect/) | Connects or disconnects already-paired Bluetooth audio devices |
| [Bluetooth Toggle](bluetooth-toggle/) | Bluetooth radio toggle for supported Android versions |
| [Brightness](brightness/) | Brightness controls, night mode, and supported TV picture controls |
| [Capacity Stats](capacity-stats/) | RAM and storage capacity readings |
| [Digital Rain](digital-rain/) | Animated screensaver |
| [Flock](flock/) | Interactive boids/flocking simulation |
| [Frigate Glance](frigate-glance/) | Frigate event notifications and camera cards |

## Build any add-on

Requirements: JDK 17, Android SDK Platform 34, and Android build tools 34.

```sh
cd addons/<add-on-name>
./gradlew --no-daemon testReleaseUnitTest lintRelease assembleRelease
```

The APK is generated at `app/build/outputs/apk/release/app-release.apk`. Install it with `adb install -r app/build/outputs/apk/release/app-release.apk`, then open it from the TV's app launcher.

The add-ons are independent applications. Some include module-card metadata for compatible third-party launchers, but **the launcher itself is not part of this repository**. Older add-on descriptions may refer to CleanYourTV launcher integration or utilities that are maintained elsewhere; use the current build instructions above for building the apps in this repository.

## Wrapper layout

All projects are pinned to Gradle 8.9. Most add-ons carry the standard Gradle wrapper files; Capacity Stats, Flock, and Frigate Glance delegate to the shared wrapper maintained in [ad-blocking](ad-blocking/gradle/wrapper/gradle-wrapper.properties). All wrappers build the selected add-on as an independent Gradle project.
