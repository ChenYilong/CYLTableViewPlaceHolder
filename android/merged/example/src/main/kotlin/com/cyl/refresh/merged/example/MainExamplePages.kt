package com.cyl.refresh.merged.example

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.ShapeDrawable
import android.graphics.drawable.shapes.OvalShape
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.RadioButton
import android.widget.RadioGroup
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.cyl.placeholder.CYLPlaceholderBadgeStyle
import com.cyl.placeholder.CYLPlaceholderMessage
import com.cyl.placeholder.CYLPlaceholderStyle
import com.cyl.placeholder.CYLPlaceholderView
import com.cyl.placeholder.CYLTableViewPlaceHolderDelegate
import com.cyl.placeholder.cyl_placeholderViewBlock
import com.cyl.placeholder.cyl_reloadData
import com.cyl.placeholder.fromItemAttributes
import com.cyl.placeholder.fromItemContentsOfURL
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.cyl_header
import com.cyl.refresh.layout.CYLRefreshLayout
import kotlin.random.Random

/*
 * The iOS main example (`Examples/Example`) on Android: the main screen (`CYLExampleViewController`, issues #2, #3,
 * #6), "Auto" (`CYLPlaceholderDemoViewController`, #11), "Styles" (`CYLPlaceholderStyleDemoViewController`) and the
 * message picker (`CYLPlaceholderMessageDemoViewController`), pushed from the Placeholder tab.
 */

private fun Context.dp(value: Float) = (value * resources.displayMetrics.density).toInt()

private fun mainLater(ms: Long, block: () -> Unit) = Handler(Looper.getMainLooper()).postDelayed(block, ms)

/**
 * A list of one-line text rows.
 */
private class MainTextRows(val text: (Context, Int) -> String) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    var count = 0

    override fun getItemCount() = count

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) = object : RecyclerView.ViewHolder(
        TextView(parent.context).apply {
            textSize = 17f
            gravity = Gravity.CENTER_VERTICAL
            minHeight = parent.context.dp(48f)
            setPadding(parent.context.dp(16f), 0, parent.context.dp(16f), 0)
            layoutParams = RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
        },
    ) {}

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        (holder.itemView as TextView).text = text(holder.itemView.context, position)
    }
}

/**
 * The collection's grey 100 dp squares, each read as its item number.
 */
private class GridRows : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    var count = 0
    override fun getItemCount() = count
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) = object : RecyclerView.ViewHolder(View(parent.context).apply {
        val c = parent.context
        setBackgroundColor(Color.LTGRAY)
        layoutParams = RecyclerView.LayoutParams(c.dp(100f), c.dp(100f)).apply { setMargins(c.dp(10f), c.dp(10f), c.dp(10f), c.dp(10f)) }
    }) {}
    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        holder.itemView.contentDescription = holder.itemView.context.t(R.string.ex_format_item, position + 1)
    }
}

/**
 * The main screen's rows; as the list's placeholder delegate it picks one of two custom placeholders at random.
 */
private class RandomRows(val makePlaceholder: () -> View) : RecyclerView.Adapter<RecyclerView.ViewHolder>(), CYLTableViewPlaceHolderDelegate {
    val values = ArrayList<Int>()
    private val rows = MainTextRows { context, position -> context.t(R.string.ex_format_random_data, values[position]) }

    override fun getItemCount() = values.size
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) = rows.onCreateViewHolder(parent, viewType)
    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        (holder.itemView as TextView).text = holder.itemView.context.t(R.string.ex_format_random_data, values[position])
    }

    override fun makePlaceHolderView(): View = makePlaceholder()
    override fun enableScrollWhenPlaceHolderViewShowing() = true
}

/**
 * TuTu's (teason) Taobao-style "network is unstable" view with a Reload button (iOS `CYLXTNetReloader`, a Swift
 * translation of `XTNetReloader`; the original copyright stays with its author). Built entirely by the app, as the
 * delegate accepts any view, so it does not use CYLPlaceholderView.
 */
