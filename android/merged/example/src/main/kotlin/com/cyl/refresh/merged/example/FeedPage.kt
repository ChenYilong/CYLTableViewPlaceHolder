package com.cyl.refresh.merged.example

import android.graphics.Color
import android.os.Bundle
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.cyl.placeholder.CYLPlaceholderAction
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
 * The Feed tab (iOS `CYLFeedViewController`): a list like a real one. The first load shows the loading scenario, a pull
 * down refresh alternately fails and shows the scenario with a "Retry" button, and pulling up loads more until "no more
 * data".
 */
class FeedPage : Fragment() {

    private enum class State { Loading, Loaded, Failed }

    private var state = State.Loading
    private var rows = 0
    private var refreshCount = 0

    private inner class Posts : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
        override fun getItemCount() = rows

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
            val context = parent.context
            val density = context.resources.displayMetrics.density
            val cell = LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                gravity = Gravity.CENTER_VERTICAL
                minimumHeight = (64 * density).toInt()
                setPadding((16 * density).toInt(), (8 * density).toInt(), (16 * density).toInt(), (8 * density).toInt())
                layoutParams = RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
                addView(TextView(context).apply { textSize = 17f; tag = "title" })
                addView(TextView(context).apply { textSize = 13f; setTextColor(Color.GRAY); tag = "hint" })
            }
            return object : RecyclerView.ViewHolder(cell) {}
        }

        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
            val context = holder.itemView.context
            holder.itemView.findViewWithTag<TextView>("title").text = context.t(R.string.merged_format_post, position + 1)
            holder.itemView.findViewWithTag<TextView>("hint").text = context.t(R.string.merged_text_feed_hint)
        }
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        val context = requireContext()
        val posts = Posts()
        val list = RecyclerView(context).apply { layoutManager = LinearLayoutManager(context); adapter = posts }
        // The list sits in a frame so its placeholder takes the list's place inside the refresh layout's content.
        val content = FrameLayout(context).apply { addView(list, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)) }
        val layout = SmartRefreshLayout(context)
        layout.setRefreshContent(content)
        val header = CYLRefreshNormalHeader(context)
        val footer = CYLRefreshAutoNormalFooter(context)
        layout.cyl_header = header
        layout.cyl_footer = footer
        val reload = { posts.notifyDataSetChanged(); list.cyl_reloadData() }

        lateinit var loadFirstPage: () -> Unit
        loadFirstPage = {
            state = State.Loading
            rows = 0
            reload()
            later {
                state = State.Loaded
                rows = 15
                footer.resetNoMoreData()
                reload()
            }
        }
        list.cyl_placeholderViewBlock {
            when (state) {
                State.Loading, State.Loaded -> CYLPlaceholderStackView(context, CYLPlaceholderScenario.Loading)
                State.Failed -> CYLPlaceholderStackView(context, CYLPlaceholderScenario.RetryButton, mapOf(CYLPlaceholderAction.Retry to { _: String -> loadFirstPage() }))
            }
        }
        header.refreshingBlock = {
            later {
                refreshCount++
                val fails = refreshCount % 2 == 1
                state = if (fails) State.Failed else State.Loaded
                rows = if (fails) 0 else 15
                footer.resetNoMoreData()
                reload()
                header.endRefreshing()
            }
        }
        footer.refreshingBlock = {
            later {
                if (rows >= 30) {
                    footer.endRefreshingWithNoMoreData()
                } else {
                    rows += 15
                    posts.notifyDataSetChanged()
                    footer.endRefreshing()
                }
            }
        }
        layout.post { loadFirstPage() }
        return layout
    }
}
