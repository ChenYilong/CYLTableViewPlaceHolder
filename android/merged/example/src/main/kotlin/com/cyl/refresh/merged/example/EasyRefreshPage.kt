package com.cyl.refresh.merged.example

import android.graphics.Color
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.cyl.refresh.CYLRefreshBackNormalFooter
import com.cyl.refresh.CYLRefreshCupertinoFooter
import com.cyl.refresh.CYLRefreshCupertinoHeader
import com.cyl.refresh.CYLRefreshFooter
import com.cyl.refresh.CYLRefreshHeader
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.CYLRefreshPaging
import com.cyl.refresh.CYLRefreshScrollMode
import com.cyl.refresh.CYLRefreshTriggerMode
import com.cyl.refresh.cyl_beginRefreshingWithStartHeader
import com.cyl.refresh.cyl_footer
import com.cyl.refresh.cyl_header
import com.cyl.refresh.layout.CYLRefreshLayout

/*
 * The demo of flutter_easy_refresh (https://github.com/xuelongqy/flutter_easy_refresh, example/lib/page, MIT; by
 * xuelongqy), translated from the iOS example's Swift (`CYLEasyRefreshDemoViewController.swift`) to Kotlin on this
 * project's Android API, one branch per page. Only data, options and taps live here; every header, footer and the
 * pagination come from the library.
 */

/**
 * The pages, as (title, iOS method) pairs, in the iOS order.
 */
internal val easyPages = listOf(
    R.string.merged_easy_cupertino to "easyCupertino", R.string.merged_easy_secondary to "easySecondary",
    R.string.merged_easy_trigger_mode to "easyTriggerMode", R.string.merged_easy_refresh_on_start to "easyRefreshOnStart",
    R.string.merged_easy_paging to "easyPaging", R.string.merged_easy_listener to "easyListener",
    R.string.merged_easy_chat to "easyChat", R.string.merged_easy_user_profile to "easyUserProfile",
)

/**
 * Plain text rows; a row with a tap handler is a button.
 */
private class TextRows(private val tap: (Int) -> Unit) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    var rows: List<String> = emptyList()
    var tappable: (Int) -> Boolean = { false }

    override fun getItemCount() = rows.size

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val density = parent.resources.displayMetrics.density
        val view = TextView(parent.context).apply {
            textSize = 17f
            gravity = Gravity.CENTER_VERTICAL
            minHeight = (48 * density).toInt()
            setPadding((16 * density).toInt(), 0, (16 * density).toInt(), 0)
            layoutParams = RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        }
        return object : RecyclerView.ViewHolder(view) {}
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val view = holder.itemView as TextView
        view.text = rows[position]
        val button = tappable(position)
        view.isClickable = button
        view.accessibilityDelegate = null
        if (button) view.setOnClickListener { tap(holder.bindingAdapterPosition) } else view.setOnClickListener(null)
        view.isClickable = button
    }
}

/**
 * One flutter_easy_refresh page (iOS `CYLEasyRefreshDemoViewController`), by its iOS [method].
 */
