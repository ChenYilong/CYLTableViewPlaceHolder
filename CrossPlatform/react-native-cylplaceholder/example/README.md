# react-native-cylplaceholder example

React Native 0.76.9 app, one screen (`App.tsx`): a `FlatList` inside the native `CYLRefreshContainer` (pull down to refresh, pull up to load more, "no more data" after page 3) with `CYLPlaceholderView` as the empty state. Android only for now (the iOS folder of a React Native template is not committed; the library's iOS half is not built, a `TODO` in `docs/Refresh-Library-Parity.md`).

| Step | Command |
|:---|:---|
| Publish the native components | from the repository root: `bash android/gradlew -p android -PcylTabBarDir=<CYLTabBarController checkout>/Example-Android :placeholder:publishToMavenLocal :merged:publishToMavenLocal` |
| Install | `npm install` (here) |
| Build | `cd android && ./gradlew :app:assembleDebug` |
| Run | `npx react-native start`, then install `android/app/build/outputs/apk/debug/app-debug.apk` and `adb reverse tcp:8081 tcp:8081` |

The library's own `android/` build uses a newer Android Gradle plugin than React Native 0.76, so `react-native.config.js` turns autolinking off for Android and `android/cyl-rn` compiles the library's Kotlin sources instead; `MainApplication` adds `CYLPlaceholderPackage` by hand. New architecture is off (the container is an old-architecture view manager).
