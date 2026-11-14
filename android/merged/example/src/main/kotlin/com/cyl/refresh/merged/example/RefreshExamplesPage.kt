package com.cyl.refresh.merged.example

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Movie
import android.graphics.Typeface
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.ScrollView
import android.widget.Switch
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.cyl.refresh.CYLRefreshAutoAnimationFooter
import com.cyl.refresh.CYLRefreshAutoFooter
import com.cyl.refresh.CYLRefreshAutoNormalFooter
import com.cyl.refresh.CYLRefreshBackAnimationFooter
import com.cyl.refresh.CYLRefreshBackFooter
import com.cyl.refresh.CYLRefreshBackNormalFooter
import com.cyl.refresh.CYLRefreshComponent
import com.cyl.refresh.CYLRefreshAnimationHeader
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.CYLRefreshState
import com.cyl.refresh.CYLRefreshStateHeader
import com.cyl.refresh.cyl_footer
import com.cyl.refresh.cyl_header
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import kotlin.random.Random

/*
 * The example layer of MJRefresh (https://github.com/CoderMJLee/MJRefresh, Examples/MJRefreshExample, MIT; originally
 * created by MJ Lee, Copyright (c) 2015 小码哥), translated from the iOS example's Swift
 * (`CYLRefreshExampleViewController.swift`, `CYLRefreshTableViewController.swift`, `CYLRefreshDIYControls.swift`) to
 * Kotlin on this project's Android API.
 */

/**
 * A page of the list (iOS `CYLRefreshExample`): its header, row titles and method names.
 */
private class RefreshExample(val header: Int, val titles: List<Int>, val methods: List<String>, val page: String)

/**
 * The Refresh tab (iOS `CYLRefreshExampleViewController`): MJRefresh's example list on the CYLRefresh API. The list
 * itself refreshes and loads more; a row opens its example.
 */
class RefreshExamplesPage : StackPage() {

    private val examples = listOf(
        RefreshExample(
            R.string.merged_mj_section_header,
            listOf(R.string.merged_mj_default, R.string.merged_mj_animated_images, R.string.merged_mj_hide_time,
                R.string.merged_mj_hide_state_and_time, R.string.merged_mj_custom_text, R.string.merged_mj_custom_control),
            listOf("example01", "example02", "example03", "example04", "example05", "example06"),
            "CYLRefreshTableViewController",
        ),
        RefreshExample(
            R.string.merged_mj_section_footer,
            listOf(R.string.merged_mj_default, R.string.merged_mj_animated_images, R.string.merged_mj_hide_refreshing_text,
                R.string.merged_mj_all_loaded, R.string.merged_mj_no_auto_loading, R.string.merged_mj_custom_text,
                R.string.merged_mj_hide_after_loading, R.string.merged_mj_auto_back01, R.string.merged_mj_auto_back02,
                R.string.merged_mj_custom_auto_control, R.string.merged_mj_custom_back_control),
            listOf("example11", "example12", "example13", "example14", "example15", "example16", "example17",
                "example18", "example19", "example20", "example21"),
            "CYLRefreshTableViewController",
        ),
        // example42 (pull left) needs a trailer, which the Android library does not have yet.
        RefreshExample(
            R.string.merged_mj_section_collection,
            listOf(R.string.merged_mj_pull_up_and_down, R.string.merged_mj_pin_header),
            listOf("example31", "example31"),
            "CYLRefreshCollectionViewController",
        ),
        RefreshExample(
            R.string.merged_mj_section_web,
            listOf(R.string.merged_mj_web_pull_old, R.string.merged_mj_web_pull),
            listOf("example40", "example41"),
            "CYLRefreshWKWebViewController",
        ),
        RefreshExample(R.string.merged_mj_section_i18n, listOf(R.string.merged_mj_languages), listOf("i18n"),
            "CYLRefreshI18NExampleViewController"),
        RefreshExample(R.string.merged_smart_section, smartStyles.map { it.first }, smartStyles.map { it.second },
            "CYLSmartRefreshDemoViewController"),
    )

