#!/usr/bin/env bash
# Usage: scripts/publish-android-native-to-maven-local.sh
#
# [EN] Publishes the Android native components the Flutter example (and any app that builds the plugins from source) needs to
#      the local Maven repository: this repository's :placeholder (io.github.chenyilong:cyltableviewplaceholder), :merged (the refresh library, io.github.chenyilong:cyltableviewplaceholder-refresh) and
#      CYLTabBarController's :cylanimateditem (io.github.chenyilong:cyltabbarcontroller-animateditem) at the commit the
#      Cartfile pins. Run it once, and again when either changes. A Flutter app built by flutter_cylplaceholder's example
#      then resolves both from mavenLocal() with no composite build (the two builds use different Android Gradle plugin
#      versions, which Gradle does not allow in one composite).
# [CN] 把 Flutter 示例（以及从源码构建插件的 App）需要的 Android 原生组件发布到本地 Maven 仓库：本仓库的 :placeholder 与
#      CYLTabBarController 的 :cylanimateditem（按 Cartfile 固定的 commit）。运行一次即可，两者变化后再运行。
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# [EN] The checkout comes first: the :placeholder build includes CYLTabBarController's Example-Android, and without
#      -PcylTabBarDir it would pick the sibling ../CYLTabBarController (another commit). :merged is the refresh library
#      (React Native and Flutter need it).
# [CN] 先检出：:placeholder 构建会包含 CYLTabBarController 的 Example-Android，不传 -PcylTabBarDir 会误用同级目录（另一个 commit）；
#      :merged 是刷新库（React Native 与 Flutter 需要）。
TAB="$(bash "$ROOT/scripts/cyltabbarcontroller-checkout.sh" | tail -n 1)/Example-Android"
bash "$ROOT/android/gradlew" --no-daemon -p "$ROOT/android" -PcylTabBarDir="$TAB" :placeholder:publishToMavenLocal :merged:publishToMavenLocal :merged-rive:publishToMavenLocal
bash "$ROOT/android/gradlew" --no-daemon -p "$TAB" :cylanimateditem:publishToMavenLocal
echo "Published to $HOME/.m2/repository/io/github/chenyilong"
