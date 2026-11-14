package com.cyl.refresh

import android.content.Context
import android.graphics.drawable.AnimationDrawable
import android.graphics.drawable.Drawable
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.annotation.ColorInt
import com.cyl.placeholder.CYLPlaceholderView
import com.cyl.refresh.merged.R

/**
 * The icon of a refresh component: one animation (or image sequence) per state, with an optional title (iOS
 * `CYLRefreshIconView`). It shows them through a [CYLPlaceholderView], so animations play with the players registered
 * by `CYLPlaceholderView.registerAnimationFactory`.
 */
class CYLRefreshIconView(context: Context) : FrameLayout(context) {

    private val attributes = HashMap<CYLRefreshState, Map<String, Any>>()
    private var shownState: CYLRefreshState? = null

    /**
     * The view that shows the icon and the title (`placeholderView`).
     */
    val placeholderView: CYLPlaceholderView = CYLPlaceholderView(context).apply { contentMargin = 0f }

    init {
        // Decorative: the component's state text is what accessibility services read.
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS
        addView(placeholderView, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER))
    }

    /**
     * The icon of [state] (`setAnimationAttributes:forState:`): [ANIMATION_FILE_PATH] (a file for a registered
     * player), [IMAGES] (a list of drawables) with [DURATION] in seconds, and [SIZE] (width and height in dp); null
     * removes it.
     */
    fun setAnimationAttributes(attributes: Map<String, Any>?, state: CYLRefreshState) {
        if (attributes == null) this.attributes.remove(state) else this.attributes[state] = attributes
        if (shownState == state) {
            shownState = null
            updateForState(state)
        }
    }

    /**
     * The icon of [state], or null (`animationAttributesForState:`).
     */
    fun animationAttributesForState(state: CYLRefreshState): Map<String, Any>? = attributes[state]

    /**
     * Whether any state has an icon (`hasAnimations`).
     */
    val hasAnimations: Boolean
        get() = attributes.isNotEmpty()

    /**
     * The icon's size in dp, width and height (`iconSize`): the shown state's, else the first one's, else 0.
     */
    val iconSize: FloatArray
        get() = ((attributes[shownState] ?: attributes.values.firstOrNull())?.get(SIZE) as? FloatArray) ?: floatArrayOf(0f, 0f)

    /**
     * The title below the icon (`title`).
     */
    var title: String? = null
        set(value) {
            field = value
            placeholderView.textLabel.text = value
            placeholderView.textLabel.visibility = if (value.isNullOrEmpty()) GONE else VISIBLE
        }

    /**
     * The title's size in sp, or 0 for the default (`titleFont`).
     */
    var titleFont: Float = 0f
        set(value) {
            field = value
            if (value > 0f) placeholderView.defaultTitleFont = value
        }

    /**
     * The title's color, or 0 for the default (`titleColor`).
     */
    @ColorInt var titleColor: Int = 0
        set(value) {
            field = value
            if (value != 0) placeholderView.defaultTitleColor = value
        }

    /**
     * The size the view needs, in pixels: width and height (`fittingSize`).
     */
    val fittingSize: IntArray
        get() {
            measure(MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED), MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED))
            return intArrayOf(measuredWidth, measuredHeight)
        }

    /**
     * Whether the pull scrubs the animation instead of playing it (`scrubsWhilePulling`).
     */
    var scrubsWhilePulling: Boolean = true

    /**
     * Shows and plays the icon of [state] (`updateForState:`); a state without one keeps the last icon.
     */
    fun updateForState(state: CYLRefreshState) {
        if (shownState == state) return
        val icon = attributes[state] ?: return
        shownState = state
        val size = icon[SIZE] as? FloatArray
        val density = resources.displayMetrics.density
        size?.let {
            placeholderView.imageView.layoutParams = placeholderView.imageView.layoutParams.apply {
                width = (it[0] * density).toInt()
                height = (it[1] * density).toInt()
            }
        }
        @Suppress("UNCHECKED_CAST")
        val images = icon[IMAGES] as? List<Drawable>
        val path = icon[ANIMATION_FILE_PATH] as? String
        when {
            images != null && images.isNotEmpty() -> {
                val frames = AnimationDrawable()
                val each = ((((icon[DURATION] as? Number)?.toDouble() ?: (images.size * 0.1)) * 1000) / images.size).toInt()
                images.forEach { frames.addFrame(it, each) }
                frames.isOneShot = false
                placeholderView.imageView.setImageDrawable(frames)
                placeholderView.imageView.visibility = VISIBLE
                if (state == CYLRefreshState.Refreshing || !scrubsWhilePulling) frames.start()
            }
            path != null -> if (placeholderView.setAnimationFile(path) && (state == CYLRefreshState.Refreshing || !scrubsWhilePulling)) {
                placeholderView.playPlaceholderAnimation()
            }
        }
    }

    /**
     * Scrubs the icon to [pullingPercent], 0 to 1, while pulling (`updateForPullingPercent:`).
     */
    fun updateForPullingPercent(pullingPercent: Float) {
        if (!scrubsWhilePulling) return
        val percent = pullingPercent.coerceIn(0f, 1f)
        (placeholderView.imageView.drawable as? AnimationDrawable)?.let { frames ->
            if (frames.numberOfFrames > 0 && !frames.isRunning) frames.selectDrawable(((frames.numberOfFrames - 1) * percent).toInt())
        }
        placeholderView.setPlaceholderAnimationProgress(percent)
    }

    /**
     * The keys of an icon's attributes, and the iOS attribute makers (`CYLRefreshIconView (CYLRefreshIconAttributes)`).
     */
    companion object {
        /** The animation file a registered player plays. */
        const val ANIMATION_FILE_PATH = "CYLPlaceholderItemAnimationFilePath"

        /** The image frames, a list of drawables. */
        const val IMAGES = "CYLPlaceholderItemImages"

        /** The image frames' total duration, in seconds. */
        const val DURATION = "CYLPlaceholderItemAnimationDuration"

        /** The icon's size in dp, width and height. */
        const val SIZE = "CYLPlaceholderItemImageSize"

        /**
         * The attributes of the animation at [filePath], [width] by [height] dp (`attributesForAnimationFilePath:size:`).
         */
        @JvmStatic
        fun attributesForAnimationFilePath(filePath: String, width: Float, height: Float): Map<String, Any> =
            mapOf(ANIMATION_FILE_PATH to filePath, SIZE to floatArrayOf(width, height))
    }
}

