package com.cyl.refresh.merged.example

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.PopupMenu
import android.widget.ScrollView
import android.widget.TextView
import android.widget.Toast
import androidx.activity.OnBackPressedCallback
import androidx.annotation.StringRes
import androidx.core.view.ViewCompat
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.cyl.placeholder.CYLPlaceholderAction
import com.cyl.placeholder.CYLPlaceholderComponent
import com.cyl.placeholder.CYLPlaceholderConfiguration_fromJSON
import com.cyl.placeholder.CYLPlaceholderLocalization
import com.cyl.placeholder.CYLPlaceholderScenario
import com.cyl.placeholder.CYLPlaceholderScenarioCategory
import com.cyl.placeholder.CYLPlaceholderScenarioCatalog
import com.cyl.placeholder.CYLPlaceholderStackView
import com.cyl.placeholder.CYLPlaceholderStyle
import com.cyl.placeholder.cyl_placeholderViewBlock
import com.cyl.placeholder.cyl_reloadData
import com.cyl.placeholder.fromConfiguration
import com.cyl.refresh.CYLRefreshConfig

/**
 * A text of the example in the language chosen with the language button (the iOS `CYLScenarioLocalizedString`).
 */
internal fun Context.t(@StringRes id: Int, vararg args: Any): String =
    CYLPlaceholderLocalization.localizedContext(this).getString(id, *args)

private fun Context.dp(value: Float) = (value * resources.displayMetrics.density).toInt()

/**
 * The Scenarios tab (the iOS example's first tab): every scenario of the placeholder catalog in three sections, the
 * configuration files, and a language button. A row opens the scenario's page; the system back button returns.
 */
class ScenariosPage : Fragment() {

