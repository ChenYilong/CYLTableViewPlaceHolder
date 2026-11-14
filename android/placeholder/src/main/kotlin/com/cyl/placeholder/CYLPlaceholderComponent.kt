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
    /**
     * The action a tap runs, or null (`action`).
     */
    val action: String?,
) {
    internal enum class Kind { Item, Hint, Button, Separator }

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
     * How often an animated icon repeats (`animationRepeatCount`); Android shows the static icon, so it is kept for
     * apps that play the animation themselves.
     */
    var animationRepeatCount: Int = 0

    /**
     * The component's description with the iOS keys (`attributes`): "CYLPlaceholderItemTitle",
     * "CYLPlaceholderItemImage" (a drawable resource), "CYLPlaceholderItemTitleColor", "CYLPlaceholderItemTitleFontSize".
     */
    val attributes: Map<String, Any>
        get() = buildMap {
            title?.let { put(TITLE, it) }
            if (image != 0) put(IMAGE, image)
            if (titleColor != 0) put(TITLE_COLOR, titleColor)
            if (titleSizeSp != 0f) put(TITLE_FONT_SIZE, titleSizeSp)
        }

    /**
     * Makes components with the iOS factory names.
     */
    companion object {
        private const val TITLE = "CYLPlaceholderItemTitle"
        private const val IMAGE = "CYLPlaceholderItemImage"
        private const val TITLE_COLOR = "CYLPlaceholderItemTitleColor"
        private const val TITLE_FONT_SIZE = "CYLPlaceholderItemTitleFontSize"

        /**
         * A component from [attributes] with the iOS keys (see [CYLPlaceholderComponent.attributes]), running [action]
         * when tapped (`componentWithAttributes:action:`).
         */
        @JvmStatic
        fun componentWithAttributes(attributes: Map<String, Any>, action: String?): CYLPlaceholderComponent = CYLPlaceholderComponent(
            Kind.Item, (attributes[IMAGE] as? Int) ?: 0, true, ICON_SIDE, attributes[TITLE] as? CharSequence,
            (attributes[TITLE_FONT_SIZE] as? Number)?.toFloat() ?: 0f, (attributes[TITLE_COLOR] as? Int) ?: 0, null, action,
        )

        /**
         * An icon of [side] dp with an optional [title] below it, running [action] when tapped. The iOS
         * `componentWithBundledAnimation:fallbackStyle:title:size:action:` plays an animation with this image as its
         * fallback; Android shows the image.
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
