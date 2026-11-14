package com.cyl.refresh.merged.example

import android.content.Context
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.cyl.tabbar.CYLPlusButton
import com.cyl.tabbar.CYLTabBarConfiguration
import com.cyl.tabbar.CYLTabBarController
import com.cyl.tabbar.CYLTabBarPageRegistry

/**
 * The merged example (docs/Android-Port.md, step 3): CYLTabBarController's Android tab bar, made from the example's own
 * configuration file (`assets/cyl_tabbar_configuration.json`, tab titles translated through `assets/Localization`),
 * with one tab per library of `android/merged` and a raised plus button that has its own page.
 */
class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ExamplePages.registerOnce()
        CYLPlusButton.registerPlusButton(ExamplePlusButton.Provider)
        val controller = CYLTabBarController.tabBarControllerWithConfigurationFile(this, "cyl_tabbar_configuration.json")
        setContentView(controller.view)
    }
}

/**
 * The example's pages, registered by the page IDs of its configuration file, and the icons of its "system:…" names.
 */
object ExamplePages {
    private var registered = false

    /**
     * The SF Symbol names of the configuration file mapped to the platform's drawables.
     */
    private val icons = mapOf(
        "tray" to android.R.drawable.ic_menu_agenda,
        "arrow" to android.R.drawable.ic_menu_rotate,
        "sparkles" to android.R.drawable.btn_star,
    )

    /**
     * Registers the pages and the icon names once.
     */
    @Synchronized
    fun registerOnce() {
        if (registered) return
        registered = true
        CYLTabBarConfiguration.imageResolver = CYLTabBarConfiguration.CYLTabBarImageResolver { context: Context, name: String ->
            val symbol = name.removePrefix("system:").substringBefore('.')
            ContextCompat.getDrawable(context, icons[symbol] ?: android.R.drawable.ic_menu_help)
        }
        val registry = CYLTabBarPageRegistry.sharedRegistry
        registry.registerPageProvider({ _, _ -> PlaceholderPage() }, listOf("placeholder"))
        registry.registerPageProvider({ _, _ -> SVPullToRefreshPage() }, listOf("svpulltorefresh"))
        registry.registerPageProvider({ _, _ -> UltraPullToRefreshPage() }, listOf("ultraptr"))
        registry.registerPageProvider({ _, _ -> SmartRefreshPage() }, listOf("smartrefresh"))
    }
}
