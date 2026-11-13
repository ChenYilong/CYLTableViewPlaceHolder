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
import org.junit.Assert.assertFalse
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
    private fun drag(view: View, dy: Float, release: Boolean = true, x: Float = 200f, fromY: Float = 300f) {
        val down = SystemClock.uptimeMillis()
        var time = down
        var y = fromY
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
        assertEquals("the circle shows again", 1f, (field(header, "mCircleView") as View).scaleX)
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

    // MARK: - The second floor (TwoLevelHeader)

    private fun twoLevel(contentView: View = content(3000)): Pair<SmartRefreshLayout, com.scwang.smart.refresh.header.TwoLevelHeader> {
        val header = com.scwang.smart.refresh.header.TwoLevelHeader(activity)
        header.addView(View(activity), ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        header.setRefreshHeader(ClassicsHeader(activity))
        return show(layout(contentView, header)) to header
    }

    private fun tap(view: View, y: Float = 200f) {
        val t = SystemClock.uptimeMillis()
        view.dispatchTouchEvent(MotionEvent.obtain(t, t, MotionEvent.ACTION_DOWN, 200f, y, 0))
        view.dispatchTouchEvent(MotionEvent.obtain(t, t + 50, MotionEvent.ACTION_UP, 200f, y, 0))
    }

    /** A quick swipe of [dy] pixels in 4 steps 8 ms apart, from [fromY]. */
    private fun swipe(view: View, dy: Float, fromY: Float) {
        val t = SystemClock.uptimeMillis()
        var y = fromY
        view.dispatchTouchEvent(MotionEvent.obtain(t, t, MotionEvent.ACTION_DOWN, 200f, y, 0))
        repeat(4) { i ->
            y += dy / 4
            view.dispatchTouchEvent(MotionEvent.obtain(t, t + 8L * (i + 1), MotionEvent.ACTION_MOVE, 200f, y, 0))
        }
        view.dispatchTouchEvent(MotionEvent.obtain(t, t + 40, MotionEvent.ACTION_UP, 200f, y, 0))
    }

    @Test
    fun aSecondFloorOpenedInCodeStaysOpenWhenTouched() {
        // #1613: after openTwoLevel(true), one touch on the second floor closed it (opened by a pull, it stayed).
        val (layout, header) = twoLevel()
        header.openTwoLevel(true)
        idle()
        assertEquals(RefreshState.TwoLevel, layout.state)
        tap(layout)
        idle()
        assertEquals(RefreshState.TwoLevel, layout.state)
        assertEquals(layout.height, spinner(layout))
    }

    @Test
    fun aSecondFloorThatCannotBePulledClosedStaysOpen() {
        // #1213: with pull-to-close off, the first swipe up on the second floor still showed the main page.
        val (layout, header) = twoLevel()
        header.setEnablePullToCloseTwoLevel(false)
        header.openTwoLevel(false)
        idle()
        assertEquals(RefreshState.TwoLevel, layout.state)
        swipe(layout, -400f, layout.height - 20f)
        assertEquals("the main page does not show", layout.height, spinner(layout))
        idle()
        assertEquals(RefreshState.TwoLevel, layout.state)
        assertEquals(layout.height, spinner(layout))
    }

    @Test
    fun aQuickSwipeUpClosesTheSecondFloor() {
        // #1213, #1387: a quick swipe up (with pull-to-close on) could leave the page stuck on the second floor;
        // finishTwoLevel sometimes left it open.
        val (layout, header) = twoLevel()
        header.openTwoLevel(false)
        idle()
        swipe(layout, -600f, layout.height - 20f)
        idle()
        assertEquals(RefreshState.None, layout.state)
        assertEquals(0, spinner(layout))
        repeat(3) {
            header.openTwoLevel(false)
            idle(300)
            header.finishTwoLevel()
            idle()
            assertEquals(RefreshState.None, layout.state)
            assertEquals(0, spinner(layout))
        }
    }

    /** Runs [block] with the Choreographer paused, so [frames] steps animations one frame at a time. */
    private fun <T> paused(block: () -> T): T {
        org.robolectric.shadows.ShadowChoreographer.setPaused(true)
        try { return block() } finally { org.robolectric.shadows.ShadowChoreographer.setPaused(false) }
    }

    @Test
    fun aTouchWhileTheFloorOpensInCodeKeepsItOpening() {
        // #1613: a touch while openTwoLevel(true) still opened the floor stopped it halfway, and lifting the finger
        // closed it.
        assumeKotlin()
        val (layout, header) = twoLevel()
        paused {
            header.openTwoLevel(true)
            frames(200)
            assertTrue(spinner(layout) in 1 until layout.height)
            tap(layout)
            frames(2000)
        }
        idle()
        assertEquals(RefreshState.TwoLevel, layout.state)
        assertEquals(layout.height, spinner(layout))
    }

    @Test
    fun finishTwoLevelWhileTheFloorOpensClosesIt() {
        // #1387: finishTwoLevel called while the floor still opened was ignored, and the floor stayed open.
        assumeKotlin()
        val (layout, header) = twoLevel()
        paused {
            header.openTwoLevel(false)
            frames(200)
            header.finishTwoLevel()
            frames(2000)
        }
        idle()
        assertEquals(RefreshState.None, layout.state)
        assertEquals(0, spinner(layout))
    }

    @Test
    fun theContentScrollsWithASecondFloorHeader() {
        // #1512: with a TwoLevelHeader, a content set by setRefreshContent (a CoordinatorLayout or NestedScrollView
        // root) would not scroll.
        val list = NestedScrollView(activity).apply {
            addView(LinearLayout(activity).apply { addView(View(activity), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 3000)) })
        }
        val (layout, _) = twoLevel(list)
        drag(layout, -300f)
        idle()
        assertTrue("the content scrolled: ${list.scrollY}", list.scrollY > 0)
    }

    // MARK: - Localization

    private fun title(component: View) = (field(component, "mTitleText") as android.widget.TextView).text.toString()

    private fun inLocale(locale: java.util.Locale): Context =
        activity.createConfigurationContext(android.content.res.Configuration(activity.resources.configuration).apply { setLocale(locale) })

    @Test
    fun theClassicTextFollowsTheDeviceLanguage() {
        // #1318, #1434: the header and footer showed English on a phone set to Chinese. The text comes from the
        // libraries' resources in the context's language; English means the app's resources lack Chinese (for
        // example resourceConfigurations / resConfigs keeping only "en") or the app's locale was reset (a WebView
        // resets it on some Android versions).
        assertEquals("下拉可以刷新", title(ClassicsHeader(inLocale(java.util.Locale.SIMPLIFIED_CHINESE))))
        assertEquals("上拉加载更多", title(ClassicsFooter(inLocale(java.util.Locale.SIMPLIFIED_CHINESE))))
        assertEquals("下拉可以重新整理", title(ClassicsHeader(inLocale(java.util.Locale.forLanguageTag("zh-Hant-TW")))))
    }

    // MARK: - CoordinatorLayout contents

    /** A RecyclerView of [count] rows 100 pixels tall. */
    private fun recycler(context: Context, count: Int) = androidx.recyclerview.widget.RecyclerView(context).apply {
        layoutManager = androidx.recyclerview.widget.LinearLayoutManager(context)
        adapter = object : androidx.recyclerview.widget.RecyclerView.Adapter<androidx.recyclerview.widget.RecyclerView.ViewHolder>() {
            override fun getItemCount() = count
            override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
                object : androidx.recyclerview.widget.RecyclerView.ViewHolder(View(parent.context).apply {
                    layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 100)
                }) {}
            override fun onBindViewHolder(holder: androidx.recyclerview.widget.RecyclerView.ViewHolder, position: Int) {}
        }
    }

    /** A long drag of [dy] pixels in [steps] steps 16 ms apart, resting before it lifts. */
    private fun longDrag(view: View, dy: Float, steps: Int = 80) {
        val down = SystemClock.uptimeMillis()
        var time = down
        var y = if (dy < 0) 400f else 20f
        view.dispatchTouchEvent(MotionEvent.obtain(down, time, MotionEvent.ACTION_DOWN, 200f, y, 0))
        repeat(steps) {
            y += dy / steps
            time += 16
            view.dispatchTouchEvent(MotionEvent.obtain(down, time, MotionEvent.ACTION_MOVE, 200f, y, 0))
            idle(16)
        }
        time += 300
        view.dispatchTouchEvent(MotionEvent.obtain(down, time, MotionEvent.ACTION_MOVE, 200f, y, 0))
        view.dispatchTouchEvent(MotionEvent.obtain(down, time + 16, MotionEvent.ACTION_UP, 200f, y, 0))
    }

    @Test
    fun aCoordinatorContentLoadsMoreInTheSameGesture() {
        // #406, #1323, #1456, #1464, #1526: with a CoordinatorLayout content, a drag that reached the end of the list
        // did not pull the footer: the finger had to lift and pull again. The layout turns its nested scrolling off for
        // such a content, so it sees only touches, and it obeyed the list's request not to intercept them.
        assumeKotlin()
        val coordinator = androidx.coordinatorlayout.widget.CoordinatorLayout(activity)
        val list = recycler(activity, 8)
        coordinator.addView(list, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        val layout = show(layout(coordinator))
        longDrag(layout, -1600f)
        idle()
        assertFalse("the list reached its end", list.canScrollVertically(1))
        assertEquals("loading more started in the same gesture", 1, loads)

        layout.finishLoadMore(0)
        idle()
        refreshes = 0
        longDrag(layout, 1600f)
        idle()
        assertEquals("and refreshing at the top", 1, refreshes)
    }

    // MARK: - Questions the existing API answers

    @Test
    fun autoLoadMoreStartsLoadingWithoutAPull() {
        // #1144, #1484 (preloading n rows before the end): the app calls autoLoadMore() from its own scroll listener
        // when the n-th last row shows; it loads at once, without a pull.
        val layout = show(layout(content(3000)))
        assertTrue(layout.autoLoadMore())
        idle()
        assertEquals(1, loads)
        assertEquals(RefreshState.Loading, layout.state)
    }

    @Test
    fun anInnerLayoutRefreshesAloneWhenNested() {
        // #1531: with one SmartRefreshLayout inside another, a pull on the inner one refreshed the outer one.
        assumeKotlin()
        var outerRefreshes = 0
        val inner = layout(content(3000))
        val outer = SmartRefreshLayout(activity).apply {
            setRefreshContent(inner)
            setRefreshHeader(ClassicsHeader(activity))
            setOnRefreshListener { outerRefreshes++ }
        }
        show(outer)
        drag(outer, 600f)
        idle()
        assertEquals(1, refreshes)
        assertEquals(0, outerRefreshes)
    }

    @Test
    fun theFooterTriggerRateIsAShareOfTheFooterHeight() {
        // #1478: setFooterTriggerRate is a share of the footer's height (not of the screen); #1494: onFooterMoving
        // reports the pulled offset.
        val layout = layout(content(300))
        layout.setFooterTriggerRate(0.5f)
        var offset = 0
        layout.setOnMultiListener(object : com.scwang.smart.refresh.layout.simple.SimpleMultiListener() {
            override fun onFooterMoving(footer: com.scwang.smart.refresh.layout.api.RefreshFooter?, isDragging: Boolean, percent: Float, offset2: Int, footerHeight: Int, maxDragHeight: Int) {
                if (isDragging) offset = maxOf(offset, offset2)
            }
            override fun onLoadMore(refreshLayout: com.scwang.smart.refresh.layout.api.RefreshLayout) { loads++ }
        })
        show(layout)
        val footerHeight = layout.refreshFooter!!.view.height
        drag(layout, -footerHeight * 0.9f, release = false)
        assertTrue("onFooterMoving reports the offset: $offset", offset > 0)
        assertTrue("past half the footer: ${layout.state}", layout.state == RefreshState.ReleaseToLoad || layout.state == RefreshState.Loading)
    }

    @Test
    fun aRefreshingHeaderCanBeKeptFromBeingPushedBack() {
        // #1413: setDisableContentWhenRefresh(true) keeps the refreshing header from being pushed back up.
        val layout = show(layout())
        layout.setDisableContentWhenRefresh(true)
        layout.autoRefresh(0)
        idle()
        val open = spinner(layout)
        drag(layout, -300f)
        idle()
        assertEquals(open, spinner(layout))
        assertEquals(RefreshState.Refreshing, layout.state)
    }

    // MARK: - Accessibility

    @Test
    fun refreshAndLoadMoreAreAccessibilityActions() {
        // #1380: no way to load more without a touch screen (a TV remote). "Refresh" and "Load more" are now
        // accessibility actions with localized labels, for TalkBack, Switch Access, Voice Access and TV accessibility.
        assumeKotlin()
        val ids = Class.forName("com.scwang.smart.refresh.layout.kernel.R\$id")
        val refreshId = ids.getField("srl_action_refresh").getInt(null)
        val loadMoreId = ids.getField("srl_action_load_more").getInt(null)
        val layout = show(layout(content(3000)))
        val actions = layout.createAccessibilityNodeInfo().actionList.associate { it.id to it.label?.toString() }
        assertEquals("Refresh", actions[refreshId])
        assertEquals("Load more", actions[loadMoreId])
        assertTrue(layout.performAccessibilityAction(loadMoreId, null))
        idle()
        assertEquals(1, loads)
        layout.finishLoadMore(0)
        idle()
        assertTrue(layout.performAccessibilityAction(refreshId, null))
        idle()
        assertEquals(1, refreshes)
        assertFalse("no actions while refreshing", layout.createAccessibilityNodeInfo().actionList.any { it.id == refreshId })
    }

    // MARK: - MaterialHeader

    @Test
    fun theMaterialSpinnerRunsAgainAfterTheBackground() {
        // #1600: back from the background (Home) while refreshing, the spinner froze, often as a full circle: the
        // system had dropped its view animation while the drawable still said it was running.
        assumeKotlin()
        val header = MaterialHeader(activity)
        val layout = show(layout(header = header))
        layout.autoRefresh(0)
        idle()
        val progress = field(header, "mProgress") as Animatable
        val circle = field(progress, "mParent") as View
        circle.clearAnimation()
        assertFalse("a dropped animation is not running", progress.isRunning)
        header.dispatchWindowVisibilityChanged(View.GONE)
        header.dispatchWindowVisibilityChanged(View.VISIBLE)
        assertTrue(progress.isRunning)
        assertTrue("the circle animates again", circle.animation != null)
    }

    @Test
    fun aMaterialHeaderPullsOverALongList() {
        // #1523: with a long RecyclerView, the MaterialHeader could hardly be pulled down and did not refresh.
        val list = recycler(activity, 1000)
        val layout = show(layout(list, MaterialHeader(activity)))
        drag(layout, 600f)
        idle()
        assertEquals(1, refreshes)
    }

    // MARK: - Performance and leaks

    @Test
    fun anIdleLayoutDoesNotKeepRedrawing() {
        // #1578, #1360, #1559: after refreshing and loading, an idle layout kept the CPU drawing.
        val layout = show(layout(content(300)))
        layout.autoRefresh(0)
        idle()
        layout.finishRefresh(0)
        idle()
        drag(layout, -600f)
        idle()
        layout.finishLoadMore(0)
        idle(3000)
        var draws = 0
        val listener = android.view.ViewTreeObserver.OnPreDrawListener { draws++; true }
        layout.viewTreeObserver.addOnPreDrawListener(listener)
        idle(2000)
        layout.viewTreeObserver.removeOnPreDrawListener(listener)
        assertEquals("no drawing while idle", 0, draws)
    }

    @Test
    fun loadingManyTimesClosesJustAsFast() {
        // #1520, #1551: after many loads, the footer took longer and longer to close (up to an ANR).
        val layout = show(layout(content(300)))
        val steps = ArrayList<Int>()
        repeat(30) {
            drag(layout, -600f)
            idle(500)
            layout.finishLoadMore(0)
            var n = 0
            while (layout.state != RefreshState.None && n < 500) { idle(16); n++ }
            steps += n
        }
        assertTrue("closing took $steps frames", steps.max() <= steps.first() + 2)
    }

    /** Shows a layout with a listener holding a page, starts an autoRefresh, removes it; returns a weak reference. */
    private fun removedRefreshingLayout(): java.lang.ref.WeakReference<SmartRefreshLayout> {
        val page = Any()
        val layout = SmartRefreshLayout(activity)
        layout.setRefreshContent(content(3000))
        layout.setRefreshHeader(ClassicsHeader(activity))
        layout.setOnRefreshListener { page.hashCode() }
        activity.setContentView(layout)
        idle(100)
        layout.autoRefresh()
        idle(100)
        activity.setContentView(View(activity))
        return java.lang.ref.WeakReference(layout)
    }

    @Test
    fun aRemovedLayoutIsNotLeaked() {
        // #1307, #1342: a layout with listeners (and an autoRefresh still opening) leaked after its page was gone.
        // The setup runs in its own function, so no local variable of this test keeps the layout.
        val ref = removedRefreshingLayout()
        idle(5000)
        repeat(5) { System.gc(); System.runFinalization(); idle(10) }
        assertTrue("the layout was collected", ref.get() == null)
    }

    // MARK: - Listeners, colors and repeated calls

    @Test
    fun aListenerSetAfterTheRefreshStartedKeepsIt() {
        // #1397, #1536: an autoRefresh before its listener was set ended by itself after 3 seconds (before the data
        // came), and the listener set a moment later was never called. The Choreographer is paused: the spinner's
        // endless animation would otherwise move the test clock on by itself.
        assumeKotlin()
        fun bare() = SmartRefreshLayout(activity).apply {
            setRefreshContent(content(3000))
            setRefreshHeader(ClassicsHeader(activity))
        }
        val layout = show(bare())
        paused {
            layout.autoRefresh(0)
            frames(1000)
            assertEquals(RefreshState.Refreshing, layout.state)
            layout.setOnRefreshListener { refreshes++ }
            assertEquals("the late listener is called", 1, refreshes)
            frames(4000)
            assertEquals("and the refresh waits for it", RefreshState.Refreshing, layout.state)
            layout.finishRefresh(0)
            frames(1000)
            assertEquals(RefreshState.None, layout.state)

            val alone = show(bare())
            alone.autoRefresh(0)
            frames(1000)
            assertEquals(RefreshState.Refreshing, alone.state)
            frames(4000)
            assertEquals("with no listener at all it still ends", RefreshState.None, alone.state)
        }
    }

    @Test
    fun theLayoutsAccentColorIsTheFootersTextColor() {
        // #1212: srlAccentColor on the layout made the header's text white, but never the (Translate) footer's.
        assumeKotlin()
        val layout = show(layout())
        layout.setPrimaryColors(0, android.graphics.Color.WHITE)
        assertEquals(android.graphics.Color.WHITE, (field(layout.refreshHeader!!.view, "mTitleText") as android.widget.TextView).currentTextColor)
        assertEquals(android.graphics.Color.WHITE, (field(layout.refreshFooter!!.view, "mTitleText") as android.widget.TextView).currentTextColor)
    }

    @Test
    fun theDefaultFooterIsCreatedOnce() {
        // #1296: with a default footer creator, the footer was created twice.
        var created = 0
        SmartRefreshLayout.setDefaultRefreshFooterCreator { context, _ -> created++; ClassicsFooter(context) }
        try {
            val layout = SmartRefreshLayout(activity)
            layout.setRefreshContent(content(3000))
            show(layout)
            val parent = layout.parent as ViewGroup
            parent.removeView(layout)
            parent.addView(layout)
            idle(100)
            assertEquals(1, created)
        } finally {
            SmartRefreshLayout.setDefaultRefreshFooterCreator { context, _ -> ClassicsFooter(context) }
        }
    }

    @Test
    fun manyAutoRefreshCallsEndCleanly() {
        // #1356: autoRefresh called from several places at once (also while finishing) froze the page with the
        // header half shown.
        val layout = show(layout())
        repeat(3) { layout.autoRefresh() }
        idle(100)
        layout.autoRefresh()
        idle()
        layout.finishRefresh(0)
        layout.autoRefresh()
        idle(50)
        layout.autoRefresh()
        idle()
        if (layout.state == RefreshState.Refreshing) {
            layout.finishRefresh(0)
            idle()
        }
        assertEquals(RefreshState.None, layout.state)
        assertEquals(0, spinner(layout))
        drag(layout, 600f)
        idle()
        assertEquals("still refreshes afterwards", RefreshState.Refreshing, layout.state)
    }

    @Test
    fun aFocusedTextFieldKeepsFocusWhenRefreshingEnds() {
        // #1157: finishRefresh / finishLoadMore closed the soft keyboard of a text field in the content.
        val field = android.widget.EditText(activity)
        val box = LinearLayout(activity).apply { orientation = LinearLayout.VERTICAL; addView(field); addView(content(3000)) }
        val layout = show(layout(box))
        field.requestFocus()
        layout.autoRefresh(0)
        idle()
        layout.finishRefresh(0)
        idle()
        drag(layout, -600f)
        idle()
        layout.finishLoadMore(0)
        idle()
        assertTrue(field.isFocused)
    }

    @Test
    fun aConstraintLayoutWithZeroHeightDoesNotRebindForEver() {
        // #1425, #1270: in a ConstraintLayout with a 0dp height, the list inside kept measuring and binding rows.
        var binds = 0
        val list = androidx.recyclerview.widget.RecyclerView(activity).apply {
            layoutManager = androidx.recyclerview.widget.LinearLayoutManager(activity)
            adapter = object : androidx.recyclerview.widget.RecyclerView.Adapter<androidx.recyclerview.widget.RecyclerView.ViewHolder>() {
                override fun getItemCount() = 100
                override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
                    object : androidx.recyclerview.widget.RecyclerView.ViewHolder(View(parent.context).apply {
                        layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 100)
                    }) {}
                override fun onBindViewHolder(holder: androidx.recyclerview.widget.RecyclerView.ViewHolder, position: Int) { binds++ }
            }
        }
        val constraint = androidx.constraintlayout.widget.ConstraintLayout(activity)
        val layout = layout(list)
        constraint.addView(layout, androidx.constraintlayout.widget.ConstraintLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0).apply {
            topToTop = androidx.constraintlayout.widget.ConstraintLayout.LayoutParams.PARENT_ID
            bottomToBottom = androidx.constraintlayout.widget.ConstraintLayout.LayoutParams.PARENT_ID
        })
        activity.setContentView(constraint)
        idle(500)
        val settled = binds
        idle(2000)
        assertTrue(settled > 0)
        assertEquals("no more binding while idle", settled, binds)
    }

    // MARK: - Lists inside lists

    /** An outer RecyclerView of 10 rows 300 pixels tall; row 2 is an inner NestedScrollView. */
    private fun listWithInnerList(): Pair<androidx.recyclerview.widget.RecyclerView, NestedScrollView> {
        val inner = NestedScrollView(activity).apply {
            addView(LinearLayout(activity).apply { addView(View(activity), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 1000)) })
        }
        val outer = androidx.recyclerview.widget.RecyclerView(activity).apply {
            layoutManager = androidx.recyclerview.widget.LinearLayoutManager(activity)
            adapter = object : androidx.recyclerview.widget.RecyclerView.Adapter<androidx.recyclerview.widget.RecyclerView.ViewHolder>() {
                override fun getItemCount() = 10
                override fun getItemViewType(position: Int) = if (position == 2) 1 else 0
                override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
                    object : androidx.recyclerview.widget.RecyclerView.ViewHolder((if (viewType == 1) inner else View(parent.context)).apply {
                        layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 300)
                    }) {}
                override fun onBindViewHolder(holder: androidx.recyclerview.widget.RecyclerView.ViewHolder, position: Int) {}
            }
        }
        return outer to inner
    }

    @Test
    fun anInnerListAtItsTopDoesNotRefreshAScrolledOuterList() {
        // #1177, #1458: with the outer list scrolled away from its top, a pull on an inner list at its own top
        // refreshed: through nested scrolling, the layout trusted the inner list's leftover pull without asking whether
        // the content was at its top.
        assumeKotlin()
        val (outer, inner) = listWithInnerList()
        val layout = show(layout(outer))
        outer.scrollBy(0, 600)
        idle(100)
        assertTrue(outer.canScrollVertically(-1))
        assertFalse(inner.canScrollVertically(-1))
        // The inner list's leftover pull, as it reaches the layout through nested scrolling (the outer RecyclerView
        // is no nested-scrolling parent, so it skips it).
        assertTrue(inner.startNestedScroll(View.SCROLL_AXIS_VERTICAL))
        repeat(10) { inner.dispatchNestedScroll(0, 0, 0, -40, null) }
        assertEquals("no pull while the outer list is not at its top", 0, spinner(layout))
        inner.stopNestedScroll()
        idle()
        assertEquals(0, refreshes)
        assertEquals(RefreshState.None, layout.state)
    }

    @Test
    fun aButtonDoesNotClickAfterThePull() {
        // #1351: a short vertical drag that started on a button pulled the header and also clicked the button.
        var clicks = 0
        val button = android.widget.Button(activity).apply { text = "Tap"; setOnClickListener { clicks++ } }
        val box = LinearLayout(activity).apply { orientation = LinearLayout.VERTICAL; addView(button, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 600)) }
        val layout = show(layout(box))
        drag(layout, 120f, fromY = 100f)
        idle()
        assertEquals("no click after a pull", 0, clicks)
        tap(layout, 100f)
        idle()
        assertEquals("a tap still clicks", 1, clicks)
    }

    /** A NestedScrollView that records the actions it gets. */
    private class RecordingScroll(context: Context) : NestedScrollView(context) {
        val actions = ArrayList<Int>()

        override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
            actions += ev.actionMasked
            return super.dispatchTouchEvent(ev)
        }
    }

    @Test
    fun aChildGetsNoLiftWhileTheFingerIsDown() {
        // #1271: a refresh finished during a nested drag sent the list an ACTION_UP while the finger was still down.
        assumeKotlin()
        val list = RecordingScroll(activity).apply {
            addView(LinearLayout(activity).apply { addView(View(activity), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 3000)) })
        }
        val layout = show(layout(list))
        layout.autoRefresh(0)
        idle()
        drag(layout, 100f, release = false)
        assertTrue("a nested drag is in progress", field(layout, "mNestedInProgress") as Boolean)
        list.actions.clear()
        layout.finishRefresh(0)
        idle()
        assertFalse("no ACTION_UP before the finger lifts: ${list.actions}", list.actions.contains(MotionEvent.ACTION_UP))
    }

    @Test
    fun aBottomSheetSeesWhetherTheListIsAtItsTop() {
        // #1158: in a BottomSheetDialog the list could scroll down but not back up: the sheet asks its scrolling child
        // (this layout) whether it can scroll up, and the layout said no even with the list scrolled.
        assumeKotlin()
        val list = content(3000)
        val layout = show(layout(list))
        layout.setEnableRefresh(false)
        assertFalse("at the top with refreshing off", layout.canScrollVertically(-1))
        list.scrollTo(0, 500)
        idle(100)
        assertTrue("the list scrolls up", layout.canScrollVertically(-1))
    }

    @Test
    @org.robolectric.annotation.GraphicsMode(org.robolectric.annotation.GraphicsMode.Mode.NATIVE)
    fun aFixedHeaderWrapsItsText() {
        // #1138: with srlFixedHeaderViewId, a TextView in the fixed part did not wrap unless it had a fixed height.
        // Native graphics: the legacy shadows measure every character 1 pixel wide, so no text ever wraps.
        assumeKotlin()
        val text = android.widget.TextView(activity).apply {
            id = View.generateViewId()
            text = "A long line of text that cannot fit on one line of a narrow screen, so it has to wrap onto more lines."
        }
        val box = LinearLayout(activity).apply {
            orientation = LinearLayout.VERTICAL
            addView(text, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
            addView(content(3000))
        }
        val layout = layout(box)
        layout.setFixedHeaderViewId(text.id)
        show(layout)
        idle(100)
        assertTrue("wraps: ${text.lineCount} lines, ${text.height} px", text.lineCount > 1 && text.height >= text.lineCount * text.lineHeight * 0.9)
    }

    @Test
    fun theFooterMovesOnlyItsTranslationView() {
        // #1406: with srlFooterTranslationViewId set to the list, a pinned part (a collapsing app bar) still moved up
        // while loading more.
        val pinned = View(activity)
        val list = content(300).apply { id = View.generateViewId() }
        val box = LinearLayout(activity).apply {
            orientation = LinearLayout.VERTICAL
            addView(pinned, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 100))
            addView(list)
        }
        val layout = layout(box)
        layout.setFooterTranslationViewId(list.id)
        show(layout)
        drag(layout, -400f, release = false)
        assertTrue(spinner(layout) < 0)
        assertEquals("the pinned part stays", 0f, pinned.translationY + box.translationY)
        assertTrue("the list moves", list.translationY < 0)
        drag(layout, 0f)
        idle()
    }

    @Test
    fun aSidewaysListInsideScrollsSideways() {
        // #1500: a sideways list inside the content (in a list's header) could not be scrolled on its own.
        val row = recycler(activity, 30).apply {
            layoutManager = androidx.recyclerview.widget.LinearLayoutManager(activity, androidx.recyclerview.widget.LinearLayoutManager.HORIZONTAL, false)
        }
        val box = LinearLayout(activity).apply { orientation = LinearLayout.VERTICAL; addView(row, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 200)); addView(content(3000)) }
        val layout = show(layout(box))
        val t = SystemClock.uptimeMillis()
        layout.dispatchTouchEvent(MotionEvent.obtain(t, t, MotionEvent.ACTION_DOWN, 300f, 100f, 0))
        repeat(10) { layout.dispatchTouchEvent(MotionEvent.obtain(t, t + 16L * (it + 1), MotionEvent.ACTION_MOVE, 300f - 20f * (it + 1), 102f, 0)); idle(16) }
        layout.dispatchTouchEvent(MotionEvent.obtain(t, t + 200, MotionEvent.ACTION_UP, 100f, 102f, 0))
        idle()
        assertTrue("scrolled sideways: ${row.computeHorizontalScrollOffset()}", row.computeHorizontalScrollOffset() > 0)
        assertEquals(0, spinner(layout))
    }

    @Test
    fun turningRefreshOffAfterSomeRefreshesLeavesScrollingNormal() {
        // #1510: after a few refreshes, setEnableRefresh(false) left the list's scrolling erratic.
        val list = content(3000)
        val layout = show(layout(list))
        repeat(3) {
            drag(layout, 600f)
            idle()
            layout.finishRefresh(0)
            idle()
        }
        layout.setEnableRefresh(false)
        drag(layout, -300f)
        idle()
        val down = list.scrollY
        assertTrue(down > 0)
        drag(layout, 150f)
        idle()
        assertTrue("scrolls back: $down -> ${list.scrollY}", list.scrollY < down)
        assertEquals(0, spinner(layout))
    }

    @Test
    fun aPullDuringTheEndBounceWorks() {
        // #1519: after a fling to the end, a pull down before the bounce settled did nothing.
        val list = content(3000)
        val layout = show(layout(list))
        layout.setEnableOverScrollBounce(true)
        list.scrollTo(0, 100000)
        idle(100)
        val t = SystemClock.uptimeMillis()
        layout.dispatchTouchEvent(MotionEvent.obtain(t, t, MotionEvent.ACTION_DOWN, 200f, 400f, 0))
        repeat(4) { layout.dispatchTouchEvent(MotionEvent.obtain(t, t + 8L * (it + 1), MotionEvent.ACTION_MOVE, 200f, 400f - 60f * (it + 1), 0)) }
        layout.dispatchTouchEvent(MotionEvent.obtain(t, t + 40, MotionEvent.ACTION_UP, 200f, 160f, 0))
        idle(30)
        val before = list.scrollY
        drag(layout, 200f)
        idle()
        assertTrue("the pull scrolled the list back: $before -> ${list.scrollY}", list.scrollY < before)
    }

    @Test
    fun loadMoreTurnedOnLaterShowsTheFooter() {
        // #1507: setEnableLoadMore(true) at run time (after starting with it off) left the footer hidden.
        val layout = layout(content(300))
        layout.setEnableLoadMore(false)
        show(layout)
        drag(layout, -400f)
        idle()
        assertEquals(0, loads)
        layout.setEnableLoadMore(true)
        idle(100)
        drag(layout, -400f, release = false)
        val footer = layout.refreshFooter!!.view
        assertTrue("the footer has a height: ${footer.height}", footer.height > 0)
        assertTrue("the footer comes into view", top(footer) < top(layout) + layout.height)
        drag(layout, 0f)
        idle()
        assertEquals(1, loads)
    }

    private fun top(v: View): Int = IntArray(2).also { v.getLocationInWindow(it) }[1]

    private fun field(obj: Any, name: String): Any? {
        var c: Class<*>? = obj.javaClass
        while (c != null) {
            try { return c.getDeclaredField(name).apply { isAccessible = true }.get(obj) } catch (_: NoSuchFieldException) { c = c.superclass }
        }
        throw NoSuchFieldException(name)
    }
}
