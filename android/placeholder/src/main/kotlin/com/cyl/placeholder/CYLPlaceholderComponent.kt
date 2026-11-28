package com.cyl.placeholder

import android.graphics.Color
import androidx.annotation.ColorInt
import androidx.annotation.DrawableRes

/**
 * The accent color of the components (iOS `CYLScenarioAccentColor`, system blue).
 */
internal val ACCENT = Color.rgb(0x00, 0x7A, 0xFF)

/**
 * One piece of a placeholder: an icon (with an optional title), a text, a hint, a button or a separator (iOS
 * `CYLPlaceholderComponent`). [CYLPlaceholderStackView] stacks them.
 */
class CYLPlaceholderComponent private constructor(
    internal val kind: Kind,
    /**
     * The icon, or 0 for none.
     */
    @DrawableRes val image: Int,
    /**
     * Whether the icon takes the accent color.
     */
    val tinted: Boolean,
    /**
     * The icon's side, in dp.
     */
    val imageSide: Float,
    /**
     * The text, or null.
     */
    val title: CharSequence?,
    /**
     * The text size in sp, or 0 for the kind's own.
     */
    val titleSizeSp: Float,
    /**
     * The text color, or 0 for the kind's own.
     */
    @ColorInt val titleColor: Int,
    /**
     * The button's look (buttons only).
     */
    val buttonStyle: CYLPlaceholderButtonStyle?,
    action: String?,
) {
    internal enum class Kind { Item, Hint, Button, Separator }

    /**
     * The action a tap runs, or null (`action`).
     */
    var action: String? = action
        internal set

    /**
     * How a finger on a component with an action is shown in the stack view (`tapHighlightStyle`): Dim (default),
     * Shrink or None.
     */
    var tapHighlightStyle: CYLPlaceholderTapHighlightStyle = CYLPlaceholderTapHighlightStyle.Dim

    /**
     * The identifier tests find the component's view by (`accessibilityIdentifier`), or null.
     */
    var accessibilityIdentifier: String? = null

    /**
     * The space above the component, in dp (`spacingBefore`).
     */
    var spacingBefore: Float = when (kind) {
        Kind.Hint -> 4f
        Kind.Button -> 20f
        Kind.Separator -> 14f
        Kind.Item -> 12f
    }

    /**
     * Whether the component reacts to taps (`interactionEnabled`); a button that does not is shown disabled.
     */
    var interactionEnabled: Boolean = true

    /**
     * How often the item's animation repeats (`animationRepeatCount`), 0 for ever: the stack view's
     * CYLPlaceholderView plays it. A scenario's bundled animation plays once unless it is a spinner (iOS
     * `componentWithBundledAnimation:`, 2026-11-19, [CYLPlaceholderScenarioCatalog.animationLoopsByDefault]); a value set
     * here wins.
     */
    var animationRepeatCount: Int = 0
        set(value) {
            field = value
            animationRepeatCountIsSet = true
        }

    /**
     * Whether the item's animation loops: the same as [animationRepeatCount] being 0 (true) or 1 (false), the name
     * CYLTabBarController's `CYLAnimatedItemView` uses.
     */
    var animationLoops: Boolean
        get() = animationRepeatCount != 1
        set(value) { animationRepeatCount = if (value) 0 else 1 }

    /**
     * The item animation's playback speed, 1 by default (`animationSpeed`); the stack view's CYLPlaceholderView applies
     * it when it is not 1. A value that is not positive is ignored.
     */
    var animationSpeed: Float = 1f
        set(value) { if (value > 0f && value.isFinite()) field = value }

    /**
     * Whether the still image replaces the item's play-once animation when it ends (CYLAnimatedItemView
     * `showsImageWhenAnimationEnds`, CYLTabBarController b13b88f1); off by default, so the last frame stays. For an
     * animation whose last frame is empty: the Success scenario's icon turns it on, so its check mark shows afterwards.
     */
    var showsImageWhenAnimationEnds: Boolean = false

    /** Whether [animationRepeatCount] was set, so the scenario default does not replace it. */
    internal var animationRepeatCountIsSet: Boolean = false
        private set

    /**
     * The other iOS item keys of a component made by [componentWithAttributes], kept as given.
     */
    private var extraAttributes: Map<String, Any> = emptyMap()

    /**
     * The component's description with the iOS keys (`attributes`): "CYLPlaceholderItemTitle",
     * "CYLPlaceholderItemImage" (a drawable resource), "CYLPlaceholderItemTitleColor", "CYLPlaceholderItemTitleFontSize",
     * and every other item key given to [componentWithAttributes] (see [CYLPlaceholderView.Companion.fromItemAttributes]).
     */
    val attributes: Map<String, Any>
        get() = buildMap {
            putAll(extraAttributes)
            title?.let { put(TITLE, it) }
            if (image != 0) put(IMAGE, image)
            if (titleColor != 0) put(TITLE_COLOR, titleColor)
            if (titleSizeSp != 0f) put(TITLE_FONT_SIZE, titleSizeSp)
        }

    /**
     * Whether the stack view shows this component as a [CYLPlaceholderView] made from [attributes]: it has item keys
     * beyond the title, image, title color and size (an animation file, other colors, accessibility...).
     */
    internal val usesItemAttributes: Boolean
        get() = kind == Kind.Item && extraAttributes.keys.any { it !in BASIC_KEYS }

    /**
     * Makes components with the iOS factory names.
     */
    companion object {
        private const val TITLE = "CYLPlaceholderItemTitle"
        private const val IMAGE = "CYLPlaceholderItemImage"
        private const val TITLE_COLOR = "CYLPlaceholderItemTitleColor"
        private const val TITLE_FONT_SIZE = "CYLPlaceholderItemTitleFontSize"
        private val BASIC_KEYS = setOf(TITLE, IMAGE, TITLE_COLOR, TITLE_FONT_SIZE)

        /**
         * A component from [attributes] with the iOS keys (see [CYLPlaceholderComponent.attributes]), running [action]
         * when tapped (`componentWithAttributes:action:`).
         */
        @JvmStatic
        fun componentWithAttributes(attributes: Map<String, Any>, action: String?): CYLPlaceholderComponent = CYLPlaceholderComponent(
            Kind.Item, (attributes[IMAGE] as? Int) ?: 0, true, ICON_SIDE, attributes[TITLE] as? CharSequence,
            (attributes[TITLE_FONT_SIZE] as? Number)?.toFloat() ?: 0f, (attributes[TITLE_COLOR] as? Int) ?: 0, null, action,
        ).apply { extraAttributes = attributes.filterKeys { it !in BASIC_KEYS } }

        /**
         * A bundled animation, [fileName] in the placeholder's `CYLPlaceholderAnimations` assets (the iOS
         * CYLTableViewPlaceHolder.bundle), [side] dp, over the image of [fallbackStyle], with an optional [title],
         * running [action] when tapped (`componentWithBundledAnimation:fallbackStyle:title:size:action:`). The fallback
         * shows until the animation is ready and when no animator plays the file (the app added no engine). It plays
         * once, a spinner loops (animationLoopsByDefault), as on iOS.
         */
        @JvmStatic
        @JvmOverloads
        fun componentWithBundledAnimation(fileName: String, fallbackStyle: CYLPlaceholderStyle, title: CharSequence?, side: Float = ICON_SIDE,
                                          action: String? = null): CYLPlaceholderComponent =
            CYLPlaceholderComponent(Kind.Item, 0, fallbackStyle != CYLPlaceholderStyle.Empty, side, title, 0f, 0, null, action).apply {
                extraAttributes = mapOf(
                    "CYLPlaceholderItemStyle" to fallbackStyle,
                    "CYLPlaceholderItemAnimationFilePath" to "asset:${CYLPlaceholderStackView.ANIMATION_FOLDER}/$fileName",
                    "CYLPlaceholderItemAnimationRepeatCount" to if (CYLPlaceholderScenarioCatalog.animationLoopsByDefault(fileName)) 0 else 1,
                )
            }

        /**
         * An icon of [side] dp with an optional [title] below it, running [action] when tapped. The iOS
         * `componentWithBundledAnimation:fallbackStyle:title:size:action:` plays an animation with this image as its
         * fallback; on Android a scenario's stack view plays its animation in place of this image.
         */
        @JvmStatic
        @JvmOverloads
        fun icon(@DrawableRes image: Int, title: CharSequence?, side: Float = ICON_SIDE, tinted: Boolean = true, action: String? = null): CYLPlaceholderComponent =
            CYLPlaceholderComponent(Kind.Item, image, tinted, side, title, 0f, 0, null, action)

        /**
         * A text of its own, [sizeSp] large and [color] colored (0 for the default).
         */
        @JvmStatic
        @JvmOverloads
        fun text(title: CharSequence, sizeSp: Float = 0f, @ColorInt color: Int = 0): CYLPlaceholderComponent =
            CYLPlaceholderComponent(Kind.Item, 0, false, 0f, title, sizeSp, color, null, null)

        /**
         * A smaller, lighter line of text (`hintComponentWithText:`).
         */
        @JvmStatic
        fun hintComponentWithText(text: CharSequence): CYLPlaceholderComponent =
            CYLPlaceholderComponent(Kind.Hint, 0, false, 0f, text, 0f, 0, null, null)

        /**
         * A button titled [title] in [style], running [action] (`buttonComponentWithTitle:style:action:`).
         */
        @JvmStatic
        fun buttonComponentWithTitle(title: CharSequence, style: CYLPlaceholderButtonStyle, action: String?): CYLPlaceholderComponent =
            CYLPlaceholderComponent(Kind.Button, 0, false, 0f, title, 0f, 0, style, action)

        /**
         * "———   [text]   ———"; accessibility services read only [text] (`separatorComponentWithText:`).
         */
        @JvmStatic
        fun separatorComponentWithText(text: CharSequence): CYLPlaceholderComponent =
            CYLPlaceholderComponent(Kind.Separator, 0, false, 0f, text, 0f, 0, null, null)
    }
}
