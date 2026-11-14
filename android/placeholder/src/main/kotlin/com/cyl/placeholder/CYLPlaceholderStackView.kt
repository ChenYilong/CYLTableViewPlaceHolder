package com.cyl.placeholder

import android.content.Context
import android.content.res.ColorStateList
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.core.view.AccessibilityDelegateCompat
import androidx.core.view.ViewCompat
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat
import androidx.core.widget.ImageViewCompat

/**
 * Components stacked and centered (iOS `CYLPlaceholderStackView`): a scenario's components
 * ([CYLPlaceholderScenarioCatalog.componentsForScenario]) or your own. `actions` maps an action
 * ([CYLPlaceholderAction]) to its handler; [setHandler] adds or replaces one; an action without a handler does nothing.
 */
class CYLPlaceholderStackView private constructor(
    context: Context,
    /**
     * The scenario shown, or null for a stack of your own components (`scenario`).
     */
    val scenario: CYLPlaceholderScenario?,
    components: List<CYLPlaceholderComponent>,
    actions: Map<String, CYLPlaceholderActionHandler>?,
) : FrameLayout(context) {

    /**
     * A scenario's components (`initWithScenario:actions:`).
     */
    @JvmOverloads
    constructor(context: Context, scenario: CYLPlaceholderScenario, actions: Map<String, CYLPlaceholderActionHandler>? = null) :
        this(context, scenario, CYLPlaceholderScenarioCatalog.componentsForScenario(context, scenario), actions)

    /**
     * Your own components (`initWithComponents:actions:`).
     */
    @JvmOverloads
    constructor(context: Context, components: List<CYLPlaceholderComponent>, actions: Map<String, CYLPlaceholderActionHandler>? = null) :
        this(context, null, components, actions)

    private val handlers = HashMap<String, CYLPlaceholderActionHandler>().apply { actions?.let { putAll(it) } }
    private val viewActions = ArrayList<Pair<View, String?>>()

    /**
     * The stacked views (`stackView`).
     */
    val stackView: LinearLayout = LinearLayout(context)

    /**
     * One view per component, in order (`componentViews`).
     */
    val componentViews: List<View>
        get() = viewActions.map { it.first }

    /**
     * The first icon (hidden and empty when there is none).
     */
    val imageView: ImageView

    /**
     * The first title.
     */
    val titleLabel: TextView

    /**
     * The first hint, or null.
     */
    val hintLabel: TextView?

    /**
     * The first button, or null.
     */
    val button: Button?

    /**
     * The action a tap anywhere on the placeholder runs, or null (`backgroundAction`).
     */
    var backgroundAction: String? = scenario?.let { CYLPlaceholderScenarioCatalog.backgroundActionForScenario(it) }
        set(value) {
            field = value
            updateBackgroundTap()
        }

    private val density = resources.displayMetrics.density

    private fun dp(value: Float) = (value * density).toInt()

    init {
        stackView.orientation = LinearLayout.VERTICAL
        stackView.gravity = Gravity.CENTER_HORIZONTAL
        val margin = dp(16f)
        addView(stackView, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER).apply {
            leftMargin = margin
            rightMargin = margin
        })
        components.forEach { appendComponent(it) }
        imageView = componentViews.flatMap { allViews(it) }.filterIsInstance<ImageView>().firstOrNull()
            ?: ImageView(context).apply { visibility = GONE }
        titleLabel = componentViews.flatMap { allViews(it) }.firstOrNull { it is TextView && it !is Button && it.tag != HINT_TAG } as? TextView
            ?: TextView(context).apply { visibility = GONE }
        hintLabel = componentViews.firstOrNull { it.tag == HINT_TAG } as? TextView
        button = componentViews.filterIsInstance<Button>().firstOrNull()
        scenario?.let { contentDescription = CYLPlaceholderScenarioCatalog.localizedNameForScenario(context, it) }
        updateBackgroundTap()
    }

    private fun allViews(view: View): List<View> =
        if (view is LinearLayout && view.tag == ITEM_TAG) (0 until view.childCount).map { view.getChildAt(it) } else listOf(view)

    /**
     * Adds [component] at the end (`appendComponent:`).
     */
    fun appendComponent(component: CYLPlaceholderComponent) {
        appendComponentView(viewFor(component), component.action, component.spacingBefore)
    }

    /**
     * Adds your own [view] at the end, [spacingBefore] dp below the previous one; a tap runs [action] (`appendComponentView:action:spacingBefore:`).
     */
    fun appendComponentView(view: View, action: String?, spacingBefore: Float) {
        val first = viewActions.isEmpty()
        stackView.addView(view, LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT).apply {
            if (!first) topMargin = dp(spacingBefore)
            gravity = Gravity.CENTER_HORIZONTAL
        })
        if (action != null) view.setOnClickListener { performAction(action) }
        viewActions += view to action
    }

    /**
     * Runs [handler] for [action], replacing its handler (`setHandler:forAction:`); null removes it.
     */
    fun setHandler(handler: CYLPlaceholderActionHandler?, action: String) {
        if (handler == null) handlers.remove(action) else handlers[action] = handler
    }

    /**
     * The view of the first component that runs [action], or null (`componentViewForAction:`).
     */
    fun componentViewForAction(action: String): View? = viewActions.firstOrNull { it.second == action }?.first

    /**
     * Runs the handler of [action], as a tap would; false when it has none (`performAction:`).
     */
    fun performAction(action: String): Boolean {
        val handler = handlers[action] ?: return false
        handler(action)
        return true
    }

    private fun updateBackgroundTap() {
        val action = backgroundAction
        if (action == null) {
            setOnClickListener(null)
            isClickable = false
            return
        }
        setOnClickListener { performAction(action) }
        // [EN] The whole placeholder is one button for accessibility services, named by its action.
        ViewCompat.setAccessibilityDelegate(this, object : AccessibilityDelegateCompat() {
            override fun onInitializeAccessibilityNodeInfo(host: View, info: AccessibilityNodeInfoCompat) {
                super.onInitializeAccessibilityNodeInfo(host, info)
                info.className = Button::class.java.name
                CYLPlaceholderScenarioCatalog.localizedTitleForAction(context, action)?.let {
                    info.addAction(AccessibilityNodeInfoCompat.AccessibilityActionCompat(AccessibilityNodeInfoCompat.ACTION_CLICK, it))
                }
            }
        })
    }

    private fun viewFor(component: CYLPlaceholderComponent): View {
        val secondary = Color.rgb(0x8E, 0x8E, 0x93)
        return when (component.kind) {
            CYLPlaceholderComponent.Kind.Item -> {
                val text = component.title?.let { title ->
                    TextView(context).apply {
                        this.text = title
                        setTextSize(TypedValue.COMPLEX_UNIT_SP, if (component.titleSizeSp != 0f) component.titleSizeSp else 17f)
                        setTextColor(if (component.titleColor != 0) component.titleColor else secondary)
                        gravity = Gravity.CENTER
                    }
                }
                if (component.image == 0) return text ?: View(context)
                val image = ImageView(context).apply {
                    setImageDrawable(ContextCompat.getDrawable(context, component.image))
                    scaleType = ImageView.ScaleType.FIT_CENTER
                    if (component.tinted) ImageViewCompat.setImageTintList(this, ColorStateList.valueOf(ACCENT))
                    if (component.action != null) {
                        // [EN] An icon that acts (RefreshIcon) is a button named by its action.
                        contentDescription = CYLPlaceholderScenarioCatalog.localizedTitleForAction(context, component.action)
                    } else {
                        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
                    }
                }
                LinearLayout(context).apply {
                    tag = ITEM_TAG
                    orientation = LinearLayout.VERTICAL
                    gravity = Gravity.CENTER_HORIZONTAL
                    addView(image, LinearLayout.LayoutParams(dp(component.imageSide), dp(component.imageSide)))
                    text?.let { addView(it, LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT).apply { topMargin = dp(12f) }) }
                }
            }
            CYLPlaceholderComponent.Kind.Hint -> TextView(context).apply {
                tag = HINT_TAG
                text = component.title
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
                setTextColor(Color.argb(0x99, 0x8E, 0x8E, 0x93))
                gravity = Gravity.CENTER
            }
            CYLPlaceholderComponent.Kind.Separator -> TextView(context).apply {
                text = "———   ${component.title}   ———"
                contentDescription = component.title
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
                setTextColor(secondary)
                gravity = Gravity.CENTER
            }
            CYLPlaceholderComponent.Kind.Button -> Button(context).apply {
                text = component.title
                isAllCaps = false
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
                isEnabled = component.interactionEnabled
                val style = component.buttonStyle ?: CYLPlaceholderButtonStyle.Filled
                val outlined = style == CYLPlaceholderButtonStyle.Outlined
                setTextColor(if (outlined) ACCENT else Color.WHITE)
                background = GradientDrawable().apply {
                    cornerRadius = if (style == CYLPlaceholderButtonStyle.Capsule) dp(999f).toFloat() else dp(6f).toFloat()
                    setColor(if (outlined) Color.TRANSPARENT else ACCENT)
                    if (outlined) setStroke(dp(1f), ACCENT)
                }
                val (vertical, horizontal, minimum) = when (style) {
                    CYLPlaceholderButtonStyle.Outlined -> Triple(8f, 22f, 128f)
                    CYLPlaceholderButtonStyle.Capsule -> Triple(10f, 30f, 140f)
                    CYLPlaceholderButtonStyle.Filled -> Triple(11f, 24f, 200f)
                }
                setPadding(dp(horizontal), dp(vertical), dp(horizontal), dp(vertical))
                minWidth = dp(minimum)
                minimumWidth = dp(minimum)
            }
        }
    }

    /**
     * The iOS names of the catalog lookups that lived here.
     */
    companion object {
        private const val ITEM_TAG = "cyl_placeholder_item"
        private const val HINT_TAG = "cyl_placeholder_hint"

        /**
         * The localized name of a scenario ("No search results"), for menus and accessibility.
         */
        @JvmStatic
        fun localizedNameForScenario(context: Context, scenario: CYLPlaceholderScenario): String =
            CYLPlaceholderScenarioCatalog.localizedNameForScenario(context, scenario)
    }
}
