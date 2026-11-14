package com.cyl.placeholder

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The empty-category scenarios have the iOS components and texts (docs/Android-Port.md).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLPlaceholderStackViewTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    @Test
    fun noSearchResultsHasAnIconATitleAndAHint() {
        val view = CYLPlaceholderStackView(context, CYLPlaceholderScenario.NoSearchResults)
        assertEquals("No matching results", view.titleLabel.text.toString())
        assertEquals("Try different keywords", view.hintLabel?.text.toString())
        assertNull(view.button)
        assertNotNull(view.imageView.drawable)
        assertEquals("No search results", view.contentDescription)
    }

    @Test
    fun theButtonRunsItsAction() {
        var action: String? = null
        val view = CYLPlaceholderStackView(context, CYLPlaceholderScenario.EmptyCart, mapOf(CYLPlaceholderAction.GoShopping to { a: String -> action = a }))
        assertEquals("Go shopping", view.button?.text.toString())
        view.button?.performClick()
        assertEquals(CYLPlaceholderAction.GoShopping, action)
    }

    @Test
    fun everyScenarioHasItsComponents() {
        // Every iOS scenario (35), each with its components; every icon has its image and every text is filled.
        assertEquals(35, CYLPlaceholderScenarioCatalog.allScenarios.size)
        for (scenario in CYLPlaceholderScenario.entries) {
            val components = CYLPlaceholderScenarioCatalog.componentsForScenario(context, scenario)
            assert(components.isNotEmpty()) { scenario.name }
            val view = CYLPlaceholderStackView(context, scenario)
            assertEquals(scenario.name, components.size, view.componentViews.size)
            components.filter { it.image != 0 }.forEach { assertNotNull(scenario.name, context.getDrawable(it.image)) }
            components.forEach { c -> c.title?.let { assert(it.isNotEmpty()) { scenario.name } } }
            val key = "cyl_placeholder_scenario_" + scenario.name.replace(Regex("(?<!^)(?=[A-Z])"), "_").lowercase() + "_name"
            assert(context.resources.getIdentifier(key, "string", context.packageName) != 0) { "localized name of ${scenario.name}" }
        }
    }

    @Test
    fun theCatalogMatchesIOS() {
        val catalog = CYLPlaceholderScenarioCatalog
        assertEquals(CYLPlaceholderScenarioCategory.Permission, catalog.categoryForScenario(CYLPlaceholderScenario.CameraPermissionDenied))
        assertEquals(CYLPlaceholderScenarioCategory.Empty, catalog.categoryForScenario(CYLPlaceholderScenario.NoOrders))
        assertEquals(CYLPlaceholderScenarioCategory.Progress, catalog.categoryForScenario(CYLPlaceholderScenario.HUD))
        assertEquals(CYLPlaceholderScenarioCategory.LoadFailed, catalog.categoryForScenario(CYLPlaceholderScenario.ServerError))
        assertEquals(CYLPlaceholderPermission.Bluetooth, catalog.permissionForScenario(CYLPlaceholderScenario.BluetoothPermissionDenied))
        assertEquals(CYLPlaceholderScenario.NoPermission, catalog.scenarioForPermission(CYLPlaceholderPermission.None))
        assertEquals(CYLPlaceholderScenario.RetryButton, catalog.scenarioNamed("CYLPlaceholderScenarioRetryButton"))
        assertEquals(CYLPlaceholderScenario.RetryButton, catalog.scenarioNamed("retrybutton"))
        assertNull(catalog.scenarioNamed("nothing"))
        assertEquals(CYLPlaceholderAction.OpenSettings, catalog.actionNamed("openSettings"))
        assertEquals("custom", catalog.actionNamed("custom"))
        assertEquals(listOf(8), catalog.readmeScreenshotNumbersForScenario(CYLPlaceholderScenario.TapToReconnect))
        assertEquals(CYLPlaceholderAction.Retry, catalog.backgroundActionForScenario(CYLPlaceholderScenario.TextOnly))
        assertEquals("CYLPlaceholderLoading.json", catalog.animationFileNamesForScenario(CYLPlaceholderScenario.Loading).first())
        assertEquals("Retry", catalog.localizedTitleForAction(context, CYLPlaceholderAction.Retry))
    }

    @Test
    fun actionsRunThroughHandlers() {
        val ran = ArrayList<String>()
        val view = CYLPlaceholderStackView(context, CYLPlaceholderScenario.RetryOrContactSupport)
        assertEquals(4, view.componentViews.size)
        assertEquals(false, view.performAction(CYLPlaceholderAction.Retry))
        view.setHandler({ ran += it }, CYLPlaceholderAction.Retry)
        view.setHandler({ ran += it }, CYLPlaceholderAction.ContactSupport)
        view.componentViewForAction(CYLPlaceholderAction.ContactSupport)!!.performClick()
        view.button!!.performClick()
        assertEquals(listOf(CYLPlaceholderAction.ContactSupport, CYLPlaceholderAction.Retry), ran)

        val tapAnywhere = CYLPlaceholderStackView(context, CYLPlaceholderScenario.TapToReload, mapOf(CYLPlaceholderAction.Retry to { a: String -> ran += "bg:$a" }))
        assertEquals(CYLPlaceholderAction.Retry, tapAnywhere.backgroundAction)
        tapAnywhere.performClick()
        assertEquals("bg:" + CYLPlaceholderAction.Retry, ran.last())

        val own = CYLPlaceholderStackView(context, listOf(
            CYLPlaceholderComponent.hintComponentWithText("Hint"),
            CYLPlaceholderComponent.separatorComponentWithText("or"),
        ))
        assertNull(own.scenario)
        own.appendComponent(CYLPlaceholderComponent.buttonComponentWithTitle("Go", CYLPlaceholderButtonStyle.Capsule, "go"))
        assertEquals(3, own.componentViews.size)
        assertEquals("or", own.componentViews[1].contentDescription)
    }

    @Test
    @Config(qualifiers = "zh-rCN")
    fun textsAreLocalized() {
        val view = CYLPlaceholderStackView(context, CYLPlaceholderScenario.NoContent)
        assertEquals(context.getString(R.string.cyl_placeholder_scenario_no_content_title), view.titleLabel.text.toString())
    }

    @Test
    fun withoutALottieAnimatorTheStillImageShows() {
        val view = CYLPlaceholderStackView(context, CYLPlaceholderScenario.NoContent)
        assertNull(view.animationView)
        assertEquals(android.view.View.VISIBLE, view.imageView.visibility)
        assertNotNull(view.imageView.drawable)
    }

    @Test
    fun theScenariosAnimationFilesAreInTheAssets() {
        val bundled = context.assets.list(CYLPlaceholderStackView.ANIMATION_FOLDER)!!.toSet()
        val played = CYLPlaceholderScenario.values().flatMap { CYLPlaceholderScenarioCatalog.animationFileNamesForScenario(it) }
            .filter { it.endsWith(".json") || it.endsWith(".gif") }.distinct()
        assertEquals(emptyList<String>(), played.filter { it.startsWith("CYLPlaceholder") && it !in bundled })
    }
}
