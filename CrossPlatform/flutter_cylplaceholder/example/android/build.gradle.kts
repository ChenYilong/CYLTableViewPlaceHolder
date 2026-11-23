allprojects {
    repositories {
        google()
        mavenCentral()
        // [EN] The native placeholder (io.github.chenyilong:cyltableviewplaceholder) and CYLTabBarController's animated item
        //      are published to the local Maven repository first: scripts/publish-android-native-to-maven-local.sh.
        // [CN] 原生占位图与 CYLTabBarController 的动画条目先发布到本地 Maven 仓库：scripts/publish-android-native-to-maven-local.sh。
        mavenLocal()
        // CYLDeallocBlockExecutor (a dependency of CYLTabBarController's animated item, which the native placeholder uses) is only on JitPack.
        maven("https://jitpack.io") { content { includeGroupByRegex("com\\.github\\.ChenYilong(\\..+)?") } }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// CYLDeallocBlockExecutor at the commit the owner named, 43f94ad, as in the repository's android/build.gradle.kts: the commit
// CYLTabBarController pins is not built on JitPack.
allprojects {
    configurations.configureEach {
        resolutionStrategy.eachDependency {
            if (requested.group == "com.github.ChenYilong.CYLDeallocBlockExecutor") useVersion("43f94ad")
        }
    }
}
