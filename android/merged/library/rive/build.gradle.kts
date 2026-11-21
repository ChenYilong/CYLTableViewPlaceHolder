import org.jetbrains.kotlin.gradle.dsl.JvmTarget

// The Rive refresh header of android/merged (iOS `RiveSwift/CYLRefreshRiveHeader.swift`): flutter_easy_refresh's Rive
// styles drawn by rive-android. Kept out of :merged so apps without Rive do not ship its native code.
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    `maven-publish`
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

// [EN] Maven publication (docs/Android-Port.md, "Maven publication coordinates"; decided 2026-11-22, docs/Task-Log.md
//      "Decide the :merged-rive publication"): the optional Rive refresh header, like the iOS `Rive` subspec, so apps
//      without Rive do not ship rive-android's native libraries. Versioned with the other two modules (0.1.0 unless
//      -PcylPlaceholderVersion is given). Check with ./gradlew publishToMavenLocal.
// [CN] Maven 发布（docs/Android-Port.md “Maven publication coordinates”；2026-11-22 决定，docs/Task-Log.md
//      “Decide the :merged-rive publication”）：可选的 Rive 刷新头部，与 iOS 的 `Rive` 子 spec 相同，不用 Rive 的应用
//      不带 rive-android 的原生库。版本与另外两个模块一致（默认 0.1.0，可用 -PcylPlaceholderVersion 指定）。
//      用 ./gradlew publishToMavenLocal 检查。
group = "io.github.chenyilong"
version = providers.gradleProperty("cylPlaceholderVersion").orNull ?: "0.1.0"

android {
    publishing {
        singleVariant("release") {
            withSourcesJar()
        }
    }
}

afterEvaluate {
    publishing {
        publications {
            create<MavenPublication>("release") {
                artifactId = "cyltableviewplaceholder-refresh-rive"
                from(components["release"])
                pom {
                    name.set("CYLRefresh Rive")
                    description.set("The Rive refresh header of CYLRefresh for Android (CYLRefreshRiveHeader, the iOS Rive subspec), drawn by rive-android.")
                    url.set("https://github.com/ChenYilong/CYLTableViewPlaceHolder")
                    licenses {
                        license {
                            name.set("MIT License")
                            url.set("https://github.com/ChenYilong/CYLTableViewPlaceHolder/blob/master/LICENSE")
                        }
                    }
                    developers {
                        developer {
                            id.set("ChenYilong")
                            name.set("ChenYilong")
                            url.set("https://github.com/ChenYilong")
                        }
                    }
                    scm {
                        url.set("https://github.com/ChenYilong/CYLTableViewPlaceHolder")
                        connection.set("scm:git:https://github.com/ChenYilong/CYLTableViewPlaceHolder.git")
                        developerConnection.set("scm:git:ssh://git@github.com/ChenYilong/CYLTableViewPlaceHolder.git")
                    }
                }
            }
        }
    }
}
