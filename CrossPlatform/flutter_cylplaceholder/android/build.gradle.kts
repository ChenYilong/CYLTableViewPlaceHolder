group = "com.cyl.placeholder.flutter_cylplaceholder"
version = "0.0.1"

buildscript {
    val kotlinVersion = "2.4.0"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:9.1.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // [EN] CYLDeallocBlockExecutor (a dependency of CYLTabBarController's animated item) is only on JitPack. [CN] CYLDeallocBlockExecutor（CYLTabBarController 动画条目的依赖）只在 JitPack 上。
        maven("https://jitpack.io") {
            content { includeGroupByRegex("com\\.github\\.ChenYilong(\\..+)?") }
        }
    }
}

plugins {
    id("com.android.library")
}

android {
    namespace = "com.cyl.placeholder.flutter_cylplaceholder"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // [EN] The native placeholder views, stack and HUD this plugin hosts (android/placeholder of this repository, published as
    //      io.github.chenyilong:cyltableviewplaceholder). Inside this repository an example builds it from source: the
    //      example's android/settings.gradle.kts includes the repository's android build, which substitutes this coordinate.
    // [CN] 本插件承载的原生占位图、堆叠与 HUD（本仓库的 android/placeholder，发布为 io.github.chenyilong:cyltableviewplaceholder）。
    //      在本仓库内，示例从源码构建它：示例的 android/settings.gradle.kts 引入本仓库的 android 构建，由它替换这个坐标。
    implementation("io.github.chenyilong:cyltableviewplaceholder:${findProperty("cylPlaceholderVersion") ?: "0.1.0"}")
}
