package com.cyl.refresh.merged.example

import android.graphics.Color
import android.graphics.Rect
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.PagerSnapHelper
import androidx.recyclerview.widget.RecyclerView
import com.cyl.refresh.CYLRefreshAnimationHeader
import com.cyl.refresh.CYLRefreshBackAnimationFooter
import com.cyl.refresh.CYLRefreshBackNormalFooter
import com.cyl.refresh.CYLRefreshState
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.CYLRefreshNormalTrailer
import com.cyl.refresh.cyl_trailer
import com.cyl.refresh.cyl_footer
import com.cyl.refresh.cyl_header
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import kotlin.random.Random

/*
 * MJCollectionViewController and MJPinHeaderCollectionViewController of MJRefresh's example layer (MIT; originally
 * created by MJ Lee, Copyright (c) 2015 小码哥), translated from the iOS example's Swift
 * (`CYLRefreshCollectionViewController.swift`) to Kotlin on this project's Android API.
 */

/**
 * A random opaque color (iOS `CYLRefreshRandomColor`).
 */
internal fun randomColor(): Int = Color.rgb(Random.nextInt(256), Random.nextInt(256), Random.nextInt(256))

/**
 * The collection's items: a purple section header, then 80 dp color squares (iOS flow layout: 80 × 80, insets and
 * spacing 20, header height 30).
 */
private class ColorItems(private val colors: List<Int>, private val open: (Int) -> Unit) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    override fun getItemCount() = colors.size + 1

    override fun getItemViewType(position: Int) = if (position == 0) HEADER else COLOR

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val density = parent.resources.displayMetrics.density
        val size = if (viewType == HEADER) ViewGroup.LayoutParams.MATCH_PARENT else (80 * density).toInt()
        val height = ((if (viewType == HEADER) 30 else 80) * density).toInt()
        val view = View(parent.context).apply { layoutParams = RecyclerView.LayoutParams(size, height) }
        return object : RecyclerView.ViewHolder(view) {}
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val view = holder.itemView
        if (position == 0) {
            view.setBackgroundColor(0xFFAF52DE.toInt())
            return
        }
        val item = position - 1
        view.setBackgroundColor(colors[item])
        view.contentDescription = view.context.t(if (item % 2 == 1) R.string.merged_mj_push else R.string.merged_mj_modal)
        view.setOnClickListener { open(item) }
    }

    companion object {
        const val HEADER = 0
        const val COLOR = 1
    }
}

/**
 * Pull down and up on a collection (iOS `CYLRefreshCollectionViewController.example31`); [pinHeader] is
 * MJPinHeaderCollectionViewController, whose header pinning is a TODO in MJRefresh too, so both pages look the same.
 */
internal fun RefreshExamplesPage.collectionPage(title: String, pinHeader: Boolean, animatedIcons: Boolean = false, openTest: () -> Unit): View {
    val context = requireContext()
    val density = context.resources.displayMetrics.density
    val gap = (20 * density).toInt()
    val colors = ArrayList<Int>()
    val columns = ((context.resources.displayMetrics.widthPixels - gap) / (100 * density)).toInt().coerceAtLeast(1)
    val items = ColorItems(colors) { openTest() }
    val grid = RecyclerView(context).apply {
        tag = if (pinHeader) "refreshPinHeaderCollection" else "refreshCollection"
        layoutManager = GridLayoutManager(context, columns).apply {
            spanSizeLookup = object : GridLayoutManager.SpanSizeLookup() {
                override fun getSpanSize(position: Int) = if (position == 0) columns else 1
            }
        }
        adapter = items
        setPadding(0, 0, 0, gap)
        clipToPadding = false
        addItemDecoration(object : RecyclerView.ItemDecoration() {
            override fun getItemOffsets(outRect: Rect, view: View, parent: RecyclerView, state: RecyclerView.State) {
                if (parent.getChildAdapterPosition(view) == 0) return
                outRect.set(gap / 2, gap, gap / 2, 0)
            }
        })
    }
    val layout = SmartRefreshLayout(context)
    layout.setRefreshContent(grid)

    @Suppress("NotifyDataSetChanged")
    fun reload() {
        items.notifyDataSetChanged()
        // Show the footer only when there is something to load after.
        layout.cyl_footer?.refreshEnabled = colors.isNotEmpty()
    }

    // Pull down: ten fake items, the refresh ends 2 seconds later.
    // example32: animated icons (Lottie arrows while pulling, a gradient spinner while refreshing, a GIF in the footer).
    val header = if (animatedIcons) CYLRefreshAnimationHeader(context).apply {
        setIconAnimationFilePath("asset:Animations/CYLRefreshCounterClockwise.json", 28f, 28f, CYLRefreshState.Idle)
        setIconAnimationFilePath("asset:Animations/CYLRefreshGradientSpinner.json", 32f, 32f, CYLRefreshState.Refreshing)
    } else CYLRefreshNormalHeader(context)
    header.refreshingBlock = {
        repeat(10) { colors.add(0, randomColor()) }
        later(2000) { reload(); header.endRefreshing() }
    }
    layout.cyl_header = header
    // Pull up: five more.
    val footer = if (animatedIcons) CYLRefreshBackAnimationFooter(context).apply {
        setIconAnimationFilePath("asset:Animations/CYLRefreshActivity.gif", 28f, 28f, CYLRefreshState.Idle)
    } else CYLRefreshBackNormalFooter(context)
    footer.refreshingBlock = {
        repeat(5) { colors += randomColor() }
        later(2000) { reload(); footer.endRefreshing() }
    }
    footer.setAnimationDisabled()
    footer.cyl_autoChangeTransparency(true)
    layout.cyl_footer = footer
    reload()
    header.beginRefreshing()
    return page(context, bar(context, title), layout)
}

/**
 * Pages that swipe left; pulling past the last one opens the test page (iOS
 * `CYLRefreshHorizontalCollectionViewController.example42`, MJHorizontalCollectionViewController).
 */
internal fun RefreshExamplesPage.horizontalCollectionPage(title: String, openTest: () -> Unit): View {
    val context = requireContext()
    val density = context.resources.displayMetrics.density
    val colors = List(5) { randomColor() }
    val list = RecyclerView(context).apply {
        tag = "refreshHorizontalCollection"
        layoutManager = LinearLayoutManager(context, LinearLayoutManager.HORIZONTAL, false)
        adapter = object : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
            override fun getItemCount() = colors.size

            override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder =
                object : RecyclerView.ViewHolder(View(parent.context).apply {
                    layoutParams = RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
                }) {}

            override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
                holder.itemView.setBackgroundColor(colors[position])
                holder.itemView.contentDescription = context.t(if (position % 2 == 1) R.string.merged_mj_push else R.string.merged_mj_modal)
                holder.itemView.setOnClickListener { openTest() }
            }
        }
        PagerSnapHelper().attachToRecyclerView(this)
    }
    // The strip is 200 dp high, 150 dp below the top (iOS frame y 150, height 200).
    val column = LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        setPadding(0, (150 * density).toInt(), 0, 0)
        addView(list, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, (200 * density).toInt()))
    }
    // Pull left past the last page: open the test page, then end at once.
    list.cyl_trailer = CYLRefreshNormalTrailer.trailerWithRefreshingBlock(context) {
        openTest()
        list.cyl_trailer?.endRefreshing()
    }
    return page(context, bar(context, title), column)
}
