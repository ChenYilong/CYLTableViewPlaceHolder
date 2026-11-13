// The Android version of CYLTableViewPlaceHolder (docs/Android-Port.md). Module `placeholder`: the placeholder views
// (CYLPlaceholderStackView, CYLPlaceholderScenario), used by CYLSearchViewController's android/merged as a
// sub-repository, pinned by commit.
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "CYLTableViewPlaceHolderAndroid"
include(":placeholder")
// SVPullToRefresh in Kotlin (docs/Android-Port.md, the refresh port).
include(":SVPullToRefresh")
// android-Ultra-Pull-To-Refresh in Kotlin (docs/Android-Port.md, the refresh port).
include(":android-Ultra-Pull-To-Refresh")

// SmartRefreshLayout's Java source (Apache-2.0, scwang90, 224db48), the source the Kotlin port translates; the
// taken pull requests and the issue fixes go here first (docs/Android-Port.md, the owner's 2026-11-13 decision).
include(":srl-java-refresh-layout-kernel")
project(":srl-java-refresh-layout-kernel").projectDir = file("SmartRefreshLayout/java/refresh-layout-kernel")
include(":srl-java-refresh-drawable-paint")
project(":srl-java-refresh-drawable-paint").projectDir = file("SmartRefreshLayout/java/refresh-drawable-paint")
include(":srl-java-refresh-drawable-path")
project(":srl-java-refresh-drawable-path").projectDir = file("SmartRefreshLayout/java/refresh-drawable-path")
include(":srl-java-refresh-footer-ball")
project(":srl-java-refresh-footer-ball").projectDir = file("SmartRefreshLayout/java/refresh-footer-ball")
include(":srl-java-refresh-footer-classics")
project(":srl-java-refresh-footer-classics").projectDir = file("SmartRefreshLayout/java/refresh-footer-classics")
include(":srl-java-refresh-header-classics")
project(":srl-java-refresh-header-classics").projectDir = file("SmartRefreshLayout/java/refresh-header-classics")
include(":srl-java-refresh-header-falsify")
project(":srl-java-refresh-header-falsify").projectDir = file("SmartRefreshLayout/java/refresh-header-falsify")
include(":srl-java-refresh-header-material")
project(":srl-java-refresh-header-material").projectDir = file("SmartRefreshLayout/java/refresh-header-material")
include(":srl-java-refresh-header-radar")
project(":srl-java-refresh-header-radar").projectDir = file("SmartRefreshLayout/java/refresh-header-radar")
include(":srl-java-refresh-header-two-level")
project(":srl-java-refresh-header-two-level").projectDir = file("SmartRefreshLayout/java/refresh-header-two-level")
include(":srl-java-refresh-header")
project(":srl-java-refresh-header").projectDir = file("SmartRefreshLayout/java/refresh-header")

// SmartRefreshLayout in Kotlin (docs/Android-Port.md): the kernel first.
include(":srl-kernel")
project(":srl-kernel").projectDir = file("SmartRefreshLayout/refresh-layout-kernel")
include(":srl-drawable-paint")
project(":srl-drawable-paint").projectDir = file("SmartRefreshLayout/refresh-drawable-paint")
include(":srl-footer-classics")
project(":srl-footer-classics").projectDir = file("SmartRefreshLayout/refresh-footer-classics")
include(":srl-header-classics")
project(":srl-header-classics").projectDir = file("SmartRefreshLayout/refresh-header-classics")
include(":srl-header-material")
project(":srl-header-material").projectDir = file("SmartRefreshLayout/refresh-header-material")
include(":srl-header-two-level")
project(":srl-header-two-level").projectDir = file("SmartRefreshLayout/refresh-header-two-level")
include(":srl-footer-ball")
project(":srl-footer-ball").projectDir = file("SmartRefreshLayout/refresh-footer-ball")
include(":srl-header-radar")
project(":srl-header-radar").projectDir = file("SmartRefreshLayout/refresh-header-radar")
include(":srl-header-falsify")
project(":srl-header-falsify").projectDir = file("SmartRefreshLayout/refresh-header-falsify")
include(":srl-drawable-path")
project(":srl-drawable-path").projectDir = file("SmartRefreshLayout/refresh-drawable-path")
