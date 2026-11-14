package com.cyl.refresh.merged.example

import android.os.Bundle
import android.view.Gravity
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.PopupMenu
import android.widget.RadioButton
import android.widget.RadioGroup
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.cyl.placeholder.CYLPlaceholderNetworkMonitor
import com.cyl.placeholder.CYLPlaceholderStatusDisplay
import com.cyl.placeholder.CYLPlaceholderStatusView
import com.cyl.placeholder.CYLPlaceholderStatusViewDelegate
import com.cyl.placeholder.cyl_applyStatusConfigurationWithContentsOfURL
import com.cyl.placeholder.cyl_placeholderScrollView
import com.cyl.placeholder.cyl_setStatusDisplay
import com.cyl.placeholder.cyl_showsStatusViewWhenOffline
import com.cyl.placeholder.cyl_statusDisplay
import com.cyl.placeholder.cyl_statusView

/**
 * The network status bar page (iOS `CYLStatusBarViewController`): a bar at the top that says the network is not
 * reachable, with a placeholder over the list. The four modes at the bottom choose what shows; "Network" makes the bar
 * follow the network by itself; "File" applies one of the status configuration files in `assets/StatusBar`.
 */
class StatusBarActivity : AppCompatActivity(), CYLPlaceholderStatusViewDelegate {

    private enum class Mode(val title: Int, val display: Int) {
        BarAndPlaceholder(R.string.merged_status_mode_both, CYLPlaceholderStatusDisplay.All),
        BarOnly(R.string.merged_status_mode_bar, CYLPlaceholderStatusDisplay.StatusBar),
        PlaceholderOnly(R.string.merged_status_mode_placeholder, CYLPlaceholderStatusDisplay.Placeholder),
        BarAndList(R.string.merged_status_mode_list, CYLPlaceholderStatusDisplay.StatusBar),
    }

    private var mode = Mode.BarAndPlaceholder
    private lateinit var list: RecyclerView
    private lateinit var modes: RadioGroup
    private lateinit var network: Button

    private val rows = object : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
        override fun getItemCount() = if (mode == Mode.BarAndList) 12 else 0

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) = object : RecyclerView.ViewHolder(
            TextView(parent.context).apply {
                textSize = 17f
                gravity = Gravity.CENTER_VERTICAL
                minHeight = (48 * resources.displayMetrics.density).toInt()
                setPadding((16 * resources.displayMetrics.density).toInt(), 0, 0, 0)
                layoutParams = RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            },
        ) {}

        override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
            (holder.itemView as TextView).text = t(R.string.merged_format_item, position + 1)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        title = t(R.string.merged_title_status_bar)
        list = RecyclerView(this).apply { layoutManager = LinearLayoutManager(this@StatusBarActivity); adapter = rows; tag = "statusBarDemo" }
        val frame = FrameLayout(this).apply { addView(list, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)) }
        modes = RadioGroup(this).apply {
            orientation = RadioGroup.HORIZONTAL
            tag = "statusBarMode"
            Mode.values().forEach { m ->
                addView(RadioButton(this@StatusBarActivity).apply { id = 100 + m.ordinal; text = t(m.title); textSize = 12f; minHeight = (56 * resources.displayMetrics.density).toInt() }, RadioGroup.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
            }
            check(100 + mode.ordinal)
            setOnCheckedChangeListener { _, id ->
                mode = Mode.values()[id - 100]
                apply(true)
            }
        }
        network = Button(this).apply { tag = "statusFollowNetwork"; text = t(R.string.merged_status_follow_network); setOnClickListener { toggleNetwork() } }
        val files = Button(this).apply { text = t(R.string.merged_action_show_file); setOnClickListener { showFiles(this) } }
        val buttons = LinearLayout(this).apply {
            gravity = Gravity.END
            addView(network)
            addView(files)
        }
        val bottom = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(0, 0, 0, (24 * resources.displayMetrics.density).toInt())
            addView(modes)
            addView(buttons)
        }
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            addView(frame, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
            addView(bottom)
        }
        setContentView(root)
        // The placeholder covers the list's own frame, so the modes stay in reach.
        cyl_placeholderScrollView = list
        cyl_statusView.delegate = this
        cyl_statusView.placeholderView.contentDescription = t(R.string.merged_feedback_reconnect)
        apply(false)
    }

    private fun apply(animated: Boolean) {
        rows.notifyDataSetChanged()
        cyl_setStatusDisplay(mode.display, animated)
    }

    private fun toggleNetwork() {
        cyl_showsStatusViewWhenOffline = !cyl_showsStatusViewWhenOffline
        network.text = t(if (cyl_showsStatusViewWhenOffline) R.string.merged_status_following_network else R.string.merged_status_follow_network)
        val status = CYLPlaceholderNetworkMonitor.nameForStatus(CYLPlaceholderNetworkMonitor.sharedMonitor(this).networkStatus)
        Toast.makeText(this, t(R.string.merged_format_network_status, status), Toast.LENGTH_SHORT).show()
    }

    override fun statusViewClicked(sender: CYLPlaceholderStatusView) {
        Toast.makeText(this, t(R.string.merged_feedback_reconnect), Toast.LENGTH_SHORT).show()
    }

    private fun showFiles(anchor: android.view.View) {
        val menu = PopupMenu(this, anchor)
        val names = assets.list("StatusBar").orEmpty().filter { it.endsWith(".json") }.sorted()
        names.forEachIndexed { index, name -> menu.menu.add(0, index, index, name) }
        menu.menu.add(0, names.size, names.size, t(R.string.merged_action_cancel))
        menu.setOnMenuItemClickListener { item ->
            if (item.itemId < names.size) applyFile(names[item.itemId])
            true
        }
        menu.show()
    }

    private fun applyFile(name: String) {
        var failure: String? = null
        if (!cyl_applyStatusConfigurationWithContentsOfURL("asset:StatusBar/$name") { failure = it.message }) {
            Toast.makeText(this, failure, Toast.LENGTH_LONG).show()
            return
        }
        cyl_statusView.delegate = this
        mode = when (cyl_statusDisplay) {
            CYLPlaceholderStatusDisplay.All -> Mode.BarAndPlaceholder
            CYLPlaceholderStatusDisplay.StatusBar -> Mode.BarOnly
            else -> Mode.PlaceholderOnly
        }
        modes.setOnCheckedChangeListener(null)
        modes.check(100 + mode.ordinal)
        modes.setOnCheckedChangeListener { _, id -> mode = Mode.values()[id - 100]; apply(true) }
        rows.notifyDataSetChanged()
    }
}
