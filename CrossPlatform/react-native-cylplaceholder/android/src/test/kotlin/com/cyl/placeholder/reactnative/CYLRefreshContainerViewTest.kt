package com.cyl.placeholder.reactnative

import android.app.Activity
import android.os.SystemClock
import android.view.MotionEvent
import android.widget.LinearLayout
import android.widget.ScrollView
import com.cyl.refresh.CYLRefreshPhase
import com.cyl.refresh.cyl_footer
import com.cyl.refresh.cyl_header
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLRefreshContainerViewTest {
    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private fun idle(ms: Long) = shadowOf(android.os.Looper.getMainLooper()).idleFor(java.time.Duration.ofMillis(ms))

    private fun container(): CYLRefreshContainerView {
        val view = CYLRefreshContainerView(activity)
        view.addView(ScrollView(activity))
        activity.setContentView(view)
        idle(100)
        return view
    }

    @Test
    fun theIosNamedHeaderIsAttached() {
        val view = container()
        assertNotNull(view.cyl_header)
    }

    @Test
    fun refreshingFromJsRunsThePhaseMachineWithoutCallingOnRefresh() {
        val view = container()
        var pulled = 0
        view.onRefresh = { pulled++ }
        view.setRefreshingFromJs(true)
        idle(100)
        assertTrue(view.cyl_header!!.isRefreshing)
        assertEquals(0, pulled)
        view.setRefreshingFromJs(false)
        idle(3000)
        assertTrue(view.cyl_header!!.phase != CYLRefreshPhase.Refreshing)
    }

    // [EN] A finger drag on the container, as the system delivers it (down, moves, a pause, up).
    // [CN] 容器上的手指拖动，与系统派发的触摸序列一致（按下、移动、停顿、抬起）。
    private fun drag(view: CYLRefreshContainerView, dy: Float) {
        val down = SystemClock.uptimeMillis()
        var y = 100f
        view.dispatchTouchEvent(MotionEvent.obtain(down, down, MotionEvent.ACTION_DOWN, 100f, y, 0))
        repeat(20) {
            y += dy / 20
            view.dispatchTouchEvent(MotionEvent.obtain(down, down + 16L * (it + 1), MotionEvent.ACTION_MOVE, 100f, y, 0))
        }
        view.dispatchTouchEvent(MotionEvent.obtain(down, down + 700, MotionEvent.ACTION_MOVE, 100f, y, 0))
        view.dispatchTouchEvent(MotionEvent.obtain(down, down + 716, MotionEvent.ACTION_UP, 100f, y, 0))
    }

    private fun scrollingContainer(): CYLRefreshContainerView {
        val view = CYLRefreshContainerView(activity)
        view.addView(ScrollView(activity).apply {
            addView(LinearLayout(activity).apply { addView(android.view.View(activity), LinearLayout.LayoutParams(-1, 3000)) })
        })
        activity.setContentView(view)
        idle(100)
        return view
    }

    @Test
    fun aRealPullGestureReachesOnRefresh() {
        val view = scrollingContainer()
        var pulled = 0
        view.onRefresh = { pulled++ }
        drag(view, 900f)
        idle(500)
        assertEquals(1, pulled)
        assertTrue(view.cyl_header!!.isRefreshing)
        view.setRefreshingFromJs(false)
        idle(3000)
    }

    @Test
    fun aPullOnADisabledContainerDoesNotReachOnRefresh() {
        val view = scrollingContainer()
        var pulled = 0
        view.onRefresh = { pulled++ }
        view.setPullEnabled(false)
        drag(view, 900f)
        idle(500)
        assertEquals(0, pulled)
        assertFalse(view.cyl_header!!.isRefreshing)
    }

    @Test
    fun theFooterIsAttachedAndLoadMoreIsOffByDefault() {
        val view = scrollingContainer()
        assertNotNull(view.cyl_footer)
        var loaded = 0
        view.onLoadMore = { loaded++ }
        drag(view, -900f)
        idle(500)
        assertEquals(0, loaded)
        assertFalse(view.cyl_footer!!.isRefreshing)
    }

    @Test
    fun loadingMoreFromJsRunsTheFooterWithoutCallingOnLoadMore() {
        val view = scrollingContainer()
        var loaded = 0
        view.onLoadMore = { loaded++ }
        view.setLoadMoreEnabled(true)
        view.setLoadingMoreFromJs(true)
        idle(100)
        assertTrue(view.cyl_footer!!.isRefreshing)
        assertEquals(0, loaded)
        view.setLoadingMoreFromJs(false)
        idle(3000)
        assertFalse(view.cyl_footer!!.isRefreshing)
    }

    @Test
    fun noMoreDataFromJsShowsAndClearsTheFooterState() {
        val view = scrollingContainer()
        view.setLoadMoreEnabled(true)
        view.setNoMoreDataFromJs(true)
        idle(100)
        assertTrue(view.cyl_footer!!.noMoreData)
        view.setNoMoreDataFromJs(false)
        idle(100)
        assertFalse(view.cyl_footer!!.noMoreData)
    }

    @Test
    fun endingALoadWithNoMoreDataKeepsTheNoMoreDataState() {
        val view = scrollingContainer()
        view.setLoadMoreEnabled(true)
        view.setLoadingMoreFromJs(true)
        idle(100)
        view.setNoMoreDataFromJs(true)
        idle(3000)
        assertTrue(view.cyl_footer!!.noMoreData)
        assertFalse(view.cyl_footer!!.isRefreshing)
    }

    // The floor's content: a child with nativeID "cyl.refresh.secondary" (React Native stores it under this tag).
    private fun floorContent(): android.view.View = android.view.View(activity).also {
        it.setTag(com.facebook.react.R.id.view_tag_native_id, CYLRefreshContainerView.SECONDARY_NATIVE_ID)
    }

    @Test
    fun theSecondaryNativeIdChildIsTheFloorAndNotAChildOfTheLayout() {
        val view = CYLRefreshContainerView(activity)
        val scroll = ScrollView(activity)
        val floor = floorContent()
        view.addReactChild(scroll, 0)
        view.addReactChild(floor, 1)
        activity.setContentView(view)
        idle(100)
        assertEquals("React Native counts both children", 2, view.reactChildCount)
        assertTrue(view.reactChildAt(1) === floor)
        assertEquals("the floor is not a child of the layout", null, floor.parent)
        assertTrue("the header got it as the floor's content", view.cyl_header!!.secondaryView === floor)
        view.removeReactChildAt(1)
        assertEquals(1, view.reactChildCount)
        assertEquals(null, view.cyl_header!!.secondaryView)
    }

    @Test
    fun secondaryOpenFromJsOpensWithoutTheEventAndAPullOrPushReportsIt() {
        val view = CYLRefreshContainerView(activity)
        view.addReactChild(ScrollView(activity), 0)
        view.addReactChild(floorContent(), 1)
        activity.setContentView(view)
        idle(100)
        var opened = 0
        var closed = 0
        view.onSecondaryOpen = { opened++ }
        view.onSecondaryClose = { closed++ }
        view.setSecondaryTriggerOffset(120f)
        view.setSecondaryDimension(300f)
        view.setSecondaryCloseTriggerOffset(80f)
        assertEquals(120f, view.cyl_header!!.secondaryTriggerOffset, 0f)
        view.setSecondaryOpenFromJs(true)
        idle(1500)
        assertTrue(view.cyl_header!!.secondaryOpen)
        assertEquals("opened by the prop: no event", 0, opened)
        view.setSecondaryOpenFromJs(false)
        idle(1500)
        assertFalse(view.cyl_header!!.secondaryOpen)
        assertEquals("closed by the prop: no event", 0, closed)
        // Opened and closed by the native side (a pull or a push): the events are sent.
        view.cyl_header!!.openSecondary()
        idle(1500)
        assertEquals(1, opened)
        view.cyl_header!!.closeSecondary()
        idle(1500)
        assertEquals(1, closed)
    }

    @Test
    fun noFloorContentOrWhileRefreshingSecondaryOpenDoesNothing() {
        val view = container()
        view.setSecondaryOpenFromJs(true)
        assertFalse("no floor content: nothing opens", view.cyl_header!!.secondaryOpen)
        val withFloor = CYLRefreshContainerView(activity)
        withFloor.addReactChild(ScrollView(activity), 0)
        withFloor.addReactChild(floorContent(), 1)
        activity.setContentView(withFloor)
        idle(100)
        withFloor.setRefreshingFromJs(true)
        idle(100)
        withFloor.setSecondaryOpenFromJs(true)
        assertFalse("no second floor while refreshing", withFloor.cyl_header!!.secondaryOpen)
    }

    @Test
    fun aRealPullUpReachesOnLoadMoreWhenItIsOn() {
        val view = container()
        var loaded = 0
        view.onLoadMore = { loaded++ }
        view.setLoadMoreEnabled(true)
        drag(view, -900f)
        idle(500)
        assertEquals(1, loaded)
        assertTrue(view.cyl_footer!!.isRefreshing)
        view.setLoadingMoreFromJs(false)
        idle(3000)
    }
}
