import org.jetbrains.kotlin.gradle.dsl.JvmTarget

// The placeholder views of CYLTableViewPlaceHolder on Android (Kotlin), with the iOS names; images and strings are
// imported from CYLTableViewPlaceHolder.bundle by ../scripts/import-ios-resources.py. No animation library: animated
// icons come from CYLTabBarController's CYLAnimatedItem engine once the app adds Lottie, libpag or rive-android.
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.cyl.placeholder"
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

val cylAnimatedItemVersion: String = gradle.includedBuilds
    .firstOrNull { it.projectDir.resolve("../CYLTabBarController.podspec").exists() }
    ?.let { Regex("""s\.version\s*=\s*["']([^"']+)["']""").find(it.projectDir.resolve("../CYLTabBarController.podspec").readText())?.groupValues?.get(1) }
    ?: throw GradleException("The CYLTabBarController checkout (included build) has no CYLTabBarController.podspec with s.version.")

dependencies {
    // CYLPlaceholderView subclasses CYLAnimatedItemView, CYLTabBarController's animated icon + title view, and plays its
    // animations through that module's engine (docs/Animated-Item.md of CYLTabBarController). Built from source by
    // commit: settings.gradle.kts substitutes the coordinate with the included build's :cylanimateditem. The engine
    // reaches Lottie, libpag and rive-android by reflection, so this module depends on no animation library: the app
    // adds the libraries it wants to animate, otherwise the static image shows.
    // [EN] The version is the one of the CYLTabBarController checkout that is built (its podspec's s.version, the same
    //      version its Gradle build publishes), so the published POM names a versioned dependency.
    // [CN] 版本取自所构建的 CYLTabBarController 副本（其 podspec 的 s.version，即其 Gradle 构建发布的版本），使发布的 POM
    //      中的依赖带有版本。
    api("io.github.chenyilong:cyltabbarcontroller-animateditem:$cylAnimatedItemVersion")
    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.core.ktx)
    // Only for the RecyclerView extensions (cyl_placeholderViewBlock, cyl_reloadData): an app that uses them has
    // RecyclerView itself.
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
