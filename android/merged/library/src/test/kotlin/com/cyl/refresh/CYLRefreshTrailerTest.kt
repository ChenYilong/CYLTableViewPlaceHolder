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

    @Test
    fun anAutomaticTrailerRefreshesWithoutARelease() {
        // Three pages: the content is wider than the list; scroll to the last one.
        val list = pages(3)
        val column = LinearLayout(activity).apply { addView(list, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 400)) }
        activity.setContentView(column)
        var refreshed = 0
        val trailer = CYLRefreshNormalTrailer.trailerWithRefreshingBlock(activity) { refreshed += 1 }
        trailer.automaticallyRefresh = true
        trailer.triggerAutomaticallyRefreshPercent = 0.5f
        list.cyl_trailer = trailer
        idle()
        list.scrollToPosition(2)
        idle()
        assertTrue("at the end", !list.canScrollHorizontally(1))
        // Pulling half the trailer into view refreshes while the finger is still down.
        val start = SystemClock.uptimeMillis()
        val y = list.height / 2f
        list.dispatchTouchEvent(MotionEvent.obtain(start, start, MotionEvent.ACTION_DOWN, 700f, y, 0))
        for (i in 1..20) list.dispatchTouchEvent(MotionEvent.obtain(start, start + i * 10L, MotionEvent.ACTION_MOVE, 700f - i * 20f, y, 0))
        assertEquals("refreshing before the release", CYLRefreshState.Refreshing, trailer.state)
        // The block runs once the trailer has slid fully in, as on iOS.
        idle()
        assertEquals(1, refreshed)
        list.dispatchTouchEvent(MotionEvent.obtain(start, start + 220, MotionEvent.ACTION_UP, 300f, y, 0))
        assertEquals("the release does not refresh again", 1, refreshed)
        trailer.endRefreshing()
        idle()
        // The default autoTriggerTimes (1) is used up until the next drag.
        assertEquals(CYLRefreshState.Idle, trailer.state)
        list.cyl_trailer = null
    }

    @Test
    fun aTrailerOverNarrowContentKeepsPullAndRelease() {
        val list = pages(1)
        activity.setContentView(LinearLayout(activity).apply { addView(list, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 400)) })
        var refreshed = 0
        val trailer = CYLRefreshNormalTrailer.trailerWithRefreshingBlock(activity) { refreshed += 1 }
        trailer.automaticallyRefresh = true
        list.cyl_trailer = trailer
        idle()
        val start = SystemClock.uptimeMillis()
        val y = list.height / 2f
        list.dispatchTouchEvent(MotionEvent.obtain(start, start, MotionEvent.ACTION_DOWN, 700f, y, 0))
        for (i in 1..20) list.dispatchTouchEvent(MotionEvent.obtain(start, start + i * 10L, MotionEvent.ACTION_MOVE, 700f - i * 30f, y, 0))
        assertEquals("no automatic refresh over a single page", 0, refreshed)
        list.dispatchTouchEvent(MotionEvent.obtain(start, start + 220, MotionEvent.ACTION_UP, 100f, y, 0))
        idle()
        assertEquals("the release still refreshes", 1, refreshed)
        list.cyl_trailer = null
    }
}
