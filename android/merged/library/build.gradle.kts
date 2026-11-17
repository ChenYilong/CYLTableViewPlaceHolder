// android/merged/library: CYLRefresh for Android, the only refresh kernel. The kernel (CYLRefreshLayout) and the
// headers, footers and drawables came from SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout,
// Apache-2.0, scwang90; LICENSE.SmartRefreshLayout.txt), translated to Kotlin and folded in under com.cyl.refresh.*
// (docs/Android-Port.md). It also brings the placeholder views, SVPullToRefresh and android-Ultra-Pull-To-Refresh.
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
    // AndroidX for the refresh kernel and the iOS-named refresh API.
    implementation(libs.androidx.appcompat)
    // MaterialHeader reads Material's progress colors when the app has Material (as SmartRefreshLayout did).
    compileOnly(libs.material)
    // Only for cyl_totalDataCount: an app that uses it has RecyclerView itself.
    compileOnly(libs.androidx.recyclerview)
    testImplementation(libs.androidx.recyclerview)
    testImplementation(libs.junit)
    testImplementation(libs.robolectric)
    testImplementation(libs.androidx.test.core)
}
