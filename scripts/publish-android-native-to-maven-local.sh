#!/usr/bin/env bash
# Usage: scripts/publish-android-native-to-maven-local.sh
#
# [EN] Publishes the Android native components the Flutter example (and any app that builds the plugins from source) needs to
#      the local Maven repository: this repository's :placeholder (io.github.chenyilong:cyltableviewplaceholder) and
#      CYLTabBarController's :cylanimateditem (io.github.chenyilong:cyltabbarcontroller-animateditem) at the commit the
#      Cartfile pins. Run it once, and again when either changes. A Flutter app built by flutter_cylplaceholder's example
#      then resolves both from mavenLocal() with no composite build (the two builds use different Android Gradle plugin
#      versions, which Gradle does not allow in one composite).
# [CN] 把 Flutter 示例（以及从源码构建插件的 App）需要的 Android 原生组件发布到本地 Maven 仓库：本仓库的 :placeholder 与
#      CYLTabBarController 的 :cylanimateditem（按 Cartfile 固定的 commit）。运行一次即可，两者变化后再运行。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/android"
bash ./gradlew --no-daemon :placeholder:publishToMavenLocal
TAB="$(bash "$ROOT/scripts/cyltabbarcontroller-checkout.sh" | tail -n 1)/Example-Android"
bash "$ROOT/android/gradlew" --no-daemon -p "$TAB" :cylanimateditem:publishToMavenLocal
echo "Published to $HOME/.m2/repository/io/github/chenyilong"
