package com.cyl.refresh.merged.example

import android.content.Context
import android.content.res.Configuration
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.core.view.WindowCompat
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
        // Android 15 draws the app edge to edge: the status bar area shows the light window background, while the
        // DarkActionBar theme asks for light status bar icons (white on white, nearly invisible). Dark icons in the
        // light theme, light icons in the dark one.
        val night = (resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
        WindowCompat.getInsetsController(window, window.decorView).isAppearanceLightStatusBars = !night
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
        "rectangle" to android.R.drawable.ic_menu_agenda,
        "arrow.triangle" to android.R.drawable.ic_menu_share,
        "arrow" to android.R.drawable.ic_menu_rotate,
        "sparkles" to android.R.drawable.btn_star,
        "bubble" to android.R.drawable.ic_menu_send,
    )

    /**
     * Registers the pages and the icon names once.
     */
    @Synchronized
    fun registerOnce() {
        if (registered) return
        registered = true
        CYLTabBarConfiguration.imageResolver = CYLTabBarConfiguration.CYLTabBarImageResolver { context: Context, name: String ->
            val symbol = name.removePrefix("system:")
            val drawable = icons[symbol.split('.').take(2).joinToString(".")] ?: icons[symbol.substringBefore('.')]
            ContextCompat.getDrawable(context, drawable ?: android.R.drawable.ic_menu_help)
        }
        val registry = CYLTabBarPageRegistry.sharedRegistry
        registry.registerPageProvider({ _, _ -> ScenariosPage() }, listOf("placeholder"))
        registry.registerPageProvider({ _, _ -> AnimationsPage() }, listOf("animations"))
        // The iOS example's Flows tab; the former Load more and StoreHouse tabs are in the Refresh tab's examples and
        // the refresh styles page.
        registry.registerPageProvider({ _, _ -> FlowsPage() }, listOf("flows"))
        registry.registerPageProvider({ _, _ -> RefreshExamplesPage() }, listOf("refresh"))
        registry.registerPageProvider({ _, _ -> FeedPage() }, listOf("feed"))
    }
}
