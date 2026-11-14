package com.cyl.refresh.merged.example

import android.content.Context
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.widget.NestedScrollView
import androidx.fragment.app.Fragment
import com.cyl.placeholder.CYLPlaceholderScenario
import com.cyl.placeholder.CYLPlaceholderStackView
import com.cyl.svpulltorefresh.SVPullToRefreshLayout
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import `in`.srain.cube.views.ptr.PtrClassicFrameLayout
import `in`.srain.cube.views.ptr.PtrDefaultHandler
import `in`.srain.cube.views.ptr.PtrFrameLayout

/**
 * A list of text rows for the pages: an intro line, then the loaded rows; with no rows it shows a placeholder.
 */
internal class RowList(context: Context, intro: Int) : NestedScrollView(context) {
    private val rows = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
    private val placeholder = CYLPlaceholderStackView(context, CYLPlaceholderScenario.NoContent)
    private var count = 0

    init {
        isFillViewport = true
        val padding = (16 * resources.displayMetrics.density).toInt()
        rows.addView(TextView(context).apply {
            setText(intro)
            setPadding(padding, padding, padding, padding)
        })
        rows.addView(placeholder, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
        addView(rows, LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
    }

    /**
     * Replaces the rows with [n] new ones (a refresh).
     */
    fun reload(n: Int) {
        while (rows.childCount > 2) rows.removeViewAt(2)
        count = 0
        more(n)
    }

    /**
     * Adds [n] rows (a load more).
     */
    fun more(n: Int) {
        placeholder.visibility = if (count + n == 0) View.VISIBLE else View.GONE
        val padding = (16 * resources.displayMetrics.density).toInt()
        repeat(n) {
            count++
            rows.addView(TextView(context).apply {
                text = context.getString(R.string.merged_row, count)
                textSize = 17f
                minHeight = (48 * resources.displayMetrics.density).toInt()
                gravity = Gravity.CENTER_VERTICAL
                setPadding(padding, 0, padding, 0)
            })
        }
    }
}

/**
 * Runs [block] after a short pause, like a network request.
 */
internal fun later(delay: Long = 1200, block: () -> Unit) {
    Handler(Looper.getMainLooper()).postDelayed(block, delay)
}

/**
 * The placeholder tab: every scenario of CYLTableViewPlaceHolder's placeholder views, one after the other.
 */
class PlaceholderPage : Fragment() {

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = requireContext()
        val column = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
        val height = (360 * resources.displayMetrics.density).toInt()
        CYLPlaceholderScenario.entries.forEach { scenario ->
            column.addView(CYLPlaceholderStackView(context, scenario), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, height))
        }
        return NestedScrollView(context).apply { addView(column) }
    }
}

/**
 * The SVPullToRefresh tab: pull to refresh at the top, infinite scrolling at the end.
 */
class SVPullToRefreshPage : Fragment() {

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = requireContext()
        val list = RowList(context, R.string.merged_intro_svpulltorefresh)
        val layout = SVPullToRefreshLayout(context)
        layout.addView(list, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        layout.addPullToRefresh { later { list.reload(20); layout.pullToRefreshView?.stopAnimating() } }
        layout.addInfiniteScrolling { later { list.more(10); layout.infiniteScrollingView?.stopAnimating() } }
        return layout
    }
}

/**
 * The android-Ultra-Pull-To-Refresh tab: the classic header.
 */
class UltraPullToRefreshPage : Fragment() {

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = requireContext()
        val list = RowList(context, R.string.merged_intro_ultraptr)
        val frame = PtrClassicFrameLayout(context)
        frame.addView(list, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        frame.setPtrHandler(object : PtrDefaultHandler() {
            override fun onRefreshBegin(frame: PtrFrameLayout) {
                later { list.reload(20); frame.refreshComplete() }
            }
        })
        return frame
    }
}