private fun xtNetReloader(context: Context, reload: () -> Unit): View = FrameLayout(context).apply {
    setBackgroundColor(Color.WHITE)
    addView(LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        gravity = Gravity.CENTER_HORIZONTAL
        addView(ImageView(context).apply {
            setImageResource(R.drawable.ex_no_wifi)
            scaleType = ImageView.ScaleType.FIT_CENTER
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
        }, LinearLayout.LayoutParams(context.dp(200f), context.dp(150f)))
        addView(TextView(context).apply {
            text = context.t(R.string.ex_net_reloader_message)
            textSize = 17f
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            setTextColor(Color.DKGRAY)
            gravity = Gravity.CENTER
            minHeight = context.dp(35f)
        }, LinearLayout.LayoutParams(context.dp(300f), ViewGroup.LayoutParams.WRAP_CONTENT))
        addView(TextView(context).apply {
            text = context.t(R.string.ex_net_reloader_reload)
            textSize = 15f
            setTextColor(Color.DKGRAY)
            gravity = Gravity.CENTER
            minWidth = context.dp(100f)
            minHeight = context.dp(30f)
            setPadding(context.dp(8f), 0, context.dp(8f), 0)
            background = GradientDrawable().apply { cornerRadius = context.dp(5f).toFloat(); setStroke(context.dp(1f), Color.DKGRAY) }
            isClickable = true
            isFocusable = true
            tag = "netReloaderReload"
            accessibilityDelegate = object : View.AccessibilityDelegate() {
                override fun onInitializeAccessibilityNodeInfo(host: View, info: android.view.accessibility.AccessibilityNodeInfo) {
                    super.onInitializeAccessibilityNodeInfo(host, info)
                    info.className = Button::class.java.name
                }
            }
            setOnClickListener { reload() }
        }, LinearLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = context.dp(10f) })
    }, FrameLayout.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.CENTER))
}

/**
 * The WeChat-style empty view: an image and a line of text, a touch anywhere reloads (iOS `CYLWeChatStylePlaceHolder`,
 * a Swift translation of `WeChatStylePlaceHolder`). The whole view is one button for accessibility.
 */
private fun weChatStylePlaceHolder(context: Context, reload: () -> Unit): View = FrameLayout(context).apply {
    setBackgroundColor(Color.WHITE)
    val image = ImageView(context).apply {
        setImageResource(R.drawable.ex_wechat_reload)
        importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
    }
    val label = context.t(R.string.ex_we_chat_empty_message)
    addView(LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        gravity = Gravity.CENTER_HORIZONTAL
        setPadding(0, context.dp(60f), 0, 0)
        addView(image, LinearLayout.LayoutParams(context.dp(150f), context.dp(150f)))
        addView(TextView(context).apply {
            text = label
            textSize = 15f
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            setTextColor(Color.GRAY)
            gravity = Gravity.CENTER
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
        }, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply { topMargin = context.dp(10f) })
    }, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.TOP))
    contentDescription = label
    tag = "weChatPlaceholder"
    isClickable = true
    // The image dims while pressed, like the original's long press of 0.001 s.
    setOnTouchListener { _, event ->
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> image.alpha = 0.4f
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> image.alpha = 1f
        }
        false
    }
    setOnClickListener { reload() }
}

/**
 * The main screen (iOS `CYLExampleViewController`): each pull toggles between five random rows and an empty list; an
 * empty list asks the adapter, which picks the Taobao-style or the WeChat-style placeholder at random.
 */
