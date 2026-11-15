package com.cyl.refresh.merged.example

import android.content.Context
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.view.ViewCompat
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.PagerSnapHelper
import androidx.recyclerview.widget.RecyclerView
import com.cyl.refresh.CYLRefreshBackNormalFooter
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.cyl_footer
import com.cyl.refresh.cyl_header
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import kotlin.random.Random

/*
 * The iOS issue reproductions `Examples/Example-objc-01` (MJRefresh #1575) and `Examples/Example-objc-02` (#1523,
 * #1506, #1483, #1430) on Android, pushed from the Placeholder tab. iOS shows the status in the navigation title; here
 * a status line under the bar shows it and is announced to TalkBack.
 */

private fun Context.dp(value: Float) = (value * resources.displayMetrics.density).toInt()

private fun issueLater(ms: Long, block: () -> Unit) = Handler(Looper.getMainLooper()).postDelayed(block, ms)

private fun issueColor() = Color.rgb(Random.nextInt(255), Random.nextInt(255), Random.nextInt(255))

/**
 * Colored cells: full-width rows of [heightDp] when [fullWidth], else squares of [heightDp]; each reads its number.
 */
private class ColorCells(val colors: MutableList<Int>, val heightDp: Float, val fullWidth: Boolean, val label: (Context, Int) -> String?) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    override fun getItemCount() = colors.size
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) = object : RecyclerView.ViewHolder(View(parent.context).apply {
        val c = parent.context
        layoutParams = if (fullWidth) RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, c.dp(heightDp))
        else RecyclerView.LayoutParams(c.dp(heightDp), c.dp(heightDp)).apply { setMargins(c.dp(10f), c.dp(10f), c.dp(10f), c.dp(10f)) }
    }) {}
    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        holder.itemView.setBackgroundColor(colors[position])
        holder.itemView.contentDescription = label(holder.itemView.context, position)
        holder.itemView.tag = "item-$position"
    }
}

private fun statusLine(context: Context, text: String) = TextView(context).apply {
    this.text = text
    textSize = 16f
    gravity = Gravity.CENTER
    tag = "status"
    setPadding(0, context.dp(4f), 0, context.dp(4f))
    ViewCompat.setAccessibilityLiveRegion(this, ViewCompat.ACCESSIBILITY_LIVE_REGION_POLITE)
}

private fun StackPage.statusPage(context: Context, title: String, status: TextView, content: View, vararg buttons: Button): View =
    page(context, bar(context, title, *buttons), LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        addView(status)
        addView(content, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
    })

/**
 * `Example-objc-01` (MJRefresh #1575, the reporter's demo by Jerry Jiang): 50 random full-width 40 dp rows with a
 * 32 dp top inset; a pull shows "Refreshing", and 3 seconds later "Finished". The texts are the demo's own, not
 * translated, as on iOS.
 */
internal fun StackPage.issue1575Page(): View {
    val context = requireContext()
    val status = statusLine(context, "Ready")
    val colors = MutableList(50) { issueColor() }
    val list = RecyclerView(context).apply {
        layoutManager = LinearLayoutManager(context)
        adapter = ColorCells(colors, 40f, fullWidth = true) { _, _ -> null }
        setBackgroundColor(Color.LTGRAY)
        setPadding(0, context.dp(32f), 0, 0)
        clipToPadding = false
        tag = "issue1575Collection"
    }
    val layout = SmartRefreshLayout(context).apply { setRefreshContent(list) }
    val header = CYLRefreshNormalHeader(context)
    layout.cyl_header = header
    header.refreshingBlock = {
        status.text = "Refreshing"
        issueLater(3000) {
            header.endRefreshing()
            for (i in colors.indices) colors[i] = issueColor()
            list.adapter?.notifyDataSetChanged()
            status.text = "Finished"
        }
    }
    return statusPage(context, "MJRefresh #1575", status, layout)
}

/**
 * `Example-objc-02`, the collection (MJRefresh #1523, #1506, #1483): 30 random 80 dp squares; the header shows
 * "Header completed N", the back footer "Footer completed". iOS's `isCollectionViewAnimationBug` works around a
 * UICollectionView animation and has no Android counterpart.
 */