    override fun root(): View {
        val context = requireContext()
        val column = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL; tag = "refreshExamples" }
        for (exam in examples) {
            column.addView(header(context, context.t(exam.header)))
            exam.titles.forEachIndexed { i, title ->
                column.addView(row(context, context.t(title), "${exam.page} - ${exam.methods[i]}", "refresh-${exam.methods[i]}") {
                    val name = context.t(title)
                    push(when {
                        exam.header == R.string.merged_mj_section_collection ->
                            collectionPage(name, pinHeader = i == 1) { push(testPage()) }
                        exam.header == R.string.merged_mj_section_web -> webPage()
                        exam.header == R.string.merged_mj_section_i18n -> i18nPage(name)
                        exam.header == R.string.merged_smart_section -> smartStylePage(name, exam.methods[i])
                        else -> tablePage(name, exam.methods[i])
                    })
                })
            }
        }
        // Pull down to refresh, pull up to load: each ends 2 seconds later.
        return SmartRefreshLayout(context).apply {
            setRefreshContent(ScrollView(context).apply { addView(column) })
            val header = CYLRefreshNormalHeader(context)
            cyl_header = header
            header.refreshingBlock = { later(2000) { header.endRefreshing() } }
            // Fades automatically.
            header.automaticallyChangeAlpha = true
            val footer = CYLRefreshBackNormalFooter(context)
            cyl_footer = footer
            footer.refreshingBlock = { later(2000) { footer.endRefreshing() } }
        }
    }

    /**
     * MJTestViewController: the page a row of an example opens. iOS pushes it on odd rows and presents it on even rows;
     * here both push, with a Close button.
     */
    internal fun testPage(): View {
        val context = requireContext()
        val close = Button(context).apply { text = context.t(R.string.merged_mj_close); setOnClickListener { pop() } }
        return page(context, bar(context, context.t(R.string.merged_mj_test_title), close), FrameLayout(context))
    }

    /**
     * MJTableViewController (iOS `CYLRefreshTableViewController`): a list of random data running one example.
     */
    private fun tablePage(title: String, method: String): View {
        val context = requireContext()
        val layout = SmartRefreshLayout(context)
        val data = MutableList(5) { randomData(context) }
        val list = RecyclerView(context).apply { layoutManager = LinearLayoutManager(context); tag = "refreshExample" }
        val rows = DataRows(data) { testPage().let(::push) }
        list.adapter = rows
        layout.setRefreshContent(list)
        val buttons = ArrayList<Button>()

        @Suppress("NotifyDataSetChanged")
        fun reload() = rows.notifyDataSetChanged()

        // New data for a pull down.
        fun loadNewData() {
            repeat(5) { data.add(0, randomData(context)) }
            later(DURATION) { reload(); layout.cyl_header?.endRefreshing() }
        }
        // More data for a pull up.
        fun loadMoreData() {
            data += randomData(context)
            later(DURATION) { reload(); layout.cyl_footer?.endRefreshing() }
        }
        // The last data: the footer then shows "no more data".
        fun loadLastData() {
            repeat(5) { data += randomData(context) }
            later(DURATION) { reload(); layout.cyl_footer?.endRefreshingWithNoMoreData() }
        }
        // Data that loads only once: the footer hides afterwards.
        fun loadOnceData() {
            repeat(5) { data += randomData(context) }
            later(DURATION) { reload(); layout.cyl_footer?.endRefreshing(); layout.setEnableLoadMore(false) }
        }

        fun <T : CYLRefreshComponent> T.on(block: () -> Unit): T = apply { refreshingBlock = block }

        /** Default: the callback runs as soon as the control enters the refreshing state. */
        fun example01() {
            layout.cyl_header = CYLRefreshNormalHeader(context).on(::loadNewData)
            layout.cyl_header?.beginRefreshing()
        }

        when (method) {
            "example01" -> example01()
            "example02" -> {
                // Animated images
                layout.cyl_header = ExampleImagesHeader(context).on(::loadNewData)
                layout.cyl_header?.beginRefreshing()
            }
            "example03" -> {
                // Hide the time
                val header = CYLRefreshNormalHeader(context).on(::loadNewData)
                header.automaticallyChangeAlpha = true
                header.lastUpdatedTimeLabel?.visibility = View.GONE
                layout.cyl_header = header
                header.beginRefreshing()
            }
            "example04" -> {
                // Hide the state and time
                val header = ExampleImagesHeader(context).on(::loadNewData)
                header.lastUpdatedTimeLabel?.visibility = View.GONE
                header.stateLabel?.visibility = View.GONE
                layout.cyl_header = header
                header.beginRefreshing()
            }
            "example05" -> {
                // Custom text, fonts and colors
                val header = CYLRefreshNormalHeader(context).on(::loadNewData)
                header.setTitle(context.t(R.string.merged_mj_custom_idle), CYLRefreshState.Idle)
                header.setTitle(context.t(R.string.merged_mj_custom_pulling), CYLRefreshState.Pulling)
                header.setTitle(context.t(R.string.merged_mj_custom_loading), CYLRefreshState.Refreshing)
                header.stateLabel?.textSize = 15f
                header.lastUpdatedTimeLabel?.textSize = 14f
                header.stateLabel?.setTextColor(Color.RED)
                header.lastUpdatedTimeLabel?.setTextColor(Color.BLUE)
                layout.cyl_header = header
                header.beginRefreshing()
            }
            "example06" -> {
                // Custom refresh control
                layout.cyl_header = DIYHeader(context).on(::loadNewData)
                layout.cyl_header?.beginRefreshing()
            }
            "example11" -> { example01(); layout.cyl_footer = CYLRefreshAutoNormalFooter(context).on(::loadMoreData) }
            "example12" -> { example01(); layout.cyl_footer = ExampleImagesFooter(context).on(::loadMoreData) }
            "example13" -> {
                example01()
                val footer = ExampleImagesFooter(context).on(::loadMoreData)
                // Refreshes automatically once 50% of the footer shows (the default 1.0 waits for all of it):
                // footer.triggerAutomaticallyRefreshPercent = 0.5f
                // Hide the text of the refreshing state
                footer.refreshingTitleHidden = true
                layout.cyl_footer = footer
            }
            "example14" -> {
                // Everything loaded; "Resume loading" resets it.
                example01()
                val footer = CYLRefreshAutoNormalFooter(context).on(::loadLastData)
                layout.cyl_footer = footer
                buttons += Button(context).apply {
                    text = context.t(R.string.merged_mj_resume_loading)
                    setOnClickListener { footer.refreshingBlock = ::loadMoreData; footer.resetNoMoreData() }
                }
            }
            "example15" -> {
                // No automatic loading
                example01()
                layout.cyl_footer = CYLRefreshAutoNormalFooter(context).on(::loadMoreData).apply { automaticallyRefresh = false }
            }
            "example16" -> {
                // Custom text
                example01()
                val footer = CYLRefreshAutoNormalFooter(context).on(::loadMoreData)
                footer.setTitle(context.t(R.string.merged_mj_footer_idle), CYLRefreshState.Idle)
                footer.setTitle(context.t(R.string.merged_mj_footer_loading), CYLRefreshState.Refreshing)
                footer.setTitle(context.t(R.string.merged_mj_footer_no_more), CYLRefreshState.NoMoreData)
                footer.stateLabel?.textSize = 17f
                footer.stateLabel?.setTextColor(Color.BLUE)
                layout.cyl_footer = footer
            }
            "example17" -> { example01(); layout.cyl_footer = CYLRefreshAutoNormalFooter(context).on(::loadOnceData) }
            "example18" -> {
                // A bottom inset that the footer ignores
                example01()
                val footer = CYLRefreshBackNormalFooter(context).on(::loadMoreData)
                val inset = (30 * resources.displayMetrics.density).toInt()
                list.clipToPadding = false
                list.setPadding(0, 0, 0, inset)
                footer.ignoredScrollViewContentInsetBottom = 30f
                layout.cyl_footer = footer
            }
            "example19" -> {
                example01()
                layout.cyl_footer = ExampleImagesBackFooter(context).on(::loadLastData).apply { automaticallyChangeAlpha = true }
            }
            "example20" -> {
                // Custom control that loads automatically, twice
                example01()
                layout.cyl_footer = DIYAutoFooter(context).on(::loadMoreData).apply { autoTriggerTimes = 2 }
            }
            "example21" -> { example01(); layout.cyl_footer = DIYBackFooter(context).on(::loadMoreData) }
        }
        return page(context, bar(context, title, *buttons.toTypedArray()), layout)
    }

    private companion object {
        /**
         * MJRefresh's MJDuration: long enough to see the refreshing state.
         */
        const val DURATION = 2000L

        fun randomData(context: Context) = context.t(R.string.merged_mj_random_data, Random.nextInt(1_000_000))
    }
}

