import org.jetbrains.kotlin.gradle.dsl.JvmTarget

// android/merged/library: CYLRefresh for Android, the only refresh kernel. The kernel (CYLRefreshLayout) and the
// headers, footers and drawables are third-party code (Apache-2.0, LICENSE.refresh-third-party.txt), translated to
// Kotlin and folded in under com.cyl.refresh.*
// (docs/Android-Port.md). It also brings the placeholder views.
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
    // AndroidX for the refresh kernel and the iOS-named refresh API.
    implementation(libs.androidx.appcompat)
    // MaterialHeader reads Material's progress colors when the app has Material (as CYLRefreshLayout did).
    compileOnly(libs.material)
    // Only for cyl_totalDataCount: an app that uses it has RecyclerView itself.
    compileOnly(libs.androidx.recyclerview)
    testImplementation(libs.androidx.recyclerview)
    testImplementation(libs.junit)
    testImplementation(libs.robolectric)
    testImplementation(libs.androidx.test.core)
}

// [EN] Kotlin compiler options at the top level: kotlinOptions {} inside android {} is deprecated and fails on Gradle 10.
kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}
