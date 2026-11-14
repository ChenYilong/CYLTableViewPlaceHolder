package com.cyl.refresh.merged.example

import android.graphics.Color
import android.graphics.Rect
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.RadioButton
import android.widget.RadioGroup
import android.widget.TextView
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.cyl.placeholder.CYLPlaceholderAction
import com.cyl.placeholder.CYLPlaceholderScenario
import com.cyl.placeholder.CYLPlaceholderStackView
import com.cyl.placeholder.CYLTableViewPlaceHolderDelegate
import com.cyl.placeholder.cyl_placeholderViewBlock
import com.cyl.placeholder.cyl_reloadData
import com.cyl.refresh.CYLRefreshAutoNormalFooter
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.cyl_footer
import com.cyl.refresh.cyl_header
import com.scwang.smart.refresh.layout.SmartRefreshLayout

/**
 * The flows of the iOS example's Flows tab (`CYLFlow`): each shows a placeholder API in a real list.
 */
internal enum class CYLFlow(val title: Int, val detail: String, val scenario: CYLPlaceholderScenario) {
    SwitchStates(R.string.merged_title_switch_states, "cyl_reloadData #3", CYLPlaceholderScenario.NoContent),
    KeepTableHeader(R.string.merged_title_keep_table_header, "frameForPlaceHolderViewInTableView #17", CYLPlaceholderScenario.NoSearchResults),
    KeepSectionHeaders(R.string.merged_title_keep_section_headers, "frameForPlaceHolderViewInTableView #16", CYLPlaceholderScenario.NoMessages),
    RefreshControls(R.string.merged_title_refresh_controls, "cyl_header + cyl_footer #8", CYLPlaceholderScenario.NoNotifications),
    Scrollable(R.string.merged_title_scrollable, "enableScrollWhenPlaceHolderViewShowing", CYLPlaceholderScenario.TextOnly),
    Collection(R.string.merged_title_collection, "cyl_placeholderViewBlock #11", CYLPlaceholderScenario.NoFavorites),
}

/**
 * A list of "Item n" rows that is also the placeholder delegate (iOS `CYLFlowDetailViewController`'s
 * `CYLTableViewPlaceHolderDelegate`): the frame keeps the headers above the list visible, and the scrollable flow lets
 * an empty list still be pulled.
 */
private class FlowRows(private val makePlaceholder: () -> View, private val scrolls: Boolean, private val top: () -> Int) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>(), CYLTableViewPlaceHolderDelegate {
    var count = 0
    var cellSide = 0

    override fun getItemCount() = count

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val density = parent.resources.displayMetrics.density
        val view = TextView(parent.context).apply {
            textSize = 17f
            gravity = if (cellSide > 0) Gravity.CENTER else Gravity.CENTER_VERTICAL
            minHeight = (48 * density).toInt()
            setPadding((16 * density).toInt(), 0, 0, 0)
            if (cellSide > 0) setBackgroundColor(Color.rgb(0xE5, 0xF6, 0xF8))
            layoutParams = if (cellSide > 0) RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, cellSide).apply { setMargins(8, 8, 8, 8) }
            else RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        }
        return object : RecyclerView.ViewHolder(view) {}
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        (holder.itemView as TextView).text = holder.itemView.context.t(R.string.merged_format_item, position + 1)
    }

    override fun makePlaceHolderView(): View = makePlaceholder()

    override fun enableScrollWhenPlaceHolderViewShowing() = scrolls

    override fun frameForPlaceHolderViewInTableView(tableView: RecyclerView): Rect? {
        val offset = top()
        return if (offset == 0) null else Rect(0, offset, (tableView.parent as View).width, (tableView.parent as View).height)
    }
}

/**
 * A flow's page (iOS `CYLFlowDetailViewController` and `CYLCollectionFlowViewController`).
 */
