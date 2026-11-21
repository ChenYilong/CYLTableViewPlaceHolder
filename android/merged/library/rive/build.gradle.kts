import org.jetbrains.kotlin.gradle.dsl.JvmTarget

// The Rive refresh header of android/merged (iOS `RiveSwift/CYLRefreshRiveHeader.swift`): flutter_easy_refresh's Rive
// styles drawn by rive-android. Kept out of :merged so apps without Rive do not ship its native code.
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.cyl.refresh.rive"
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
    api(project(":merged"))
    api(libs.rive)
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