internal fun StackPage.mainExampleScreen(): View {
    val context = requireContext()
    val list = RecyclerView(context).apply { layoutManager = LinearLayoutManager(context) }
    val layout = CYLRefreshLayout(context)
    val header = CYLRefreshNormalHeader(context)
    val beginRefreshing = { header.beginRefreshing() }
    val rows = RandomRows {
        if (Random.nextBoolean()) xtNetReloader(context, beginRefreshing) else weChatStylePlaceHolder(context, beginRefreshing)
    }
    list.adapter = rows
    val frame = FrameLayout(context).apply {
        setBackgroundColor(Color.YELLOW)
        addView(list, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
    }
    layout.setRefreshContent(frame)
    layout.cyl_header = header
    header.refreshingBlock = {
        if (rows.values.isNotEmpty()) rows.values.clear() else repeat(5) { rows.values.add(0, Random.nextInt(1_000_000)) }
        // A one-second fake request, then reload and end refreshing.
        mainLater(1000) {
            rows.notifyDataSetChanged()
            list.cyl_reloadData()
            header.endRefreshing()
        }
    }
    list.post { header.beginRefreshing() }
    val auto = Button(context).apply { text = context.t(R.string.ex_action_auto); tag = "mainExampleAuto"; setOnClickListener { push(automaticPage()) } }
    return page(context, bar(context, "CYLTableViewPlaceHolder", auto), layout)
}

/**
 * "Auto" (iOS `CYLPlaceholderDemoViewController`, #11): a table and a collection share one count; Clear shows the
 * placeholder, + removes it, Disable / Enable turns the block off and on.
 */
private fun StackPage.automaticPage(): View {
    val context = requireContext()
    val tableRows = MainTextRows { c, position -> c.t(R.string.ex_format_item, position + 1) }
    val gridRows = GridRows()
    val table = RecyclerView(context).apply { layoutManager = LinearLayoutManager(context); adapter = tableRows }
    val grid = RecyclerView(context).apply {
        layoutManager = GridLayoutManager(context, 3)
        adapter = gridRows
        setPadding(context.dp(10f), context.dp(10f), context.dp(10f), context.dp(10f))
        clipToPadding = false
        visibility = View.GONE
    }
    fun framed(list: RecyclerView) = FrameLayout(context).apply {
        addView(list, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
    }
    val tableFrame = framed(table)
    val gridFrame = framed(grid).apply { visibility = View.GONE }
    var enabled = true
    fun enable() {
        table.cyl_placeholderViewBlock { CYLPlaceholderView(context, CYLPlaceholderStyle.Empty, CYLPlaceholderMessage.Empty) }
        grid.cyl_placeholderViewBlock { CYLPlaceholderView(context, CYLPlaceholderStyle.Empty, CYLPlaceholderMessage.Empty) }
    }
    enable()
    fun reloadBoth() {
        tableRows.notifyDataSetChanged(); gridRows.notifyDataSetChanged()
        table.cyl_reloadData(); grid.cyl_reloadData()
    }
    val mode = RadioGroup(context).apply {
        orientation = RadioGroup.HORIZONTAL
        contentDescription = context.t(R.string.ex_mode_label)
        listOf(R.string.ex_mode_table, R.string.ex_mode_collection).forEachIndexed { i, title ->
            addView(RadioButton(context).apply { id = 400 + i; text = context.t(title) }, RadioGroup.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
        }
        check(400)
        setOnCheckedChangeListener { _, id ->
            val isTable = id == 400
            tableFrame.visibility = if (isTable) View.VISIBLE else View.GONE
            gridFrame.visibility = if (isTable) View.GONE else View.VISIBLE
            table.visibility = tableFrame.visibility
            grid.visibility = gridFrame.visibility
            reloadBoth()
        }
    }
    val buttons = LinearLayout(context).apply {
        orientation = LinearLayout.HORIZONTAL
        addView(Button(context).apply { text = context.t(R.string.ex_action_styles); setOnClickListener { push(stylesPage()) } })
        addView(Button(context).apply {
            text = context.t(R.string.ex_action_disable)
            setOnClickListener {
                enabled = !enabled
                text = context.t(if (enabled) R.string.ex_action_disable else R.string.ex_action_enable)
                if (enabled) enable() else { table.cyl_placeholderViewBlock(null); grid.cyl_placeholderViewBlock(null) }
            }
        })
        addView(Button(context).apply {
            text = context.t(R.string.ex_action_clear)
            setOnClickListener { tableRows.count = 0; gridRows.count = 0; reloadBoth() }
        })
        addView(Button(context).apply {
            text = "+"
            contentDescription = "Add"
            setOnClickListener {
                tableRows.count++; gridRows.count++
                tableRows.notifyItemInserted(tableRows.count - 1); gridRows.notifyItemInserted(gridRows.count - 1)
                table.cyl_reloadData(); grid.cyl_reloadData()
            }
        })
    }
    val column = LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        addView(mode)
        addView(buttons)
        addView(tableFrame, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
        addView(gridFrame, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
    }
    table.post { reloadBoth() }
    return page(context, bar(context, context.t(R.string.ex_title_automatic)), column)
}

/**
 * "Styles" (iOS `CYLPlaceholderStyleDemoViewController`): every bundled style, then a custom image, the FlatDesign item
 * from code and from a file, and three badges.
 */
private fun StackPage.stylesPage(): View {
    val context = requireContext()
    // The bundled image name is a technical identifier and stays as it is.
    val styles = CYLPlaceholderStyle.values().map { style ->
        MenuItem(CYLPlaceholderView.imageNameForStyle(style), null, null) { push(messagesPage(style, customImage = false)) }
    } + MenuItem(context.t(R.string.ex_style_custom_image), null, null) { push(messagesPage(CYLPlaceholderStyle.Empty, customImage = true)) }
    val flatDesign = listOf(
        MenuItem(context.t(R.string.ex_style_flat_design_code), null, null) { flatDesignItem(fromFile = false) },
        MenuItem(context.t(R.string.ex_style_flat_design_plist), null, null) { flatDesignItem(fromFile = true) },
    )
    val badges = listOf(
        R.string.ex_style_badge_dot to (CYLPlaceholderBadgeStyle.Dot to null),
        R.string.ex_style_badge_number to (CYLPlaceholderBadgeStyle.Number to "105"),
        R.string.ex_style_badge_text to (CYLPlaceholderBadgeStyle.Text to context.t(R.string.ex_badge_new)),
    ).map { (title, badge) ->
        MenuItem(context.t(title), null, null) {
            val placeholder = CYLPlaceholderView(context, CYLPlaceholderStyle.NotificationsOff, CYLPlaceholderMessage.NoNotifications)
            placeholder.showBadgeWithStyle(badge.first, badge.second)
            push(page(context, bar(context, context.t(R.string.ex_title_badge_preview)), placeholder))
        }
    }
    return page(context, bar(context, context.t(R.string.ex_title_styles)), tagMenu(context, listOf(
        MenuSection(context.t(R.string.ex_title_styles), styles),
        MenuSection("FlatDesign", flatDesign),
        MenuSection(context.t(R.string.ex_title_badge_preview), badges),
    )))
}

/**
 * The FlatDesign item from code, or from `assets/CYLPlaceholderItemDemo.json` (the iOS example reads a plist;
 * Android item files are JSON).
 */
private fun StackPage.flatDesignItem(fromFile: Boolean) {
    val context = requireContext()
    var failure: String? = null
    val placeholder = if (fromFile) {
        CYLPlaceholderView.fromItemContentsOfURL(context, "asset:$ITEM_FILE") { failure = it.message }
    } else {
        // The same keys as the iOS example: style, message, offsets and a reserved animation file (the icon stays when
        // no animator plays it).
        CYLPlaceholderView.fromItemAttributes(context, mapOf(
            "CYLPlaceholderItemStyle" to CYLPlaceholderStyle.Warning.ordinal,
            "CYLPlaceholderItemMessage" to CYLPlaceholderMessage.Error.ordinal,
            "CYLPlaceholderItemImagePositionAdjustment" to listOf(8, -6),
            "CYLPlaceholderItemTitlePositionAdjustment" to listOf(0, 6),
            "CYLPlaceholderItemAnimationFilePath" to "reserved-animation.json",
        )) { failure = it.message }
    }
    if (placeholder == null) {
        AlertDialog.Builder(context).setTitle(context.t(R.string.ex_title_configuration_error))
            .setMessage(failure ?: context.t(R.string.ex_format_missing_file, ITEM_FILE))
            .setPositiveButton(context.t(R.string.ex_action_ok), null).show()
        return
    }
    push(page(context, bar(context, context.t(R.string.ex_title_flat_design_item)), placeholder))
}

private const val ITEM_FILE = "CYLPlaceholderItemDemo.json"

/**
 * The message picker (iOS `CYLPlaceholderMessageDemoViewController`): every bundled message, or custom text, shown
 * with [style] (or a blue circle as a custom image).
 */
private fun StackPage.messagesPage(style: CYLPlaceholderStyle, customImage: Boolean): View {
    val context = requireContext()
    fun preview(text: String?, message: CYLPlaceholderMessage?) {
        val placeholder = when {
            customImage -> CYLPlaceholderView(context, ShapeDrawable(OvalShape()).apply {
                paint.color = Color.BLUE
                intrinsicWidth = context.dp(64f)
                intrinsicHeight = context.dp(64f)
            }, text)
            message == null -> CYLPlaceholderView(context, style, text)
            else -> CYLPlaceholderView(context, style, message)
        }
        push(page(context, bar(context, context.t(R.string.ex_action_preview)), placeholder))
    }
    val messages = CYLPlaceholderMessage.values().map { message ->
        val text = CYLPlaceholderView.localizedTextForMessage(context, message)
        MenuItem(text, null, null) { preview(text, message) }
    } + MenuItem(context.t(R.string.ex_custom_text), null, null) {
        val field = EditText(context).apply { hint = context.t(R.string.ex_custom_text_placeholder) }
        AlertDialog.Builder(context).setTitle(context.t(R.string.ex_custom_text)).setView(field)
            .setNegativeButton(context.t(R.string.ex_action_cancel), null)
            .setPositiveButton(context.t(R.string.ex_action_preview)) { _, _ -> preview(field.text.toString(), null) }
            .show()
    }
    return page(context, bar(context, context.t(R.string.ex_title_choose_message)), tagMenu(context, listOf(MenuSection(context.t(R.string.ex_title_choose_message), messages))))
}