internal fun ScenariosPage.flowPage(flow: CYLFlow): View {
    val context = requireContext()
    val density = resources.displayMetrics.density
    var state = 0 // empty, failed, offline, data
    val frame = FrameLayout(context)
    val list = RecyclerView(context)
    lateinit var rows: FlowRows
    lateinit var switcher: RadioGroup
    val reload = { rows.notifyDataSetChanged(); list.cyl_reloadData() }
    fun select(newState: Int) {
        state = newState
        rows.count = if (newState == 3) 12 else 0
        if (flow == CYLFlow.SwitchStates && switcher.checkedRadioButtonId != 300 + newState) switcher.check(300 + newState)
        reload()
    }
    fun placeholder(): View {
        val scenario = when (state) {
            1 -> CYLPlaceholderScenario.RetryButton
            2 -> CYLPlaceholderScenario.NetworkUnavailable
            else -> flow.scenario
        }
        return CYLPlaceholderStackView(context, scenario, mapOf(CYLPlaceholderAction.Retry to { _: String -> select(3) })).apply { setBackgroundColor(Color.WHITE) }
    }

    // The headers the placeholder keeps visible: a search box (#17) or the section titles (#16).
    val headers = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
    when (flow) {
        CYLFlow.KeepTableHeader -> headers.addView(EditText(context).apply { hint = context.t(R.string.merged_search_placeholder); setSingleLine() })
        CYLFlow.KeepSectionHeaders -> listOf(R.string.merged_section_pinned, R.string.merged_section_all).forEach {
            headers.addView(TextView(context).apply {
                text = context.t(it); textSize = 13f; setTextColor(Color.GRAY)
                setPadding((16 * density).toInt(), (12 * density).toInt(), 0, (6 * density).toInt())
            })
        }
        else -> Unit
    }
    rows = FlowRows(::placeholder, flow == CYLFlow.Scrollable) { headers.height }
    list.adapter = rows
    if (flow == CYLFlow.Collection) {
        rows.cellSide = (104 * density).toInt()
        list.layoutManager = GridLayoutManager(context, 3)
        list.setPadding(12, 12, 12, 12)
    } else {
        list.layoutManager = LinearLayoutManager(context)
    }
    frame.addView(list, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT).apply {
        // The list starts below the headers; the delegate's frame keeps the placeholder there too.
        topMargin = 0
    })
    frame.addView(headers, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
    headers.addOnLayoutChangeListener { _, _, top, _, bottom, _, oldTop, _, oldBottom ->
        list.setPadding(list.paddingLeft, bottom - top, list.paddingRight, list.paddingBottom)
        if (bottom - top != oldBottom - oldTop) list.post { list.cyl_reloadData() }
    }

    // The flows with a block use cyl_placeholderViewBlock; the others use the adapter as the delegate.
    if (flow == CYLFlow.SwitchStates || flow == CYLFlow.RefreshControls || flow == CYLFlow.Collection) {
        list.cyl_placeholderViewBlock { placeholder() }
    }

    val content: View = if (flow == CYLFlow.Scrollable || flow == CYLFlow.RefreshControls) {
        SmartRefreshLayout(context).apply {
            setRefreshContent(frame)
            val header = CYLRefreshNormalHeader(context)
            cyl_header = header
            header.refreshingBlock = {
                later(1000) {
                    rows.count = if (rows.count > 0) 0 else 12
                    cyl_footer?.resetNoMoreData()
                    reload()
                    header.endRefreshing()
                }
            }
            if (flow == CYLFlow.RefreshControls) {
                val footer = CYLRefreshAutoNormalFooter(context)
                cyl_footer = footer
                footer.refreshingBlock = { later(1000) { footer.endRefreshingWithNoMoreData() } }
            }
        }
    } else frame

    val buttons = ArrayList<Button>()
    if (flow == CYLFlow.Collection) {
        buttons += Button(context).apply {
            text = context.t(R.string.merged_action_add)
            setOnClickListener {
                rows.count = if (rows.count > 0) 0 else 18
                text = context.t(if (rows.count > 0) R.string.merged_action_clear else R.string.merged_action_add)
                reload()
            }
        }
    }
    val column = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
    if (flow == CYLFlow.SwitchStates) {
        switcher = RadioGroup(context).apply {
            orientation = RadioGroup.HORIZONTAL
            tag = "stateSwitcher"
            listOf(R.string.merged_state_empty, R.string.merged_state_failed, R.string.merged_state_offline, R.string.merged_state_data).forEachIndexed { i, title ->
                addView(RadioButton(context).apply { id = 300 + i; text = context.t(title) }, RadioGroup.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
            }
            check(300)
            setOnCheckedChangeListener { _, id -> if (id - 300 != state) select(id - 300) }
        }
        column.addView(switcher)
    }
    column.addView(content, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
    list.post { list.cyl_reloadData() }
    return page(context, bar(context, context.t(flow.title), *buttons.toTypedArray()), column)
}
