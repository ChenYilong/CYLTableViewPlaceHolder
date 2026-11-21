plugins {
    alias(libs.plugins.android.library) apply false
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.android) apply false
}

// [EN] Maven publication of the library modules (docs/Android-Port.md, "Maven publication coordinates"): group
//      io.github.chenyilong, as upstream CYLTabBarController's modules, version 0.1.0 (-PcylPlaceholderVersion overrides).
//      :placeholder publishes cyltableviewplaceholder, :merged (CYLRefresh) cyltableviewplaceholder-refresh. Each AAR
//      carries the MIT LICENSE in src/main/resources/META-INF/<module>/. Check with ./gradlew publishToMavenLocal.
// [CN] 库模块的 Maven 发布（docs/Android-Port.md “Maven publication coordinates”）：group 为 io.github.chenyilong（与上游
//      CYLTabBarController 的模块相同），版本 0.1.0（可用 -PcylPlaceholderVersion 覆盖）。:placeholder 发布为
//      cyltableviewplaceholder，:merged（CYLRefresh）发布为 cyltableviewplaceholder-refresh。每个 AAR 都在
//      src/main/resources/META-INF/<module>/ 中带有 MIT LICENSE。用 ./gradlew publishToMavenLocal 检查。
val cylPlaceholderGroup = "io.github.chenyilong"
val cylPlaceholderVersion: String = providers.gradleProperty("cylPlaceholderVersion").orNull ?: "0.1.0"
val cylPlaceholderArtifacts = mapOf(
    "placeholder" to Triple(
        "cyltableviewplaceholder",
        "CYLTableViewPlaceHolder",
        "Placeholder views for Android with the iOS names: CYLPlaceholderView, CYLPlaceholderStackView, the scenario catalog, the HUD and the status bar.",
    ),
    "merged" to Triple(
        "cyltableviewplaceholder-refresh",
        "CYLRefresh",
        "CYLRefresh for Android, the pull-to-refresh kernel of CYLTableViewPlaceHolder with its headers and footers, plus the placeholder views.",
    ),
)

subprojects {
    val artifact = cylPlaceholderArtifacts[name] ?: return@subprojects
    group = cylPlaceholderGroup
    version = cylPlaceholderVersion
    apply(plugin = "maven-publish")
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
            publishing {
                singleVariant("release") {
                    withSourcesJar()
                }
            }
        }
        // [EN] Registered after the Android plugin's own afterEvaluate, which creates the "release" component.
        // [CN] 在 Android 插件自己的 afterEvaluate（它创建 "release" 组件）之后注册。
        afterEvaluate { cylPublishRelease(artifact) }
    }
}

fun Project.cylPublishRelease(artifact: Triple<String, String, String>) {
    run {
        extensions.configure<PublishingExtension>("publishing") {
            publications {
                create<MavenPublication>("release") {
                    groupId = cylPlaceholderGroup
                    artifactId = artifact.first
                    version = cylPlaceholderVersion
                    from(components["release"])
                    pom {
                        name.set(artifact.second)
                        description.set(artifact.third)
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
}
