package com.cyl.refresh

import android.app.Activity
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.PagerSnapHelper
import androidx.recyclerview.widget.RecyclerView
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.time.Duration

/**
 * MJRefresh #1430 on Android (iOS `Examples/Example-objc-02`, paging): a paged list left between pages when a refresh
 * ends goes back to its nearest page.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLRefreshPagingSnapTest {

    private val activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private fun idle(ms: Long = 1000) = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(ms))

    @Test
    fun aPagedListLeftBetweenPagesSnapsToTheNearestPage() {
        val list = RecyclerView(activity).apply {
            layoutManager = LinearLayoutManager(activity)
            adapter = object : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
                override fun getItemCount() = 8
                override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
                    object : RecyclerView.ViewHolder(View(activity).apply { layoutParams = RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 1000) }) {}
                override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) = Unit
            }
        }
        PagerSnapHelper().attachToRecyclerView(list)
        activity.setContentView(FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(1080, 1000)) })
        idle()
        // Page 2 sits 400 px down, as after restoring an offset while the header was open.
        (list.layoutManager as LinearLayoutManager).scrollToPositionWithOffset(2, 400)
        idle()
        CYLRefreshBridge.snapToPage(list)
        idle()
        val manager = list.layoutManager as LinearLayoutManager
        assertEquals(2, manager.findFirstCompletelyVisibleItemPosition())
        assertEquals(0, manager.findViewByPosition(2)!!.top)
        // A list without a SnapHelper is left where it is.
        list.onFlingListener = null
        manager.scrollToPositionWithOffset(3, 300)
        idle()
        CYLRefreshBridge.snapToPage(list)
        idle()
        assertEquals(300, manager.findViewByPosition(3)!!.top)
    }
}
