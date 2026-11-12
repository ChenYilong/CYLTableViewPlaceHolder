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
    fun everyScenarioHasItsImageAndTitle() {
        for (scenario in CYLPlaceholderScenario.entries) {
            val view = CYLPlaceholderStackView(context, scenario)
            assertNotNull(scenario.name, view.imageView.drawable)
            assert(view.titleLabel.text.isNotEmpty()) { scenario.name }
        }
    }

    @Test
    @Config(qualifiers = "zh-rCN")
    fun textsAreLocalized() {
        val view = CYLPlaceholderStackView(context, CYLPlaceholderScenario.NoContent)
        assertEquals(context.getString(R.string.cyl_placeholder_scenario_no_content_title), view.titleLabel.text.toString())
    }
}
