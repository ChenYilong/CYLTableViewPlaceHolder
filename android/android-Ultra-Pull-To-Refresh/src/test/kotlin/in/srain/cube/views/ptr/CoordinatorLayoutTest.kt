package `in`.srain.cube.views.ptr

import android.app.Activity
import android.content.Context
import android.os.Looper
import android.os.SystemClock
import android.view.ContextThemeWrapper
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import androidx.coordinatorlayout.widget.CoordinatorLayout
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.test.core.app.ApplicationProvider
import com.google.android.material.appbar.AppBarLayout
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
 * PtrFrameLayout with a CoordinatorLayout and a collapsing AppBarLayout, inside or around the frame (issues #115, #204,
 * #283, #315, #327, #340): the app bar expands before the header comes down.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CoordinatorLayoutTest {

    private val context: Context = ContextThemeWrapper(
        ApplicationProvider.getApplicationContext(),
        com.google.android.material.R.style.Theme_MaterialComponents_Light_NoActionBar,
    )

    private class Calls : PtrDefaultHandler() {
        var refreshes = 0
        override fun onRefreshBegin(frame: PtrFrameLayout) { refreshes++ }
    }

    private fun recycler() = RecyclerView(context).apply {
        layoutManager = LinearLayoutManager(context)
        adapter = object : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
            override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
                object : RecyclerView.ViewHolder(View(parent.context).apply { layoutParams = ViewGroup.LayoutParams(400, 100) }) {}
            override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {}
            override fun getItemCount() = 30
        }
    }

    private fun appBar() = AppBarLayout(context).apply {
        addView(View(context), AppBarLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 200).apply {
            scrollFlags = AppBarLayout.LayoutParams.SCROLL_FLAG_SCROLL
        })
    }

    private fun frame(content: View, calls: Calls) = PtrFrameLayout(context).apply {
        headerView = View(context).apply { layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 60) }
        addView(content)
        setPtrHandler(calls)
        loadingMinTime = 0
    }

    private fun scrollingParams() = CoordinatorLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT).apply {
        behavior = AppBarLayout.ScrollingViewBehavior()
    }

    // Attached to a window, so views report their window positions and nested scrolling can follow a moving parent.
    private fun layout(root: View) {
        if (root.parent == null) {
            val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
            activity.setContentView(root)
        }
        shadowOf(Looper.getMainLooper()).idle()
    }

    private var downTime = 0L
    private var time = 0L
    private var y = 0f

    // Events 16 ms apart, like a real finger, so the release is not a fling.
    private fun down(root: View, at: Float = 400f) {
        downTime = SystemClock.uptimeMillis()
        time = downTime
        y = at
        root.dispatchTouchEvent(MotionEvent.obtain(downTime, time, MotionEvent.ACTION_DOWN, 200f, y, 0))
    }

    private fun moveBy(root: View, dy: Float, steps: Int = 10) {
        repeat(steps) {
            y += dy / steps
            time += 16
            root.dispatchTouchEvent(MotionEvent.obtain(downTime, time, MotionEvent.ACTION_MOVE, 200f, y, 0))
            layout(root)
        }
    }

    private fun up(root: View) {
        // The finger rests before it lifts.
        time += 300
        root.dispatchTouchEvent(MotionEvent.obtain(downTime, time, MotionEvent.ACTION_MOVE, 200f, y, 0))
        time += 16
        root.dispatchTouchEvent(MotionEvent.obtain(downTime, time, MotionEvent.ACTION_UP, 200f, y, 0))
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(1500))
        layout(root)
    }

    @Test
    fun frameInsideACoordinatorLayoutLetsTheAppBarExpandFirst() {
        // #204, #340: the frame as the CoordinatorLayout's scrolling child; #283, #327: the app bar expands first.
        val calls = Calls()
        val list = recycler()
        val frame = frame(list, calls)
        val coordinator = CoordinatorLayout(context)
        val bar = appBar()
        coordinator.addView(bar, CoordinatorLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        coordinator.addView(frame, scrollingParams())
        layout(coordinator)
        assertTrue(frame.isNestedScrollingEnabled)

        down(coordinator)
        moveBy(coordinator, -260f, 26)
        up(coordinator)
        assertEquals("scrolling up collapsed the app bar through the frame", -200, bar.top)

        down(coordinator, 200f)
        moveBy(coordinator, 160f, 16)
        assertEquals("the list scrolls back first", 0, frame.ptrIndicator.getCurrentPosY())
        assertTrue("then the app bar expands", bar.top > -200)
        moveBy(coordinator, 400f, 40)
        assertEquals(0, bar.top)
        assertTrue("the header comes down last", frame.ptrIndicator.getCurrentPosY() > 0)
        up(coordinator)
        assertEquals(1, calls.refreshes)
        frame.refreshComplete()
        up(coordinator)
        assertEquals(0, frame.ptrIndicator.getCurrentPosY())
    }

    @Test
    fun frameAroundACoordinatorLayoutWaitsForTheAppBar() {
        // #115, #283, #327: the frame around a CoordinatorLayout; #315: scrolling up still works after a refresh.
        val calls = Calls()
        val coordinator = CoordinatorLayout(context)
        val bar = appBar()
        coordinator.addView(bar, CoordinatorLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        coordinator.addView(recycler(), scrollingParams())
        val frame = frame(coordinator, calls)
        layout(frame)

        down(frame)
        moveBy(frame, -260f, 26)
        up(frame)
        assertEquals(-200, bar.top)
        assertFalse("a collapsed app bar is not the content's top", PtrDefaultHandler.checkContentCanBePulledDown(frame, coordinator, frame.headerView))

        down(frame, 200f)
        moveBy(frame, 200f, 20)
        assertEquals("no pull while the app bar expands", 0, frame.ptrIndicator.getCurrentPosY())
        moveBy(frame, 400f, 40)
        assertEquals(0, bar.top)
        assertTrue(frame.ptrIndicator.getCurrentPosY() > 0)
        up(frame)
        assertEquals(1, calls.refreshes)
        frame.refreshComplete()
        up(frame)

        down(frame)
        moveBy(frame, -260f, 26)
        up(frame)
        assertEquals("after a refresh the app bar still collapses (#315)", -200, bar.top)
    }
}
