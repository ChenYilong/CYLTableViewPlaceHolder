plugins {
    alias(libs.plugins.android.library) apply false
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.kotlin.android) apply false
}

// CYLDeallocBlockExecutor (JitPack, a dependency of CYLTabBarController's animateditem and cyltabbar modules) at the commit
// the owner named, 43f94ad: the commit CYLTabBarController pins (6aef46d9) is not built on JitPack, so its coordinates did not
// resolve in CI. Gradle applies this to the whole graph a project here resolves, including the included build's modules.
subprojects {
    configurations.configureEach {
        resolutionStrategy.eachDependency {
            if (requested.group == "com.github.ChenYilong.CYLDeallocBlockExecutor") useVersion("43f94ad")
        }
    }
}