/**
 * The rows "Push - data" / "Modal - data" of an example list.
 */
private class DataRows(private val data: List<String>, private val open: () -> Unit) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    override fun getItemCount() = data.size

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val density = parent.resources.displayMetrics.density
        val view = TextView(parent.context).apply {
            textSize = 16f
            gravity = Gravity.CENTER_VERTICAL
            minHeight = (48 * density).toInt()
            setPadding((16 * density).toInt(), 0, (16 * density).toInt(), 0)
            layoutParams = RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            setBackgroundResource(android.R.drawable.list_selector_background)
        }
        return object : RecyclerView.ViewHolder(view) {}
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val context = holder.itemView.context
        val action = context.t(if (position % 2 == 1) R.string.merged_mj_push else R.string.merged_mj_modal)
        (holder.itemView as TextView).text = "$action - ${data[position]}"
        holder.itemView.setOnClickListener { open() }
    }
}

// MARK: - Animated images (MJChiBaoZi…)

/**
 * The frames of the example's refresh GIFs (iOS `CYLRefreshExampleImages`), in place of MJRefresh's mascot images.
 */
private object ExampleImages {
    private val cache = HashMap<String, List<Drawable>>()

    fun idle(context: Context) = frames(context, "Animations/CYLRefreshArrows.gif")

