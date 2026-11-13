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
