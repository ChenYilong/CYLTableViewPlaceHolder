// SmartRefreshLayout's kernel (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, 224db48; by scwang90)
// translated from Java to Kotlin, with the pull requests and issue fixes of the Java copy in java/refresh-layout-kernel
// (docs/Android-Port.md). Package and class names stay, and the JVM signatures match the Java version, so headers and
// footers written in Java (and the Java modules in java/) work with it unchanged.
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.scwang.smart.refresh.layout.kernel"
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
        // Interface default methods are real JVM default methods, so Java components implement them as before.
        freeCompilerArgs += "-Xjvm-default=all"
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
    }
}

dependencies {
    implementation(libs.androidx.appcompat)
    compileOnly(libs.material)
}
