package com.cyl.placeholder

import android.app.Activity
import android.content.Context
import android.view.ViewGroup
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import java.io.File

/**
 * Placeholders, components, banners and status settings made from configuration dictionaries and JSON files.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLPlaceholderConfigurationTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    private fun failure(block: ((CYLPlaceholderConfigurationError) -> Unit) -> Any?): String? {
        var message: String? = null
        assertNull(block { message = it.message })
        return message
    }

    @Test
    fun aComponentIsMadeFromADictionary() {
        val icon = CYLPlaceholderComponent.componentWithDictionary(context, mapOf("style" to "WifiOff", "title" to "Offline", "size" to 80, "repeatCount" to "once", "spacingBefore" to 6, "highlightStyle" to "shrink"))!!
        assertEquals("Offline", icon.title)
        assertEquals(80f, icon.imageSide)
        assertEquals(1, icon.animationRepeatCount)
        assertEquals(6f, icon.spacingBefore)
        assertEquals(CYLPlaceholderTapHighlightStyle.Shrink, icon.tapHighlightStyle)
        val button = CYLPlaceholderComponent.componentWithDictionary(context, mapOf("type" to "button", "action" to "retry", "buttonStyle" to "capsule", "accessibilityIdentifier" to "go"))!!
        assertEquals(CYLPlaceholderButtonStyle.Capsule, button.buttonStyle)
        assertEquals("go", button.accessibilityIdentifier)
        assertTrue(CYLPlaceholderComponent.componentWithDictionary(context, mapOf("type" to "hint", "text" to "Pull down"))!!.title == "Pull down")
        assertEquals("or", CYLPlaceholderComponent.componentWithDictionary(context, mapOf("type" to "separator"))!!.title)
    }

    @Test
    fun aBadComponentSaysWhy() {
        assertEquals("Unknown placeholder style.", failure { e -> CYLPlaceholderComponent.componentWithDictionary(context, mapOf("style" to "Nope"), e) })
        assertEquals("A button needs an action.", failure { e -> CYLPlaceholderComponent.componentWithDictionary(context, mapOf("type" to "button"), e) })
        assertEquals("Unknown component type star.", failure { e -> CYLPlaceholderComponent.componentWithDictionary(context, mapOf("type" to "star"), e) })
        assertEquals("spacingBefore must be a number of points.", failure { e -> CYLPlaceholderComponent.componentWithDictionary(context, mapOf("spacingBefore" to -1), e) })
        assertEquals("Bundled animation Nope.json was not found.", failure { e -> CYLPlaceholderComponent.componentWithDictionary(context, mapOf("animation" to "Nope.json"), e) })
        assertEquals("A component must be a dictionary.", failure { e -> CYLPlaceholderComponent.componentWithDictionary(context, null, e) })
    }

    @Test
    fun aPlaceholderIsMadeFromAScenarioWithOverrides() {
        val stack = CYLPlaceholderStackView.fromConfiguration(context, mapOf(
            "scenario" to "NetworkUnavailable",
            "overrides" to listOf(mapOf("index" to 0, "spacingBefore" to 3, "interactionEnabled" to false)),
            "backgroundAction" to "",
        ))!!
        assertEquals(CYLPlaceholderScenario.NetworkUnavailable, stack.scenario)
        assertNull(stack.backgroundAction)
        assertNotNull(stack.placeholderView)
        val own = CYLPlaceholderStackView.fromConfiguration(context, mapOf("components" to listOf(mapOf("title" to "Hello"), mapOf("type" to "hint", "text" to "More"))))!!
        assertEquals(2, own.componentViews.size)
        assertEquals("needs a scenario or components", "The configuration needs a \"scenario\" or \"components\".", failure { e -> CYLPlaceholderStackView.fromConfiguration(context, emptyMap(), null, e) })
        assertEquals("Unknown scenario Nope.", failure { e -> CYLPlaceholderStackView.fromConfiguration(context, mapOf("scenario" to "Nope"), null, e) })
        assertEquals("Each override needs the \"index\" of an existing component.", failure { e -> CYLPlaceholderStackView.fromConfiguration(context, mapOf("scenario" to "NetworkUnavailable", "overrides" to listOf(mapOf("index" to 99))), null, e) })
    }

    @Test
    fun aJSONFileMakesAPlaceholderAndABanner() {
        val file = File.createTempFile("cyl", ".json").apply { writeText("""{"scenario":"NetworkUnavailable","accessibilityIdentifier":"offline"}""") }
        val stack = CYLPlaceholderStackView.fromContentsOfURL(context, file.path)!!
        assertEquals("offline", stack.tag)
        file.writeText("not json")
        assertTrue(failure { e -> CYLPlaceholderStackView.fromContentsOfURL(context, file.path, null, e) }!!.contains("JSON"))
        assertEquals("A property list is an iOS format; use a .json file.", failure { e -> CYLPlaceholderStackView.fromContentsOfURL(context, "a.plist", null, e) })
        val bar = CYLPlaceholderStatusView.fromConfiguration(context, mapOf("text" to "Saving", "titleColor" to "#112233", "backgroundColor" to "#FFC7C7", "accessibilityIdentifier" to "bar"))!!
        assertEquals("Saving", bar.text)
        assertEquals("bar", bar.tag)
        assertEquals("\"text\" must be a string.", failure { e -> CYLPlaceholderStatusView.fromConfiguration(context, mapOf("text" to 4), e) })
        assertEquals("An SF Symbol is an iOS image; name a drawable.", failure { e -> CYLPlaceholderStatusView.fromConfiguration(context, mapOf("image" to "system:wifi"), e) })
        file.delete()
    }

    @Test
    fun anItemViewIsMadeFromAttributes() {
        val view = CYLPlaceholderView.fromItemAttributes(context, mapOf("CYLPlaceholderItemTitle" to "Nothing here", "CYLPlaceholderItemImage" to "CYLPlaceholderWifiOff", "CYLPlaceholderItemTitleColor" to "#336699"))!!
        assertEquals("Nothing here", view.textLabel.text.toString())
        assertEquals("CYLPlaceholderItemTitle must be a string.", failure { e -> CYLPlaceholderView.fromItemAttributes(context, mapOf("CYLPlaceholderItemTitle" to 3), e) })
        assertEquals("The image Missing was not found.", failure { e -> CYLPlaceholderView.fromItemAttributes(context, mapOf("CYLPlaceholderItemImage" to "Missing"), e) })
    }

    @Test
    fun anActivityAppliesAStatusConfiguration() {
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        assertTrue(activity.cyl_applyStatusConfiguration(mapOf("statusBar" to mapOf("text" to "Custom"), "showsWhenOffline" to false)))
        assertEquals(CYLPlaceholderStatusDisplay.All, activity.cyl_statusDisplay)
        assertEquals("Custom", activity.cyl_statusView.text)
        assertTrue(activity.cyl_applyStatusConfiguration(mapOf("display" to "none")))
        assertEquals(CYLPlaceholderStatusDisplay.None, activity.cyl_statusDisplay)
        assertTrue(activity.cyl_applyStatusConfiguration(mapOf("statusBar" to true, "display" to "status")))
        assertFalse("back to the network banner", activity.cyl_statusView.text == "Custom")
        var message: String? = null
        assertFalse(activity.cyl_applyStatusConfiguration(mapOf("display" to "sideways")) { message = it.message })
        assertEquals("\"display\" must be \"statusAndPlaceholder\", \"status\", \"placeholder\" or \"none\".", message)
        assertEquals("nothing changed", CYLPlaceholderStatusDisplay.StatusBar, activity.cyl_statusDisplay)
        assertTrue((activity.findViewById<ViewGroup>(android.R.id.content)).childCount > 0)
    }
}