/**
 * A refresh component with a per-state icon (iOS `CYLRefreshIconAnimating`); every [CYLRefreshComponent] is one through
 * the `cyl_` extensions below.
 */
interface CYLRefreshIconAnimating {
    /** The icon view (`iconView`). */
    val iconView: CYLRefreshIconView

    /** Whether any state has an icon (`usesIconView`). */
    val usesIconView: Boolean

    /** The icon of [state] (`setIconAnimationAttributes:forState:`). */
    fun setIconAnimationAttributes(attributes: Map<String, Any>?, state: CYLRefreshState): CYLRefreshIconAnimating

    /** The animation file of [state] (`setIconAnimationFilePath:size:forState:`). */
    fun setIconAnimationFilePath(filePath: String, width: Float, height: Float, state: CYLRefreshState): CYLRefreshIconAnimating
}

/**
 * The component's icon view, made and added to the component's view on first use (`cyl_iconView`).
 */
val CYLRefreshComponent.cyl_iconView: CYLRefreshIconView
    get() {
        val host = view.view
        (host.getTag(R.id.cyl_refresh_icon_view) as? CYLRefreshIconView)?.let { return it }
        val icon = CYLRefreshIconView(host.context)
        icon.visibility = View.GONE
        host.setTag(R.id.cyl_refresh_icon_view, icon)
        (host as? ViewGroup)?.addView(icon, ViewGroup.LayoutParams(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        addPhaseObserver { component, _, _ ->
            if (icon.hasAnimations) icon.visibility = View.VISIBLE
            icon.updateForState(component.state)
        }
        return icon
    }

/**
 * Whether the component shows its icon view (`cyl_usesIconView`).
 */
val CYLRefreshComponent.cyl_usesIconView: Boolean
    get() = (view.view.getTag(R.id.cyl_refresh_icon_view) as? CYLRefreshIconView)?.hasAnimations == true

/**
 * The icon of [state] (`cyl_setIconAnimationAttributes:forState:`).
 */
fun CYLRefreshComponent.cyl_setIconAnimationAttributes(attributes: Map<String, Any>?, state: CYLRefreshState) {
    cyl_iconView.setAnimationAttributes(attributes, state)
    if (state == CYLRefreshState.Idle || this.state == state) cyl_iconView.updateForState(this.state)
}

/**
 * Image frames as the icon of [state], [duration] seconds in all (`cyl_setIconImages:duration:forState:`).
 */
fun CYLRefreshComponent.cyl_setIconImages(images: List<Drawable>, duration: Double, state: CYLRefreshState) {
    val side = 40f
    cyl_setIconAnimationAttributes(
        mapOf(CYLRefreshIconView.IMAGES to images, CYLRefreshIconView.DURATION to duration, CYLRefreshIconView.SIZE to floatArrayOf(side, side)),
        state,
    )
}

/**
 * Shows the frame of [images] at [pullingPercent], 0 to 1 (`cyl_showIconImageFrameOf:pullingPercent:`).
 */
fun CYLRefreshComponent.cyl_showIconImageFrameOf(images: List<Drawable>?, pullingPercent: Float) {
    if (images.isNullOrEmpty()) return
    val index = ((images.size - 1) * pullingPercent.coerceIn(0f, 1f)).toInt()
    cyl_iconView.placeholderView.imageView.apply {
        setImageDrawable(images[index])
        visibility = View.VISIBLE
    }
}

/**
 * Shows or hides the icon view, hiding [views] (the component's own arrow and spinner) while it shows
 * (`cyl_updateIconViewVisible:replacingViews:`).
 */
fun CYLRefreshComponent.cyl_updateIconViewVisible(visible: Boolean, views: List<View>) {
    val show = visible && cyl_usesIconView
    cyl_iconView.visibility = if (show) View.VISIBLE else View.GONE
    if (show) views.forEach { it.visibility = View.INVISIBLE }
}

/**
 * Centers the icon view at ([centerX], [centerY]) pixels in the component and shows or hides it
 * (`cyl_placeIconViewAtCenter:visible:replacingViews:`).
 */
fun CYLRefreshComponent.cyl_placeIconViewAtCenter(centerX: Float, centerY: Float, visible: Boolean, views: List<View>) {
    val icon = cyl_iconView
    val size = icon.fittingSize
    icon.x = centerX - size[0] / 2f
    icon.y = centerY - size[1] / 2f
    cyl_updateIconViewVisible(visible, views)
}

/**
 * Shows the icon view with [title] in place of [labels] (`cyl_placeIconViewWithTitle:labels:visible:replacingViews:`).
 */
fun CYLRefreshComponent.cyl_placeIconViewWithTitle(title: String?, labels: List<TextView>, visible: Boolean, views: List<View>) {
    val icon = cyl_iconView
    icon.title = title
    cyl_updateIconViewVisible(visible, views + labels)
    val host = view.view
    if (host.width > 0) cyl_placeIconViewAtCenter(host.width / 2f, host.height / 2f, visible, views + labels)
}
