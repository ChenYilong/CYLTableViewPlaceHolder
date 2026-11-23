package com.cyl.placeholder.reactnative

import android.app.Activity
import android.os.SystemClock
import android.view.MotionEvent
import android.widget.LinearLayout
import android.widget.ScrollView
import com.cyl.refresh.CYLRefreshPhase
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
}
