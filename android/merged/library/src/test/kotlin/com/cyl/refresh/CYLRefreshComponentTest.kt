package com.cyl.refresh

import android.app.Activity
import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.ScrollView
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.time.Duration

/**
 * The iOS-named refresh API of android/merged (`CYLRefreshComponent`, `CYLRefreshHeader`, `CYLRefreshFooter`,
 * `cyl_header` / `cyl_footer`), checked against the iOS behavior (docs/Android-API-Map.md).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLRefreshComponentTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private fun idle(ms: Long = 2000) = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(ms))

    private fun layout(contentHeight: Int = 3000): SmartRefreshLayout {
        val layout = SmartRefreshLayout(activity)
        layout.setRefreshContent(ScrollView(activity).apply {
            addView(LinearLayout(activity).apply { addView(View(activity), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, contentHeight)) })
        })
        return layout
    }

    private fun show(layout: SmartRefreshLayout): SmartRefreshLayout {
        activity.setContentView(layout)
        idle(100)
        return layout
    }

    private fun drag(view: View, dy: Float) {
        val down = SystemClock.uptimeMillis()
        var y = 300f
        view.dispatchTouchEvent(MotionEvent.obtain(down, down, MotionEvent.ACTION_DOWN, 200f, y, 0))
        repeat(20) {
            y += dy / 20
            view.dispatchTouchEvent(MotionEvent.obtain(down, down + 16L * (it + 1), MotionEvent.ACTION_MOVE, 200f, y, 0))
        }
        view.dispatchTouchEvent(MotionEvent.obtain(down, down + 700, MotionEvent.ACTION_MOVE, 200f, y, 0))
        view.dispatchTouchEvent(MotionEvent.obtain(down, down + 716, MotionEvent.ACTION_UP, 200f, y, 0))
    }

    @Test
    fun aHeaderRefreshesWithTheIOSCalls() {
        var refreshes = 0
        var began = 0
        var ended = 0
        val phases = ArrayList<CYLRefreshPhase>()
        val layout = show(layout())
        val header = CYLRefreshHeader.headerWithRefreshingBlock(activity) { refreshes++ }
        layout.cyl_header = header
        assertSame(header, layout.cyl_header)
        assertTrue(header.attached)
        assertNotNull(header.scrollView)
        header.addPhaseObserver { _, _, new -> phases += new }
        header.beginRefreshingWithCompletionBlock { began++ }
        idle()
        assertEquals(1, refreshes)
        assertEquals(1, began)
        assertTrue(header.isRefreshing)
        assertEquals(CYLRefreshState.Refreshing, header.state)
        header.endRefreshingWithCompletionBlock { ended++ }
        idle()
        assertEquals(1, ended)
        assertEquals(CYLRefreshState.Idle, header.state)
        assertFalse(header.isRefreshing)
        assertTrue(phases.containsAll(listOf(CYLRefreshPhase.Refreshing, CYLRefreshPhase.Finishing, CYLRefreshPhase.Idle)))
        assertNotNull("a successful refresh records the time", header.lastUpdatedTime)
    }

    @Test
    fun aPullMovesThePhasesAndThePercent() {
        val layout = show(layout())
        val header = CYLRefreshHeader.headerWithRefreshingBlock(activity) { }
        header.automaticallyChangeAlpha = true
        header.attach(layout)
        drag(layout, 600f)
        assertTrue("pulled: ${header.pullingPercent}", header.pullingPercent > 0f)
        assertTrue(header.dragOffset > 0)
        idle()
        assertEquals(CYLRefreshPhase.Refreshing, header.phase)
        assertEquals(1f, header.view.view.alpha)
        header.endRefreshingWithSuccess(false)
        assertFalse(header.lastRefreshSucceeded)
        idle()
        assertTrue(header.isInAnyPhase(CYLRefreshPhase.Idle))
    }

    @Test
    fun aFooterLoadsAndShowsNoMoreData() {
        var loads = 0
        val layout = show(layout(300))
        val footer = CYLRefreshFooter.footerWithRefreshingBlock(activity) { loads++ }
        layout.cyl_footer = footer
        footer.beginRefreshing()
        idle()
        assertEquals(1, loads)
        assertEquals(CYLRefreshState.Refreshing, footer.state)
        footer.endRefreshingWithNoMoreData()
        idle(3000)
        assertTrue(footer.noMoreData)
        assertEquals(CYLRefreshState.NoMoreData, footer.state)
        footer.resetNoMoreData()
        assertEquals(CYLRefreshState.Idle, footer.state)
    }

    @Test
    fun refreshEnabledAndDetaching() {
        var refreshes = 0
        val layout = show(layout())
        val header = CYLRefreshHeader.headerWithRefreshingBlock(activity) { refreshes++ }
        layout.cyl_header = header
        header.refreshEnabled = false
        drag(layout, 600f)
        idle()
        assertEquals(0, refreshes)
        layout.cyl_header = null
        assertNull(layout.cyl_header)
        assertFalse(header.attached)
    }

    @Test
    fun chainingSetsTheBlocks() {
        val layout = show(layout())
        var order = ""
        CYLRefreshHeader.headerWithRefreshingBlock(activity) { order += "r" }
            .cyl_afterBeginningAction { order += "b" }
            .cyl_endingAnimationBeginningAction { order += "e" }
            .cyl_afterEndingAction { order += "a" }
            .cyl_linkTo(layout)
        layout.cyl_header!!.beginRefreshing()
        idle()
        layout.cyl_header!!.endRefreshing()
        idle()
        assertEquals("rbea", order)
    }
}