    fun refreshing(context: Context) = frames(context, "Animations/CYLRefreshRing.gif")

    /**
     * Decodes [asset] into one drawable every 50 ms of the GIF.
     */
    @Suppress("DEPRECATION")
    private fun frames(context: Context, asset: String): List<Drawable> = cache.getOrPut(asset) {
        val movie = context.assets.open(asset).use { Movie.decodeStream(it) } ?: return@getOrPut emptyList()
        val duration = movie.duration().takeIf { it > 0 } ?: 1000
        (0 until duration step 50).map { time ->
            val bitmap = Bitmap.createBitmap(movie.width().coerceAtLeast(1), movie.height().coerceAtLeast(1), Bitmap.Config.ARGB_8888)
            movie.setTime(time)
            movie.draw(Canvas(bitmap), 0f, 0f)
            BitmapDrawable(context.resources, bitmap)
        }
    }
}

/**
 * MJChiBaoZiHeader: images for the idle, pulling and refreshing states.
 */
internal class ExampleImagesHeader(context: Context) : CYLRefreshAnimationHeader(context) {
    init {
        setAnimationImages(ExampleImages.idle(context), CYLRefreshState.Idle)
        setAnimationImages(ExampleImages.refreshing(context), CYLRefreshState.Pulling)
        setAnimationImages(ExampleImages.refreshing(context), CYLRefreshState.Refreshing)
    }
}

/**
 * MJChiBaoZiFooter: images for the refreshing state of an automatic footer.
 */
private class ExampleImagesFooter(context: Context) : CYLRefreshAutoAnimationFooter(context) {
    init {
        setAnimationImages(ExampleImages.refreshing(context), CYLRefreshState.Refreshing)
    }
}

/**
 * MJChiBaoZiFooter2: images for the idle, pulling and refreshing states of a back footer.
 */
private class ExampleImagesBackFooter(context: Context) : CYLRefreshBackAnimationFooter(context) {
    init {
        setAnimationImages(ExampleImages.idle(context), CYLRefreshState.Idle)
        setAnimationImages(ExampleImages.refreshing(context), CYLRefreshState.Pulling)
        setAnimationImages(ExampleImages.refreshing(context), CYLRefreshState.Refreshing)
    }
}

// MARK: - Custom controls (MJDIY…)

/**
 * The subviews the three custom controls share (iOS `CYLRefreshDIYViews`): a label, a switch only for show, a logo and
 * a spinner. They cover the component's view, whose own subviews are hidden; MJRefresh's DIY example builds its own
 * subviews on purpose, so CYLPlaceholderView is not used.
 */
private class DIYViews(component: CYLRefreshComponent, logo: Boolean, switchAtEnd: Boolean) {
    private val host = component.view.view as ViewGroup
    private val context = host.context
    val label = TextView(context).apply {
        setTextColor(Color.rgb(255, 128, 0)); textSize = 16f; typeface = Typeface.DEFAULT_BOLD; gravity = Gravity.CENTER
    }
    @Suppress("UseSwitchCompatOrMaterialCode")
    val toggle = Switch(context).apply { isClickable = false; importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO }
    val loading = ProgressBar(context).apply { visibility = View.INVISIBLE }

