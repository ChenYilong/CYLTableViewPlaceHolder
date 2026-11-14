package com.cyl.placeholder

import android.content.Context
import android.view.View
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * CYLPlaceholderView with the iOS API (docs/Android-API-Map.md).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLPlaceholderViewTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    @Test
    fun everyStyleHasItsIconAndEveryMessageItsText() {
        CYLPlaceholderStyle.entries.forEach { assertNotNull(it.name, CYLPlaceholderView.imageForStyle(context, it)) }
        assertEquals("CYLPlaceholderWifiOff", CYLPlaceholderView.imageNameForStyle(CYLPlaceholderStyle.WifiOff))
        assertEquals("No internet connection", CYLPlaceholderView.localizedTextForMessage(context, CYLPlaceholderMessage.NoInternet))
        val view = CYLPlaceholderView(context, CYLPlaceholderStyle.WifiOff, CYLPlaceholderMessage.NoInternet)
        assertNotNull(view.imageView.drawable)
        assertEquals("No internet connection", view.textLabel.text.toString())
        assertEquals("No internet connection", view.itemAttributes["CYLPlaceholderItemTitle"].toString())
    }

    @Test
    fun aBadgeShowsDotsNumbersAndTexts() {
        val view = CYLPlaceholderView(context, CYLPlaceholderStyle.Inbox, "Inbox")
        view.badgeValue = "3"
        assertEquals(View.VISIBLE, view.badgeLabel.visibility)
        assertEquals("3", view.badgeLabel.text.toString())
        assertEquals("Inbox, 3", view.contentDescription)
        view.badgeValue = ""
        assertEquals("", view.badgeLabel.text.toString())
        view.badgeValue = null
        assertEquals(View.GONE, view.badgeLabel.visibility)
    }

    @Test
    fun aTapRunsTheHandlerUnlessTurnedOff() {
        var taps = 0
        val view = CYLPlaceholderView(context, CYLPlaceholderStyle.Refresh, "Reload")
        assertFalse(view.tapInteractive)
        view.tapHandler = { taps++ }
        assertTrue(view.tapInteractive)
        view.performClick()
        assertEquals(1, taps)
        view.tapInteractionEnabled = false
        assertFalse(view.performTap())
        assertEquals(1, taps)
    }

    @Test
    fun selectionChangesTheColors() {
        val view = CYLPlaceholderView(context, CYLPlaceholderStyle.Favorite, "Saved")
        view.defaultSelectedTitleColor = 0xFFFF0000.toInt()
        assertEquals(view.defaultTitleColor, view.textLabel.currentTextColor)
        view.selectedState = true
        assertEquals(0xFFFF0000.toInt(), view.textLabel.currentTextColor)
    }

    @Test
    fun anAnimationPlaysThroughTheRegisteredFactory() {
        val calls = ArrayList<String>()
        CYLPlaceholderView.registerAnimationFactory({ ctx, path ->
            object : CYLPlaceholderAnimationPlayer {
                override val view = View(ctx)
                override val ready = true
                override var errorHandler: ((Throwable) -> Unit)? = null
                override var readyHandler: (() -> Unit)? = null
                override fun play() { calls += "play:$path" }
                override fun stop() { calls += "stop" }
                override fun showLastFrame() { calls += "last" }
                override fun setAnimationProgress(progress: Float) { calls += "progress:$progress" }
                override fun setAnimationSpeed(speed: Float) { calls += "speed:$speed" }
                override fun setAnimationRepeatCount(count: Int) { calls += "repeat:$count" }
                override fun setAnimationColors(colors: List<Int>) {}
            }
        }, "json")
        try {
            val view = CYLPlaceholderView(context, CYLPlaceholderStyle.Empty, CYLPlaceholderMessage.Empty)
            assertFalse("no factory for gif", view.setAnimationFile("a.gif"))
            assertTrue(view.setAnimationFile("CYLPlaceholderEmpty.json"))
            assertEquals(View.GONE, view.imageView.visibility)
            view.playPlaceholderAnimation()
            view.setPlaceholderAnimationSpeed(2f)
            view.stopPlaceholderAnimation()
            assertEquals(listOf("repeat:0", "play:CYLPlaceholderEmpty.json", "speed:2.0", "stop"), calls)
        } finally {
            CYLPlaceholderView.registerAnimationFactory(null, "json")
        }
    }
}
