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
// The Lottie animator of the placeholder (iOS subspec CYLPlaceholderAnimation/Lottie).
include(":placeholder-lottie")
// The PAG animator of the placeholder (iOS subspec CYLPlaceholderAnimation/PAG).
include(":placeholder-pag")
// The Rive animator of the placeholder (iOS subspec CYLPlaceholderAnimation/Rive).
include(":placeholder-rive")
// SVPullToRefresh in Kotlin (docs/Android-Port.md, the refresh port).
include(":SVPullToRefresh")
// android-Ultra-Pull-To-Refresh in Kotlin (docs/Android-Port.md, the refresh port).
include(":android-Ultra-Pull-To-Refresh")

// android/merged (docs/Android-Port.md, step 3): CYLRefresh, the only refresh kernel (SmartRefreshLayout folded in),
// with the placeholder and the two other Kotlin ports, and one example app with CYLTabBarController's Android tab bar, one tab per library.
include(":merged")
project(":merged").projectDir = file("merged/library")
// The Rive refresh header (iOS CYLRefresh/Custom/Rive/CYLRefreshRiveHeader.swift): inside the CYLRefresh library folder,
// a module of its own because it needs the Rive runtime (as the iOS Rive subspec); its Gradle path stays :merged-rive.
include(":merged-rive")
project(":merged-rive").projectDir = file("merged/library/rive")
include(":merged-example")
project(":merged-example").projectDir = file("merged/example")

// CYLTabBarController for Android, built from source (a Gradle composite build): its repository has no Gradle build at
// the root, so a JitPack commit reference cannot build it. The default is the vault's checkout next to this
// repository; -PcylTabBarDir=<…/CYLTabBarController/Example-Android> points to a clone at the latest commit
// (scripts/resolve-cyltabbarcontroller-commit.sh in the repository root finds it).
val cylTabBarDir = providers.gradleProperty("cylTabBarDir").orNull ?: "../../CYLTabBarController/Example-Android"
if (file(cylTabBarDir).resolve("settings.gradle.kts").exists()) {
    includeBuild(cylTabBarDir) {
        dependencySubstitution {
            substitute(module("io.github.chenyilong:cyltabbar")).using(project(":cyltabbar"))
        }
    }
}
