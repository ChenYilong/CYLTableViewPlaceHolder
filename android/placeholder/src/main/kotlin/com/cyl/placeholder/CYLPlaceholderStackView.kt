package com.cyl.placeholder

import android.content.Context
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

/**
 * Components stacked and centered (iOS `CYLPlaceholderStackView`): a scenario's components
 * ([CYLPlaceholderScenarioCatalog.componentsForScenario]) or your own. `actions` maps an action
 * ([CYLPlaceholderAction]) to its handler; [setHandler] adds or replaces one; an action without a handler does nothing.
 */
class CYLPlaceholderStackView internal constructor(
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
     * The reserved first component, the icon and title (`placeholderView`).
     */
    val placeholderView: View get() = componentViews.first()

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

    /**
     * The animation view playing in place of the first icon (made by CYLTabBarController's CYLAnimatedItem engine,
     * the first item's inherited `animationView`), or null when no animator plays any of the scenario's files (the app
     * added no animation library for them) and the still image shows (`animationView`).
     */
    val animationView: View?
        get() = animatedItem?.animationView

    // The item that plays the scenario's animation file, if one was found.
    private var animatedItem: CYLPlaceholderView? = null

    // The component each item view was made from.
    private val itemComponents = mutableMapOf<View, CYLPlaceholderComponent>()

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
        imageView = componentViews.flatMap { allViews(it) }.filterIsInstance<ImageView>().firstOrNull { it.visibility == VISIBLE && it.drawable != null }
            ?: ImageView(context).apply { visibility = GONE }
        titleLabel = componentViews.flatMap { allViews(it) }
            .firstOrNull { it is TextView && it !is Button && it.tag != HINT_TAG && it.visibility == VISIBLE && !it.text.isNullOrEmpty() } as? TextView
            ?: TextView(context).apply { visibility = GONE }
        hintLabel = componentViews.firstOrNull { it.tag == HINT_TAG } as? TextView
        button = componentViews.filterIsInstance<Button>().firstOrNull()
        scenario?.let { contentDescription = CYLPlaceholderScenarioCatalog.localizedNameForScenario(context, it) }
        scenario?.let { attachScenarioAnimation(it) }
        updateBackgroundTap()
    }

    // The first of the scenario's animation files (its own icon first) that is in the assets and that an animator of
    // the CYLAnimatedItem engine plays (its library is in the app) replaces the first icon, through the first item's
    // CYLPlaceholderView; the still image stays as the fallback.
    private fun attachScenarioAnimation(scenario: CYLPlaceholderScenario) {
        val item = componentViews.firstOrNull { it is CYLPlaceholderView } as? CYLPlaceholderView ?: return
        if (item.imageView.drawable == null) return
        val bundled = runCatching { context.assets.list(ANIMATION_FOLDER)?.toSet() }.getOrNull().orEmpty()
        val names = CYLPlaceholderScenarioCatalog.animationFileNamesForScenario(scenario).filter { it in bundled }
        for (name in names) {
            if (!item.setAnimationFile("asset:$ANIMATION_FOLDER/$name")) continue
            animatedItem = item
            item.animationRepeatCount = CYLPlaceholderScenarioCatalog.scenarioAnimationRepeatCount(name, itemComponents[item])
            // [EN] An animation whose last frame is empty (Success) hands back to the still image when it ends.
            item.showsImageWhenAnimationEnds = itemComponents[item]?.showsImageWhenAnimationEnds == true
            item.animationView?.let { view ->
                view.contentDescription = item.imageView.contentDescription
                view.importantForAccessibility = item.imageView.importantForAccessibility
            }
            return
        }
        // [EN] None plays: no animation file stays on the item, so its still image shows.
        if (names.isNotEmpty()) item.animationURL = null
    }

    private fun allViews(view: View): List<View> = when {
        view is CYLPlaceholderView -> listOf(view.imageView, view.textLabel)
        else -> listOf(view)
    }

    /**
     * Adds [component] at the end (`appendComponent:`).
     */
    fun appendComponent(component: CYLPlaceholderComponent) {
        val view = viewFor(component)
        appendComponentView(view, component.action, component.spacingBefore)
        if (component.action != null) showTapsWithStyle(view, component)
    }

    // iOS `tapHighlightStyle` of a component that acts: a finger on it dims it (Dim, the default), shrinks it to 95 %
    // (Shrink) or leaves it as it is (None); the tap still reaches the click listener.
    @android.annotation.SuppressLint("ClickableViewAccessibility")
    private fun showTapsWithStyle(view: View, component: CYLPlaceholderComponent) {
        view.setOnTouchListener { touched, event ->
            val style = component.tapHighlightStyle
            val pressed = (event.actionMasked == android.view.MotionEvent.ACTION_DOWN) && touched.isEnabled &&
                component.interactionEnabled && style != CYLPlaceholderTapHighlightStyle.None
            when (event.actionMasked) {
                android.view.MotionEvent.ACTION_DOWN, android.view.MotionEvent.ACTION_UP,
                android.view.MotionEvent.ACTION_CANCEL -> {
                    touched.alpha = if (pressed && style == CYLPlaceholderTapHighlightStyle.Dim) 0.5f else 1f
                    val scale = if (pressed && style == CYLPlaceholderTapHighlightStyle.Shrink) 0.95f else 1f
                    touched.scaleX = scale
                    touched.scaleY = scale
                }
            }
            false
        }
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
            // Every item is a CYLPlaceholderView, the one component that shows an icon with a title and plays every
            // animation type: a new type added there works in every stack view too.
            CYLPlaceholderComponent.Kind.Item -> {
                if (component.usesItemAttributes) {
                    CYLPlaceholderView.fromItemAttributes(context, component.attributes)?.let {
                        return it.apply { contentMargin = 0f; reportsContentSize = true }
                    }
                }
                val image = if (component.image != 0) ContextCompat.getDrawable(context, component.image) else null
                CYLPlaceholderView(context, image, component.title).apply {
                    itemComponents[this] = component
                    reportsContentSize = true
                    contentMargin = 0f
                    tintsIcon = component.tinted
                    if (image != null) setIconSide(component.imageSide)
                    if (component.titleSizeSp != 0f) defaultTitleFont = component.titleSizeSp
                    if (component.titleColor != 0) defaultTitleColor = component.titleColor
                    animationRepeatCount = component.animationRepeatCount
                    val iconAction = component.action
                    if (iconAction != null && image != null) {
                        // [EN] An icon that acts (RefreshIcon) is a button named by its action.
                        imageView.contentDescription = CYLPlaceholderScenarioCatalog.localizedTitleForAction(context, iconAction)
                        imageView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
                    }
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
        private const val HINT_TAG = "cyl_placeholder_hint"

        /**
         * The assets folder of the bundled animations (iOS `CYLTableViewPlaceHolder.bundle/Animations`).
         */
        const val ANIMATION_FOLDER = "CYLPlaceholderAnimations"

        /**
         * The localized name of a scenario ("No search results"), for menus and accessibility.
         */
        @JvmStatic
        fun localizedNameForScenario(context: Context, scenario: CYLPlaceholderScenario): String =
            CYLPlaceholderScenarioCatalog.localizedNameForScenario(context, scenario)
    }
}
