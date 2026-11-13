// android-Ultra-Pull-To-Refresh (https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh, MIT, 46fdc86; by Huqiu
// Liao) translated from Java to Kotlin, with the open pull requests taken in docs/Android-Port.md. The package stays
// in.srain.cube.views.ptr, so layouts and code that use the Java library keep their class names.
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "in.srain.cube.views.ptr"
    compileSdk = 35

    defaultConfig {
        minSdk = 23
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
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
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.swiperefreshlayout)
    testImplementation(libs.junit)
    testImplementation(libs.robolectric)
    testImplementation(libs.androidx.test.core)
    testImplementation(libs.androidx.recyclerview)
    testImplementation(libs.material)
}