    /**
     * The label's text for each state.
     */
    var texts: Map<CYLRefreshState, Int> = emptyMap()

    init {
        // The component's own views stay hidden, also when its state changes and animations show them again.
        val own = (0 until host.childCount).map { host.getChildAt(it) }
        own.forEach { it.visibility = View.GONE }
        host.viewTreeObserver.addOnPreDrawListener {
            own.forEach { if (it.visibility != View.GONE) it.visibility = View.GONE }
            true
        }
        val density = context.resources.displayMetrics.density
        val row = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            setPadding((16 * density).toInt(), 0, (16 * density).toInt(), 0)
        }
        val start: View = if (switchAtEnd) loading else toggle
        val end: View = if (switchAtEnd) toggle else loading
        val side = (40 * density).toInt()
        row.addView(start, LinearLayout.LayoutParams(side * 2, side))
        if (logo) {
            row.addView(ImageView(context).apply {
                setImageResource(android.R.drawable.ic_popup_sync); setColorFilter(Color.rgb(0x30, 0xB0, 0xC7))
                importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
            }, LinearLayout.LayoutParams(side / 2, side / 2))
        }
        row.addView(label, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
        row.addView(end, LinearLayout.LayoutParams(side * 2, side))
        host.addView(row, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, (50 * density).toInt()))
        component.addPhaseObserver { c, _, _ -> show(c.state) }
        show(CYLRefreshState.Idle)
    }

    fun show(state: CYLRefreshState) {
        val text = texts[state] ?: return
        label.text = context.t(text)
        toggle.isChecked = state == CYLRefreshState.Pulling || state == CYLRefreshState.Refreshing
        loading.visibility = if (state == CYLRefreshState.Refreshing) View.VISIBLE else View.INVISIBLE
    }

    /**
     * MJDIYHeader's color: from orange to purple as the control is pulled out.
     */
    fun follow(percent: Float) {
        val p = percent.coerceIn(0f, 1f)
        label.setTextColor(Color.rgb(((1f - p * 0.5f) * 255).toInt(), ((0.5f - 0.5f * p) * 255).toInt(), (0.5f * p * 255).toInt()))
    }
}

/**
 * MJDIYHeader
 */
private class DIYHeader(context: Context) : CYLRefreshStateHeader(context) {
    private val views = DIYViews(this, logo = true, switchAtEnd = false).apply {
        texts = mapOf(
            CYLRefreshState.Idle to R.string.merged_mjdiy_pull_down,
            CYLRefreshState.Pulling to R.string.merged_mjdiy_release,
            CYLRefreshState.Refreshing to R.string.merged_mjdiy_loading,
        )
        show(CYLRefreshState.Idle)
    }

    override fun didScrollWithOffset(offset: Int, percent: Float, dragging: Boolean) = views.follow(percent)
}

/**
 * MJDIYAutoFooter
 */
private class DIYAutoFooter(context: Context) : CYLRefreshAutoFooter(context) {
    init {
        DIYViews(this, logo = false, switchAtEnd = true).apply {
            texts = mapOf(
                CYLRefreshState.Idle to R.string.merged_mjdiy_pull_up,
                CYLRefreshState.Refreshing to R.string.merged_mjdiy_loading,
                CYLRefreshState.NoMoreData to R.string.merged_mjdiy_no_more,
            )
            show(CYLRefreshState.Idle)
        }
    }
}

/**
 * MJDIYBackFooter
 */
private class DIYBackFooter(context: Context) : CYLRefreshBackFooter(context) {
    private val views = DIYViews(this, logo = true, switchAtEnd = false).apply {
        texts = mapOf(
            CYLRefreshState.Idle to R.string.merged_mjdiy_pull_up,
            CYLRefreshState.Pulling to R.string.merged_mjdiy_release,
            CYLRefreshState.Refreshing to R.string.merged_mjdiy_loading,
            CYLRefreshState.NoMoreData to R.string.merged_mjdiy_no_more,
        )
        show(CYLRefreshState.Idle)
    }

    override fun didScrollWithOffset(offset: Int, percent: Float, dragging: Boolean) = views.follow(percent)
}
