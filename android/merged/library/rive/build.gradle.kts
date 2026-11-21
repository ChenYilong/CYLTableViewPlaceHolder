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

// [EN] This module has no unit tests yet (the Rive header needs the native runtime, checked on an emulator); Gradle 9
//      fails a test task that finds none, so a project-wide testDebugUnitTest would stop here.
// [CN] 本模块暂无单元测试（Rive 头部需要原生运行时，在模拟器上检查）；Gradle 9 会让找不到测试的测试任务失败，
//      全项目的 testDebugUnitTest 会停在这里。
tasks.withType<Test>().configureEach {
    failOnNoDiscoveredTests.set(false)
}
