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

    kotlinOptions {
        jvmTarget = "17"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }
}

dependencies {
    implementation(project(":merged"))
    implementation("io.github.chenyilong:cyltabbar")
    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.recyclerview)
}
