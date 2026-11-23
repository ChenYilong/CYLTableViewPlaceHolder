package com.cyl.placeholder.bridge

import android.app.Activity
import android.os.Looper
import android.widget.FrameLayout
import com.cyl.placeholder.CYLPlaceholderComponent
import com.cyl.placeholder.CYLPlaceholderHUDState
import com.cyl.placeholder.componentWithDictionary
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.time.Duration

/**
 * The map-driven bridge entry points (the Flutter and React Native Android halves call them with plain maps).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLPlaceholderBridgeTest {
    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()
    private val container = FrameLayout(activity).also { activity.setContentView(it) }

    private fun idle(ms: Long) = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(ms))

    @Test
    fun aPlaceholderViewComesFromAnItemMapWithTheLoopAndSpeedKeys() {
        val view = CYLPlaceholderBridge.placeholderView(
            activity,
            mapOf("CYLTabBarItemTitle" to "Offline", "CYLPlaceholderItemStyle" to "wifiOff", "animationLoops" to true, "animationSpeed" to 2.0),
        )
        assertNotNull(view)
        assertTrue(view!!.animationLoops)
        assertEquals(2f, view.animationSpeed, 0f)
    }

    @Test
    fun anInvalidItemMapGivesNoView() {
        assertNull(CYLPlaceholderBridge.placeholderView(activity, mapOf("CYLPlaceholderItemStyle" to 12345.6)))
    }

    @Test
    fun liveUpdatesChangeLoopsAndSpeedAndRestartAndRejectWhatTheyDoNotUnderstand() {
        val view = CYLPlaceholderBridge.placeholderView(activity, mapOf("CYLTabBarItemTitle" to "x"))!!
        assertTrue(CYLPlaceholderBridge.updatePlaceholderView(view, "animationLoops", true))
        assertTrue(view.animationLoops)
        assertTrue(CYLPlaceholderBridge.updatePlaceholderView(view, "animationSpeed", 1.5))
        assertEquals(1.5f, view.animationSpeed, 0f)
        assertTrue(CYLPlaceholderBridge.updatePlaceholderView(view, "restartAnimation", null))
        assertFalse(CYLPlaceholderBridge.updatePlaceholderView(view, "animationSpeed", -1))
        assertFalse(CYLPlaceholderBridge.updatePlaceholderView(view, "animationLoops", "yes"))
        assertFalse(CYLPlaceholderBridge.updatePlaceholderView(view, "unknown", 1))
    }

    @Test
    fun aStackComesFromAConfigurationAndReportsTheActionOfATappedButton() {
        val actions = ArrayList<String>()
        val stack = CYLPlaceholderBridge.stackView(
            activity,
            mapOf(
                "components" to listOf(
                    mapOf("type" to "icon", "title" to "Failed", "animationLoops" to true, "animationSpeed" to 2),
                    mapOf("type" to "button", "title" to "Retry", "action" to "retry"),
                ),
            ),
        ) { actions += it }
        assertNotNull(stack)
        assertTrue(CYLPlaceholderBridge.updateStackView(stack!!, "restartAnimation", null))
        assertFalse(CYLPlaceholderBridge.updateStackView(stack, "other", null))
    }

    @Test
    fun aComponentTakesAnimationLoopsAndSpeedFromItsDictionary() {
        val component = CYLPlaceholderComponent.componentWithDictionary(
            activity,
            mapOf("type" to "icon", "animationLoops" to true, "animationSpeed" to 2),
        )!!
        assertTrue(component.animationLoops)
        assertEquals(2f, component.animationSpeed, 0f)
        var reason: String? = null
        assertNull(
            CYLPlaceholderComponent.componentWithDictionary(activity, mapOf("type" to "icon", "animationSpeed" to -1)) { reason = it.message },
        )
        assertEquals("animationSpeed must be a positive number.", reason)
    }

    @Test
    fun theHUDBridgeRunsTheHUDMethodsByName() {
        val bridge = CYLPlaceholderHUDBridge(activity, container)
        assertTrue(bridge.handle("showWithStatus", mapOf("status" to "Please wait")))
        idle(300)
        assertTrue(bridge.hud.visible)
        assertEquals(CYLPlaceholderHUDState.Loading, bridge.hud.state)
        assertTrue(bridge.handle("showProgress", mapOf("progress" to 3, "status" to "Uploading")))
        assertEquals(1f, bridge.hud.progress, 0f)
        assertTrue(bridge.handle("dismiss", null))
        idle(400)
        assertFalse(bridge.hud.visible)
        assertTrue(bridge.handle("showSuccessWithStatus", mapOf("status" to "Done")))
        assertEquals(CYLPlaceholderHUDState.Success, bridge.hud.state)
        assertFalse(bridge.handle("noSuchMethod", null))
    }

    @Test
    fun theHUDBridgeShowsComponentsAndTheirActionComesBack() {
        val actions = ArrayList<String>()
        val bridge = CYLPlaceholderHUDBridge(activity, container) { actions += it }
        assertFalse(bridge.handle("showComponents", null))
        assertTrue(bridge.handle("showComponents", mapOf("components" to listOf(mapOf("type" to "hint", "title" to "Hello"), mapOf("type" to "button", "title" to "OK", "action" to "ok")))))
        idle(300)
        assertEquals(CYLPlaceholderHUDState.Custom, bridge.hud.state)
    }
}
