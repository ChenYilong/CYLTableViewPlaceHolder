// SmartRefreshLayout refresh-header (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, 224db48), Java source copied
// unchanged except the manifest's package attribute (now the namespace below); fixes are recorded in docs/Android-Port.md.
plugins {
    alias(libs.plugins.android.library)
    // Only for the shared Kotlin standard library version (the code is Java).
    alias(libs.plugins.kotlin.android)
}

android {
    namespace = "com.scwang.smart.refresh.header"
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

    lint {
        abortOnError = false
    }

    testOptions {
        unitTests.isIncludeAndroidResources = true
    }
}

dependencies {
    // refresh-layout in the source only bundles these modules.
    api(project(":srl-java-refresh-footer-ball"))
    api(project(":srl-java-refresh-header-falsify"))
    api(project(":srl-java-refresh-header-radar"))
    api(project(":srl-java-refresh-header-two-level"))
    api(project(":srl-java-refresh-drawable-path"))
    api(project(":srl-java-refresh-header-material"))
    api(project(":srl-java-refresh-layout-kernel"))
    implementation(libs.androidx.appcompat)
    compileOnly(libs.material)
    testImplementation(libs.junit)
    testImplementation(libs.robolectric)
    testImplementation(libs.androidx.test.core)
    testImplementation(libs.material)
}

// -PsrlKernel=kotlin runs this module's tests (and its remaining Java headers and footers) on the modules already
// translated to Kotlin (the kernel, the paint drawables, the classics header and footer): the same tests check them.
if (project.findProperty("srlKernel") == "kotlin") {
    configurations.all {
        resolutionStrategy.dependencySubstitution {
            substitute(project(":srl-java-refresh-layout-kernel")).using(project(":srl-kernel"))
            substitute(project(":srl-java-refresh-drawable-paint")).using(project(":srl-drawable-paint"))
            substitute(project(":srl-java-refresh-footer-classics")).using(project(":srl-footer-classics"))
            substitute(project(":srl-java-refresh-header-classics")).using(project(":srl-header-classics"))
        }
    }
}
