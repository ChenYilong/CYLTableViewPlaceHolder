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
// The placeholder core. Its icon + title view, CYLPlaceholderView, subclasses CYLTabBarController's CYLAnimatedItemView
// (module :cylanimateditem, Maven `io.github.chenyilong:cyltabbarcontroller-animateditem`), whose animation engine
// reaches Lottie, libpag and rive-android by reflection: the core depends on no animation library, and animated icons
// show only in an app that adds one (docs/Animated-Item.md of CYLTabBarController). The former animator modules
// placeholder-lottie, placeholder-pag and placeholder-rive are gone.
include(":placeholder")

// android/merged (docs/Android-Port.md, step 3): CYLRefresh, the only refresh kernel (SmartRefreshLayout folded in),
// with the placeholder, and one example app with CYLTabBarController's Android tab bar, one tab per library.
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
// (scripts/resolve-cyltabbarcontroller-commit.sh in the repository root finds it). It brings two modules:
// - `io.github.chenyilong:cyltabbar` (the tab bar of the example app);
// - `io.github.chenyilong:cyltabbarcontroller-animateditem` (CYLAnimatedItemView and the animation engine), which the
//   core module :placeholder depends on, so every build needs the checkout.
val cylTabBarDir = providers.gradleProperty("cylTabBarDir").orNull ?: "../../CYLTabBarController/Example-Android"
if (!file(cylTabBarDir).resolve("settings.gradle.kts").exists()) {
    throw GradleException(
        "CYLTabBarController's Example-Android was not found at '$cylTabBarDir'. The placeholder core depends on its " +
            "module :cylanimateditem (io.github.chenyilong:cyltabbarcontroller-animateditem). Clone " +
            "https://github.com/ChenYilong/CYLTabBarController at the commit printed by " +
            "scripts/resolve-cyltabbarcontroller-commit.sh and pass -PcylTabBarDir=<clone>/Example-Android.",
    )
}
includeBuild(cylTabBarDir) {
    dependencySubstitution {
        substitute(module("io.github.chenyilong:cyltabbar")).using(project(":cyltabbar"))
        substitute(module("io.github.chenyilong:cyltabbarcontroller-animateditem")).using(project(":cylanimateditem"))
    }
}
