package com.cyl.refresh.merged.example

import android.graphics.Color
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.cyl.placeholder.CYLPlaceholderAction
import com.cyl.placeholder.CYLPlaceholderHUD
import com.cyl.placeholder.CYLPlaceholderScenario
import com.cyl.placeholder.CYLPlaceholderStackView
import com.cyl.placeholder.cyl_placeholderViewBlock
import com.cyl.placeholder.cyl_reloadData
import com.cyl.refresh.CYLRefreshAutoNormalFooter
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.cyl_footer
import com.cyl.refresh.cyl_header
import com.scwang.smart.refresh.layout.SmartRefreshLayout

/**
 * The rows "Item n" of the life cycle page.
 */
private class LifecycleRows : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    var items: List<Int> = emptyList()

    override fun getItemCount() = items.size

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val density = parent.resources.displayMetrics.density
        val view = TextView(parent.context).apply {
            textSize = 17f
            gravity = Gravity.CENTER_VERTICAL
            minHeight = (48 * density).toInt()
            setPadding((16 * density).toInt(), 0, 0, 0)
            layoutParams = RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        }
        return object : RecyclerView.ViewHolder(view) {}
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        (holder.itemView as TextView).text = holder.itemView.context.t(R.string.merged_hud_lifecycle_row, items[position])
    }
}

/**
 * The HUD's page life cycle (iOS `CYLHUDLifecycleViewController`): the first load shows the HUD and fails, so the
 * Retry placeholder shows; Retry loads again and succeeds; then pull down refreshes and pull up loads more, up to 45.
 */
internal fun ScenariosPage.hudLifecyclePage(): View {
    val context = requireContext()
    val frame = FrameLayout(context)
    val list = RecyclerView(context).apply { layoutManager = LinearLayoutManager(context); tag = "hudLifecycle" }
    val rows = LifecycleRows()
    list.adapter = rows
    frame.addView(list, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
    val hud = CYLPlaceholderHUD(context, frame).apply { minimumDismissTimeInterval = 1.0 }
    var attempts = 0
    fun reload(items: List<Int>) { rows.items = items; list.cyl_reloadData() }

    // The first attempt fails, the next succeeds, so every state of the cycle shows once.
    lateinit var loadFirstPage: () -> Unit
    loadFirstPage = {
        attempts += 1
        hud.showWithStatus(context.t(R.string.merged_hud_status_loading))
        later(1500) {
            if (attempts == 1) {
                hud.showErrorWithStatus(context.t(R.string.merged_hud_status_failed))
                reload(emptyList())
            } else {
                hud.dismiss()
                reload((1..15).toList())
            }
        }
    }
    // Failed: the placeholder with a "Retry" button, shown only while the list is empty.
    list.cyl_placeholderViewBlock {
        CYLPlaceholderStackView(context, CYLPlaceholderScenario.RetryButton, mapOf(CYLPlaceholderAction.Retry to { _: String -> loadFirstPage() }))
            .apply { setBackgroundColor(Color.WHITE) }
    }
    // Loaded: pull down to refresh, pull up to load more.
    val layout = SmartRefreshLayout(context).apply {
        setRefreshContent(frame)
        val header = CYLRefreshNormalHeader(context)
        cyl_header = header
        header.refreshingBlock = {
            later(1000) {
                reload((1..15).toList())
                header.endRefreshing()
                cyl_footer?.resetNoMoreData()
            }
        }
        val footer = CYLRefreshAutoNormalFooter(context)
        cyl_footer = footer
        footer.refreshingBlock = {
            later(1000) {
                val next = rows.items.size + 1
                reload(rows.items + (next until next + 10))
                if (rows.items.size >= 45) footer.endRefreshingWithNoMoreData() else footer.endRefreshing()
            }
        }
    }
    frame.addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
        override fun onViewAttachedToWindow(v: View) = Unit

        override fun onViewDetachedFromWindow(v: View) = hud.dismiss()
    })
    list.post { loadFirstPage() }
    return page(context, bar(context, context.t(R.string.merged_hud_section_lifecycle)), layout)
}
