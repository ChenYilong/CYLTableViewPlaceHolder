// SmartRefreshLayout refresh-header (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, 224db48), Java source copied
// unchanged except the manifest's package attribute (now the namespace below); fixes are recorded in docs/Android-Port.md.
plugins {
    alias(libs.plugins.android.library)
    // Only for the shared Kotlin standard library version (the code is Java).
    alias(libs.plugins.kotlin.android)
}

// -PsrlKernel=kotlin (below) also swaps this module's own headers for the Kotlin module :srl-header.
val srlKotlin = project.findProperty("srlKernel") == "kotlin"

android {
    // In Kotlin mode the headers and their resources come from :srl-header, which owns this namespace's R class.
    namespace = if (srlKotlin) "com.scwang.smart.refresh.header.javatests" else "com.scwang.smart.refresh.header"
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

    if (srlKotlin) {
        sourceSets.getByName("main") {
            java.setSrcDirs(emptyList<String>())
            res.setSrcDirs(emptyList<String>())
        }
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

// -PsrlKernel=kotlin runs this module's tests on the Kotlin translation: every Java module is swapped for its Kotlin
// module, and this module's own headers for :srl-header. The same tests check both versions.
if (srlKotlin) {
    dependencies {
        api(project(":srl-header"))
    }
    configurations.all {
        resolutionStrategy.dependencySubstitution {
            substitute(project(":srl-java-refresh-layout-kernel")).using(project(":srl-kernel"))
            substitute(project(":srl-java-refresh-drawable-paint")).using(project(":srl-drawable-paint"))
            substitute(project(":srl-java-refresh-footer-classics")).using(project(":srl-footer-classics"))
            substitute(project(":srl-java-refresh-header-classics")).using(project(":srl-header-classics"))
            substitute(project(":srl-java-refresh-header-material")).using(project(":srl-header-material"))
            substitute(project(":srl-java-refresh-header-two-level")).using(project(":srl-header-two-level"))
            substitute(project(":srl-java-refresh-drawable-path")).using(project(":srl-drawable-path"))
            substitute(project(":srl-java-refresh-header-falsify")).using(project(":srl-header-falsify"))
            substitute(project(":srl-java-refresh-header-radar")).using(project(":srl-header-radar"))
            substitute(project(":srl-java-refresh-footer-ball")).using(project(":srl-footer-ball"))
        }
    }
}
