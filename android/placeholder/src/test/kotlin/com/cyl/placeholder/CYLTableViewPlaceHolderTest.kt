package com.cyl.placeholder

import android.app.Activity
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.core.widget.NestedScrollView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.time.Duration

/**
 * The one-line placeholder of an empty list (iOS `cyl_placeholderViewBlock:`, `cyl_reloadData`,
 * `CYLTableViewPlaceHolderDelegate`) on RecyclerView.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLTableViewPlaceHolderTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private open class Rows(var count: Int) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
        override fun getItemCount() = count
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
            object : RecyclerView.ViewHolder(View(parent.context).apply { layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 100) }) {}
        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {}
    }

    private class DelegateRows(count: Int, val placeholder: View) : Rows(count), CYLTableViewPlaceHolderDelegate {
        override fun makePlaceHolderView() = placeholder
        override fun enableScrollWhenPlaceHolderViewShowing() = true
    }

    private fun list(adapter: RecyclerView.Adapter<*>): Pair<LinearLayout, RecyclerView> {
        val parent = LinearLayout(activity).apply { orientation = LinearLayout.VERTICAL }
        val list = RecyclerView(activity).apply {
            layoutManager = LinearLayoutManager(activity)
            this.adapter = adapter
        }
        parent.addView(View(activity), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 50))
        parent.addView(list, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
        activity.setContentView(parent)
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))
        return parent to list
    }

    @Test
    fun aBlockShowsThePlaceholderWhileTheListIsEmpty() {
        val rows = Rows(0)
        val (parent, list) = list(rows)
        var normal = 0
        list.cyl_placeholderViewBlock({ CYLPlaceholderStackView(activity, CYLPlaceholderScenario.NoContent) }, { normal++ })
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(100))
        val shown = list.cyl_placeholderView
        assertNotNull(shown)
        assertEquals(View.GONE, list.visibility)
        assertEquals("the placeholder takes the list's place", parent.indexOfChild(list) + 1, parent.indexOfChild(shown))
        assertTrue("and its size", shown!!.height > 0 && shown.top == 50)

        rows.count = 3
        rows.notifyDataSetChanged()
        assertNull("data came: the placeholder goes by itself", list.cyl_placeholderView)
        assertEquals(View.VISIBLE, list.visibility)
        assertEquals(1, normal)

        rows.count = 0
        list.cyl_reloadData()
        assertNotNull(list.cyl_placeholderView)
        list.cyl_placeholderHidden = true
        assertNull(list.cyl_placeholderView)
    }

    @Test
    fun aDelegateAdapterGivesThePlaceholderAndKeepsScrolling() {
        val placeholder = CYLPlaceholderView(activity, CYLPlaceholderStyle.Empty, CYLPlaceholderMessage.Empty)
        val (_, list) = list(DelegateRows(0, placeholder))
        list.cyl_reloadData()
        val shown = list.cyl_placeholderView
        assertTrue("scrollable, so a pull to refresh still works", shown is NestedScrollView)
        assertNotNull(placeholder.parent)
    }
}
