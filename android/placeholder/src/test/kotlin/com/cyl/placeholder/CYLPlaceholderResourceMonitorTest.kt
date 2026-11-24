package com.cyl.placeholder

import android.app.Activity
import android.content.Context
import android.net.NetworkCapabilities
import android.os.Looper
import android.view.View
import org.junit.After
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
import org.robolectric.shadows.ShadowNetworkCapabilities

/** Stands in for the engine's `CYLAnimationEngines` (the real property needs a CYLTabBarController commit not in every pin). */
object CYLFakeEngines {
    var resourceMissingListener: ((String, String) -> Unit)? = null
}

/** Stands in for a `CYLAnimatedItemView` with the `onResourceMissing` hook. */
class CYLFakeAnimatedView(context: Context) : View(context) {
    var onResourceMissing: ((String, String) -> Unit)? = null
}

/**
 * The red bar that names the missing animation resources (`CYLPlaceholderResourceMonitor`, key
 * `CYLPlaceholderResourceMissing`).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLPlaceholderResourceMonitorTest {

    private val controller = Robolectric.buildActivity(Activity::class.java).setup()
    private val activity: Activity = controller.get()

    @After
    fun reset() {
        CYLPlaceholderResourceMonitor.resetForTests()
        CYLFakeEngines.resourceMissingListener = null
        CYLPlaceholderLocalization.language = null
    }

    @Test
    fun aMissingResourceShowsInTheBar() {
        CYLPlaceholderResourceMonitor.report(activity, "home.pag", "file not found")
        assertEquals("Missing resource: home.pag (file not found)", activity.cyl_statusView.text)
        assertNotNull("the bar is on the page", activity.cyl_statusView.parent)
        assertTrue(activity.cyl_statusDisplay and CYLPlaceholderStatusDisplay.StatusBar != 0)
        assertEquals(listOf("home.pag"), CYLPlaceholderResourceMonitor.missingResources(activity))
    }

    @Test
    fun aSecondReportOfTheSameResourceDoesNothing() {
        CYLPlaceholderResourceMonitor.report(activity, "asset:Folder/home.pag", "file not found")
        CYLPlaceholderResourceMonitor.report(activity, "home.pag", "unreadable")
        assertEquals(listOf("home.pag"), CYLPlaceholderResourceMonitor.missingResources(activity))
        assertEquals("Missing resource: home.pag (file not found)", activity.cyl_statusView.text)
    }

    @Test
    fun severalResourcesMakeOneBarWithTheFirstAndACount() {
        listOf("a.pag", "b.pag", "c.riv", "d.json").forEach { CYLPlaceholderResourceMonitor.report(activity, it, "file not found") }
        assertEquals("Missing resources: a.pag +3 more", activity.cyl_statusView.text)
        val content = activity.findViewById<android.view.ViewGroup>(android.R.id.content)
        assertEquals("one bar, not four", 1, (0 until content.childCount).count { content.getChildAt(it) is CYLPlaceholderStatusView })
    }

    @Test
    fun clearingTakesAResourceOffAndTheLastOneHidesTheBar() {
        val before = activity.cyl_statusView.text
        CYLPlaceholderResourceMonitor.report(activity, "a.pag", "file not found")
        CYLPlaceholderResourceMonitor.report(activity, "b.pag", "unreadable")
        CYLPlaceholderResourceMonitor.clear(activity, "a.pag")
        assertEquals("Missing resource: b.pag (unreadable)", activity.cyl_statusView.text)
        CYLPlaceholderResourceMonitor.clear(activity, "b.pag")
        assertTrue(CYLPlaceholderResourceMonitor.missingResources(activity).isEmpty())
        assertNull("the bar is gone", activity.cyl_statusView.parent)
        assertEquals(CYLPlaceholderStatusDisplay.None, activity.cyl_statusDisplay)
        assertEquals("the bar's own text is back", before, activity.cyl_statusView.text)
    }

    @Test
    fun aBarThePageAlreadyShowsStaysWhenTheListEmpties() {
        activity.cyl_statusDisplay = CYLPlaceholderStatusDisplay.StatusBar
        CYLPlaceholderResourceMonitor.report(activity, "a.pag", "file not found")
        CYLPlaceholderResourceMonitor.clear(activity, "a.pag")
        assertEquals(CYLPlaceholderStatusDisplay.StatusBar, activity.cyl_statusDisplay)
        assertNotNull(activity.cyl_statusView.parent)
    }

    @Test
    fun destroyingTheActivityClearsItsList() {
        CYLPlaceholderResourceMonitor.report(activity, "a.pag", "file not found")
        controller.pause().stop().destroy()
        assertTrue(CYLPlaceholderResourceMonitor.missingResources(activity).isEmpty())
    }

    @Test
    fun theOfflineTextWinsAndTheResourcesComeBackOnline() {
        activity.cyl_showsStatusViewWhenOffline = true
        CYLPlaceholderResourceMonitor.report(activity, "a.pag", "file not found")
        assertEquals("Missing resource: a.pag (file not found)", activity.cyl_statusView.text)
        val monitor = CYLPlaceholderNetworkMonitor.sharedMonitor(activity)
        monitor.update(null)
        shadowOf(Looper.getMainLooper()).idle()
        assertEquals("Network unavailable, Check network", activity.cyl_statusView.text)
        val wifi = ShadowNetworkCapabilities.newInstance()
        shadowOf(wifi).addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
        monitor.update(wifi)
        shadowOf(Looper.getMainLooper()).idle()
        assertEquals("Missing resource: a.pag (file not found)", activity.cyl_statusView.text)
        assertEquals(listOf("a.pag"), CYLPlaceholderResourceMonitor.missingResources(activity))
    }

    @Test
    fun withoutAnEngineClassTheHookDoesNothing() {
        CYLPlaceholderResourceMonitor.enginesClassName = "com.cyl.animateditem.NoSuchEngines"
        assertFalse(CYLPlaceholderResourceMonitor.installEngineListener(activity))
        assertFalse("a plain view has no onResourceMissing", CYLPlaceholderResourceMonitor.attach(View(activity)))
        CYLPlaceholderResourceMonitor.report(null, "a.pag", "file not found")
    }

    @Test
    fun theEngineListenerReportsToTheActivityInFront() {
        CYLPlaceholderResourceMonitor.enginesClassName = CYLFakeEngines::class.java.name
        assertTrue(CYLPlaceholderResourceMonitor.installEngineListener(activity))
        CYLFakeEngines.resourceMissingListener!!.invoke("tab.svga", "no runtime")
        assertEquals("Missing resource: tab.svga (no runtime)", activity.cyl_statusView.text)
    }

    @Test
    fun theHookOfTheRealEngineIsSetOnlyWhenTheCommitHasIt() {
        val has = runCatching {
            Class.forName("com.cyl.animateditem.CYLAnimationEngines").methods.any { it.name == "setResourceMissingListener" }
        }.getOrDefault(false)
        assertEquals(has, CYLPlaceholderResourceMonitor.installEngineListener(activity))
        assertEquals(has, CYLPlaceholderResourceMonitor.attach(CYLPlaceholderView(activity)))
    }

    @Test
    fun aViewHookReportsToTheActivityOfItsContext() {
        val view = CYLFakeAnimatedView(activity)
        assertTrue(CYLPlaceholderResourceMonitor.attach(view))
        view.onResourceMissing!!.invoke("home.riv", "unreadable")
        assertEquals("Missing resource: home.riv (unreadable)", activity.cyl_statusView.text)
    }

    @Test
    fun aMissingAnimationAssetIsReportedByThePlaceholderView() {
        val view = CYLPlaceholderView(activity)
        view.setAnimationFile("asset:CYLPlaceholderAnimations/NoSuchAnimation.json")
        assertEquals(listOf("NoSuchAnimation.json"), CYLPlaceholderResourceMonitor.missingResources(activity))
        assertEquals("Missing resource: NoSuchAnimation.json (file not found)", activity.cyl_statusView.text)
        view.setAnimationFile("asset:CYLPlaceholderAnimations/CYLPlaceholderLoading.json")
        // [EN] The engine may list the file too (no Lottie runtime in a unit test); the missing one stays listed either way.
        assertTrue("NoSuchAnimation.json" in CYLPlaceholderResourceMonitor.missingResources(activity))
    }
}