    private lateinit var host: FrameLayout
    private val pages = ArrayList<View>()
    private val back = object : OnBackPressedCallback(false) {
        override fun handleOnBackPressed() = pop()
    }

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        host = FrameLayout(requireContext())
        requireActivity().onBackPressedDispatcher.addCallback(viewLifecycleOwner, back)
        pages.clear()
        push(list())
        return host
    }

    internal fun push(view: View) {
        pages.lastOrNull()?.visibility = View.GONE
        pages += view
        host.addView(view, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        back.isEnabled = pages.size > 1
    }

    internal fun pop() {
        if (pages.size <= 1) return
        host.removeView(pages.removeAt(pages.size - 1))
        pages.last().visibility = View.VISIBLE
        back.isEnabled = pages.size > 1
    }

    // MARK: - The list

    internal fun row(context: Context, title: String, subtitle: String?, id: String, onClick: () -> Unit) = LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        setPadding(context.dp(16f), context.dp(10f), context.dp(16f), context.dp(10f))
        minimumHeight = context.dp(56f)
        gravity = Gravity.CENTER_VERTICAL
        tag = id
        contentDescription = listOfNotNull(title, subtitle).joinToString(", ")
        addView(TextView(context).apply { text = title; textSize = 17f; importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO })
        subtitle?.let {
            addView(TextView(context).apply { text = it; textSize = 13f; setTextColor(Color.GRAY); importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO })
        }
        isClickable = true
        isFocusable = true
        setBackgroundResource(android.R.drawable.list_selector_background)
        setOnClickListener { onClick() }
    }

    internal fun header(context: Context, text: String) = TextView(context).apply {
        this.text = text
        textSize = 13f
        setTextColor(Color.GRAY)
        setPadding(context.dp(16f), context.dp(18f), context.dp(16f), context.dp(6f))
        ViewCompat.setAccessibilityHeading(this, true)
    }

    private fun list(): View {
        val context = requireContext()
        val column = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
        column.addView(languageRow(context))
        val all = CYLPlaceholderScenarioCatalog.allScenarios
        val isPermission = { s: CYLPlaceholderScenario -> CYLPlaceholderScenarioCatalog.categoryForScenario(s) == CYLPlaceholderScenarioCategory.Permission }
        val hasScreenshots = { s: CYLPlaceholderScenario -> CYLPlaceholderScenarioCatalog.readmeScreenshotNumbersForScenario(s).isNotEmpty() }
        val sections = listOf(
            R.string.merged_section_readme to all.filter { hasScreenshots(it) && !isPermission(it) },
            R.string.merged_section_permissions to all.filter(isPermission),
            R.string.merged_section_business to all.filter { !hasScreenshots(it) && !isPermission(it) },
        )
        for ((title, scenarios) in sections) {
            column.addView(header(context, context.t(title)))
            for (scenario in scenarios) {
                val count = CYLPlaceholderScenarioCatalog.componentsForScenario(context, scenario).size
                var detail = context.t(R.string.merged_format_components, count)
                val numbers = CYLPlaceholderScenarioCatalog.readmeScreenshotNumbersForScenario(scenario)
                if (numbers.isNotEmpty()) detail = context.t(R.string.merged_format_readme_numbers, numbers.joinToString(", ") { "#%02d".format(it) }) + " · " + detail
                column.addView(row(context, CYLPlaceholderScenarioCatalog.localizedNameForScenario(context, scenario), detail, "scenario-${scenario.ordinal}") { push(detail(scenario)) })
            }
        }
        column.addView(header(context, context.t(R.string.merged_section_flows)))
        for (flow in CYLFlow.values()) {
            column.addView(row(context, context.t(flow.title), flow.detail, "flow-${flow.name}") { push(flowPage(flow)) })
        }
        column.addView(row(context, context.t(R.string.merged_title_hud), null, "flow-hud") { push(hudPage()) })
        column.addView(row(context, context.t(R.string.merged_title_status_bar), null, "flow-status-bar") {
            startActivity(Intent(context, StatusBarActivity::class.java))
        })
        column.addView(header(context, context.t(R.string.merged_section_configurations)))
        for (name in context.assets.list("Configurations").orEmpty().sorted()) {
            column.addView(row(context, name, "CYLPlaceholderStackView.fromConfiguration · JSON", "configuration-${name.substringBeforeLast('.')}") { push(configuration(name)) })
        }
        return ScrollView(context).apply { addView(column) }
    }

    private fun languageRow(context: Context): View {
        val languages = listOf<String?>(null) + CYLPlaceholderLocalization.supportedLanguages
        val current = CYLPlaceholderLocalization.language
        val label = current?.let { java.util.Locale.forLanguageTag(it).getDisplayName(java.util.Locale.forLanguageTag(it)) } ?: context.t(R.string.merged_follow_system)
        return row(context, context.t(R.string.merged_language), label, "languageButton") {
            val menu = PopupMenu(context, host, Gravity.TOP or Gravity.END)
            languages.forEachIndexed { index, tag ->
                menu.menu.add(0, index, index, tag?.let { java.util.Locale.forLanguageTag(it).let { l -> l.getDisplayName(l) } } ?: context.t(R.string.merged_follow_system))
            }
            menu.setOnMenuItemClickListener { item ->
                val tag = languages[item.itemId]
                CYLPlaceholderLocalization.language = tag
                CYLRefreshConfig.defaultConfig.languageCode = tag
                // The whole interface is built again in the new language.
                requireActivity().recreate()
                true
            }
            menu.show()
        }
    }

    // MARK: - A scenario's page

    private class Rows(var count: Int = 0) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
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
            (holder.itemView as TextView).text = holder.itemView.context.t(R.string.merged_format_item, position + 1)
        }
    }

    internal fun bar(context: Context, title: String, vararg buttons: Button): View = LinearLayout(context).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.CENTER_VERTICAL
        setPadding(context.dp(8f), 0, context.dp(8f), 0)
        addView(Button(context).apply { text = "‹"; contentDescription = null; setOnClickListener { pop() } })
        addView(TextView(context).apply { text = title; textSize = 18f; ViewCompat.setAccessibilityHeading(this, true) }, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f))
        buttons.forEach { addView(it) }
    }

    internal fun page(context: Context, bar: View, content: View): View = LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        setBackgroundColor(Color.WHITE)
        addView(bar)
        addView(content, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
    }

    private fun detail(scenario: CYLPlaceholderScenario): View {
        val context = requireContext()
        var isLoading = false
        var interactionEnabled = true
        val rows = Rows()
        val list = RecyclerView(context).apply { layoutManager = LinearLayoutManager(context); adapter = rows }
        val frame = FrameLayout(context).apply { addView(list, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)) }
        val reload = { rows.notifyDataSetChanged(); list.cyl_reloadData() }
        lateinit var interaction: Button
        val retry = {
            isLoading = true
            reload()
            later {
                isLoading = false
                rows.count = 12
                reload()
                Toast.makeText(context, context.t(R.string.merged_feedback_retry), Toast.LENGTH_SHORT).show()
            }
        }
        fun placeholder(): View {
            if (isLoading) return CYLPlaceholderStackView(context, CYLPlaceholderScenario.Loading)
            val stack = CYLPlaceholderStackView(context, scenario, mapOf(
                CYLPlaceholderAction.Retry to { _: String -> retry() },
                CYLPlaceholderAction.ContactSupport to { _: String -> push(support()) },
                CYLPlaceholderAction.OpenSettings to { _: String ->
                    context.startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:${context.packageName}")).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                },
                CYLPlaceholderAction.GoShopping to { _: String -> Toast.makeText(context, context.t(R.string.merged_feedback_go_shopping), Toast.LENGTH_SHORT).show() },
                CYLPlaceholderAction.ChooseManually to { _: String -> Toast.makeText(context, context.t(R.string.merged_feedback_choose_manually), Toast.LENGTH_SHORT).show() },
                CYLPlaceholderAction.Done to { _: String -> pop() },
            ))
            stack.componentViews.forEach { it.isClickable = it.isClickable && interactionEnabled; it.isEnabled = interactionEnabled || !it.isClickable }
            stack.setBackgroundColor(Color.WHITE)
            return stack
        }
        list.cyl_placeholderViewBlock { placeholder() }
        interaction = Button(context).apply {
            tag = "interactionToggle"
            text = context.t(R.string.merged_interaction_on)
            setOnClickListener {
                interactionEnabled = !interactionEnabled
                text = context.t(if (interactionEnabled) R.string.merged_interaction_on else R.string.merged_interaction_off)
                reload()
                list.cyl_placeholderViewBlock { placeholder() }
            }
        }
        val clear = Button(context).apply {
            text = context.t(R.string.merged_action_clear)
            setOnClickListener { isLoading = false; rows.count = 0; reload() }
        }
        return page(context, bar(context, CYLPlaceholderScenarioCatalog.localizedNameForScenario(context, scenario), clear, interaction), frame).also { it.post { list.cyl_reloadData() } }
    }

    private fun support(): View {
        val context = requireContext()
        val stack = CYLPlaceholderStackView(context, listOf(
            CYLPlaceholderComponent.icon(com.cyl.placeholder.R.drawable.cyl_placeholder_help, context.t(R.string.merged_support_title), 120f),
            CYLPlaceholderComponent.hintComponentWithText(context.t(R.string.merged_support_text)),
        ))
        stack.tag = "supportPage"
        return page(context, bar(context, context.t(R.string.merged_support_title)), stack)
    }

    // MARK: - A configuration file's page

    private fun configuration(name: String): View {
        val context = requireContext()
        val json = context.assets.open("Configurations/$name").bufferedReader().use { it.readText() }
        @Suppress("UNCHECKED_CAST")
        val configuration = (CYLPlaceholderConfiguration_fromJSON(json) as? MutableMap<String, Any?>)
        // A file that uses the example's own texts marks them "exampleTitleKey"; the example resolves them.
        (configuration?.get("components") as? List<*>)?.forEach { entry ->
            @Suppress("UNCHECKED_CAST")
            val component = entry as? MutableMap<String, Any?> ?: return@forEach
            (component.remove("exampleTitleKey") as? String)?.let { key ->
                val id = context.resources.getIdentifier("merged_" + key.removePrefix("CYLScenario").replace(Regex("(?<=[a-z0-9])(?=[A-Z])"), "_").lowercase(), "string", context.packageName)
                if (id != 0) component["title"] = context.t(id)
            }
        }
        val actions = listOf(
            CYLPlaceholderAction.Retry, CYLPlaceholderAction.ContactSupport, CYLPlaceholderAction.OpenSettings,
            CYLPlaceholderAction.GoShopping, CYLPlaceholderAction.ChooseManually, CYLPlaceholderAction.Done,
        ).associateWith { action -> { _: String -> Toast.makeText(context, context.t(R.string.merged_format_action_tapped, action.removePrefix("CYLPlaceholderAction")), Toast.LENGTH_SHORT).show(); Unit } }
        var failure: String? = null
        val stack = CYLPlaceholderStackView.fromConfiguration(context, configuration, actions) { failure = it.message }
        val content: View = stack ?: TextView(context).apply { text = failure; setPadding(context.dp(16f), context.dp(16f), context.dp(16f), 0) }
        stack?.tag = "configurationPage"
        return page(context, bar(context, name), content)
    }
}
