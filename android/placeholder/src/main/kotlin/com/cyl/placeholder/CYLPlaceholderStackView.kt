package com.cyl.placeholder

import android.content.Context
import android.content.res.ColorStateList
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.core.widget.ImageViewCompat

/**
 * The views of a scenario stacked and centered (iOS `CYLPlaceholderStackView`): its icon and title, then its hint or
 * button. `actions` maps an action (`CYLPlaceholderAction.GoShopping`) to its handler; an action without a handler
 * does nothing.
 */
class CYLPlaceholderStackView @JvmOverloads constructor(
    context: Context,
    val scenario: CYLPlaceholderScenario,
    private val actions: Map<String, (String) -> Unit>? = null,
) : FrameLayout(context) {

    /**
     * The stacked views.
     */
    val stackView: LinearLayout = LinearLayout(context)

    /**
     * The scenario's icon or illustration.
     */
    val imageView: ImageView = ImageView(context)

    /**
     * The scenario's title.
     */
    val titleLabel: TextView = TextView(context)

    /**
     * The scenario's hint, or null when it has none.
     */
    val hintLabel: TextView?

    /**
     * The scenario's button ("Go shopping"), or null when it has none.
     */
    val button: Button?

    init {
        val density = resources.displayMetrics.density
        fun dp(value: Float) = (value * density).toInt()
        val secondary = Color.rgb(0x8E, 0x8E, 0x93)
        val accent = Color.rgb(0x00, 0x7A, 0xFF)
        stackView.orientation = LinearLayout.VERTICAL
        stackView.gravity = Gravity.CENTER_HORIZONTAL
        imageView.setImageDrawable(ContextCompat.getDrawable(context, scenario.image))
        imageView.scaleType = ImageView.ScaleType.FIT_CENTER
        imageView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        if (scenario.tinted) {
            ImageViewCompat.setImageTintList(imageView, ColorStateList.valueOf(accent))
        }
        stackView.addView(imageView, LinearLayout.LayoutParams(dp(scenario.imageSide), dp(scenario.imageSide)))
        titleLabel.text = context.getString(scenario.title)
        titleLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
        titleLabel.setTextColor(secondary)
        titleLabel.gravity = Gravity.CENTER
        stackView.addView(titleLabel, LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT).apply { topMargin = dp(12f) })
        hintLabel = scenario.hint?.let { hint ->
            TextView(context).apply {
                text = context.getString(hint)
                setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
                setTextColor(Color.argb(0x99, 0x8E, 0x8E, 0x93))
                gravity = Gravity.CENTER
                stackView.addView(this, LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT).apply { topMargin = dp(6f) })
            }
        }
        button = scenario.button?.let { style ->
            Button(context).apply {
                text = context.getString(R.string.cyl_placeholder_action_go_shopping_title)
                isAllCaps = false
                val outlined = style == CYLPlaceholderButtonStyle.Outlined
                setTextColor(if (outlined) accent else Color.WHITE)
                background = GradientDrawable().apply {
                    cornerRadius = dp(18f).toFloat()
                    setColor(if (outlined) Color.TRANSPARENT else accent)
                    if (outlined) setStroke(dp(1f), accent)
                }
                setPadding(dp(20f), 0, dp(20f), 0)
                setOnClickListener { actions?.get(CYLPlaceholderAction.GoShopping)?.invoke(CYLPlaceholderAction.GoShopping) }
                stackView.addView(this, LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, dp(36f)).apply { topMargin = dp(16f) })
            }
        }
        val margin = dp(16f)
        addView(stackView, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER).apply {
            leftMargin = margin
            rightMargin = margin
        })
        contentDescription = context.getString(scenario.localizedName)
    }

    companion object {
        /**
         * The localized name of a scenario ("No search results"), for menus and accessibility.
         */
        @JvmStatic
        fun localizedNameForScenario(context: Context, scenario: CYLPlaceholderScenario): String = context.getString(scenario.localizedName)
    }
}
