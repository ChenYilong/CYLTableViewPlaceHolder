// The Android version of CYLTableViewPlaceHolder (docs/Android-Port.md). Module `placeholder`: the placeholder views
// (CYLPlaceholderStackView, CYLPlaceholderScenario), used by CYLSearchViewController's android/merged as a
// sub-repository, pinned by commit.
pluginManagement {
    repositories {
        google()
        // Google's mirror of Maven Central first: the shared GitHub runner address is sometimes refused by repo1.maven.org
        // and plugins.gradle.org (run 45278544433: the Kotlin plugin could not be resolved); the mirror serves the same files.
        maven("https://maven-central.storage-download.googleapis.com/maven2")
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        maven("https://maven-central.storage-download.googleapis.com/maven2")
        mavenCentral()
        // SVGAPlayer-Android (com.github.yyued), which the example's SVGA files need, is only on JitPack; so is
        // CYLDeallocBlockExecutor (com.github.ChenYilong, or com.github.ChenYilong.CYLDeallocBlockExecutor for its multi-module
        // coordinates), a dependency of CYLTabBarController's animateditem and cyltabbar modules.
        maven("https://jitpack.io") {
            content {
                includeGroup("com.github.yyued")
                includeGroupByRegex("com\\.github\\.ChenYilong(\\..+)?")
            }
        }
    }
}
rootProject.name = "CYLTableViewPlaceHolderAndroid"
// The placeholder core. Its icon + title view, CYLPlaceholderView, subclasses CYLTabBarController's CYLAnimatedItemView
// (module :cylanimateditem, Maven `io.github.chenyilong:cyltabbarcontroller-animateditem`), whose animation engine
// reaches Lottie, libpag and rive-android by reflection: the core depends on no animation library, and animated icons
// show only in an app that adds one (docs/Animated-Item.md of CYLTabBarController). The former animator modules
// placeholder-lottie, placeholder-pag and placeholder-rive are gone.
include(":placeholder")

// android/merged (docs/Android-Port.md, step 3): CYLRefresh, the only refresh kernel (CYLRefreshLayout folded in),
// with the placeholder, and one example app with CYLTabBarController's Android tab bar, one tab per library.
include(":merged")
project(":merged").projectDir = file("merged/library")
// The Rive refresh header (iOS CYLRefresh/Custom/Rive/CYLRefreshRiveHeader.swift): inside the CYLRefresh library folder,
// a module of its own because it needs the Rive runtime (as the iOS Rive subspec); its Gradle path stays :merged-rive.
include(":merged-rive")
project(":merged-rive").projectDir = file("merged/library/rive")
include(":merged-example")
project(":merged-example").projectDir = file("merged/example")

// CollectionViewClassifyMenu's Android module (its tag list: the example's menu and index screens), at the commit pinned in
// classifymenu.commit (commit c0b183de of its feat/glass-backdrop branch, never a branch or a version). Only :merged-example uses it; the core modules
// :placeholder and :merged do not. Where it comes from, first match wins:
// 1. -PcylClassifyMenuDir=<a CollectionViewClassifyMenu checkout> (CI passes a clone of the pinned commit);
// 2. otherwise scripts/classifymenu-checkout.sh checks the pinned commit out into android/.classifymenu.
// Its own dependency, io.github.chenyilong:cyltabbarcontroller-animateditem, resolves through the CYLTabBarController
// composite below.
val cylClassifyMenuDir: String = providers.gradleProperty("cylClassifyMenuDir").orNull ?: run {
    val repository = rootDir.parentFile
    val script = repository.resolve("scripts/classifymenu-checkout.sh")
    val process = ProcessBuilder("bash", script.path).directory(repository).redirectErrorStream(false).start()
    val output = process.inputStream.bufferedReader().readText().trim()
    val error = process.errorStream.bufferedReader().readText().trim()
    if (process.waitFor() != 0) {
        throw GradleException("scripts/classifymenu-checkout.sh failed: $error")
    }
    output.lines().last()
}
if (!file(cylClassifyMenuDir).resolve("android/merged/library/build.gradle.kts").exists()) {
    throw GradleException(
        "CollectionViewClassifyMenu's android/merged/library was not found at '$cylClassifyMenuDir'. Pass " +
            "-PcylClassifyMenuDir=<clone>, or run scripts/classifymenu-checkout.sh in the repository root.",
    )
}
include(":classifymenu")
project(":classifymenu").projectDir = file(cylClassifyMenuDir).resolve("android/merged/library")

// CYLTabBarController for Android, built from source (a Gradle composite build) at a commit, since its modules are not
// on Maven Central yet and its repository has no Gradle build at the root, so a JitPack commit reference cannot build
// it. It brings two modules:
// - `io.github.chenyilong:cyltabbar` (the tab bar of the example app);
// - `io.github.chenyilong:cyltabbarcontroller-animateditem` (CYLAnimatedItemView and the animation engine), which the
//   core module :placeholder depends on, so every build needs the checkout.
// Where it comes from, first match wins:
// 1. -PcylTabBarDir=<…/CYLTabBarController/Example-Android> (CI passes a clone of the newest commit);
// 2. ../Carthage/Checkouts/CYLTabBarController, the commit the repository's Cartfile pins (the same checkout iOS uses);
// 3. the vault's checkout next to this repository, ../../CYLTabBarController;
// 4. otherwise scripts/cyltabbarcontroller-checkout.sh checks out the Cartfile's commit into (2), so a fresh clone
//    builds without any manual step.
fun cylTabBarExampleAndroid(root: File): File = root.resolve("Example-Android")
val cylTabBarDir: String = providers.gradleProperty("cylTabBarDir").orNull ?: run {
    val repository = rootDir.parentFile
    val candidates = listOf(
        cylTabBarExampleAndroid(repository.resolve("Carthage/Checkouts/CYLTabBarController")),
        cylTabBarExampleAndroid(repository.resolve("../CYLTabBarController")),
    )
    candidates.firstOrNull { it.resolve("settings.gradle.kts").exists() }?.path ?: run {
        val script = repository.resolve("scripts/cyltabbarcontroller-checkout.sh")
        val process = ProcessBuilder("bash", script.path).directory(repository).redirectErrorStream(false).start()
        val output = process.inputStream.bufferedReader().readText().trim()
        val error = process.errorStream.bufferedReader().readText().trim()
        if (process.waitFor() != 0) {
            throw GradleException("scripts/cyltabbarcontroller-checkout.sh failed: $error")
        }
        cylTabBarExampleAndroid(File(output.lines().last())).path
    }
}
if (!file(cylTabBarDir).resolve("settings.gradle.kts").exists()) {
    throw GradleException(
        "CYLTabBarController's Example-Android was not found at '$cylTabBarDir'. The placeholder core depends on its " +
            "module :cylanimateditem (io.github.chenyilong:cyltabbarcontroller-animateditem). Pass " +
            "-PcylTabBarDir=<clone>/Example-Android, or run scripts/cyltabbarcontroller-checkout.sh in the repository root.",
    )
}
includeBuild(cylTabBarDir) {
    dependencySubstitution {
        substitute(module("io.github.chenyilong:cyltabbar")).using(project(":cyltabbar"))
        substitute(module("io.github.chenyilong:cyltabbarcontroller-animateditem")).using(project(":cylanimateditem"))
    }
}
