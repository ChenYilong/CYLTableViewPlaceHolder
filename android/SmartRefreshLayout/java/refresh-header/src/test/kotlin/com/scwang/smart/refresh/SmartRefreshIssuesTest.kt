package com.scwang.smart.refresh

import android.app.Activity
import android.graphics.drawable.Animatable
import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ScrollView
import com.scwang.smart.refresh.footer.ClassicsFooter
import com.scwang.smart.refresh.header.ClassicsHeader
import com.scwang.smart.refresh.header.MaterialHeader
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.constant.RefreshState
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.time.Duration

/**
 * SmartRefreshLayout issues checked on the Java source copy (docs/Android-Port.md): fixes made here, and reports
 * whose behavior the current source (224db48) already gets right. Each test names its issues.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class SmartRefreshIssuesTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()
    private var refreshes = 0
    private var loads = 0

    private fun idle(ms: Long = 2000) = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(ms))

    private fun content(height: Int) = ScrollView(activity).apply {
        addView(LinearLayout(activity).apply { addView(View(activity), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, height)) })
    }

    private fun make(contentHeight: Int = 3000, header: RefreshHeader = ClassicsHeader(activity), attach: Boolean = true): SmartRefreshLayout {
        val layout = SmartRefreshLayout(activity)
        layout.setRefreshContent(content(contentHeight))
        layout.setRefreshHeader(header)
        layout.setRefreshFooter(ClassicsFooter(activity))
        layout.setOnRefreshListener { refreshes++ }
        layout.setOnLoadMoreListener { loads++ }
        if (attach) {
            activity.setContentView(layout)
            idle(100)
        }
        return layout
    }

    private fun spinner(layout: SmartRefreshLayout) =
        SmartRefreshLayout::class.java.getDeclaredField("mSpinner").apply { isAccessible = true }.getInt(layout)

    private fun field(obj: Any, name: String): Any? {
        var c: Class<*>? = obj.javaClass
        while (c != null) {
            try { return c.getDeclaredField(name).apply { isAccessible = true }.get(obj) } catch (_: NoSuchFieldException) { c = c.superclass }
        }
        throw NoSuchFieldException(name)
    }

    private fun scrollView(v: View): ScrollView? = when (v) {
        is ScrollView -> v
        is ViewGroup -> (0 until v.childCount).firstNotNullOfOrNull { scrollView(v.getChildAt(it)) }
        else -> null
    }

    private fun top(v: View): Int = IntArray(2).also { v.getLocationInWindow(it) }[1]

    /** A finger drag of [dy] pixels in 20 steps 16 ms apart, resting before it lifts. */
    private fun drag(view: View, dy: Float, release: Boolean = true) {
        val down = SystemClock.uptimeMillis()
        var time = down
        var y = 300f
        view.dispatchTouchEvent(MotionEvent.obtain(down, time, MotionEvent.ACTION_DOWN, 200f, y, 0))
        repeat(20) {
            y += dy / 20
            time += 16
            view.dispatchTouchEvent(MotionEvent.obtain(down, time, MotionEvent.ACTION_MOVE, 200f, y, 0))
        }
        if (release) {
            time += 300
            view.dispatchTouchEvent(MotionEvent.obtain(down, time, MotionEvent.ACTION_MOVE, 200f, y, 0))
            view.dispatchTouchEvent(MotionEvent.obtain(down, time + 16, MotionEvent.ACTION_UP, 200f, y, 0))
        }
    }

    // MARK: - Fixed here

    @Test
    fun aLayoutTallerThanTheScreenPullsLikeANormalOne() {
        // #1197, #1200, #1236: inside a ScrollView (or growing with each page) the pull got harder until it could not
        // reach the refresh height.
        val normal = make()
        drag(normal, 300f, release = false)
        val normalSpinner = spinner(normal)
        val tall = SmartRefreshLayout(activity)
        tall.setRefreshContent(content(6000))
        tall.setRefreshHeader(ClassicsHeader(activity))
        tall.setOnRefreshListener { refreshes++ }
        val scroll = ScrollView(activity)
        scroll.addView(tall, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        activity.setContentView(scroll)
        idle(100)
        assertTrue(tall.height > 3 * normal.height)
        drag(tall, 300f, release = false)
        assertTrue("tall ${spinner(tall)} vs normal $normalSpinner", spinner(tall) >= normalSpinner * 0.9)
        drag(tall, 600f)
        idle()
        assertEquals("a long pull still refreshes", RefreshState.Refreshing, tall.state)
    }

    @Test
    fun pureScrollModeInCode() {
        // #1109: pure scroll mode set in code pulls up too; #1199: turning it off in code takes back the pull up it
        // allowed.
        val attrs = Robolectric.buildAttributeSet()
            .addAttribute(com.scwang.smart.refresh.layout.kernel.R.attr.srlEnablePureScrollMode, "true").build()
        val layout = SmartRefreshLayout(activity, attrs)
        assertTrue((field(layout, "mEnableLoadMore") as Boolean))
        layout.setEnablePureScrollMode(false)
        assertFalse("load more was only on for pure scroll mode", (field(layout, "mEnableLoadMore") as Boolean))

        val code = make(300)
        val manual = SmartRefreshLayout(activity)
        manual.setEnablePureScrollMode(true)
        assertTrue((field(manual, "mEnableLoadMore") as Boolean))
        manual.setEnablePureScrollMode(false)
        assertFalse((field(manual, "mEnableLoadMore") as Boolean))
        code.setEnablePureScrollMode(true)
        drag(code, -400f, release = false)
        assertTrue("pure scroll mode pulls up", spinner(code) < 0)
        assertEquals("but loads nothing", 0, loads)
    }

    @Test
    fun contentWrappedInCodeIsShown() {
        // #1235: removing the content and adding a view that wraps it left a blank area.
        val layout = make()
        val scroll = scrollView(layout)!!
        val index = layout.indexOfChild(scroll)
        layout.removeView(scroll)
        val wrapper = FrameLayout(activity)
        wrapper.addView(scroll)
        layout.addView(wrapper, index)
        idle(200)
        assertEquals(layout.height, wrapper.height)
        drag(layout, 600f)
        idle()
        assertEquals(RefreshState.Refreshing, layout.state)
    }

    // MARK: - Already right in the current source (224db48)

    @Test
    fun autoRefreshIsReliable() {
        // #1215: repeated autoRefresh calls refresh once; #1171: an autoRefresh before the header is measured uses its
        // real height; #1409: autoRefresh(delay, duration, rate, animationOnly) ends refreshing and closes.
        val layout = make()
        repeat(5) { layout.autoRefresh(); idle(60) }
        idle()
        assertEquals(1, refreshes)
        assertEquals(RefreshState.Refreshing, layout.state)

        val measured = SmartRefreshLayout(activity)
        measured.setRefreshContent(content(3000))
        val header = ClassicsHeader(activity)
        measured.setRefreshHeader(header, ViewGroup.LayoutParams.MATCH_PARENT, 300)
        measured.setOnRefreshListener { }
        measured.autoRefresh(0)
        activity.setContentView(measured)
        idle()
        assertEquals(300, spinner(measured))

        val timed = make()
        timed.autoRefresh(300, 3000, 1f, true)
        idle(5000)
        assertEquals(RefreshState.Refreshing, timed.state)
        timed.finishRefresh(0)
        idle()
        assertEquals(0, spinner(timed))
    }

    @Test
    fun animationOnlyRefreshes() {
        // #1266: autoRefreshAnimationOnly never calls onRefresh; #1363, #1558: its state is Refreshing and
        // finishRefresh closes it; #1602: also when finished during the opening animation; #1190: a rate of 0.5 shows
        // half the header.
        val layout = make()
        layout.autoRefreshAnimationOnly()
        idle()
        assertEquals(RefreshState.Refreshing, layout.state)
        assertEquals(0, refreshes)
        layout.finishRefresh()
        idle()
        assertEquals(RefreshState.None, layout.state)
        assertEquals(0, spinner(layout))

        layout.autoRefreshAnimationOnly()
        idle(100)
        layout.finishRefresh(0)
        idle()
        assertEquals(RefreshState.None, layout.state)
        assertEquals(0, spinner(layout))

        layout.autoRefresh(0, 0, 0.5f, true)
        idle()
        assertEquals(layout.refreshHeader!!.view.height / 2, spinner(layout))
    }

    @Test
    fun refreshingAndTouches() {
        // #1324: an autoRefresh while a finger is down still refreshes; #1430: scrolling right after autoRefresh does
        // not cancel it; #1339, #1379: pulling again and again while refreshing refreshes once and finishRefresh
        // closes it; #1420: setEnableRefresh(false) stops the pull from refreshing.
        val touched = make()
        val t = SystemClock.uptimeMillis()
        touched.dispatchTouchEvent(MotionEvent.obtain(t, t, MotionEvent.ACTION_DOWN, 200f, 300f, 0))
        touched.autoRefresh(0)
        idle()
        touched.dispatchTouchEvent(MotionEvent.obtain(t, t + 500, MotionEvent.ACTION_UP, 200f, 300f, 0))
        idle()
        assertEquals(RefreshState.Refreshing, touched.state)
        assertEquals(1, refreshes)

        refreshes = 0
        val scrolled = make()
        scrolled.autoRefresh(0)
        idle(30)
        drag(scrolled, -300f)
        idle()
        assertEquals(RefreshState.Refreshing, scrolled.state)
        assertEquals(1, refreshes)

        refreshes = 0
        val repeated = make()
        repeat(4) { drag(repeated, 600f); idle(150) }
        idle()
        assertEquals(1, refreshes)
        repeated.finishRefresh(0)
        idle()
        assertEquals(RefreshState.None, repeated.state)
        assertEquals(0, spinner(repeated))

        refreshes = 0
        val disabled = make(header = MaterialHeader(activity))
        disabled.setEnableRefresh(false)
        drag(disabled, 600f)
        idle()
        assertEquals(0, refreshes)
    }

    @Test
    fun loadingMore() {
        // #1203: loading more starts while the finger is still down; #1112: no second load right after
        // finishLoadMoreWithNoMoreData; #1452: setEnableLoadMoreWhenContentNotFull(false) works; #1346: on short
        // content, a refresh after loading more still calls back; #1214: the footer goes back after loading.
        val held = make(300)
        drag(held, -600f, release = false)
        idle(500)
        assertEquals(1, loads)

        loads = 0
        val noMore = make(300)
        drag(noMore, -600f)
        idle()
        noMore.finishLoadMoreWithNoMoreData()
        drag(noMore, -600f)
        idle()
        assertEquals(1, loads)

        loads = 0
        val notFull = make(300)
        notFull.setEnableLoadMoreWhenContentNotFull(false)
        drag(notFull, -600f)
        idle()
        assertEquals(0, loads)

        loads = 0
        refreshes = 0
        val both = make(300)
        drag(both, -600f)
        idle()
        both.finishLoadMore(0)
        idle()
        drag(both, 600f)
        idle()
        assertEquals(1, loads)
        assertEquals(1, refreshes)

        val screenFull = make(800)
        drag(screenFull, -600f)
        idle()
        screenFull.finishLoadMore(0)
        idle()
        assertEquals(0, spinner(screenFull))
        assertEquals(RefreshState.None, screenFull.state)
    }

    @Test
    fun footerAfterLoading() {
        // #1175, #1301, #1391, #1392: after loading more the footer does not cover the last item; #1151, #1154: the
        // "no more data" footer is not left over the list; #1153: a 52 dp footer is 52 dp; #1361: a normal refresh
        // after finishRefreshWithNoMoreData clears no-more-data; #1367: an autoRefresh after setNoMoreData moves the
        // content below the header.
        val layout = make(3000)
        val scroll = scrollView(layout)!!
        scroll.scrollTo(0, 100000)
        idle(100)
        drag(layout, -400f)
        idle()
        layout.finishLoadMore(0)
        idle()
        assertEquals(0, spinner(layout))
        assertEquals(0f, scroll.translationY)
        assertTrue("the footer is below the visible list", top(layout.refreshFooter!!.view) >= top(layout) + layout.height)

        drag(layout, -400f)
        idle()
        layout.finishLoadMoreWithNoMoreData()
        idle(3000)
        assertEquals(0, spinner(layout))
        assertTrue(top(layout.refreshFooter!!.view) >= top(layout) + layout.height)

        val sized = make()
        sized.setFooterHeight(52f)
        idle(100)
        assertEquals((52 * activity.resources.displayMetrics.density).toInt(), sized.refreshFooter!!.view.height)

        val noMore = make(300)
        noMore.autoRefresh(0)
        idle()
        noMore.finishRefreshWithNoMoreData()
        idle()
        noMore.autoRefresh(0)
        idle()
        noMore.finishRefresh(0)
        idle()
        assertEquals(false, field(noMore, "mFooterNoMoreData"))

        val after = make()
        after.setNoMoreData(true)
        after.autoRefresh(0)
        idle()
        assertEquals(spinner(after).toFloat(), scrollView(after)!!.translationY)
        assertTrue(spinner(after) > 0)
    }

    @Test
    fun materialHeader() {
        // #1317: the circle shows on every one of several quick refreshes; #1148: the circle does not come in from
        // the side.
        val header = MaterialHeader(activity)
        val layout = make(header = header)
        repeat(3) {
            layout.autoRefresh(0)
            idle()
            layout.finishRefresh(0)
            idle(100)
        }
        layout.autoRefresh(0)
        idle(30)
        val circle = field(header, "mCircleView") as View
        val x = circle.x
        idle()
        assertEquals(x, circle.x)
        assertEquals(1f, circle.alpha)
        assertEquals(1f, circle.scaleX)
        assertEquals(View.VISIBLE, circle.visibility)
    }

    @Test
    fun leavingTheWindowWhileRefreshing() {
        // #1163, #1166: a layout that leaves the window while refreshing (a fragment switched away) is reset, so no
        // spinner is left frozen and finishing works after it comes back.
        val header = MaterialHeader(activity)
        val layout = make(header = header)
        layout.autoRefresh(0)
        idle()
        assertTrue((field(header, "mProgress") as Animatable).isRunning)
        val parent = layout.parent as ViewGroup
        parent.removeView(layout)
        idle(300)
        parent.addView(layout)
        idle(300)
        assertEquals(RefreshState.None, layout.state)
        assertFalse("no frozen spinner", (field(header, "mProgress") as Animatable).isRunning)
        assertEquals(0, spinner(layout))
        layout.autoRefresh(0)
        idle()
        layout.finishRefresh(0)
        idle()
        assertEquals(RefreshState.None, layout.state)
    }
}