internal fun StackPage.issue1523Page(): View {
    val context = requireContext()
    val status = statusLine(context, context.t(R.string.o2_title_collection))
    val colors = MutableList(30) { issueColor() }
    val list = RecyclerView(context).apply {
        layoutManager = GridLayoutManager(context, 3)
        adapter = ColorCells(colors, 80f, fullWidth = false) { c, position -> c.t(R.string.o2_format_item, position + 1) }
        setBackgroundColor(Color.WHITE)
        setPadding(context.dp(10f), context.dp(10f), context.dp(10f), context.dp(10f))
        clipToPadding = false
        tag = "issue1523Collection"
    }
    val layout = SmartRefreshLayout(context).apply { setRefreshContent(list) }
    var headerCount = 0
    val header = CYLRefreshNormalHeader(context)
    layout.cyl_header = header
    header.refreshingBlock = {
        status.text = context.t(R.string.o2_title_header_refreshing)
        issueLater(800) {
            list.adapter?.notifyDataSetChanged()
            header.endRefreshing()
            headerCount++
            status.text = context.t(R.string.o2_format_header_completed, headerCount)
        }
    }
    val footer = CYLRefreshBackNormalFooter(context)
    layout.cyl_footer = footer
    footer.refreshingBlock = {
        status.text = context.t(R.string.o2_title_footer_refreshing)
        issueLater(800) {
            list.adapter?.notifyDataSetChanged()
            footer.endRefreshing()
            status.text = context.t(R.string.o2_title_footer_completed)
        }
    }
    return statusPage(context, "MJRefresh #1523 #1506 #1483", status, layout)
}

/**
 * `Example-objc-02`, the paging table (MJRefresh #1430): 8 pages as tall as the list, snapping per page. "Refresh"
 * adds a page and returns to page 2; "Last page" jumps to the end, where a pull up adds a page and stays in place.
 */
internal fun StackPage.issue1430Page(): View {
    val context = requireContext()
    val status = statusLine(context, context.t(R.string.o2_title_paging))
    var count = 8
    lateinit var list: RecyclerView
    val pages = object : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
        override fun getItemCount() = count
        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) = object : RecyclerView.ViewHolder(TextView(parent.context).apply {
            textSize = 17f
            gravity = Gravity.CENTER_VERTICAL
            setPadding(parent.context.dp(16f), 0, parent.context.dp(16f), 0)
            layoutParams = RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, parent.height)
        }) {}
        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
            (holder.itemView as TextView).text = context.t(R.string.o2_format_page, position)
            holder.itemView.setBackgroundColor(if (position % 2 == 0) Color.WHITE else Color.rgb(0xEE, 0xEE, 0xEE))
            holder.itemView.tag = "page-$position"
        }
    }
    list = RecyclerView(context).apply {
        layoutManager = LinearLayoutManager(context)
        adapter = pages
        tag = "pagingTable"
    }
    PagerSnapHelper().attachToRecyclerView(list)
    val layout = SmartRefreshLayout(context).apply { setRefreshContent(list) }
    val header = CYLRefreshNormalHeader(context)
    layout.cyl_header = header
    header.refreshingBlock = {
        issueLater(500) {
            count++
            pages.notifyDataSetChanged()
            (list.layoutManager as LinearLayoutManager).scrollToPositionWithOffset(2, 0)
            header.endRefreshingWithCompletionBlock { status.text = context.t(R.string.o2_title_refresh_completed) }
        }
    }
    val footer = CYLRefreshBackNormalFooter(context)
    layout.cyl_footer = footer
    footer.refreshingBlock = {
        issueLater(500) {
            count++
            pages.notifyItemInserted(count - 1)
            footer.endRefreshingWithCompletionBlock { status.text = context.t(R.string.o2_title_load_completed) }
        }
    }
    val refresh = Button(context).apply {
        text = context.t(R.string.o2_action_refresh)
        tooltipText = context.t(R.string.o2_hint_refresh)
        setOnClickListener { header.beginRefreshing() }
    }
    val last = Button(context).apply {
        text = context.t(R.string.o2_action_last_page)
        tooltipText = context.t(R.string.o2_hint_last_page)
        setOnClickListener { (list.layoutManager as LinearLayoutManager).scrollToPositionWithOffset(count - 1, 0) }
    }
    return statusPage(context, "MJRefresh #1430", status, layout, last, refresh)
}
