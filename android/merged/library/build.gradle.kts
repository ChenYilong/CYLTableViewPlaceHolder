// android/merged: one dependency for the whole Android port (docs/Android-Port.md, step 3). It brings together, with
// every public API kept as it is: the placeholder views, SVPullToRefresh, android-Ultra-Pull-To-Refresh and the Kotlin
// modules of SmartRefreshLayout. Each library keeps its package, its license and its tests in its own folder; this
// module only joins them, so no class is copied twice.
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.cyl.refresh.merged"
    compileSdk = 35

    defaultConfig {
        minSdk = 23
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    testOptions {
        unitTests.isIncludeAndroidResources = true
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }
}

dependencies {
    // CYLTableViewPlaceHolder's placeholder views.
    api(project(":placeholder"))
    // SVPullToRefresh (MIT, samvermette) in Kotlin.
    api(project(":SVPullToRefresh"))
    // android-Ultra-Pull-To-Refresh (MIT, liaohuqiu) in Kotlin.
    api(project(":android-Ultra-Pull-To-Refresh"))
    // SmartRefreshLayout (Apache-2.0, scwang90) in Kotlin: the kernel, every header and footer, and the drawables.
    api(project(":srl-kernel"))
    api(project(":srl-header-classics"))
    api(project(":srl-footer-classics"))
    api(project(":srl-header-material"))
    api(project(":srl-header-two-level"))
    api(project(":srl-header-radar"))
    api(project(":srl-header-falsify"))
    api(project(":srl-footer-ball"))
    api(project(":srl-drawable-path"))
    api(project(":srl-drawable-paint"))
    api(project(":srl-header"))
    // AndroidX for the iOS-named refresh API (SmartRefreshLayout's supertypes come from it).
    implementation(libs.androidx.appcompat)
    // Only for cyl_totalDataCount: an app that uses it has RecyclerView itself.
    compileOnly(libs.androidx.recyclerview)
    testImplementation(libs.androidx.recyclerview)
    testImplementation(libs.junit)
    testImplementation(libs.robolectric)
    testImplementation(libs.androidx.test.core)
}
