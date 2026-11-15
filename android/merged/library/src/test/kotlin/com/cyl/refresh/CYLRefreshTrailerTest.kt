package com.cyl.refresh

import android.app.Activity
import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import org.junit.Assert.assertEquals
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
 * `CYLRefreshTrailer` on a horizontal RecyclerView, checked against iOS example42: pulling left past the last page and
 * releasing refreshes.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLRefreshTrailerTest {

    private val activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private fun idle(ms: Long = 500) = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(ms))

    private fun pages(count: Int) = RecyclerView(activity).apply {
        layoutManager = LinearLayoutManager(activity, LinearLayoutManager.HORIZONTAL, false)
        adapter = object : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
            override fun getItemCount() = count
            override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
                object : RecyclerView.ViewHolder(View(activity).apply { layoutParams = RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT) }) {}
            override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) = Unit
        }
    }

    private fun swipe(view: View, fromX: Float, toX: Float) {
        val start = SystemClock.uptimeMillis()
        val y = view.height / 2f
        view.dispatchTouchEvent(MotionEvent.obtain(start, start, MotionEvent.ACTION_DOWN, fromX, y, 0))
        for (i in 1..20) {
            view.dispatchTouchEvent(MotionEvent.obtain(start, start + i * 10L, MotionEvent.ACTION_MOVE, fromX + (toX - fromX) * i / 20, y, 0))
        }
        view.dispatchTouchEvent(MotionEvent.obtain(start, start + 220, MotionEvent.ACTION_UP, toX, y, 0))
    }

    @Test
    fun pullingLeftPastTheEndRefreshes() {
        // One page only, so the list is at its end from the start.
        val list = pages(1)
        val column = LinearLayout(activity).apply { addView(list, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 400)) }
        activity.setContentView(column)
        var refreshed = 0
        val trailer = CYLRefreshNormalTrailer.trailerWithRefreshingBlock(activity) { refreshed += 1 }
        list.cyl_trailer = trailer
        idle()
        assertTrue("wrapped", list.parent is FrameLayout)
        assertEquals("hidden at rest", trailer.trailerWidth.toFloat(), trailer.translationX, 0.5f)
        // A short pull springs back.
        swipe(list, 600f, 560f)
        idle()
        assertEquals(0, refreshed)
        assertEquals(0f, list.translationX, 0.5f)
        // A long pull past the trigger refreshes and keeps the trailer shown.
        swipe(list, 700f, 100f)
        idle()
        assertEquals(1, refreshed)
        assertEquals(CYLRefreshState.Refreshing, trailer.state)
        assertEquals(0f, trailer.translationX, 0.5f)
        trailer.endRefreshing()
        idle()
        assertEquals(CYLRefreshState.Idle, trailer.state)
        assertEquals(0f, list.translationX, 0.5f)
        // Removing it puts the list back.
        list.cyl_trailer = null
        assertSame(column, list.parent)
        assertNull(trailer.parent)
    }
}
