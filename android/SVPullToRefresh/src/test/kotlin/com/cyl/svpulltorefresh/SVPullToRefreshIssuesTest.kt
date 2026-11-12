package com.cyl.svpulltorefresh

import android.content.Context
import android.graphics.Typeface
import android.os.Looper
import android.os.SystemClock
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import android.widget.HorizontalScrollView
import android.widget.LinearLayout
import android.widget.ScrollView
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.time.Duration

/**
 * The source's open issues fixed in the Kotlin version (docs/Android-Port.md, the SVPullToRefresh issue table); each
 * test names its issues.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class SVPullToRefreshIssuesTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    private fun measure(layout: SVPullToRefreshLayout) {
        layout.measure(View.MeasureSpec.makeMeasureSpec(400, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(800, View.MeasureSpec.EXACTLY))
        layout.layout(0, 0, 400, 800)
    }

    /** A layout of 400 x 800 around a ScrollView whose content is [contentHeight] high. */
    private fun makeLayout(contentHeight: Int): Pair<SVPullToRefreshLayout, ScrollView> {
        val layout = SVPullToRefreshLayout(context)
        val scrollView = ScrollView(context)
        val content = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
        content.addView(View(context), LinearLayout.LayoutParams(400, contentHeight))
        scrollView.addView(content)
        layout.addView(scrollView)
        layout.viewHeight = 60
        measure(layout)
        return layout to scrollView
    }

    private fun drag(layout: SVPullToRefreshLayout, distance: Float, release: Boolean = true, startY: Float = 400f) {
        val t = SystemClock.uptimeMillis()
        layout.dispatchTouchEvent(MotionEvent.obtain(t, t, MotionEvent.ACTION_DOWN, 200f, startY, 0))
        val steps = 20
        for (i in 1..steps) {
            layout.dispatchTouchEvent(MotionEvent.obtain(t, t + i * 10, MotionEvent.ACTION_MOVE, 200f, startY + distance * i / steps, 0))
        }
        if (release) layout.dispatchTouchEvent(MotionEvent.obtain(t, t + 300, MotionEvent.ACTION_UP, 200f, startY + distance, 0))
    }

    private fun lift(layout: SVPullToRefreshLayout) {
        val t = SystemClock.uptimeMillis()
        layout.dispatchTouchEvent(MotionEvent.obtain(t, t, MotionEvent.ACTION_UP, 200f, 700f, 0))
    }

    private fun idle(millis: Long = 600) = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(millis))

    private class RecordingView(context: Context, position: SVPullToRefreshPosition) : SVPullToRefreshView(context, position) {
        var pulls = 0
        var updates = 0
        override fun onPull(distance: Float, progress: Float) { pulls++ }
        override fun updateForState() { super.updateForState(); updates++ }
    }

    private class RecordingInfiniteView(context: Context) : SVInfiniteScrollingView(context) {
        val states = mutableListOf<SVInfiniteScrollingState>()
        override fun updateForState() { super.updateForState(); states += state }
    }

    @Test
    fun subclassedViewsComeFromFactories() {
        // #195: the refresh view can be subclassed.
        val (layout, scrollView) = makeLayout(2000)
        layout.addPullToRefresh(viewFactory = ::RecordingView) { }
        layout.addInfiniteScrolling(viewFactory = ::RecordingInfiniteView) { }
        val view = layout.pullToRefreshView as RecordingView
        val updatesBefore = view.updates
        drag(layout, 300f)
        idle()
        assertTrue("onPull is called while pulling", view.pulls > 0)
        assertTrue("updateForState runs on each state change", view.updates > updatesBefore)
        assertEquals("the subclass is not taken for the content", scrollView, layout.target)
        val infinite = layout.infiniteScrollingView as RecordingInfiniteView
        view.stopAnimating()
        idle()
        layout.triggerInfiniteScrolling()
        assertEquals(SVInfiniteScrollingState.LOADING, infinite.states.last())
    }

    @Test
    fun contentGravityAndFonts() {
        // #155 alignment, #162 fonts.
        val (layout, _) = makeLayout(2000)
        layout.addPullToRefresh { }
        val view = layout.pullToRefreshView!!
        view.contentGravity = Gravity.START or Gravity.CENTER_VERTICAL
        fun horizontal(gravity: Int) = Gravity.getAbsoluteGravity(gravity, View.LAYOUT_DIRECTION_LTR) and Gravity.HORIZONTAL_GRAVITY_MASK
        assertEquals(Gravity.LEFT, horizontal(view.titleLabel.gravity))
        val content = view.titleLabel.parent.parent as LinearLayout
        assertEquals(Gravity.LEFT, horizontal(content.gravity))
        view.titleLabel.typeface = Typeface.SERIF
        view.titleLabel.textSize = 20f
        view.setTitle("Custom", SVPullToRefreshState.ALL)
        assertEquals("a font set on the label survives title changes", Typeface.SERIF, view.titleLabel.typeface)
    }

    @Test
    fun completedTitleStaysThenHides() {
        // #231: "refresh complete" for a second, then hide.
        val (layout, scrollView) = makeLayout(2000)
        layout.addPullToRefresh { }
        val view = layout.pullToRefreshView!!
        view.completedTitle = context.getString(R.string.sv_refresh_completed)
        layout.triggerPullToRefresh()
        idle()
        view.stopAnimating()
        idle(300)
        assertEquals(SVPullToRefreshState.STOPPED, view.state)
        assertTrue(view.isShowingCompleted)
        assertEquals("Updated", view.titleLabel.text)
        assertEquals("still open", 60, scrollView.top)
        assertEquals(View.VISIBLE, view.visibility)
        idle(1000)
        assertFalse(view.isShowingCompleted)
        assertEquals(0, scrollView.top)
        assertEquals(context.getString(R.string.sv_pull_to_refresh), view.titleLabel.text)
    }

    @Test
    fun hiddenBeforeTheFirstPullAndAfterHiding() {
        // #210 and #232: no arrow or texts before the first pull; #131: hides cleanly when stopped mid-animation.
        val (layout, scrollView) = makeLayout(2000)
        layout.addPullToRefresh { }
        val view = layout.pullToRefreshView!!
        assertEquals(View.INVISIBLE, view.visibility)
        drag(layout, 300f, release = false)
        assertEquals(View.VISIBLE, view.visibility)
        lift(layout)
        idle()
        assertEquals(SVPullToRefreshState.LOADING, view.state)
        view.stopAnimating()
        layout.triggerPullToRefresh()
        view.stopAnimating()
        idle()
        assertEquals(0, scrollView.top)
        assertEquals(View.INVISIBLE, view.visibility)
        layout.showsPullToRefresh = false
        assertEquals(View.GONE, view.visibility)
    }

    @Test
    fun titleSetBeforeTheFirstPullShows() {
        // #291: setTitle works on the first pull.
        val (layout, _) = makeLayout(2000)
        layout.addPullToRefresh { }
        val view = layout.pullToRefreshView!!
        view.setTitle("Pull now", SVPullToRefreshState.STOPPED)
        view.setTitle("Let go", SVPullToRefreshState.TRIGGERED)
        drag(layout, 60f, release = false)
        assertEquals("Pull now", view.titleLabel.text)
        drag(layout, 300f, release = false)
        assertEquals("Let go", view.titleLabel.text)
    }

    @Test
    fun removePullToRefreshAndInfiniteScrolling() {
        // #261: remove infinite scrolling (and pull to refresh).
        val (layout, scrollView) = makeLayout(2000)
        var loads = 0
        layout.addPullToRefresh { loads++ }
        layout.removePullToRefresh()
        assertNull(layout.pullToRefreshView)
        drag(layout, 300f)
        idle()
        assertEquals(0, loads)
        assertEquals(0, scrollView.top)
        layout.addInfiniteScrolling { loads++ }
        layout.triggerInfiniteScrolling()
        assertEquals(60, scrollView.paddingBottom)
        layout.removeInfiniteScrolling()
        assertNull(layout.infiniteScrollingView)
        assertEquals("the room is given back", 0, scrollView.paddingBottom)
        assertEquals(1, layout.childCount)
    }

    @Test
    fun loadMoreButtonAndNoMoreData() {
        // #217: no automatic trigger, a manual one instead; #246: a "Load more" button and "No more data".
        val (layout, scrollView) = makeLayout(2000)
        var loads = 0
        layout.addInfiniteScrolling { loads++ }
        layout.automaticallyTriggersInfiniteScrolling = false
        val view = layout.infiniteScrollingView!!
        assertEquals(View.VISIBLE, view.visibility)
        assertEquals("room for the button", 60, scrollView.paddingBottom)
        assertEquals(context.getString(R.string.sv_load_more), view.titleLabel.text)
        assertTrue(view.titleLabel.isClickable)
        scrollView.scrollTo(0, 2000 + 60 - 800)
        layout.checkInfiniteScrolling()
        assertEquals("the end does not load by itself", 0, loads)
        measure(layout)
        assertEquals("the button sits after the content's end", 800 - 60, view.top)
        view.titleLabel.performClick()
        assertEquals(1, loads)
        assertEquals(SVInfiniteScrollingState.LOADING, view.state)
        assertEquals(View.GONE, view.titleLabel.visibility)
        assertEquals(scrollView.scrollY, 2000 + 60 - 800)
        view.stopAnimating()
        assertEquals("the button stays", 60, scrollView.paddingBottom)
        view.showsNoMoreData = true
        assertEquals(context.getString(R.string.sv_no_more_data), view.titleLabel.text)
        assertFalse(view.titleLabel.isClickable)
        layout.triggerInfiniteScrolling()
        assertEquals(1, loads)
        layout.automaticallyTriggersInfiniteScrolling = true
        assertEquals("No more data keeps its room", 60, scrollView.paddingBottom)
        view.showsNoMoreData = false
        assertEquals(0, scrollView.paddingBottom)
        assertEquals(View.GONE, view.visibility)
    }

    @Test
    fun scrollingBackDoesNotLoadMore() {
        // #288: scrolling up must not start infinite scrolling.
        val (layout, scrollView) = makeLayout(2000)
        var loads = 0
        layout.addInfiniteScrolling { loads++ }
        layout.infiniteScrollingThreshold = 300
        scrollView.scrollTo(0, 1100)
        assertEquals("scrolling forward near the end loads", 1, loads)
        layout.infiniteScrollingView!!.stopAnimating()
        scrollView.scrollTo(0, 1050)
        assertEquals("scrolling back does not", 1, loads)
        scrollView.scrollTo(0, 1080)
        assertEquals("forward again loads again (#293)", 2, loads)
    }

    @Test
    fun horizontalInfiniteScrolling() {
        // Pull requests #146, #180, #203.
        val layout = SVPullToRefreshLayout(context)
        val scrollView = HorizontalScrollView(context)
        val content = LinearLayout(context)
        content.addView(View(context), LinearLayout.LayoutParams(2000, 800))
        scrollView.addView(content)
        layout.addView(scrollView)
        layout.viewHeight = 60
        measure(layout)
        var loads = 0
        layout.addInfiniteScrolling(SVInfiniteScrollingDirection.HORIZONTAL) { loads++ }
        scrollView.scrollTo(800, 0)
        assertEquals(0, loads)
        scrollView.scrollTo(2000 - 400, 0)
        assertEquals(1, loads)
        assertEquals(60, scrollView.paddingRight)
        assertEquals(0, scrollView.paddingBottom)
        layout.infiniteScrollingView!!.stopAnimating()
        assertEquals(0, scrollView.paddingRight)
    }

    @Test
    fun contentInsetsMoveTheTriggers() {
        // Pull requests #173, #177 (top) and #297, #300 (bottom).
        val (layout, scrollView) = makeLayout(2000)
        layout.addPullToRefresh { }
        layout.contentInsetTop = 40
        drag(layout, 180f, release = false)
        assertEquals("90 px is short of 60 + 40", SVPullToRefreshState.STOPPED, layout.pullToRefreshView!!.state)
        drag(layout, 220f, release = false)
        assertEquals(SVPullToRefreshState.TRIGGERED, layout.pullToRefreshView!!.state)
        lift(layout)
        layout.pullToRefreshView!!.stopAnimating()
        idle()
        var loads = 0
        layout.addInfiniteScrolling { loads++ }
        layout.contentInsetBottom = 100
        scrollView.scrollTo(0, 1200 - 90)
        assertEquals("within the bottom inset", 1, loads)
    }

    @Test
    fun stoppingKeepsTheContentWhereTheAppPutIt() {
        // #70: prepended items keep their position after stopAnimating.
        val (layout, scrollView) = makeLayout(2000)
        layout.addPullToRefresh { }
        layout.triggerPullToRefresh()
        idle()
        scrollView.scrollTo(0, 300)
        layout.pullToRefreshView!!.stopAnimating()
        idle()
        assertEquals(300, scrollView.scrollY)
        assertEquals(0, scrollView.top)
    }

    @Test
    fun severalLayoutsOnScreenAreIndependent() {
        // #88: several scroll views with pull to refresh.
        val (first, _) = makeLayout(2000)
        val (second, _) = makeLayout(2000)
        first.addPullToRefresh { }
        second.addPullToRefresh { }
        var secondChanges = 0
        second.pullToRefreshView!!.listener = object : SVPullToRefreshViewListener {
            override fun onPull(view: SVPullToRefreshView, distance: Float, progress: Float) { secondChanges++ }
        }
        drag(first, 300f)
        idle()
        assertEquals(SVPullToRefreshState.LOADING, first.pullToRefreshView!!.state)
        assertEquals(SVPullToRefreshState.STOPPED, second.pullToRefreshView!!.state)
        assertEquals(0, secondChanges)
    }

    @Test
    fun pullingShortContentDoesNotLoadMore() {
        // #96 and #284: a pull on short content does not start infinite scrolling (and does not crash), whichever is
        // added first.
        val (layout, _) = makeLayout(300)
        val calls = mutableListOf<String>()
        layout.addInfiniteScrolling { calls += "more" }
        layout.addPullToRefresh { calls += "refresh" }
        drag(layout, 300f)
        idle()
        assertEquals(listOf("refresh"), calls)
    }

    @Test
    fun triggerInfiniteScrollingThenStopRestores() {
        // #208: a manual trigger keeps the position and stopping restores the content.
        val (layout, scrollView) = makeLayout(2000)
        layout.addInfiniteScrolling { }
        scrollView.scrollTo(0, 500)
        layout.triggerInfiniteScrolling()
        assertEquals(500, scrollView.scrollY)
        layout.infiniteScrollingView!!.stopAnimating()
        assertEquals(0, scrollView.paddingBottom)
        assertEquals(500, scrollView.scrollY)
    }

    @Test
    fun hidingInfiniteScrollingDoesNotJump() {
        // #250: showsInfiniteScrolling = NO only gives the room back.
        val (layout, scrollView) = makeLayout(2000)
        layout.addInfiniteScrolling { }
        scrollView.scrollTo(0, 600)
        layout.triggerInfiniteScrolling()
        layout.showsInfiniteScrolling = false
        assertEquals(600, scrollView.scrollY)
        assertEquals(0, scrollView.paddingBottom)
        assertEquals(View.GONE, layout.infiniteScrollingView!!.visibility)
    }

    @Test
    fun gridRecyclerViewRefreshesMoreThanOnce() {
        // #196 and #258: a collection view (a grid RecyclerView) refreshes, also the second time.
        val layout = SVPullToRefreshLayout(context)
        val recycler = RecyclerView(context)
        recycler.layoutManager = GridLayoutManager(context, 2)
        recycler.adapter = object : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
            override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
                object : RecyclerView.ViewHolder(View(parent.context).apply { layoutParams = ViewGroup.LayoutParams(200, 100) }) {}
            override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {}
            override fun getItemCount() = 4
        }
        layout.addView(recycler)
        layout.viewHeight = 60
        var loads = 0
        layout.addPullToRefresh { loads++ }
        measure(layout)
        repeat(2) {
            drag(layout, 400f)
            idle()
            assertEquals(it + 1, loads)
            layout.pullToRefreshView!!.stopAnimating()
            idle()
            assertEquals(0, recycler.top)
        }
    }

    @Test
    fun webViewPullsToRefresh() {
        // #302: pull to refresh on a web view.
        val layout = SVPullToRefreshLayout(context)
        layout.addView(WebView(context))
        layout.viewHeight = 60
        var loads = 0
        layout.addPullToRefresh { loads++ }
        measure(layout)
        drag(layout, 300f, release = false)
        assertEquals(SVPullToRefreshState.TRIGGERED, layout.pullToRefreshView!!.state)
        lift(layout)
        idle()
        assertEquals(1, loads)
    }

    @Test
    fun customArrowOwnHeightAndInfiniteCustomView() {
        // #117 and #174: hide or replace the arrow (pull requests #107, #190); #103: a custom view taller than the view
        // keeps its height (#148); #205: the infinite-scrolling custom view shows while loading (#140, #165).
        val (layout, _) = makeLayout(2000)
        layout.addPullToRefresh { }
        val view = layout.pullToRefreshView!!
        val arrow = View(context)
        view.customArrowView = arrow
        assertEquals(view.activityIndicatorView.parent, arrow.parent)
        assertEquals(View.VISIBLE, arrow.visibility)
        layout.triggerPullToRefresh()
        assertEquals("the arrow hides while loading", View.GONE, arrow.visibility)
        view.stopAnimating()
        idle()
        view.customArrowView = null
        assertNull(arrow.parent)
        view.customViewKeepsOwnHeight = true
        val tall = View(context)
        view.setCustomView(tall, SVPullToRefreshState.ALL)
        assertEquals(ViewGroup.LayoutParams.WRAP_CONTENT, tall.layoutParams.height)

        layout.addInfiniteScrolling { }
        val infinite = layout.infiniteScrollingView!!
        val spinner = View(context)
        infinite.setCustomView(spinner, SVInfiniteScrollingState.LOADING)
        assertNull("not shown while stopped", spinner.parent)
        layout.triggerInfiniteScrolling()
        assertEquals(infinite, spinner.parent)
        assertEquals(View.GONE, infinite.activityIndicatorView.visibility)
        infinite.stopAnimating()
        assertNull(spinner.parent)
    }
}
