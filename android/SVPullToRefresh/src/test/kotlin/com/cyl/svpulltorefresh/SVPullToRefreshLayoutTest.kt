package com.cyl.svpulltorefresh

import android.content.Context
import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.time.Duration

/**
 * SVPullToRefresh in Kotlin: pull to refresh at the top and the bottom, infinite scrolling, and the behavior taken from
 * the source's open pull requests (docs/Android-Port.md).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class SVPullToRefreshLayoutTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    /** A layout of 400 x 800 around a ScrollView whose content is [contentHeight] high. */
    private fun makeLayout(contentHeight: Int): Pair<SVPullToRefreshLayout, ScrollView> {
        val layout = SVPullToRefreshLayout(context)
        val scrollView = ScrollView(context)
        val content = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
        content.addView(View(context), LinearLayout.LayoutParams(400, contentHeight))
        scrollView.addView(content)
        layout.addView(scrollView)
        layout.viewHeight = 60
        layout.measure(View.MeasureSpec.makeMeasureSpec(400, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(800, View.MeasureSpec.EXACTLY))
        layout.layout(0, 0, 400, 800)
        return layout to scrollView
    }

    /** A finger drag of [distance] pixels (negative = up) on the layout, optionally released. */
    private fun drag(layout: SVPullToRefreshLayout, distance: Float, release: Boolean = true, startY: Float = 400f) {
        val t = SystemClock.uptimeMillis()
        layout.dispatchTouchEvent(MotionEvent.obtain(t, t, MotionEvent.ACTION_DOWN, 200f, startY, 0))
        val steps = 20
        for (i in 1..steps) {
            layout.dispatchTouchEvent(MotionEvent.obtain(t, t + i * 10, MotionEvent.ACTION_MOVE, 200f, startY + distance * i / steps, 0))
        }
        if (release) layout.dispatchTouchEvent(MotionEvent.obtain(t, t + 300, MotionEvent.ACTION_UP, 200f, startY + distance, 0))
    }

    /** Lifts the finger of the drag in progress. */
    private fun lift(layout: SVPullToRefreshLayout) {
        val t = SystemClock.uptimeMillis()
        layout.dispatchTouchEvent(MotionEvent.obtain(t, t, MotionEvent.ACTION_UP, 200f, 700f, 0))
    }

    private fun settle() = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(600))

    @Test
    fun pullDownPastTheTriggerLoadsAndStopAnimatingHides() {
        val (layout, scrollView) = makeLayout(2000)
        var loads = 0
        layout.addPullToRefresh { loads++ }
        val view = layout.pullToRefreshView!!
        drag(layout, 300f, release = false)
        assertEquals("150 px pulled (resistance 2) is past 60", SVPullToRefreshState.TRIGGERED, view.state)
        assertTrue("the content moved down with the pull", scrollView.top > 0)
        lift(layout)
        settle()
        assertEquals(SVPullToRefreshState.LOADING, view.state)
        assertEquals(1, loads)
        assertEquals("held open at the view's height", 60, scrollView.top)
        view.stopAnimating()
        settle()
        assertEquals(SVPullToRefreshState.STOPPED, view.state)
        assertEquals(0, scrollView.top)
    }

    @Test
    fun shortPullDoesNotLoad() {
        val (layout, scrollView) = makeLayout(2000)
        var loads = 0
        layout.addPullToRefresh { loads++ }
        drag(layout, 80f)
        settle()
        assertEquals(SVPullToRefreshState.STOPPED, layout.pullToRefreshView!!.state)
        assertEquals(0, loads)
        assertEquals(0, scrollView.top)
    }

    @Test
    fun pullThresholdFactorScalesTheTriggerDistance() {
        val (layout, _) = makeLayout(2000)
        layout.addPullToRefresh { }
        layout.pullThresholdFactor = 3f
        drag(layout, 300f, release = false)
        assertEquals("150 px is short of 180", SVPullToRefreshState.STOPPED, layout.pullToRefreshView!!.state)
    }

    @Test
    fun noPullDownWhenTheContentIsNotAtItsStart() {
        val (layout, scrollView) = makeLayout(2000)
        var loads = 0
        layout.addPullToRefresh { loads++ }
        scrollView.scrollTo(0, 500)
        drag(layout, 300f)
        settle()
        assertEquals(0, loads)
    }

    @Test
    fun triggerPullToRefreshLoadsAndShowsTheView() {
        val (layout, scrollView) = makeLayout(2000)
        var loads = 0
        layout.addPullToRefresh { loads++ }
        layout.triggerPullToRefresh()
        settle()
        assertEquals(SVPullToRefreshState.LOADING, layout.pullToRefreshView!!.state)
        assertEquals(1, loads)
        assertEquals(60, scrollView.top)
    }

    @Test
    fun topAndBottomTogether() {
        val (layout, scrollView) = makeLayout(300)
        val calls = mutableListOf<String>()
        layout.addPullToRefresh(SVPullToRefreshPosition.TOP) { calls += "top" }
        layout.addPullToRefresh(SVPullToRefreshPosition.BOTTOM) { calls += "bottom" }
        assertNotNull(layout.pullToRefreshView(SVPullToRefreshPosition.BOTTOM))
        drag(layout, -300f)
        settle()
        assertEquals(listOf("bottom"), calls)
        assertEquals("held open above the bottom view", -60, scrollView.top)
        layout.pullToRefreshView(SVPullToRefreshPosition.BOTTOM)!!.stopAnimating()
        settle()
        drag(layout, 300f)
        settle()
        assertEquals(listOf("bottom", "top"), calls)
    }

    @Test
    fun titlesSubtitlesAndCustomViews() {
        val (layout, _) = makeLayout(2000)
        layout.addPullToRefresh { }
        val view = layout.pullToRefreshView!!
        assertEquals(context.getString(R.string.sv_pull_to_refresh), view.titleLabel.text)
        view.setTitle("Pull me", SVPullToRefreshState.ALL)
        view.setSubtitle("Last update: now", SVPullToRefreshState.STOPPED)
        assertEquals("Pull me", view.titleLabel.text)
        assertEquals(View.VISIBLE, view.subtitleLabel.visibility)
        assertEquals("Pull me, Last update: now", view.contentDescription)
        val first = TextView(context)
        val second = TextView(context)
        view.setCustomView(first, SVPullToRefreshState.STOPPED)
        assertEquals(view, first.parent)
        view.setCustomView(second, SVPullToRefreshState.STOPPED)
        assertNull("a replaced custom view is removed (#165)", first.parent)
        assertEquals(view, second.parent)
    }

    @Test
    fun listenerSeesStatesAndProgress() {
        val (layout, _) = makeLayout(2000)
        layout.addPullToRefresh { }
        val states = mutableListOf<SVPullToRefreshState>()
        var lastProgress = 0f
        layout.pullToRefreshView!!.listener = object : SVPullToRefreshViewListener {
            override fun onStateChanged(view: SVPullToRefreshView, oldState: SVPullToRefreshState, state: SVPullToRefreshState) { states += state }
            override fun onPull(view: SVPullToRefreshView, distance: Float, progress: Float) { lastProgress = progress }
        }
        drag(layout, 300f, release = false)
        assertTrue(lastProgress >= 1f)
        lift(layout)
        settle()
        assertEquals(listOf(SVPullToRefreshState.TRIGGERED, SVPullToRefreshState.STOPPED, SVPullToRefreshState.LOADING), states)
    }

    @Test
    fun infiniteScrollingAtTheEndOnly() {
        val (layout, scrollView) = makeLayout(2000)
        var loads = 0
        layout.addInfiniteScrolling { loads++ }
        scrollView.scrollTo(0, 600)
        layout.checkInfiniteScrolling()
        assertEquals("not at the end yet", 0, loads)
        scrollView.scrollTo(0, 2000 - 800)
        layout.checkInfiniteScrolling()
        assertEquals(1, loads)
        val view = layout.infiniteScrollingView!!
        assertEquals(SVInfiniteScrollingState.LOADING, view.state)
        assertEquals(View.VISIBLE, view.visibility)
        assertEquals("room for the view after the content", 60, scrollView.paddingBottom)
        view.stopAnimating()
        assertEquals(SVInfiniteScrollingState.STOPPED, view.state)
        assertEquals("the inset is reset (#237)", 0, scrollView.paddingBottom)
    }

    @Test
    fun noInfiniteScrollingOnShortContentOrWhileRefreshing() {
        val (shortLayout, _) = makeLayout(300)
        var loads = 0
        shortLayout.addInfiniteScrolling { loads++ }
        shortLayout.checkInfiniteScrolling()
        assertEquals("content shorter than the view (#157, #277)", 0, loads)

        val (layout, scrollView) = makeLayout(2000)
        layout.addPullToRefresh { }
        layout.addInfiniteScrolling { loads++ }
        layout.triggerPullToRefresh()
        settle()
        scrollView.scrollTo(0, 2000 - 800)
        layout.checkInfiniteScrolling()
        assertEquals("not while refreshing (#163, #254, #260)", 0, loads)
    }

    @Test
    fun infiniteScrollingThresholdAndDisabling() {
        val (layout, scrollView) = makeLayout(2000)
        var loads = 0
        layout.addInfiniteScrolling { loads++ }
        layout.infiniteScrollingThreshold = 300
        scrollView.scrollTo(0, 2000 - 800 - 250)
        layout.checkInfiniteScrolling()
        assertEquals("within 300 px of the end (#154)", 1, loads)
        layout.infiniteScrollingView!!.stopAnimating()
        layout.infiniteScrollingView!!.isInfiniteScrollingEnabled = false
        scrollView.scrollTo(0, 2000 - 800)
        layout.checkInfiniteScrolling()
        assertEquals(1, loads)
        layout.showsInfiniteScrolling = false
        layout.triggerInfiniteScrolling()
        assertEquals(1, loads)
    }
}