@Suppress("NotifyDataSetChanged", "CyclomaticComplexMethod", "LongMethod")
internal fun RefreshExamplesPage.easyPage(title: String, method: String): View {
    val context = requireContext()
    val density = context.resources.displayMetrics.density
    val layout = CYLRefreshLayout(context)
    var count = 10
    var refreshCount = 0
    var loadCount = 0
    var earliestMessage = 0
    var header: CYLRefreshHeader? = null
    var footer: CYLRefreshFooter? = null
    lateinit var reloadTriggerMode: () -> Unit
    val adapter = TextRows { position ->
        if (method != "easyTriggerMode") return@TextRows
        when (position) {
            2 -> header?.let { it.triggerMode = if (it.triggerMode == CYLRefreshTriggerMode.OnEdge) CYLRefreshTriggerMode.Anywhere else CYLRefreshTriggerMode.OnEdge }
            3 -> footer?.let { it.triggerMode = if (it.triggerMode == CYLRefreshTriggerMode.OnEdge) CYLRefreshTriggerMode.Anywhere else CYLRefreshTriggerMode.OnEdge }
            else -> return@TextRows
        }
        reloadTriggerMode()
    }
    if (method == "easyTriggerMode") adapter.tappable = { it == 2 || it == 3 }
    val list = RecyclerView(context).apply {
        tag = "easyRefreshDemo"
        layoutManager = LinearLayoutManager(context)
        this.adapter = adapter
    }
    fun testRow(i: Int) = context.t(R.string.merged_style_test_data_row, i)
    fun show(rows: List<String>) { adapter.rows = rows; adapter.notifyDataSetChanged() }
    fun reloadCounted() = show((1..count).map(::testRow))
    reloadTriggerMode = {
        val headerOnEdge = header?.triggerMode == CYLRefreshTriggerMode.OnEdge
        val footerOnEdge = footer?.triggerMode == CYLRefreshTriggerMode.OnEdge
        show(listOf(
            context.t(R.string.merged_easy_refresh_count, refreshCount),
            context.t(R.string.merged_easy_load_count, loadCount),
            context.t(if (headerOnEdge) R.string.merged_easy_header_on_edge else R.string.merged_easy_header_anywhere),
            context.t(if (footerOnEdge) R.string.merged_easy_footer_on_edge else R.string.merged_easy_footer_anywhere),
        ) + (1..count).map(::testRow))
    }

    // Refresh: back to 10 rows after 2 seconds, and the footer can load again. Ends the header attached now
    // (during refresh on start that is the start header).
    val refreshCounted: () -> Unit = {
        later(2000) {
            count = 10
            reloadCounted()
            layout.cyl_header?.endRefreshing()
            footer?.resetNoMoreData()
        }
    }
    // Load: 5 more rows after 2 seconds; no more data at 20.
    val loadCounted: () -> Unit = {
        later(2000) {
            count += 5
            reloadCounted()
            if (count >= 20) footer?.endRefreshingWithNoMoreData() else footer?.endRefreshing()
        }
    }
    fun attach(h: CYLRefreshHeader?, f: CYLRefreshFooter?) {
        header = h
        footer = f
        // A null header or footer also turns that pull off.
        layout.cyl_header = h
        layout.cyl_footer = f
    }

    var content: View = list
    when (method) {
        // cupertino_page.dart: the iOS-style header and footer.
        "easyCupertino" -> {
            attach(CYLRefreshCupertinoHeader(context).apply { refreshingBlock = refreshCounted },
                CYLRefreshCupertinoFooter(context).apply { refreshingBlock = loadCounted })
            reloadCounted()
        }
        // secondary_page.dart: pull past 120 dp and release to open the second floor; its button closes it.
        "easySecondary" -> {
            val normal = CYLRefreshNormalHeader(context).apply { refreshingBlock = refreshCounted }
            normal.secondaryTriggerOffset = 120f
            val floor = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER
                setBackgroundColor(0xFF5856D6.toInt())
                addView(TextView(context).apply {
                    text = context.t(R.string.merged_easy_second_floor)
                    textSize = 28f
                    setTextColor(Color.WHITE)
                }, LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT))
                addView(Button(context).apply {
                    text = context.t(R.string.merged_easy_close_second_floor)
                    setOnClickListener { normal.closeSecondary() }
                }, LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply {
                    topMargin = (16 * density).toInt()
                })
            }
            normal.secondaryView = floor
            attach(normal, CYLRefreshBackNormalFooter(context).apply { refreshingBlock = loadCounted })
            reloadCounted()
        }
        // trigger_mode_page.dart: two rows switch the trigger modes; the counts show what triggered.
        "easyTriggerMode" -> {
            val h = CYLRefreshNormalHeader(context)
            val f = CYLRefreshBackNormalFooter(context)
            h.refreshingBlock = { later(500) { refreshCount += 1; reloadTriggerMode(); layout.cyl_header?.endRefreshing() } }
            f.refreshingBlock = { later(500) { loadCount += 1; reloadTriggerMode(); f.endRefreshing() } }
            attach(h, f)
            count = 30
            reloadTriggerMode()
        }
        // refresh_on_start_page.dart: the first refresh uses the Cupertino header, later pulls the classic one.
        "easyRefreshOnStart" -> {
            val normal = CYLRefreshNormalHeader(context).apply { refreshingBlock = refreshCounted }
            val back = CYLRefreshBackNormalFooter(context)
            back.refreshingBlock = {
                later(2000) {
                    count += 10
                    reloadCounted()
                    if (count >= 30) back.endRefreshingWithNoMoreData() else back.endRefreshing()
                }
            }
            attach(normal, back)
            count = 0
            reloadCounted()
            val start = CYLRefreshCupertinoHeader(context).apply { refreshingBlock = refreshCounted }
            // The classic header comes back once the start refresh ends.
            start.endRefreshingCompletionBlock = { later(400) { layout.cyl_header = normal } }
            list.post { layout.cyl_beginRefreshingWithStartHeader(start) }
        }
        // paging_page.dart: a server of 45 items, 10 per page, 2 seconds per request; refresh on start.
        "easyPaging" -> {
            val normal = CYLRefreshNormalHeader(context)
            val back = CYLRefreshBackNormalFooter(context)
            attach(normal, back)
            val paging = CYLRefreshPaging(normal, back) { page, done ->
                later(2000) {
                    val total = 45
                    val start = (page - 1) * 10
                    val items: List<Any> = if (start >= total) emptyList() else (start until minOf(start + 10, total)).map { it + 1 }
                    done(items, total, 0, null)
                }
            }
            paging.itemsDidChange = { p -> show((p.items ?: emptyList()).map { testRow(it as Int) }) }
            list.post { paging.start() }
        }
        // listener_header_page.dart: the header draws nothing; the bar above the list shows how far it is pulled.
        "easyListener" -> {
            val progress = ProgressBar(context, null, android.R.attr.progressBarStyleHorizontal).apply {
                max = 100
                contentDescription = context.t(R.string.merged_easy_pull_progress)
            }
            // A plain CYLRefreshHeader draws nothing; it reports the pull as it moves.
            val listener = object : CYLRefreshHeader(context) {
                override fun didScrollWithOffset(offset: Int, percent: Float, dragging: Boolean) {
                    val value = (minOf(percent, 1f) * 100).toInt()
                    progress.progress = value
                    progress.stateDescription = "$value%"
                }
            }.apply { refreshingBlock = refreshCounted }
            attach(listener, CYLRefreshBackNormalFooter(context).apply { refreshingBlock = loadCounted })
            reloadCounted()
            content = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                addView(progress, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, (4 * density).toInt()))
                addView(layout, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
            }
        }
        // chat_page.dart: the newest messages at the bottom; pulling at the top loads 10 earlier ones and keeps the
        // visible messages in place.
        "easyChat" -> {
            val h = CYLRefreshNormalHeader(context)
            earliestMessage = 31
            val messages = (31..50).map { context.t(R.string.merged_easy_message_row, it) }.toMutableList()
            h.refreshingBlock = {
                later(2000) {
                    val first = maxOf(1, earliestMessage - 10)
                    val added = (first until earliestMessage).map { context.t(R.string.merged_easy_message_row, it) }
                    earliestMessage = first
                    messages.addAll(0, added)
                    adapter.rows = messages.toList()
                    // Inserting above the visible rows keeps them where they are.
                    adapter.notifyItemRangeInserted(0, added.size)
                    (list.layoutManager as LinearLayoutManager).scrollToPositionWithOffset(added.size, 0)
                    h.endRefreshing()
                    if (first == 1) h.refreshEnabled = false
                }
            }
            attach(h, null)
            show(messages.toList())
            list.post { list.scrollToPosition(messages.size - 1) }
        }
        // user_profile_page.dart: a banner above the list and the header pinned behind the content.
        else -> {
            val normal = CYLRefreshNormalHeader(context).apply { refreshingBlock = refreshCounted }
            normal.scrollMode = CYLRefreshScrollMode.Behind
            attach(normal, null)
            reloadCounted()
            val banner = TextView(context).apply {
                text = context.t(R.string.merged_easy_profile_banner)
                gravity = Gravity.CENTER
                textSize = 22f
                setTextColor(Color.WHITE)
                setBackgroundColor(0xFF30B0C7.toInt())
            }
            val column = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                setBackgroundColor(Color.WHITE)
                addView(banner, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, (160 * density).toInt()))
                addView(list, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
            }
            layout.setRefreshContent(column)
            return page(context, bar(context, title), layout)
        }
    }
    layout.setRefreshContent(list)
    return page(context, bar(context, title), if (method == "easyListener") content else layout)
}
