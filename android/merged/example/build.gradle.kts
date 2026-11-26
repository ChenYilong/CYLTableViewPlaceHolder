import org.jetbrains.kotlin.gradle.dsl.JvmTarget

// The merged example (docs/Android-Port.md, step 3): one app, one tab per library, on CYLTabBarController's Android
// tab bar (built from source, see settings.gradle.kts), with a raised plus button that has its own page.
plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.cyl.refresh.merged.example"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.cyl.refresh.merged.example"
        minSdk = 23
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    testOptions {
        unitTests.isIncludeAndroidResources = true
    }
}

dependencies {
    implementation(project(":merged"))
    // The animation libraries of the animated-icon examples (example32, example51–56). The core depends on none: the
    // CYLAnimatedItem engine of CYLTabBarController (under CYLPlaceholderView) finds Lottie, libpag and rive-android by
    // reflection once the app adds them, and shows the static image otherwise. GIF needs no library.
    implementation(libs.lottie)
    implementation(libs.libpag)
    implementation(libs.rive)
    // SVGAPlayer-Android: the engine finds it by reflection and plays the .svga files of assets/Animations.
    implementation(libs.svgaplayer)
    // The Rive refresh styles of the CYLRefresh section.
    implementation(project(":merged-rive"))
    implementation("io.github.chenyilong:cyltabbar")
    // CollectionViewClassifyMenu's tag list, the example's menu and index screens (only the example, never the core).
    implementation(project(":classifymenu"))
    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.recyclerview)
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
