package com.scwang.smart.refresh

import android.app.Activity
import android.content.Context
import android.graphics.drawable.Animatable
import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ScrollView
import androidx.core.widget.NestedScrollView
import com.scwang.smart.refresh.footer.ClassicsFooter
import com.scwang.smart.refresh.header.ClassicsHeader
import com.scwang.smart.refresh.header.MaterialHeader
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.constant.RefreshState
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Assume.assumeTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.time.Duration

/**
 * SmartRefreshLayout issues handled in the Kotlin version (docs/Android-Port.md, "the remaining 133 issues"). The tests
 * run on both versions (`-PsrlKernel=kotlin` for the Kotlin one); a test of a fix made only in Kotlin is skipped on the
 * Java version through [assumeKotlin]. Each test names its issues.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class SmartRefreshKotlinIssuesTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()
    private var refreshes = 0
    private var loads = 0

    private val isKotlin = runCatching { Class.forName("com.scwang.smart.refresh.header.HeaderAccessibilityKt") }.isSuccess

    private fun assumeKotlin() = assumeTrue("fixed in the Kotlin version only", isKotlin)

    private fun idle(ms: Long = 2000) = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(ms))

    private fun content(height: Int) = ScrollView(activity).apply {
        addView(LinearLayout(activity).apply { addView(View(activity), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, height)) })
    }

    private fun layout(contentView: View = content(3000), header: RefreshHeader = ClassicsHeader(activity)) = SmartRefreshLayout(activity).apply {
        setRefreshContent(contentView)
        setRefreshHeader(header)
        setRefreshFooter(ClassicsFooter(activity))
        setOnRefreshListener { refreshes++ }
        setOnLoadMoreListener { loads++ }
    }

    /** Shows [view] as the activity's content, inside [parent] when given. */
    private fun <T : View> show(view: T, parent: ViewGroup? = null): T {
        if (parent != null) {
            parent.addView(view, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
            activity.setContentView(parent)
        } else {
            activity.setContentView(view)
        }
        idle(100)
        return view
    }

    private fun spinner(layout: SmartRefreshLayout) =
        SmartRefreshLayout::class.java.getDeclaredField("mSpinner").apply { isAccessible = true }.getInt(layout)

    /** A finger drag of [dy] pixels in 20 steps 16 ms apart, resting before it lifts. */
    private fun drag(view: View, dy: Float, release: Boolean = true, x: Float = 200f) {
        val down = SystemClock.uptimeMillis()
        var time = down
        var y = 300f
        view.dispatchTouchEvent(MotionEvent.obtain(down, time, MotionEvent.ACTION_DOWN, x, y, 0))
        repeat(20) {
            y += dy / 20
            time += 16
            view.dispatchTouchEvent(MotionEvent.obtain(down, time, MotionEvent.ACTION_MOVE, x, y, 0))
        }
        if (release) {
            time += 300
            view.dispatchTouchEvent(MotionEvent.obtain(down, time, MotionEvent.ACTION_MOVE, x, y, 0))
            view.dispatchTouchEvent(MotionEvent.obtain(down, time + 16, MotionEvent.ACTION_UP, x, y, 0))
        }
    }

    /** A parent that records what its children ask (a stand-in for ViewPager, ViewPager2 or a bottom sheet). */
    private class RecordingParent(context: Context) : FrameLayout(context) {
        val disallowRequests = ArrayList<Boolean>()
        var nestedDyUnconsumed = 0

        override fun requestDisallowInterceptTouchEvent(disallowIntercept: Boolean) {
            disallowRequests += disallowIntercept
            super.requestDisallowInterceptTouchEvent(disallowIntercept)
        }

        override fun onStartNestedScroll(child: View, target: View, axes: Int) = true

        override fun onNestedScroll(target: View, dxConsumed: Int, dyConsumed: Int, dxUnconsumed: Int, dyUnconsumed: Int) {
            nestedDyUnconsumed += dyUnconsumed
        }
    }

    // MARK: - Touches and the parent

    @Test
    fun aChildsRequestReachesTheParent() {
        // #1241: a child of a content without nested scrolling (a WebView with a sideways scrolling area) asks its
        // parents not to intercept; the request reached no parent, so the ViewPager around the layout still switched
        // pages.
        assumeKotlin()
        val parent = RecordingParent(activity)
        val inner = View(activity)
        val box = FrameLayout(activity).apply { addView(inner) }
        show(layout(box), parent)
        parent.disallowRequests.clear()
        inner.parent.requestDisallowInterceptTouchEvent(true)
        assertEquals(listOf(true), parent.disallowRequests)
    }

    @Test
    fun aTouchWhileLoadingKeepsThePager() {
        // #1258, #1260, #1305, #1432, #1534: while loading more (the footer still showing), a new finger on the layout
        // went to the ViewPager or ViewPager2 around it, which switched pages.
        assumeKotlin()
        val parent = RecordingParent(activity)
        val layout = show(layout(content(300)), parent)
        drag(layout, -600f)
        idle(500)
        assertEquals(RefreshState.Loading, layout.state)
        assertTrue(spinner(layout) < 0)
        parent.disallowRequests.clear()
        val t = SystemClock.uptimeMillis()
        layout.dispatchTouchEvent(MotionEvent.obtain(t, t, MotionEvent.ACTION_DOWN, 200f, 300f, 0))
        assertTrue("the parent is asked not to intercept", parent.disallowRequests.contains(true))
    }

    @Test
    fun withRefreshOffThePullDownGoesToTheParent() {
        // #1612: with refreshing turned off, the pull down at the top goes to the parent (a bottom sheet) through
        // nested scrolling. The content must keep nested scrolling on; turning it off also takes it from the parent.
        val parent = RecordingParent(activity)
        val list = NestedScrollView(activity).apply {
            addView(LinearLayout(activity).apply { addView(View(activity), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 3000)) })
        }
        val layout = show(layout(list), parent)
        layout.setEnableRefresh(false)
        drag(layout, 400f)
        idle()
        assertTrue("the parent got the pull: ${parent.nestedDyUnconsumed}", parent.nestedDyUnconsumed < 0)
        assertEquals(0, refreshes)
        assertEquals(RefreshState.None, layout.state)
    }

    // MARK: - Leaving the window

    @Test
    fun aFragmentSwitchedAwayKeepsRefreshing() {
        // #1429, #1168, #1198: switching to another fragment (the layout leaves the window) and back lost the refresh:
        // the header was gone and its animation stopped. Now it is still open and animating, and finishRefresh
        // closes it; a finish asked for while away still runs (#1400, #1414).
        assumeKotlin()
        val header = MaterialHeader(activity)
        val layout = show(layout(header = header))
        val parent = layout.parent as ViewGroup
        layout.autoRefresh(0)
        idle()
        assertEquals(RefreshState.Refreshing, layout.state)
        val height = spinner(layout)
        parent.removeView(layout)
        idle(300)
        assertEquals("still refreshing while away", RefreshState.Refreshing, layout.state)
        parent.addView(layout)
        idle(300)
        assertEquals(RefreshState.Refreshing, layout.state)
        assertEquals("the header is open again", height, spinner(layout))
        assertTrue("the spinner runs again", (field(header, "mProgress") as Animatable).isRunning)
        assertEquals(1, refreshes)
        layout.finishRefresh(0)
        idle()
        assertEquals(RefreshState.None, layout.state)
        assertEquals(0, spinner(layout))

        layout.autoRefresh(0)
        idle()
        layout.finishRefresh(1000)
        parent.removeView(layout)
        idle(3000)
        parent.addView(layout)
        idle(300)
        assertEquals("the finish asked for before leaving ran", RefreshState.None, layout.state)
        assertEquals(0, spinner(layout))
    }

    @Test
    fun aReleaseCutOffByLeavingStillRefreshes() {
        // #1137: leaving the window right after the release (RefreshReleased, the header still opening) left the
        // layout in RefreshReleased for good, and onRefresh never ran.
        assumeKotlin()
        val layout = show(layout())
        val parent = layout.parent as ViewGroup
        drag(layout, 600f)
        assertEquals(RefreshState.RefreshReleased, layout.state)
        parent.removeView(layout)
        assertEquals(RefreshState.Refreshing, layout.state)
        assertEquals(1, refreshes)
        parent.addView(layout)
        idle(300)
        assertEquals(layout.refreshHeader!!.view.height, spinner(layout))
        layout.finishRefresh(0)
        idle()
        assertEquals(RefreshState.None, layout.state)
    }

    @Test
    fun loadingKeepsGoingAcrossAFragmentSwitch() {
        // #1168: the same for loading more.
        assumeKotlin()
        val layout = show(layout(content(300)))
        val parent = layout.parent as ViewGroup
        drag(layout, -600f)
        idle()
        assertEquals(RefreshState.Loading, layout.state)
        parent.removeView(layout)
        idle(300)
        parent.addView(layout)
        idle(300)
        assertEquals(RefreshState.Loading, layout.state)
        assertTrue(spinner(layout) < 0)
        layout.finishLoadMore(0)
        idle()
        assertEquals(RefreshState.None, layout.state)
        assertEquals(0, spinner(layout))
    }

    // MARK: - The "no more data" footer

    @Test
    fun theFollowingFooterSitsRightBelowTheContent() {
        // #1475 (also the how-to of #1243, #1471: a wrap_content content): the footer that follows the content after
        // "no more data" sat lower by the layout's top padding, then jumped up to the last item.
        assumeKotlin()
        val layout = layout()
        layout.setRefreshContent(content(300), ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        layout.setPadding(0, 50, 0, 0)
        layout.setEnableFooterFollowWhenNoMoreData(true)
        show(layout)
        layout.setNoMoreData(true)
        layout.requestLayout()
        idle(100)
        val contentView = layout.refreshFooter!!.view.let { footer -> (0 until layout.childCount).map { layout.getChildAt(it) }.first { it is ScrollView } }
        assertEquals(contentView.bottom, layout.refreshFooter!!.view.top)
    }

    @Test
    fun theHeldFooterLetsGoWhenTheListGrows() {
        // #1352, #1615: with "no more data" shown below the last item, items added (or expanded) left the footer
        // floating over the list at the bottom until the list was scrolled to the end again.
        assumeKotlin()
        val list = content(3000)
        val layout = show(layout(list))
        layout.setEnableFooterFollowWhenNoMoreData(true)
        list.scrollTo(0, 100000)
        idle(100)
        drag(layout, -400f)
        idle()
        assertEquals(RefreshState.Loading, layout.state)
        layout.finishLoadMoreWithNoMoreData()
        idle(3000)
        val footerHeight = layout.refreshFooter!!.view.height
        assertEquals("the footer is held below the last item", -footerHeight, spinner(layout))
        val scrollBefore = list.scrollY
        // The list grows by 500 pixels (the content's LinearLayout is horizontal: its one child gets taller).
        (list.getChildAt(0) as ViewGroup).getChildAt(0).apply { layoutParams.height = 3500; requestLayout() }
        idle(100)
        assertEquals(0, spinner(layout))
        assertEquals("the items stay where they were", scrollBefore + footerHeight, list.scrollY)
        assertEquals(RefreshState.None, layout.state)
    }

    @Test
    fun theNoMoreDataFooterCanBeSeenUnderShortContent() {
        // #1427: with load more on short content turned off, the "no more data" footer just below the screen could
        // never be pulled into view.
        assumeKotlin()
        val layout = layout(content(300))
        layout.setEnableLoadMoreWhenContentNotFull(false)
        layout.setEnableFooterFollowWhenNoMoreData(true)
        show(layout)
        layout.setNoMoreData(true)
        drag(layout, -400f, release = false)
        assertTrue("the footer comes into view", spinner(layout) < 0)
        drag(layout, 0f)
        idle()
        assertEquals(0, loads)
    }

    // MARK: - Touches during animations

    /** Steps the clock [millis] in 16 ms frames, calling [each] after every frame. */
    private fun frames(millis: Long, each: () -> Unit = {}) = repeat((millis / 16).toInt()) { idle(16); each() }

    @Test
    fun aTouchDoesNotStopAnAutoRefresh() {
        // #1326, #1401, #1595: touching the screen while autoRefresh opens the header stopped the animation halfway:
        // the header jumped back (flashed), and with a child asking the parents not to intercept, no refresh came.
        assumeKotlin()
        val layout = show(layout())
        org.robolectric.shadows.ShadowChoreographer.setPaused(true)
        try {
            layout.autoRefresh(0, 3000, 1f, false)
            frames(160)
        } finally {
            org.robolectric.shadows.ShadowChoreographer.setPaused(false)
        }
        val before = spinner(layout)
        assertTrue("before the refresh height: $before of ${layout.refreshHeader!!.view.height}", before > 0 && before < layout.refreshHeader!!.view.height)
        val t = SystemClock.uptimeMillis()
        layout.dispatchTouchEvent(MotionEvent.obtain(t, t, MotionEvent.ACTION_DOWN, 200f, 300f, 0))
        (layout.getChildAt(0) as? ViewGroup)?.requestDisallowInterceptTouchEvent(true)
        layout.dispatchTouchEvent(MotionEvent.obtain(t, t + 16, MotionEvent.ACTION_MOVE, 200f, 305f, 0))
        assertTrue("no jump back: $before -> ${spinner(layout)}", spinner(layout) >= before)
        layout.dispatchTouchEvent(MotionEvent.obtain(t, t + 32, MotionEvent.ACTION_UP, 200f, 305f, 0))
        idle()
        assertEquals(RefreshState.Refreshing, layout.state)
        assertEquals(1, refreshes)
    }

    @Test
    fun aDragRateOfOneOpensTheHeaderWithoutOvershoot() {
        // #1449: autoRefresh(delay, duration, 1f, animationOnly) opens the header to its height and no further.
        val layout = show(layout())
        var highest = 0
        layout.autoRefresh(0, 300, 1f, false)
        frames(1000) { highest = maxOf(highest, spinner(layout)) }
        assertEquals(RefreshState.Refreshing, layout.state)
        assertEquals(layout.refreshHeader!!.view.height, highest)
    }

    /** A header that, like WeChat Moments, springs back to 0 on release with the kernel's animSpinner. */
    private class SpringBackHeader(context: Context) : ClassicsHeader(context) {
        private var kernel: com.scwang.smart.refresh.layout.api.RefreshKernel? = null

        override fun onInitialized(kernel: com.scwang.smart.refresh.layout.api.RefreshKernel, height: Int, maxDragHeight: Int) {
            super.onInitialized(kernel, height, maxDragHeight)
            this.kernel = kernel
        }

        override fun onReleased(refreshLayout: com.scwang.smart.refresh.layout.api.RefreshLayout, height: Int, maxDragHeight: Int) {
            super.onReleased(refreshLayout, height, maxDragHeight)
            kernel?.animSpinner(0)
        }
    }

    @Test
    fun aHeaderAnimatingItsOwnReleaseStillRefreshes() {
        // #1455: a header that runs its own release animation (kernel.animSpinner in onReleased) lost the refresh.
        assumeKotlin()
        val layout = show(layout(header = SpringBackHeader(activity)))
        drag(layout, 600f)
        idle()
        assertEquals(1, refreshes)
        assertEquals(RefreshState.Refreshing, layout.state)
        assertEquals(0, spinner(layout))
    }

    @Test
    fun theListScrollsRightAfterLoadingMore() {
        // #1169: after finishLoadMore the list would not scroll for about 300 ms, however it was swiped.
        assumeKotlin()
        val list = content(3000)
        val layout = show(layout(list))
        list.scrollTo(0, 100000)
        idle(100)
        drag(layout, -400f)
        idle()
        assertEquals(RefreshState.Loading, layout.state)
        layout.finishLoadMore(0)
        assertEquals(RefreshState.LoadFinish, layout.state)
        val before = list.scrollY
        drag(layout, 300f)
        assertTrue("the list scrolled: $before -> ${list.scrollY}", list.scrollY < before)
        idle()
        assertEquals(RefreshState.None, layout.state)
    }

    // MARK: - Crashes

    @Test
    fun aTranslucentPathsDrawableNeedsNoBitmap() {
        // #1405, #1533, #1535: a translucent PathsDrawable cached a bitmap the size of its bounds: "trying to draw too
        // large bitmap", or out of memory. Empty bounds scaled by setGeometricWidth also became huge.
        assumeKotlin()
        val drawable = com.scwang.smart.drawable.PathsDrawable()
        drawable.parserPaths("M0,0 L10,0 L10,20 Z")
        drawable.setBounds(0, 0, 20000, 20000)
        drawable.alpha = 128
        val canvas = android.graphics.Canvas(android.graphics.Bitmap.createBitmap(10, 10, android.graphics.Bitmap.Config.ARGB_8888))
        drawable.draw(canvas)
        assertEquals("the paint keeps its alpha", 128, (field(drawable, "mPaint") as android.graphics.Paint).alpha)
        val empty = com.scwang.smart.drawable.PathsDrawable()
        empty.setBounds(0, 0, 0, 0)
        empty.setGeometricWidth(100)
        assertEquals(0, empty.bounds.width())
    }

    /** A header that removes the layout's content while it is laid out, once. */
    private class RemovingHeader(context: Context) : ClassicsHeader(context) {
        var armed = false

        override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
            super.onLayout(changed, l, t, r, b)
            if (!armed) return
            armed = false
            val layout = parent as ViewGroup
            (0 until layout.childCount).map { layout.getChildAt(it) }.filter { it !== this }.forEach { layout.removeView(it) }
        }
    }

    @Test
    fun aChildRemovedDuringLayoutDoesNotCrash() {
        // #1544: a child removed while the layout laid out its children: NullPointerException (resolveLayoutParams on
        // a null child) in onLayout.
        assumeKotlin()
        val header = RemovingHeader(activity)
        val layout = show(layout(header = header))
        header.armed = true
        header.requestLayout()
        idle(100)
        assertTrue("the header removed its siblings", layout.childCount == 1)
    }

    @Test
    fun removedFromInsideAnAnimationFrameDoesNotCrash() {
        // #1228: a layout removed from inside an animation frame (here a listener of the closing header) emptied the
        // update listeners ValueAnimator was walking: NullPointerException in ValueAnimator.animateValue.
        assumeKotlin()
        val list = content(3000)
        val layout = show(layout(list))
        val parent = layout.parent as ViewGroup
        layout.autoRefresh(0)
        idle()
        // A list scrolled from the top: the closing animation also scrolls it, so it has two update listeners.
        list.scrollTo(0, 500)
        var removed = false
        layout.setOnMultiListener(object : com.scwang.smart.refresh.layout.simple.SimpleMultiListener() {
            override fun onHeaderMoving(header: RefreshHeader?, isDragging: Boolean, percent: Float, offset: Int, headerHeight: Int, maxDragHeight: Int) {
                if (!removed && !isDragging && offset in 1 until headerHeight) {
                    removed = true
                    parent.removeView(layout)
                }
            }
        })
        layout.finishRefresh(0)
        idle()
        assertTrue(removed)
    }

    @Test
    fun aThrowingScrollerStopsTheFlingInsteadOfCrashing() {
        // #1546: some devices' Scroller throws ArrayIndexOutOfBoundsException in computeScrollOffset.
        assumeKotlin()
        val layout = show(layout())
        val throwing = object : android.widget.Scroller(activity) {
            override fun computeScrollOffset(): Boolean = throw ArrayIndexOutOfBoundsException("length=101; index=-36")
        }
        SmartRefreshLayout::class.java.getDeclaredField("mScroller").apply { isAccessible = true }.set(layout, throwing)
        layout.computeScroll()
        assertTrue(throwing.isFinished)
    }

    private fun field(obj: Any, name: String): Any? {
        var c: Class<*>? = obj.javaClass
        while (c != null) {
            try { return c.getDeclaredField(name).apply { isAccessible = true }.get(obj) } catch (_: NoSuchFieldException) { c = c.superclass }
        }
        throw NoSuchFieldException(name)
    }
}
