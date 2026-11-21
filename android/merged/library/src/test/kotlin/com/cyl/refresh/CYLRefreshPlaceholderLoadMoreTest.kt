package com.cyl.refresh

import android.app.Activity
import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.cyl.placeholder.cyl_placeholderViewBlock
import com.cyl.placeholder.cyl_reloadData
import com.cyl.refresh.layout.CYLRefreshLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.time.Duration

/**
 * An empty list has nothing more to load (iOS hides footers over the placeholder): while the placeholder shows,
 * pulling up does not load more; with data again it does.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLRefreshPlaceholderLoadMoreTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private fun idle(ms: Long = 2000) = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(ms))

    private class Rows(var count: Int) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
        override fun getItemCount() = count
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
            object : RecyclerView.ViewHolder(View(parent.context).apply { layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 200) }) {}
        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {}
    }

    private fun pullUp(view: View) {
        val down = SystemClock.uptimeMillis()
        var y = 1200f
        view.dispatchTouchEvent(MotionEvent.obtain(down, down, MotionEvent.ACTION_DOWN, 200f, y, 0))
        repeat(20) {
            y -= 60f
            view.dispatchTouchEvent(MotionEvent.obtain(down, down + 16L * (it + 1), MotionEvent.ACTION_MOVE, 200f, y, 0))
        }
        view.dispatchTouchEvent(MotionEvent.obtain(down, down + 700, MotionEvent.ACTION_MOVE, 200f, y, 0))
        view.dispatchTouchEvent(MotionEvent.obtain(down, down + 716, MotionEvent.ACTION_UP, 200f, y, 0))
    }

    @Test
    fun noLoadMoreWhileThePlaceholderShows() {
        val rows = Rows(0)
        val list = RecyclerView(activity).apply { layoutManager = LinearLayoutManager(activity); adapter = rows }
        val content = FrameLayout(activity).apply { addView(list, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)) }
        val layout = CYLRefreshLayout(activity)
        layout.setRefreshContent(content)
        val footer = CYLRefreshAutoNormalFooter(activity)
        layout.cyl_footer = footer
        var loads = 0
        footer.refreshingBlock = { loads++ }
        val placeholder = View(activity)
        list.cyl_placeholderViewBlock { placeholder }
        activity.setContentView(layout, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 1600))
        list.cyl_reloadData()
        idle()
        assertNotNull("the placeholder shows", placeholder.parent)

        pullUp(layout)
        idle()
        assertEquals("no load more over the empty placeholder", 0, loads)

        rows.count = 3
        rows.notifyDataSetChanged()
        list.cyl_reloadData()
        idle()
        pullUp(layout)
        idle()
        assertEquals("load more returns with the data", 1, loads)
    }
}
