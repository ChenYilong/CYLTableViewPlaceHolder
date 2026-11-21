import org.jetbrains.kotlin.gradle.dsl.JvmTarget

// android/merged/library: CYLRefresh for Android, the only refresh kernel. The kernel (CYLRefreshLayout) and the
// headers, footers and drawables are third-party code (Apache-2.0, LICENSE.refresh-third-party.txt), translated to
// Kotlin and folded in under com.cyl.refresh.*
// (docs/Android-Port.md). It also brings the placeholder views.
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    `maven-publish`
}

android {
    namespace = "com.cyl.refresh.merged"
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

dependencies {
    // CYLTableViewPlaceHolder's placeholder views.
    api(project(":placeholder"))
    // AndroidX for the refresh kernel and the iOS-named refresh API.
    implementation(libs.androidx.appcompat)
    // MaterialHeader reads Material's progress colors when the app has Material (as CYLRefreshLayout did).
    compileOnly(libs.material)
    // Only for cyl_totalDataCount: an app that uses it has RecyclerView itself.
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

// [EN] Maven publication (docs/Android-Port.md, "Maven publication coordinates"), in this module's own build file so a
//      host that includes only this module (CYLSearchViewController's android/merged) gets the same coordinates.
//      Version 0.1.0 unless -PcylPlaceholderVersion is given. Check with ./gradlew publishToMavenLocal.
// [CN] Maven 发布（docs/Android-Port.md “Maven publication coordinates”），写在本模块自己的构建文件中，使只引入本模块的
//      宿主（CYLSearchViewController 的 android/merged）得到相同的坐标。版本默认 0.1.0，可用 -PcylPlaceholderVersion 指定。
//      用 ./gradlew publishToMavenLocal 检查。
group = "io.github.chenyilong"
version = providers.gradleProperty("cylPlaceholderVersion").orNull ?: "0.1.0"

android {
    publishing {
        singleVariant("release") {
            withSourcesJar()
        }
    }
}

afterEvaluate {
    publishing {
        publications {
            create<MavenPublication>("release") {
                artifactId = "cyltableviewplaceholder-refresh"
                from(components["release"])
                pom {
                    name.set("CYLRefresh")
                    description.set("CYLRefresh for Android, the pull-to-refresh kernel of CYLTableViewPlaceHolder with its headers and footers, plus the placeholder views.")
                    url.set("https://github.com/ChenYilong/CYLTableViewPlaceHolder")
                    licenses {
                        license {
                            name.set("MIT License")
                            url.set("https://github.com/ChenYilong/CYLTableViewPlaceHolder/blob/master/LICENSE")
                        }
                    }
                    developers {
                        developer {
                            id.set("ChenYilong")
                            name.set("ChenYilong")
                            url.set("https://github.com/ChenYilong")
                        }
                    }
                    scm {
                        url.set("https://github.com/ChenYilong/CYLTableViewPlaceHolder")
                        connection.set("scm:git:https://github.com/ChenYilong/CYLTableViewPlaceHolder.git")
                        developerConnection.set("scm:git:ssh://git@github.com/ChenYilong/CYLTableViewPlaceHolder.git")
                    }
                }
            }
        }
    }
}
