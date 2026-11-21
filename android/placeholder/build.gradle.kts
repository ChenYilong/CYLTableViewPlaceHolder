import org.jetbrains.kotlin.gradle.dsl.JvmTarget

// The placeholder views of CYLTableViewPlaceHolder on Android (Kotlin), with the iOS names; images and strings are
// imported from CYLTableViewPlaceHolder.bundle by ../scripts/import-ios-resources.py. No animation library: animated
// icons come from CYLTabBarController's CYLAnimatedItem engine once the app adds Lottie, libpag or rive-android.
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    `maven-publish`
}

android {
    namespace = "com.cyl.placeholder"
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

// [EN] The version of CYLTabBarController's CYLAnimatedItem module, for the published POM: -PcylAnimatedItemVersion, else
//      the podspec s.version of the CYLTabBarController checkout that is built, found as an included build (this
//      repository's settings.gradle.kts) or as a :cylanimateditem subproject (CYLSearchViewController's android/merged
//      includes it that way). When none is found the dependency stays unversioned (the build substitutes it anyway).
// [CN] CYLTabBarController 的 CYLAnimatedItem 模块版本（用于发布的 POM）：-PcylAnimatedItemVersion，否则取所构建的
//      CYLTabBarController 副本 podspec 的 s.version；副本以 included build（本仓库的 settings.gradle.kts）或
//      :cylanimateditem 子项目（CYLSearchViewController 的 android/merged 如此引入）的形式找到。都找不到时依赖不带版本
//      （构建仍会替换它）。
val cylAnimatedItemVersion: String? = providers.gradleProperty("cylAnimatedItemVersion").orNull ?: run {
    val podspecs = gradle.includedBuilds.map { it.projectDir.resolve("../CYLTabBarController.podspec") } +
        listOfNotNull(rootProject.findProject(":cylanimateditem")?.projectDir?.resolve("../../CYLTabBarController.podspec"))
    podspecs.firstOrNull { it.exists() }?.let {
        Regex("""s\.version\s*=\s*["']([^"']+)["']""").find(it.readText())?.groupValues?.get(1)
    }
}

dependencies {
    // CYLPlaceholderView subclasses CYLAnimatedItemView, CYLTabBarController's animated icon + title view, and plays its
    // animations through that module's engine (docs/Animated-Item.md of CYLTabBarController). Built from source by
    // commit: settings.gradle.kts substitutes the coordinate with the included build's :cylanimateditem. The engine
    // reaches Lottie, libpag and rive-android by reflection, so this module depends on no animation library: the app
    // adds the libraries it wants to animate, otherwise the static image shows.
    // [EN] The version is the one of the CYLTabBarController checkout that is built (its podspec's s.version, the same
    //      version its Gradle build publishes), so the published POM names a versioned dependency.
    // [CN] 版本取自所构建的 CYLTabBarController 副本（其 podspec 的 s.version，即其 Gradle 构建发布的版本），使发布的 POM
    //      中的依赖带有版本。
    api("io.github.chenyilong:cyltabbarcontroller-animateditem" + (cylAnimatedItemVersion?.let { ":$it" } ?: ""))
    implementation(libs.androidx.appcompat)
    implementation(libs.androidx.core.ktx)
    // Only for the RecyclerView extensions (cyl_placeholderViewBlock, cyl_reloadData): an app that uses them has
    // RecyclerView itself.
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
                artifactId = "cyltableviewplaceholder"
                from(components["release"])
                pom {
                    name.set("CYLTableViewPlaceHolder")
                    description.set("Placeholder views for Android with the iOS names: CYLPlaceholderView, CYLPlaceholderStackView, the scenario catalog, the HUD and the status bar.")
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
