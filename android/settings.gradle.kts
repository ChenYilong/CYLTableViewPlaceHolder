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
        // SVGAPlayer-Android (com.github.yyued), which the example's SVGA files need, is only on JitPack.
        maven("https://jitpack.io") { content { includeGroup("com.github.yyued") } }
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
