package com.cyl.placeholder

import android.app.Activity
import android.os.Looper
import android.view.ViewGroup
import android.widget.FrameLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.time.Duration

/**
 * CYLPlaceholderHUD with the iOS API (docs/Android-API-Map.md).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLPlaceholderHUDTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()
    private val container = FrameLayout(activity).also { activity.setContentView(it) }

    private fun idle(ms: Long) = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(ms))

    @Test
    fun loadingCountsActivitiesAndHidesWhenTheyEnd() {
        val hud = CYLPlaceholderHUD(activity, container)
        hud.show()
        hud.showWithStatus("Loading")
        idle(300)
        assertTrue(hud.visible)
        assertEquals(CYLPlaceholderHUDState.Loading, hud.state)
        assertEquals(2, hud.activityCount)
        assertEquals("Loading", hud.placeholderView?.textLabel?.text.toString())
        hud.popActivity()
        idle(300)
        assertTrue("one activity is still running", hud.visible)
        hud.popActivity()
        idle(500)
        assertFalse(hud.visible)
        assertEquals(CYLPlaceholderHUDState.Hidden, hud.state)
    }

    @Test
    fun successHidesByItselfAfterItsDisplayDuration() {
        val hud = CYLPlaceholderHUD(activity, container)
        assertEquals(1.5, hud.displayDurationForString("Saved"), 0.001)
        assertEquals(5.0, hud.displayDurationForString("x".repeat(200)), 0.001)
        var completed = false
        hud.showSuccessWithStatus("Saved")
        idle(300)
        assertEquals(CYLPlaceholderHUDState.Success, hud.state)
        assertNotNull(hud.placeholderView?.imageView?.drawable)
        assertEquals("Saved", hud.hudView.contentDescription)
        idle(2000)
        assertFalse(hud.visible)
        hud.showErrorWithStatus("Failed")
        hud.dismissWithCompletion { completed = true }
        idle(500)
        assertTrue(completed)
    }

    @Test
    fun progressStatusAndScenario() {
        val hud = CYLPlaceholderHUD(activity, container)
        hud.showProgress(0.4f, "Uploading")
        assertEquals(CYLPlaceholderHUDState.Progress, hud.state)
        assertEquals(0.4f, hud.progress)
        hud.setStatus("Almost")
        assertEquals("Almost", hud.status)
        var ran: String? = null
        hud.showScenario(CYLPlaceholderScenario.Success, mapOf(CYLPlaceholderAction.Done to { a: String -> ran = a }))
        assertEquals(CYLPlaceholderHUDState.Custom, hud.state)
        assertEquals(1, hud.actions.size)
        hud.maskType = CYLPlaceholderHUDMaskType.Black
        hud.showWithStatus(null)
        assertTrue("a mask blocks touches", hud.isClickable)
        hud.dismiss()
        idle(500)
        assertFalse(hud.visible)
        assertEquals(null, ran)
    }

    @Test
    fun theGraceTimeHidesAQuickTask() {
        val hud = CYLPlaceholderHUD(activity, container)
        hud.graceTimeInterval = 0.5
        hud.show()
        idle(100)
        assertFalse("not yet shown", hud.visible)
        hud.popActivity()
        idle(1000)
        assertFalse(hud.visible)
    }

    @Test
    fun theSharedHUDNeedsItsContainer() {
        assertFalse(CYLPlaceholderHUD.isVisible())
        val hud = CYLPlaceholderHUD.sharedHUD(container)
        CYLPlaceholderHUD.showWithStatus("Shared")
        idle(300)
        assertTrue(CYLPlaceholderHUD.isVisible())
        assertEquals(container, hud.parent as ViewGroup)
        CYLPlaceholderHUD.dismiss()
        idle(500)
        assertFalse(CYLPlaceholderHUD.isVisible())
    }
}
