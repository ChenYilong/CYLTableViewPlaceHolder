package com.cyl.placeholder.reactnative

import android.app.Activity
import android.os.Looper
import com.cyl.placeholder.CYLPlaceholderHUDState
import com.facebook.react.bridge.BridgeReactContext
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
 * The native stack view and the HUD module controller of the React Native package, over the real
 * `CYLPlaceholderBridge` / `CYLPlaceholderHUDBridge` of the Android core.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLPlaceholderStackAndHUDTest {
    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private fun idle(ms: Long) = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(ms))

    private val retryComponents = listOf(
        mapOf("type" to "icon", "title" to "Failed", "animationLoops" to true, "animationSpeed" to 2),
        mapOf("type" to "button", "title" to "Retry", "action" to "retry"),
    )

    @Test
    fun theStackIsBuiltFromTheComponentDictionariesAfterTheUpdate() {
        val host = CYLPlaceholderStackHostView(activity)
        host.setComponents(retryComponents)
        assertNull(host.stack)
        assertTrue(host.applyPendingConfiguration())
        assertNotNull(host.stack)
        assertEquals(1, host.childCount)
    }

    @Test
    fun aTappedButtonReportsItsActionName() {
        val actions = ArrayList<String>()
        val host = CYLPlaceholderStackHostView(activity)
        host.onAction = { actions += it }
        host.setComponents(retryComponents)
        host.applyPendingConfiguration()
        host.stack!!.button!!.performClick()
        assertEquals(listOf("retry"), actions)
    }

    @Test
    fun anInvalidOrMissingConfigurationShowsNoStack() {
        val host = CYLPlaceholderStackHostView(activity)
        assertFalse(host.applyPendingConfiguration())
        host.setComponents(listOf(mapOf("type" to "nonsense")))
        assertFalse(host.applyPendingConfiguration())
        assertNull(host.stack)
        assertEquals(0, host.childCount)
    }

    @Test
    fun aScenarioNameWorksWithoutComponentsAndAChangeRebuildsTheStack() {
        val host = CYLPlaceholderStackHostView(activity)
        host.setScenario("networkUnavailable")
        host.applyPendingConfiguration()
        val first = host.stack
        host.setComponents(retryComponents)
        host.applyPendingConfiguration()
        assertNotNull(host.stack)
        assertTrue(first !== host.stack)
        assertEquals(1, host.childCount)
    }

    @Test
    fun restartTokenAndCommandRestartWithoutRebuilding() {
        val host = CYLPlaceholderStackHostView(activity)
        host.setComponents(retryComponents)
        host.applyPendingConfiguration()
        val stack = host.stack
        host.setRestartToken(0)
        host.setRestartToken(1)
        host.restartAnimation()
        assertTrue(stack === host.stack)
        assertTrue(host.applyPendingConfiguration())
    }

    @Test
    fun theManagerReadsReactPropsAndExportsTheActionEventAndCommand() {
        val manager = CYLPlaceholderStackManager()
        assertEquals("CYLPlaceholderStack", manager.name)
        assertEquals(1, manager.commandsMap["restartAnimation"])
        assertTrue(manager.exportedCustomDirectEventTypeConstants.containsKey("topAction"))
        val host = CYLPlaceholderStackHostView(activity)
        manager.setScenario(host, "networkUnavailable")
        manager.setBackgroundAction(host, "tapped")
        manager.onAfterUpdateTransaction(host)
        assertNotNull(host.stack)
        manager.receiveCommand(host, "restartAnimation", null)
    }

    @Test
    fun thePackageRegistersTheStackManagerAndTheHUDModule() {
        val context = BridgeReactContext(activity)
        val package_ = CYLPlaceholderPackage()
        assertEquals(setOf("CYLRefreshContainer", "CYLPlaceholderStack"), package_.createViewManagers(context).map { it.name }.toSet())
        assertEquals(listOf("CYLPlaceholderHUD"), package_.createNativeModules(context).map { it.name })
    }

    @Test
    fun theHUDControllerDrivesTheHUDOverTheContentViewAndReusesIt() {
        val controller = CYLPlaceholderHUDController({ activity }) {}
        assertTrue(controller.handle("showWithStatus", mapOf("status" to "Please wait")))
        idle(300)
        val content = activity.findViewById<android.view.ViewGroup>(android.R.id.content)
        assertTrue(content.childCount > 0)
        assertEquals(CYLPlaceholderHUDState.Loading, controller.hud!!.state)
        val hud = controller.hud
        assertTrue(controller.handle("showProgress", mapOf("progress" to 0.5, "status" to "Uploading")))
        assertTrue(hud === controller.hud)
        assertEquals(0.5f, controller.hud!!.progress, 0f)
        assertTrue(controller.handle("dismiss", null))
        idle(400)
        assertFalse(controller.hud!!.visible)
        assertFalse(controller.handle("noSuchMethod", null))
    }

    @Test
    fun theHUDControllerShowsComponentsAndReportsWithoutAnActivity() {
        val controller = CYLPlaceholderHUDController({ activity }) {}
        val components = listOf(mapOf("type" to "hint", "title" to "Hello"), mapOf("type" to "button", "title" to "OK", "action" to "ok"))
        assertTrue(controller.handle("showComponents", mapOf("components" to components)))
        idle(300)
        assertEquals(CYLPlaceholderHUDState.Custom, controller.hud!!.state)
        assertFalse(CYLPlaceholderHUDController({ null }) {}.handle("show", null))
    }
}
