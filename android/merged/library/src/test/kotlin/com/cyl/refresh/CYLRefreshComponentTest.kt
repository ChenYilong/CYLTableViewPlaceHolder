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

    @Test
    fun anIconPerStateShowsAndScrubs() {
        // CYLRefreshIconView through the component's cyl_ calls: image frames per state, scrubbed while pulling.
        val layout = show(layout())
        val header = CYLRefreshHeader.headerWithRefreshingBlock(activity) { }
        layout.cyl_header = header
        assertFalse(header.cyl_usesIconView)
        val frames = listOf(android.graphics.drawable.ColorDrawable(1), android.graphics.drawable.ColorDrawable(2), android.graphics.drawable.ColorDrawable(3))
        header.cyl_setIconImages(frames, 0.3, CYLRefreshState.Refreshing)
        assertTrue(header.cyl_usesIconView)
        val icon = header.cyl_iconView
        assertSame(icon, header.cyl_iconView)
        assertNotNull(icon.animationAttributesForState(CYLRefreshState.Refreshing))
        assertEquals(40f, icon.iconSize[0])
        header.beginRefreshing()
        idle()
        assertEquals(View.VISIBLE, icon.visibility)
        assertTrue(icon.placeholderView.imageView.drawable is android.graphics.drawable.AnimationDrawable)
        header.cyl_showIconImageFrameOf(frames, 1f)
        assertSame(frames[2], icon.placeholderView.imageView.drawable)
        icon.title = "Loading"
        assertEquals("Loading", icon.placeholderView.textLabel.text.toString())
        assertTrue(icon.fittingSize[0] > 0)
        val attrs = CYLRefreshIconView.attributesForAnimationFilePath("a.json", 30f, 30f)
        assertEquals("a.json", attrs[CYLRefreshIconView.ANIMATION_FILE_PATH])
    }


    @Test
    fun theClassicHeadersAndFootersHaveTheIOSNames() {
        val layout = show(layout(300))
        val header = CYLRefreshNormalHeader(activity)
        var refreshes = 0
        header.refreshingBlock = { refreshes++ }
        header.setTitle("Pull me", CYLRefreshState.Idle).setTitle("Working", CYLRefreshState.Refreshing)
        header.cyl_modifyLastUpdatedTimeText { time -> if (time == null) "Never" else "Just now" }
        layout.cyl_header = header
        assertNotNull(header.stateLabel)
        assertNotNull(header.arrowView)
        assertNotNull(header.loadingView)
        assertEquals("Never", header.lastUpdatedTimeString)
        header.beginRefreshing()
        idle()
        assertEquals(1, refreshes)
        assertEquals("Working", header.stateLabel!!.text.toString())
        header.endRefreshing()
        idle()
        assertEquals("Just now", header.lastUpdatedTimeString)

        var loads = 0
        val footer = CYLRefreshAutoNormalFooter(activity)
        footer.refreshingBlock = { loads++ }
        footer.setTitle("That is all", CYLRefreshState.NoMoreData)
        layout.cyl_footer = footer
        assertEquals("That is all", footer.titleForState(CYLRefreshState.NoMoreData))
        footer.beginRefreshing()
        idle()
        assertEquals(1, loads)
        footer.endRefreshingWithNoMoreData()
        idle(3000)
        assertEquals("That is all", footer.stateLabel!!.text.toString())

        val gif = CYLRefreshBackGifFooter(activity)
        gif.setImages(listOf(android.graphics.drawable.ColorDrawable(1), android.graphics.drawable.ColorDrawable(2)), CYLRefreshState.Refreshing)
        assertTrue(gif.cyl_usesIconView)
        assertNotNull(gif.gifView)
    }


    @Test
    fun pagingRefreshesLoadsMoreAndStopsAtTheEnd() {
        val layout = show(layout(300))
        val header = CYLRefreshNormalHeader(activity)
        val footer = CYLRefreshBackNormalFooter(activity)
        layout.cyl_header = header
        layout.cyl_footer = footer
        val requested = ArrayList<Int>()
        var changes = 0
        val paging = CYLRefreshPaging(header, footer) { page, completion ->
            requested += page
            completion(List(10) { "p$page-$it" }, 25, 0, null)
        }
        paging.itemsDidChange = { changes++ }
        paging.start()
        idle()
        assertEquals(listOf(1), requested)
        assertEquals(10, paging.count)
        assertFalse(paging.isNoMore)
        assertEquals(CYLRefreshState.Idle, header.state)
        paging.loadMore()
        idle(3000)
        paging.loadMore()
        idle(3000)
        assertEquals(listOf(1, 2, 3), requested)
        assertEquals(30, paging.count)
        assertTrue("25 items in all: the third page is the last", paging.isNoMore)
        assertTrue(footer.noMoreData)
        paging.loadMore()
        idle()
        assertEquals("nothing after the last page", 3, requested.size)
        paging.refresh()
        idle()
        assertEquals(10, paging.count)
        assertFalse("a refresh clears no-more-data", footer.noMoreData)
        assertEquals("three pages and one refresh", 4, changes)
    }

    @Test
    fun theLeftoverComponentOptions() {
        val layout = show(layout())
        val header = CYLRefreshHeader.headerWithRefreshingBlock(activity) { }
        val footer = CYLRefreshFooter.footerWithRefreshingBlock(activity) { }
        layout.cyl_header = header
        layout.cyl_footer = footer
        header.autoHideRefresh = true
        assertTrue(header.isReadyToAutoHide())
        assertEquals(View.INVISIBLE, header.view.view.visibility)
        assertTrue(layout.cyl_autoHideRefreshHeader)
        header.beginRefreshingWithDuration(0.2, 20f, false)
        idle()
        assertTrue(header.expanded)
        assertEquals(View.VISIBLE, header.view.view.visibility)
        assertTrue(header.expandHeight > 0)
        var blocked = 0
        footer.blockedByOtherRefreshBlock = { blocked++ }
        footer.beginRefreshing()
        assertEquals("a load is refused while refreshing", 1, blocked)
        header.endRefreshing()
        idle()
        assertFalse(header.expanded)
        assertEquals(0, layout.cyl_totalDataCount())
        CYLRefreshConfig.defaultConfig.languageCode = "ko"
        assertEquals("ko", com.cyl.placeholder.CYLPlaceholderLocalization.language)
        CYLRefreshConfig.defaultConfig.languageCode = null
    }

}
