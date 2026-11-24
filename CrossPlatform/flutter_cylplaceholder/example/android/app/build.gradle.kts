plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.cyl.placeholder.flutter_cylplaceholder_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.cyl.placeholder.flutter_cylplaceholder_example"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // [EN] The native placeholder's animation engine reaches Lottie by reflection (the app brings the library it wants to play), so
    //      the stack's CYLPlaceholderLoadFailed.json animates instead of showing its still image.
    // [CN] 原生占位图的动画引擎通过反射调用 Lottie（由 App 自带要播放的库），堆叠里的 CYLPlaceholderLoadFailed.json 才会播放而不是只显示静态图。
    implementation("com.airbnb.android:lottie:6.6.2")
    // [EN] The optional Rive refresh header (module :merged-rive, with rive-android): the Styles page's Rive chip is classic with one log line without it.
    //      Publish it first: android/ `./gradlew :merged-rive:publishToMavenLocal`.
    // [CN] 可选的 Rive 刷新头部（模块 :merged-rive，带 rive-android）：没有它时，样式页的 Rive 标签是经典样式并记录一行日志。先发布：android/ `./gradlew :merged-rive:publishToMavenLocal`。
    implementation("io.github.chenyilong:cyltableviewplaceholder-refresh-rive:${findProperty("cylPlaceholderVersion") ?: "0.1.0"}")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
