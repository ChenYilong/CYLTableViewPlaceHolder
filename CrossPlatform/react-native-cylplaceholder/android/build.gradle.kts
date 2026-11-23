buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:9.1.1")
    }
}

apply(plugin = "com.android.library")

repositories {
    mavenLocal()
    google()
    mavenCentral()
    // [EN] CYLDeallocBlockExecutor (a dependency of CYLTabBarController's animated item) is only on JitPack. [CN] 只在 JitPack 上。
    maven("https://jitpack.io") {
        content { includeGroupByRegex("com\\.github\\.ChenYilong(\\..+)?") }
    }
}

configure<com.android.build.api.dsl.LibraryExtension> {
    namespace = "com.cyl.placeholder.reactnative"
    compileSdk = 36
    defaultConfig { minSdk = 24 }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    testOptions { unitTests.isIncludeAndroidResources = true }
}


dependencies {
    // [EN] The refresh kernel and its headers (android/merged of this repository, published as
    //      io.github.chenyilong:cyltableviewplaceholder-refresh; scripts/publish-android-native-to-maven-local.sh).
    // [CN] 刷新内核与各种头部（本仓库的 android/merged，发布为 io.github.chenyilong:cyltableviewplaceholder-refresh）。
    add("api", "io.github.chenyilong:cyltableviewplaceholder-refresh:${findProperty("cylPlaceholderVersion") ?: "0.1.0"}")
    // The host app provides React Native.
    add("compileOnly", "com.facebook.react:react-android:${findProperty("reactNativeVersion") ?: "0.76.9"}")
    add("testImplementation", "androidx.core:core:1.13.1")
    add("testImplementation", "androidx.appcompat:appcompat:1.6.1")
    add("testImplementation", "androidx.recyclerview:recyclerview:1.3.2")
    add("testImplementation", "junit:junit:4.13.2")
    add("testImplementation", "org.robolectric:robolectric:4.14.1")
    add("testImplementation", "androidx.test:core:1.6.1")
}
