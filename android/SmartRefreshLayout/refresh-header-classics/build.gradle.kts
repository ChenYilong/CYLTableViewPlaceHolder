// SmartRefreshLayout refresh-header-classics (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, 224db48; by scwang90)
// translated from Java to Kotlin (docs/Android-Port.md). Package, class and field names and the JVM signatures stay.
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.scwang.smart.refresh.header.classics"
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
        freeCompilerArgs += "-Xjvm-default=all"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }
}

dependencies {
    api(project(":srl-footer-classics"))
    api(project(":srl-kernel"))
    implementation(libs.androidx.appcompat)
}
