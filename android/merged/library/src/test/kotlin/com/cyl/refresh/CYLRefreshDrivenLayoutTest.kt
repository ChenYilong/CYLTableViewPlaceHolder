package com.cyl.refresh

import android.app.Activity
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.time.Duration

/**
 * The driven mode ([CYLRefreshDrivenLayout]): Robolectric ports of the Dart phase tests
 * (`CrossPlatform/flutter_cylplaceholder/test/refresh_component_test.dart`, groups "component state" and "trigger
 * rules"), with the pull fed from outside instead of touches.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLRefreshDrivenLayoutTest {
    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private fun idle(ms: Long = 2000) = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(ms))

    private fun texts(view: View): List<String> =
        if (view is TextView) listOf(view.text.toString()) else (view as? ViewGroup)?.let { g -> (0 until g.childCount).flatMap { texts(g.getChildAt(it)) } } ?: emptyList()

    private fun driven(header: CYLRefreshHeader = CYLRefreshNormalHeader(activity)): Pair<CYLRefreshDrivenLayout, CYLRefreshHeader> {
        val layout = CYLRefreshDrivenLayout(activity)
        layout.cyl_header = header
        // On screen, as a host puts it: a view posted to a detached layout (triggersWhenReached) would never run.
        activity.setContentView(layout)
        idle(100)
        return layout to header
    }

    @Test
    fun pullingWalksIdleToPullToRefreshToReleaseToRefreshAndReportsThePercent() {
        val (layout, header) = driven()
        val h = header.expandHeight
        val phases = mutableListOf<CYLRefreshPhase>()
        header.addPhaseObserver { _, _, new -> phases += new }
        layout.drive(h / 3, dragging = true)
        assertEquals(CYLRefreshPhase.PullToRefresh, header.phase)
        assertEquals(CYLRefreshState.Idle, header.state)
        assertEquals(1f / 3, header.pullingPercent, 0.02f)
        assertEquals(h / 3, header.dragOffset)
        layout.drive(h + 5, dragging = true)
        assertEquals(CYLRefreshPhase.ReleaseToRefresh, header.phase)
        assertEquals(CYLRefreshState.Pulling, header.state)
        layout.drive(0, dragging = true)
        assertEquals(CYLRefreshPhase.Idle, header.phase)
        assertEquals(listOf(CYLRefreshPhase.PullToRefresh, CYLRefreshPhase.ReleaseToRefresh, CYLRefreshPhase.Idle), phases)
    }

    @Test
    fun releaseStartsRefreshingOnceAndEndRefreshingRecordsTheResult() {
        val (layout, header) = driven()
        var calls = 0
        header.refreshingHandler = { calls++ }
        header.finishDuration = 0.01
        layout.drive(header.expandHeight + 5, dragging = true)
        layout.release()
        idle()
        assertEquals(CYLRefreshPhase.Refreshing, header.phase)
        assertTrue(header.isRefreshing)
        assertEquals(1, calls)
        header.endRefreshingWithSuccess(false)
        assertEquals(CYLRefreshPhase.Finishing, header.phase)
        assertFalse(header.lastRefreshSucceeded)
        idle()
        assertEquals(CYLRefreshPhase.Idle, header.phase)
    }

    @Test
    fun theCallerAlwaysEndsRefreshing() {
        val (layout, header) = driven()
        layout.drive(header.expandHeight + 5, dragging = true)
        layout.release()
        idle(5000)
        assertEquals(CYLRefreshPhase.Refreshing, header.phase)
    }

    @Test
    fun aShortPullIsCanceledOnRelease() {
        val (layout, header) = driven()
        layout.drive(header.expandHeight / 2, dragging = true)
        layout.release()
        idle()
        assertEquals(CYLRefreshPhase.Idle, header.phase)
        assertFalse(header.isRefreshing)
    }

    @Test
    fun refreshEnabledFalseNeverArms() {
        val (layout, header) = driven()
        header.refreshEnabled = false
        layout.drive(header.expandHeight + 20, dragging = true)
        assertEquals(CYLRefreshPhase.Idle, header.phase)
        layout.release()
        idle()
        assertFalse(header.isRefreshing)
    }

    @Test
    fun onEdgeIgnoresAPullThatDidNotStartAtTheEdge() {
        val (layout, header) = driven()
        header.triggerMode = CYLRefreshTriggerMode.OnEdge
        layout.drive(header.expandHeight + 20, dragging = true, startedAtEdge = false)
        assertEquals(CYLRefreshPhase.Idle, header.phase)
        layout.drive(header.expandHeight + 20, dragging = true, startedAtEdge = true)
        assertEquals(CYLRefreshPhase.ReleaseToRefresh, header.phase)
    }

    @Test
    fun triggersWhenReachedRefreshesWithoutARelease() {
        val (layout, header) = driven()
        header.triggersWhenReached = true
        layout.drive(header.expandHeight + 5, dragging = true)
        idle()
        assertTrue(header.isRefreshing)
    }

    @Test
    fun phaseObserversCanBeRemoved() {
        val (layout, header) = driven()
        var n = 0
        val observer: (CYLRefreshComponent, CYLRefreshPhase, CYLRefreshPhase) -> Unit = { _, _, _ -> n++ }
        header.addPhaseObserver(observer)
        layout.drive(10, dragging = true)
        header.removePhaseObserver(observer)
        layout.drive(0, dragging = true)
        assertEquals(1, n)
    }

    @Test
    fun theHeaderViewDrawsFromTheDrivenPhase() {
        // The spike (CYLRefreshDrivenModeSpikeTest) found the classic header's text follows the layout's state callbacks;
        // the driven layout calls them, so the text now changes with the pull.
        val (layout, header) = driven()
        val rest = texts(header.view.view)
        layout.drive(header.expandHeight + 5, dragging = true)
        val armed = texts(header.view.view)
        assertNotEquals(rest, armed)
        layout.release()
        idle()
        assertNotEquals(armed, texts(header.view.view))
    }

    @Test
    fun anAttachedDrivenLayoutShowsNoEmptyContentWarning() {
        // The base layout draws an orange warning text when it has no content view; the host's content is Flutter's, so the
        // driven layout supplies an empty content of its own and no child shows the warning.
        val (layout, _) = driven()
        assertTrue(layout.isAttachedToWindow)
        val warning = activity.getString(com.cyl.refresh.merged.R.string.srl_content_empty)
        assertFalse(texts(layout).any { it == warning })
        fun anyOrange(view: View): Boolean =
            (view is TextView && view.currentTextColor == 0xffff6600.toInt()) || (view as? ViewGroup)?.let { g -> (0 until g.childCount).any { anyOrange(g.getChildAt(it)) } } == true
        assertFalse(anyOrange(layout))
    }

    private fun drivenFooter(footer: CYLRefreshFooter = CYLRefreshBackNormalFooter(activity)): Pair<CYLRefreshDrivenLayout, CYLRefreshFooter> {
        val layout = CYLRefreshDrivenLayout(activity)
        layout.cyl_footer = footer
        activity.setContentView(layout)
        idle(100)
        return layout to footer
    }

    // Footer path of drive (negative offset). Port of the Dart "footer" cases, which use a back footer.

    @Test
    fun aNegativeOffsetPullsTheFooterThroughPullToLoadToReleaseToLoad() {
        val (layout, footer) = drivenFooter()
        val h = footer.expandHeight
        val phases = mutableListOf<CYLRefreshPhase>()
        footer.addPhaseObserver { _, _, new -> phases += new }
        layout.drive(-(h / 3), dragging = true)
        assertEquals(CYLRefreshPhase.PullToRefresh, footer.phase)
        assertEquals(CYLRefreshState.Idle, footer.state)
        layout.drive(-(h + 5), dragging = true)
        assertEquals(CYLRefreshPhase.ReleaseToRefresh, footer.phase)
        layout.drive(0, dragging = true)
        assertEquals(CYLRefreshPhase.Idle, footer.phase)
        assertEquals(listOf(CYLRefreshPhase.PullToRefresh, CYLRefreshPhase.ReleaseToRefresh, CYLRefreshPhase.Idle), phases)
    }

    @Test
    fun releasingAnArmedFooterLoadsOnceAndAShortPullIsCanceled() {
        val (layout, footer) = drivenFooter()
        var calls = 0
        footer.refreshingHandler = { calls++ }
        footer.finishDuration = 0.01
        layout.drive(-(footer.expandHeight / 2), dragging = true)
        layout.release()
        idle()
        assertEquals(CYLRefreshPhase.Idle, footer.phase)
        assertFalse(footer.isRefreshing)
        layout.drive(-(footer.expandHeight + 5), dragging = true)
        layout.release()
        idle()
        assertTrue(footer.isRefreshing)
        assertEquals(1, calls)
        footer.endRefreshing()
        idle()
        assertEquals(CYLRefreshPhase.Idle, footer.phase)
    }

    @Test
    fun endRefreshingWithNoMoreDataStopsLoadingUntilResetNoMoreData() {
        val (layout, footer) = drivenFooter()
        assertFalse(footer.noMoreData)
        layout.drive(-80, dragging = true)
        layout.release()
        idle()
        footer.endRefreshingWithNoMoreData()
        idle()
        assertTrue(footer.noMoreData)
        assertEquals(CYLRefreshState.NoMoreData, footer.state)
        layout.drive(-80, dragging = true)
        layout.release()
        idle()
        assertFalse("no more data: a pull must not load", footer.isRefreshing)
        footer.resetNoMoreData()
        assertFalse(footer.noMoreData)
    }

    @Test
    fun loadsAfterNoMoreDataLetsAPullLoadAgainAndClearsTheFlag() {
        val (layout, footer) = drivenFooter()
        footer.loadsAfterNoMoreData = true
        footer.noticeNoMoreData()
        layout.drive(-(footer.expandHeight + 5), dragging = true)
        assertEquals(CYLRefreshPhase.ReleaseToRefresh, footer.phase)
        layout.release()
        idle()
        assertTrue(footer.isRefreshing)
        assertFalse(footer.noMoreData)
    }

    @Test
    fun hapticFeedbackVibratesOnceWhenThePullIsArmed() {
        var buzzes = 0
        val header = CYLRefreshHeader(object : com.cyl.refresh.header.ClassicsHeader(activity) {
            override fun performHapticFeedback(feedbackConstant: Int): Boolean { buzzes++; return true }
        })
        header.hapticFeedback = true
        val (layout, _) = driven(header)
        layout.drive(header.expandHeight + 5, dragging = true)
        layout.drive(header.expandHeight + 15, dragging = true)
        assertEquals(1, buzzes)
    }

    @Test
    fun notifiesWhenHiddenDecidesWhetherAHiddenComponentReportsThePull() {
        val (layout, quiet) = driven()
        quiet.notifiesWhenHidden = false
        quiet.view.view.visibility = View.GONE
        layout.drive(10, dragging = true)
        assertEquals(0, quiet.dragOffset)
        assertTrue(CYLRefreshNormalHeader(activity).notifiesWhenHidden)
        val (layout2, loud) = driven()
        loud.view.view.visibility = View.GONE
        layout2.drive(10, dragging = true)
        assertEquals(10, loud.dragOffset)
    }
}
