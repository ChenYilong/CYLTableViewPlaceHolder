package com.cyl.placeholder

import android.app.Activity
import android.view.View
import android.view.ViewGroup
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
import org.robolectric.annotation.Config

/**
 * The status banner, the network monitor, the language switch and the activity's status display (iOS
 * `CYLPlaceholderStatusView`, `CYLPlaceholderNetworkMonitor`, `CYLPlaceholderLocalization`,
 * `UIViewController (CYLPlaceholderStatus)`).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLPlaceholderStatusTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    @After
    fun resetLanguage() {
        CYLPlaceholderLocalization.language = null
    }

    @Test
    fun theLanguageSwitchChangesTheBuiltInTexts() {
        assertEquals(7, CYLPlaceholderLocalization.supportedLanguages.size)
        assertEquals("en", CYLPlaceholderLocalization.effectiveLanguage)
        assertEquals("Nothing here yet", CYLPlaceholderView.localizedTextForMessage(activity, CYLPlaceholderMessage.Empty))
        CYLPlaceholderLocalization.language = "ja"
        assertEquals("ja", CYLPlaceholderLocalization.effectiveLanguage)
        val japanese = CYLPlaceholderView.localizedTextForMessage(activity, CYLPlaceholderMessage.Empty)
        assertFalse(japanese == "Nothing here yet")
        assertEquals(japanese, CYLPlaceholderLocalization.localizedStringForKey(activity, "CYLPlaceholderEmptyText", null))
        assertEquals("fallback", CYLPlaceholderLocalization.localizedStringForKey(activity, "CYLPlaceholderNoSuchKey", "fallback"))
        assertFalse(CYLPlaceholderScenarioCatalog.localizedTitleForAction(activity, CYLPlaceholderAction.Retry) == "Retry")
    }

    @Test
    fun theBannerSaysTheNetworkIsUnavailableAndHearsTaps() {
        var taps = 0
        var delegated = 0
        val banner = CYLPlaceholderStatusView(activity)
        assertEquals("Network unavailable, Check network", banner.text)
        assertNotNull(banner.placeholderView.imageView.drawable)
        banner.tapHandler = { taps++ }
        banner.delegate = object : CYLPlaceholderStatusViewDelegate {
            override fun statusViewClicked(sender: CYLPlaceholderStatusView) { delegated++ }
        }
        banner.performClick()
        assertEquals(1, taps)
        assertEquals(1, delegated)
        banner.text = "Offline"
        assertEquals("Offline", banner.contentDescription)
    }

    @Test
    fun anActivityShowsTheBannerAndThePlaceholder() {
        val content = activity.findViewById<ViewGroup>(android.R.id.content)
        activity.cyl_setStatusDisplay(CYLPlaceholderStatusDisplay.All, false)
        assertEquals(CYLPlaceholderStatusDisplay.All, activity.cyl_statusDisplay)
        assertEquals(content, activity.cyl_statusView.parent)
        assertEquals(2, content.childCount)
        activity.cyl_placeholderHidden = true
        assertEquals("only the banner", 1, content.childCount)
        activity.cyl_statusDisplay = CYLPlaceholderStatusDisplay.None
        assertNull(activity.cyl_statusView.parent)
        assertEquals(0, content.childCount)
    }

    @Test
    fun theMonitorNamesStatusesAndStartsAndStops() {
        assertEquals("Wi-Fi", CYLPlaceholderNetworkMonitor.nameForStatus(CYLPlaceholderNetworkStatus.ReachableViaWiFi))
        assertEquals("not reachable", CYLPlaceholderNetworkMonitor.nameForStatus(CYLPlaceholderNetworkStatus.NotReachable))
        val monitor = CYLPlaceholderNetworkMonitor.sharedMonitor(activity)
        monitor.startMonitoring()
        assertTrue(monitor.monitoring)
        assertTrue(monitor.networkStatus != CYLPlaceholderNetworkStatus.Unknown)
        monitor.stopMonitoring()
        assertFalse(monitor.monitoring)
    }

    @Test
    fun thePlaceholderCoversOnlyTheScrollViewsContainer() {
        // iOS puts the placeholder over `cyl_placeholderScrollView`, not over the whole view; the status bar stays at
        // the top of the content.
        val frame = android.widget.FrameLayout(activity)
        val list = View(activity)
        frame.addView(list)
        val root = android.widget.LinearLayout(activity).apply { orientation = android.widget.LinearLayout.VERTICAL }
        root.addView(frame, android.widget.LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
        root.addView(View(activity), android.widget.LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 100))
        activity.setContentView(root)
        activity.cyl_placeholderScrollView = list
        activity.cyl_statusDisplay = CYLPlaceholderStatusDisplay.All
        assertEquals("the placeholder is in the list's frame", 2, frame.childCount)
        assertEquals("the bar is in the content", activity.findViewById<ViewGroup>(android.R.id.content), activity.cyl_statusView.parent)
        activity.cyl_statusDisplay = CYLPlaceholderStatusDisplay.StatusBar
        assertEquals("and goes from the frame again", 1, frame.childCount)
    }

}
