package com.cyl.placeholder

import android.content.Context
import android.content.res.ColorStateList
import android.graphics.Color
import android.graphics.drawable.AnimationDrawable
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.provider.Settings
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.accessibility.AccessibilityNodeInfo
import android.widget.ImageView
import android.widget.TextView
import androidx.annotation.ColorInt
import androidx.core.content.ContextCompat
import androidx.core.widget.ImageViewCompat
import com.cyl.animateditem.CYLAnimatedItemAccessibilityText
import com.cyl.animateditem.CYLAnimatedItemAxis
import com.cyl.animateditem.CYLAnimatedItemView
import com.cyl.animateditem.CYLGIFTabBarItemAnimationView
import com.cyl.animateditem.CYLSize
import com.cyl.animateditem.CYLTabBarItemAnimationBasePlayer
import com.cyl.animateditem.CYLTabBarItemAnimationPlayer
import com.cyl.animateditem.CYLTabBarItemAnimator
import com.cyl.animateditem.CYLTabBarItemAnimatorPriority
import com.cyl.animateditem.CYLTabBarItemAnimatorRegistry

/**
 * The built-in icons (iOS `CYLPlaceholderStyle`), in the iOS order.
 */
enum class CYLPlaceholderStyle {
    /** The colored empty illustration. */
    Empty,
    /** No results. */
    NoResults,
    /** An error. */
    Error,
    /** Wi-Fi off. */
    WifiOff,
    /** No Wi-Fi signal. */
    SignalWifiOff,
    /** No internet. */
    NoInternet,
    /** Cloud off. */
    CloudOff,
    /** A sync problem. */
    SyncProblem,
    /** Sync disabled. */
    SyncDisabled,
    /** A locked network. */
    NetworkLocked,
    /** Bluetooth disabled. */
    BluetoothDisabled,
    /** Location off. */
    LocationOff,
    /** Public off. */
    PublicOff,
    /** An outlined error. */
    ErrorOutline,
    /** A warning. */
    Warning,
    /** A reported problem. */
    ReportProblem,
    /** Blocked. */
    Blocked,
    /** Help. */
    Help,
    /** An hourglass. */
    Hourglass,
    /** Locked. */
    Locked,
    /** Visibility off. */
    VisibilityOff,
    /** Search off. */
    SearchOff,
    /** Folder off. */
    FolderOff,
    /** An open folder. */
    FolderOpen,
    /** Download off. */
    DownloadOff,
    /** Upload off. */
    UploadOff,
    /** An inbox. */
    Inbox,
    /** A broken image. */
    BrokenImage,
    /** An unavailable image. */
    ImageUnavailable,
    /** A photo library. */
    PhotoLibrary,
    /** Music off. */
    MusicOff,
    /** Video off. */
    VideoOff,
    /** Person off. */
    PersonOff,
    /** Group off. */
    GroupOff,
    /** A busy event. */
    EventBusy,
    /** An empty cart. */
    EmptyCart,
    /** A favorite. */
    Favorite,
    /** A battery alert. */
    BatteryAlert,
    /** An unknown device. */
    UnknownDevice,
    /** Phone disabled. */
    PhoneDisabled,
    /** A wrong location. */
    WrongLocation,
    /** An archive. */
    Archive,
    /** Info. */
    Info,
    /** Refresh. */
    Refresh,
    /** Delete. */
    Delete,
    /** Search. */
    Search,
    /** Mail. */
    Mail,
    /** An image. */
    Image,
    /** A cloud. */
    Cloud,
    /** Notifications off. */
    NotificationsOff,
    /** History. */
    History,
}

/**
 * The built-in texts (iOS `CYLPlaceholderMessage`).
 */
enum class CYLPlaceholderMessage {
    /** "Nothing here yet". */
    Empty,
    /** "No results found". */
    NoResults,
    /** "No internet connection". */
    NoInternet,
    /** "Server unavailable". */
    ServerUnavailable,
    /** "Something went wrong". */
    Error,
    /** "Loading". */
    Loading,
    /** "Access unavailable". */
    NoPermission,
    /** "Your cart is empty". */
    EmptyCart,
    /** "No notifications". */
    NoNotifications,
}

/**
 * How a tappable placeholder answers a finger (iOS `CYLPlaceholderTapHighlightStyle`).
 */
enum class CYLPlaceholderTapHighlightStyle {
    /** It dims. */
    Dim,
    /** It shrinks a little. */
    Shrink,
    /** It does not change. */
    None,
}

/**
 * The badge of a placeholder (iOS `CYLPlaceholderBadgeStyle`).
 */
enum class CYLPlaceholderBadgeStyle {
    /** No badge. */
    None,
    /** A dot. */
    Dot,
    /** A number. */
    Number,
    /** A text. */
    Text,
}

/**
 * The look of every badge (iOS `CYLPlaceholderBadgeAppearance`).
 */
class CYLPlaceholderBadgeAppearance {
    /** The badge's color. */
    @ColorInt var backgroundColor: Int = Color.rgb(0xFF, 0x3B, 0x30)

    /** The text's color. */
    @ColorInt var textColor: Int = Color.WHITE

    /** The text's size, in sp (the size of the iOS `font`). */
    var font: Float = 12f

    /** The text's typeface, or null for the default (the family and weight of the iOS `font`). */
    var fontTypeface: android.graphics.Typeface? = null

    /** The corner radius, in dp; below 0 makes a capsule. */
    var cornerRadius: Float = -1f

    /** The text's insets, in dp: top, left, bottom, right. */
    var contentInsets: FloatArray = floatArrayOf(1f, 5f, 1f, 5f)

    /** How long a badge change pops (scales from 0.6 to its size), in seconds (`animationDuration`). */
    var animationDuration: Double = 0.2

    /** Whether a badge change pops; off when the device turns animations off (`animatesChanges`). */
    var animatesChanges: Boolean = true

    /**
     * The appearance every badge uses.
     */
    companion object {
        /**
         * The shared appearance (`sharedAppearance`).
         */
        @JvmStatic
        val sharedAppearance = CYLPlaceholderBadgeAppearance()
    }
}


/**
 * Plays a placeholder animation (iOS `CYLPlaceholderAnimationPlayer`): what an app's own factory returns
 * ([CYLPlaceholderView.registerAnimationFactory]). Lottie, PAG, Rive and GIF files need none: the animation engine of
 * CYLTabBarController's CYLAnimatedItem plays them once the app adds lottie-android, libpag or rive-android (GIF needs
 * no library). A factory is for another library, or another way to play a file type.
 */
interface CYLPlaceholderAnimationPlayer {
    /** The view that shows the animation. */
    val view: View

    /** Whether the animation is loaded (`ready`). */
    val ready: Boolean

    /** Called when the animation cannot load (`errorHandler`). */
    var errorHandler: ((Throwable) -> Unit)?

    /** Called once the animation is loaded (`readyHandler`). */
    var readyHandler: (() -> Unit)?

    /** Plays from the start (`play`). */
    fun play()

    /** Stops (`stop`). */
    fun stop()

    /** Shows the last frame (`showLastFrame`). */
    fun showLastFrame()

    /** Moves to [progress], 0 to 1 (`setAnimationProgress:`). */
    fun setAnimationProgress(progress: Float)

    /** Plays at [speed] (`setAnimationSpeed:`). */
    fun setAnimationSpeed(speed: Float)

    /** Repeats [count] times, 0 for ever (`setAnimationRepeatCount:`). */
    fun setAnimationRepeatCount(count: Int)

    /** Recolors the animation (`setAnimationColors:`). */
    fun setAnimationColors(colors: List<Int>)
}

/**
 * Makes a player for an animation file (iOS `CYLPlaceholderAnimationFactory`); null when it cannot.
 */
typealias CYLPlaceholderAnimationFactory = (context: Context, path: String) -> CYLPlaceholderAnimationPlayer?

/**
 * Called when a tappable placeholder is tapped (iOS `CYLPlaceholderTapHandler`).
 */
typealias CYLPlaceholderTapHandler = (CYLPlaceholderView) -> Unit

// An app's factories are looked up before the engine's own animators, as they were before the engine moved.
private const val FACTORY_PRIORITY: CYLTabBarItemAnimatorPriority = 1000

private fun fileExtensionOf(url: String): String =
    url.substringBefore('#').substringBefore('?').substringAfterLast('/').substringAfterLast('.', "").lowercase()

// An app's factory (registerAnimationFactory) as an animator of the CYLAnimatedItem engine: CYLPlaceholderView plays
// every file through the engine, so a factory is one more animator, registered for its file extension.
private class CYLPlaceholderFactoryAnimator(extension: String, private val factory: CYLPlaceholderAnimationFactory) : CYLTabBarItemAnimator {
    override val identifier: String = "CYLPlaceholderAnimationFactory.$extension"
    override val priority: CYLTabBarItemAnimatorPriority = FACTORY_PRIORITY
    override val fileExtensions: List<String> = listOf(extension)

    override fun canAnimateFileAtURL(url: String): Boolean = fileExtensionOf(url) == fileExtensions.first()

    override fun animationViewWithURL(context: Context, url: String, size: CYLSize, contentMode: ImageView.ScaleType): View? {
        val player = factory(context, url) ?: return null
        player.view.setTag(R.id.cyl_placeholder_factory_player, player)
        // [EN] A file the app's player cannot load is listed in the status bar; it leaves the list when the player is ready.
        val activity = CYLPlaceholderResourceMonitor.activityOf(context)
        val failed = player.errorHandler
        player.errorHandler = { error ->
            failed?.invoke(error)
            CYLPlaceholderResourceMonitor.report(activity, url, "unreadable")
        }
        val ready = player.readyHandler
        player.readyHandler = {
            ready?.invoke()
            CYLPlaceholderResourceMonitor.clear(activity, url)
        }
        return player.view
    }

    override fun playerForAnimationView(view: View): CYLTabBarItemAnimationPlayer? {
        val player = view.getTag(R.id.cyl_placeholder_factory_player) as? CYLPlaceholderAnimationPlayer ?: return null
        // [EN] One engine player per view, so the repeat count the placeholder gives it stays.
        (view.getTag(R.id.cyl_placeholder_state) as? CYLPlaceholderFactoryPlayer)?.let { return it }
        return CYLPlaceholderFactoryPlayer(view, player).also { view.setTag(R.id.cyl_placeholder_state, it) }
    }
}

// The engine's player around an app's CYLPlaceholderAnimationPlayer. The engine knows only "loops"; the view passes
// its repeat count so a count above 1 still reaches the app's player.
private class CYLPlaceholderFactoryPlayer(view: View, private val player: CYLPlaceholderAnimationPlayer) : CYLTabBarItemAnimationBasePlayer(view) {
    var repeatCount: Int = 0
    private var position = 0f
    private var speed = 1f
    private var looping = true

    override fun play() = player.play()

    override fun showLastFrame() = player.showLastFrame()

    override fun stop() = player.stop()

    override var progress: Float
        get() = position
        set(value) { position = value; player.setAnimationProgress(value) }

    override var animationSpeed: Float
        get() = speed
        set(value) { speed = value; player.setAnimationSpeed(value) }

    override var loops: Boolean
        get() = looping
        set(value) {
            looping = value
            player.setAnimationRepeatCount(if (!value) 1 else if (repeatCount > 1) repeatCount else 0)
        }
}

/**
 * An icon (or an animation) above a text, with an optional badge and tap (iOS `CYLPlaceholderView`).
 *
 * It is a [CYLAnimatedItemView], CYLTabBarController's animated icon + title view (docs/Animated-Item.md there), on the
 * vertical axis: [imageView] is the inherited `iconView`, [textLabel] the inherited `titleView`, and an animation file
 * ([setAnimationFile]) plays through the inherited `animationURL` with the CYLAnimatedItem engine. The core depends on
 * no animation library: Lottie, PAG and Rive files play only when the app adds lottie-android, libpag or rive-android
 * (GIF needs none), otherwise the static image stays. An image sequence ([setAnimationImages]), the badge, the
 * selection colors and the tap handler belong to this class.
 */
class CYLPlaceholderView @JvmOverloads constructor(
    context: Context,
    image: Drawable? = null,
    text: CharSequence? = null,
) : CYLAnimatedItemView(context) {

    /**
     * The built-in icon of [style] above the built-in text of [message] (`initWithStyle:message:`).
     */
    constructor(context: Context, style: CYLPlaceholderStyle, message: CYLPlaceholderMessage) :
        this(context, imageForStyle(context, style), localizedTextForMessage(context, message)) {
        tintsIcon = style != CYLPlaceholderStyle.Empty
    }

    /**
     * The built-in icon of [style] above [text] (`initWithStyle:text:`).
     */
    constructor(context: Context, style: CYLPlaceholderStyle, text: CharSequence?) : this(context, imageForStyle(context, style), text) {
        tintsIcon = style != CYLPlaceholderStyle.Empty
    }

    private val density = resources.displayMetrics.density

    private fun dp(value: Float) = (value * density).toInt()

    /**
     * The icon (`imageView`): the inherited `iconView`. Give the image through `image` (the inherited
     * `CYLAnimatedItemContent` property), which the view shows again whenever an animation cannot play.
     */
    val imageView: ImageView get() = iconView

    /** The text (`textLabel`): the inherited `titleView`; set it through `title`. */
    val textLabel: TextView get() = titleView

    /** The badge's label (`badgeLabel`). */
    val badgeLabel: TextView = TextView(context).apply {
        gravity = Gravity.CENTER
        visibility = GONE
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    internal var tintsIcon = true
        set(value) { field = value; refreshColors() }

    /**
     * Whether the animation (a file or an image sequence) plays by itself while the view is on screen, true by default;
     * a component that drives it, such as a refresh icon following the pull, sets false and calls
     * [playPlaceholderAnimation] / [setPlaceholderAnimationProgress] itself.
     */
    var autoPlaysAnimation: Boolean = true

    /**
     * The image sequence shown as the icon ([setAnimationImages]), or null.
     */
    private var frames: AnimationDrawable? = null

    // Whether the animation was asked to play: it plays again once a file that loads in the background is in.
    private var wantsToPlay = false

    // The engine plays a GIF once: the view replays it while it should loop (animationRepeatCount).
    private var gifPlaysLeft = 0
    private val gifLoop = Runnable { replayGIF() }

    // The badge's text for accessibility services, null without a badge.
    private var badgeText: String? = null

    /**
     * Sets the icon's side in dp, for the image and an animation file alike (the inherited `iconSizeDp`).
     */
    internal fun setIconSide(sideDp: Float) {
        iconSizeDp = CYLSize(sideDp, sideDp)
    }

    /** The text color (`defaultTitleColor`). */
    @ColorInt var defaultTitleColor: Int = Color.rgb(0x8E, 0x8E, 0x93)
        set(value) { field = value; refreshColors() }

    /** The icon color (`defaultIconColor`). */
    @ColorInt var defaultIconColor: Int = ACCENT
        set(value) { field = value; refreshColors() }

    /** The background color (`defaultBackgroundColor`). */
    @ColorInt var defaultBackgroundColor: Int = Color.TRANSPARENT
        set(value) { field = value; refreshColors() }

    /** The text size in sp (`defaultTitleFont`, the size of the iOS UIFont). */
    var defaultTitleFont: Float = 17f
        set(value) { field = value; refreshColors() }

    /** The text's typeface, or null for the default (the family and weight of the iOS `defaultTitleFont`). */
    var defaultTitleTypeface: android.graphics.Typeface? = null
        set(value) { field = value; refreshColors() }

    /** The text's offset in dp, x and y (`defaultTitlePositionAdjustment`). */
    var defaultTitlePositionAdjustment: FloatArray = floatArrayOf(0f, 0f)
        set(value) {
            field = value
            titleView.translationX = value[0] * density
            titleView.translationY = value[1] * density
        }

    /** The text color when selected, or 0 for [defaultTitleColor] (`defaultSelectedTitleColor`). */
    @ColorInt var defaultSelectedTitleColor: Int = 0
        set(value) { field = value; refreshColors() }

    /** The icon color when selected, or 0 for [defaultIconColor] (`defaultSelectedIconColor`). */
    @ColorInt var defaultSelectedIconColor: Int = 0
        set(value) { field = value; refreshColors() }

    /** The background color when selected, or 0 for [defaultBackgroundColor] (`defaultSelectedBackgroundColor`). */
    @ColorInt var defaultSelectedBackgroundColor: Int = 0
        set(value) { field = value; refreshColors() }

    /** The text size in sp when selected, or 0 for [defaultTitleFont] (`defaultSelectedTitleFont`). */
    var defaultSelectedTitleFont: Float = 0f
        set(value) { field = value; refreshColors() }

    /** The image drawn behind a selected placeholder by default (`defaultSelectionIndicatorImage`). */
    var defaultSelectionIndicatorImage: Drawable? = null

    /** The default tint of the selection image (`defaultSelectionIndicatorTintColor`). */
    @ColorInt var defaultSelectionIndicatorTintColor: Int = 0

    /** The image drawn behind a selected placeholder (`selectionIndicatorImage`). */
    var selectionIndicatorImage: Drawable? = null
        set(value) { field = value; refreshColors() }

    /** The tint of the selection image (`selectionIndicatorTintColor`). */
    @ColorInt var selectionIndicatorTintColor: Int = 0
        set(value) { field = value; refreshColors() }

    /** Whether the placeholder is selected (`selected`); it also selects the view, which shows `selectedImage`. */
    var selectedState: Boolean = false
        set(value) { field = value; isSelected = value; refreshColors() }

    /** The margin around the content, in dp (`contentMargin`): the view's padding. */
    var contentMargin: Float = 16f
        set(value) { field = value; applyContentMargin() }

    /** The widest the text lays out, in px, or 0 for no limit (`preferredMaxLayoutWidth`). */
    var preferredMaxLayoutWidth: Int = 0
        set(value) { field = value; titleView.maxWidth = if (value > 0) value else Int.MAX_VALUE }

    /**
     * false (the default, as on iOS): the view fills the room it is given (a wrap-content size up to its limit) and
     * centers its content. true: it measures to its content, so a container can size it; CYLPlaceholderStackView, the
     * HUD, the status view and the refresh icon set it on their placeholder views, as on iOS (`reportsContentSize`).
     */
    var reportsContentSize: Boolean = false
        set(value) {
            if (field == value) return
            field = value
            requestLayout()
        }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        if (reportsContentSize) {
            super.onMeasure(widthMeasureSpec, heightMeasureSpec)
            return
        }
        // iOS: no intrinsic size; the view keeps the size it is given. An AT_MOST (wrap-content) limit is that size.
        fun fill(spec: Int) = if (MeasureSpec.getMode(spec) == MeasureSpec.AT_MOST) {
            MeasureSpec.makeMeasureSpec(MeasureSpec.getSize(spec), MeasureSpec.EXACTLY)
        } else spec
        super.onMeasure(fill(widthMeasureSpec), fill(heightMeasureSpec))
    }

    /** The badge's value: null for none, "" for a dot, else the text (`badgeValue`). */
    var badgeValue: String? = null
        set(value) {
            val changed = field != value
            field = value
            showBadgeWithStyle(
                when {
                    value == null -> CYLPlaceholderBadgeStyle.None
                    value.isEmpty() -> CYLPlaceholderBadgeStyle.Dot
                    value.all { it.isDigit() } -> CYLPlaceholderBadgeStyle.Number
                    else -> CYLPlaceholderBadgeStyle.Text
                },
                value,
            )
            if (changed) popBadge()
        }

    /**
     * iOS `cyl_setBadgeValue:`: a new value pops the badge from 0.6 to its size over the shared appearance's
     * `animationDuration`, when `animatesChanges` is on, the view is on screen and animations are not turned off.
     */
    private fun popBadge() {
        val appearance = CYLPlaceholderBadgeAppearance.sharedAppearance
        val animatorScale = runCatching {
            android.provider.Settings.Global.getFloat(context.contentResolver, android.provider.Settings.Global.ANIMATOR_DURATION_SCALE, 1f)
        }.getOrDefault(1f)
        if (badgeValue == null || !appearance.animatesChanges || appearance.animationDuration <= 0 || !isAttachedToWindow ||
            animatorScale == 0f) return
        badgeLabel.animate().cancel()
        badgeLabel.scaleX = 0.6f
        badgeLabel.scaleY = 0.6f
        badgeLabel.animate().scaleX(1f).scaleY(1f).setDuration((appearance.animationDuration * 1000).toLong())
            .setInterpolator(android.view.animation.OvershootInterpolator()).start()
    }

    /** The badge's offset from the icon's top right corner, in dp, x and y (`badgeCenterOffset`). */
    var badgeCenterOffset: FloatArray = floatArrayOf(0f, 0f)
        set(value) { field = value; positionBadge() }

    /** Called when the placeholder is tapped (`tapHandler`); setting it makes the placeholder a button. */
    var tapHandler: CYLPlaceholderTapHandler? = null
        set(value) { field = value; refreshTap() }

    /** Whether taps reach [tapHandler] (`tapInteractionEnabled`). */
    var tapInteractionEnabled: Boolean = true
        set(value) { field = value; refreshTap() }

    /** How the placeholder answers a finger (`tapHighlightStyle`). */
    var tapHighlightStyle: CYLPlaceholderTapHighlightStyle = CYLPlaceholderTapHighlightStyle.Dim

    /** Whether a finger is down on it (`tapHighlighted`). */
    var tapHighlighted: Boolean = false
        private set(value) {
            field = value
            val pressed = value && tapHighlightStyle != CYLPlaceholderTapHighlightStyle.None
            val contentAlpha = if (pressed && tapHighlightStyle == CYLPlaceholderTapHighlightStyle.Dim) 0.5f else 1f
            val scale = if (pressed && tapHighlightStyle == CYLPlaceholderTapHighlightStyle.Shrink) 0.95f else 1f
            listOfNotNull(iconView, titleView, animationView, badgeLabel).forEach {
                it.alpha = contentAlpha
                it.scaleX = scale
                it.scaleY = scale
            }
        }

    /** Whether a tap does something now (`tapInteractive`). */
    val tapInteractive: Boolean
        get() = tapHandler != null && tapInteractionEnabled

    /**
     * How often the animation repeats, 0 for ever (`animationRepeatCount`). The engine's players know only whether
     * they loop (`animationLoops`): 1 plays once, any other count loops; a GIF and an app's factory player repeat the
     * exact count.
     */
    var animationRepeatCount: Int = 0
        set(value) {
            field = value
            frames?.isOneShot = value == 1
            applyRepeatCount()
        }

    /**
     * Whether the animation loops. A value set directly is kept: a change of kind writes [animationRepeatCount] (0 for
     * true, 1 for false), so [applyRepeatCount] does not undo it when the animation is loaded again; a count above 1
     * stays when false is set.
     */
    override var animationLoops: Boolean
        get() = super.animationLoops
        set(value) {
            super.animationLoops = value
            if ((animationRepeatCount != 1) != value) animationRepeatCount = if (value) 0 else 1
        }

    /**
     * What accessibility services read for the placeholder (iOS `accessibilityLabel`); null reads the text and the
     * badge.
     */
    var accessibilityLabel: CharSequence? = null
        set(value) { field = value; updateAccessibility() }

    /** The description the view was made from, with the iOS keys (`itemAttributes`). */
    var itemAttributes: Map<String, Any> = emptyMap()
        internal set

    init {
        // [EN] The item base class defaults `drivesAnimationPlayback` to true (CYLTabBarController 82b85e064), which would
        //      let `selectedState` (-> isSelected) start or restart the player; this view's playback belongs to its own state.
        drivesAnimationPlayback = false
        axis = CYLAnimatedItemAxis.Vertical
        spacingDp = TITLE_SPACING
        iconSizeDp = CYLSize(ICON_SIDE, ICON_SIDE)
        // [EN] The text wraps, as on iOS (numberOfLines = 0).
        titleView.maxLines = Int.MAX_VALUE
        titleView.ellipsize = null
        clipChildren = false
        addView(badgeLabel, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT))
        this.image = image
        title = text
        animationLoops = true
        applyContentMargin()
        itemAttributes = buildMap {
            text?.let { put("CYLPlaceholderItemTitle", it) }
            image?.let { put("CYLPlaceholderItemImage", it) }
        }
        refreshTap()
        refreshColors()
    }

    private fun applyContentMargin() {
        val margin = dp(contentMargin)
        setPadding(margin, margin, margin, margin)
    }

    private fun applyRepeatCount() {
        (animationPlayer as? CYLPlaceholderFactoryPlayer)?.repeatCount = animationRepeatCount
        animationLoops = animationRepeatCount != 1
    }

    private fun refreshColors() {
        val selected = selectedState
        val title = if (selected && defaultSelectedTitleColor != 0) defaultSelectedTitleColor else defaultTitleColor
        val icon = if (selected && defaultSelectedIconColor != 0) defaultSelectedIconColor else defaultIconColor
        val backgroundColor = if (selected && defaultSelectedBackgroundColor != 0) defaultSelectedBackgroundColor else defaultBackgroundColor
        val size = if (selected && defaultSelectedTitleFont != 0f) defaultSelectedTitleFont else defaultTitleFont
        titleView.setTextColor(title)
        titleView.setTextSize(TypedValue.COMPLEX_UNIT_SP, size)
        defaultTitleTypeface?.let { titleView.typeface = it }
        if (tintsIcon) ImageViewCompat.setImageTintList(iconView, ColorStateList.valueOf(icon)) else ImageViewCompat.setImageTintList(iconView, null)
        val indicator = if (selected) (selectionIndicatorImage ?: defaultSelectionIndicatorImage) else null
        background = indicator?.mutate()?.also { drawable ->
            val tint = if (selectionIndicatorTintColor != 0) selectionIndicatorTintColor else defaultSelectionIndicatorTintColor
            if (tint != 0) drawable.setTint(tint)
        } ?: if (backgroundColor != 0) GradientDrawable().apply { setColor(backgroundColor) } else null
    }

    /**
     * Shows a badge of [style] with [value] (`showBadgeWithStyle:value:`).
     */
    fun showBadgeWithStyle(style: CYLPlaceholderBadgeStyle, value: String?) {
        val appearance = CYLPlaceholderBadgeAppearance.sharedAppearance
        if (style == CYLPlaceholderBadgeStyle.None) {
            badgeLabel.visibility = GONE
            badgeText = null
            updateAccessibility()
            return
        }
        badgeLabel.text = if (style == CYLPlaceholderBadgeStyle.Dot) "" else value
        badgeLabel.setTextColor(appearance.textColor)
        badgeLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, appearance.font)
        appearance.fontTypeface?.let { badgeLabel.typeface = it }
        val insets = appearance.contentInsets
        if (style == CYLPlaceholderBadgeStyle.Dot) {
            badgeLabel.setPadding(0, 0, 0, 0)
            badgeLabel.minWidth = dp(8f)
            badgeLabel.minHeight = dp(8f)
            badgeLabel.layoutParams = badgeLabel.layoutParams.apply { width = dp(8f); height = dp(8f) }
        } else {
            badgeLabel.setPadding(dp(insets[1]), dp(insets[0]), dp(insets[3]), dp(insets[2]))
            badgeLabel.layoutParams = badgeLabel.layoutParams.apply { width = LayoutParams.WRAP_CONTENT; height = LayoutParams.WRAP_CONTENT }
        }
        badgeLabel.background = GradientDrawable().apply {
            setColor(appearance.backgroundColor)
            cornerRadius = if (appearance.cornerRadius < 0) dp(999f).toFloat() else dp(appearance.cornerRadius).toFloat()
        }
        badgeLabel.visibility = VISIBLE
        positionBadge()
        requestLayout()
        // [EN] The badge is part of the placeholder's spoken description (accessibilityText).
        badgeText = if (style == CYLPlaceholderBadgeStyle.Dot) "" else value
        updateAccessibility()
    }

    private fun positionBadge() {
        badgeLabel.translationX = badgeCenterOffset[0] * density
        badgeLabel.translationY = badgeCenterOffset[1] * density
    }

    /**
     * The inherited layout (the icon above the text), then the badge on the icon's top right corner.
     */
    override fun layoutContent(left: Int, top: Int, right: Int, bottom: Int) {
        super.layoutContent(left, top, right, bottom)
        if (badgeLabel.visibility == GONE) return
        val params = badgeLabel.layoutParams
        fun spec(size: Int) = if (size > 0) MeasureSpec.makeMeasureSpec(size, MeasureSpec.EXACTLY) else MeasureSpec.makeMeasureSpec(0, MeasureSpec.UNSPECIFIED)
        badgeLabel.measure(spec(params?.width ?: 0), spec(params?.height ?: 0))
        val x = iconView.right - badgeLabel.measuredWidth
        val y = iconView.top
        badgeLabel.layout(x, y, x + badgeLabel.measuredWidth, y + badgeLabel.measuredHeight)
    }

    /**
     * What accessibility services read: [accessibilityLabel], else the text and the badge.
     */
    override fun accessibilityText(): CharSequence = accessibilityLabel ?: CYLAnimatedItemAccessibilityText(title, badgeText)

    private fun refreshTap() {
        // [EN] Only a tappable placeholder (or one with a click listener, such as a stack view's action) takes touches,
        //      so a plain placeholder leaves them to the views behind it.
        val clickable = tapInteractive || hasOnClickListeners()
        isClickable = clickable
        isFocusable = clickable
        if (!tapInteractive) tapHighlighted = false
    }

    /**
     * A tappable placeholder is a button, not enabled while [tapInteractionEnabled] is false; any other reads as text.
     */
    override fun onInitializeAccessibilityNodeInfo(info: AccessibilityNodeInfo) {
        super.onInitializeAccessibilityNodeInfo(info)
        if (tapHandler != null) {
            info.isEnabled = tapInteractionEnabled
        } else if (!hasOnClickListeners()) {
            info.className = TextView::class.java.name
        }
    }

    /**
     * The inherited tap, long press and drag handling, with the tap highlight; a placeholder that cannot be tapped
     * does not take touches.
     */
    @android.annotation.SuppressLint("ClickableViewAccessibility")
    override fun onTouchEvent(event: MotionEvent): Boolean {
        if (!isClickable && !isLongClickable && gestureListener == null) return false
        if (tapInteractive) {
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> tapHighlighted = true
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> tapHighlighted = false
            }
        }
        return super.onTouchEvent(event)
    }

    /**
     * A click (a tap or an accessibility action) runs the click listener, the gesture listener and [tapHandler].
     */
    override fun performClick(): Boolean {
        val handled = super.performClick()
        return performTap() || handled
    }

    /**
     * Calls [tapHandler] as a tap would; false when the placeholder is not interactive (`performTap`).
     */
    fun performTap(): Boolean {
        if (!tapInteractive) return false
        tapHandler?.invoke(this)
        return true
    }

    /**
     * Shows the animation at [path] instead of the icon (the inherited `animationURL`), through the animator of the
     * CYLAnimatedItem engine for it (an app's [registerAnimationFactory] first); false when no animator plays it (for
     * example a Lottie file in an app without lottie-android): then the static image shows, or the inherited
     * placeholder when there is none, and the file is kept in `animationURL`. [path] is
     * "asset:<name>" in the app's assets, a path, a `file:` or `http(s):` URL; options such as Rive's artboard follow
     * '#' (or '?' for a local file): "asset:CYLRefreshIcon.riv#artboard=refresh&animation=active". A file the engine
     * loads in the background (PAG, Rive, GIF, a download) shows the static image (or the placeholder) while it loads
     * and again if it turns out to be unreadable.
     */
    fun setAnimationFile(path: String): Boolean {
        // [EN] The display priority is the inherited one (docs/Animated-Item.md of CYLTabBarController): the animation
        //      when it can play, else the static image, else the component's placeholder; `animationURL` is kept.
        // [EN] A file that is not there is listed in the status bar at the top of the page (CYLPlaceholderResourceMonitor);
        //      a file that is there but has no animator (no runtime) is the engine's report, not this one.
        val activity = CYLPlaceholderResourceMonitor.activityOf(context)
        val missing = isMissingFile(path)
        if (missing) CYLPlaceholderResourceMonitor.report(activity, path, "file not found")
        animationURL = engineURL(path)
        if (!isAnimationReady) return false
        // [EN] An animator that exists says nothing about the file: a missing one stays listed.
        if (!missing) CYLPlaceholderResourceMonitor.clear(activity, path)
        frames?.stop()
        frames = null
        wantsToPlay = false
        removeCallbacks(gifLoop)
        applyRepeatCount()
        itemAttributes = itemAttributes + ("CYLPlaceholderItemAnimationFilePath" to path)
        if (autoPlaysAnimation && isAttachedToWindow) playPlaceholderAnimation()
        return true
    }

    // Whether an "asset:" name or an absolute / file: path does not exist; other strings (a URL, an app's own name for its
    // factory) are not checked.
    private fun isMissingFile(path: String): Boolean {
        val bare = path.substringBefore('#').substringBefore('?')
        val asset = when {
            bare.startsWith("asset:") -> bare.removePrefix("asset:").trimStart('/')
            bare.startsWith("file:///android_asset/") -> bare.removePrefix("file:///android_asset/")
            else -> null
        }
        if (asset != null) return try { context.assets.open(asset).close(); false } catch (_: java.io.IOException) { true }
        val file = bare.removePrefix("file://")
        return (bare.startsWith("file:") || bare.startsWith("/")) && !java.io.File(file.removePrefix("file:")).exists()
    }

    // The engine reads options after '#'; this view's earlier Android API put them after '?' for local files.
    private fun engineURL(path: String): String {
        val remote = path.startsWith("http://") || path.startsWith("https://")
        return if (!remote && '?' in path && '#' !in path) path.replaceFirst('?', '#') else path
    }

    /**
     * Shows [images] as one animated icon of [duration] seconds (iOS `CYLPlaceholderItemImages` with
     * `CYLPlaceholderItemAnimationDuration`): played, stopped and moved by the same calls as an animation file, and it
     * replaces an animation file. With animations off (the system animator duration scale is 0) the first image stays
     * still. False for an empty list.
     */
    @JvmOverloads
    fun setAnimationImages(images: List<Drawable>, duration: Double = images.size * 0.1): Boolean {
        if (images.isEmpty()) return false
        frames?.stop()
        removeCallbacks(gifLoop)
        animationURL = null
        if (images.size == 1 || !animationsEnabled()) {
            frames = null
            image = images.first()
        } else {
            val sequence = AnimationDrawable().apply {
                val each = maxOf(1, ((if (duration > 0) duration else images.size * 0.1) * 1000 / images.size).toInt())
                images.forEach { addFrame(it, each) }
                isOneShot = animationRepeatCount == 1
            }
            frames = sequence
            image = sequence
        }
        itemAttributes = itemAttributes + mapOf("CYLPlaceholderItemImages" to images, "CYLPlaceholderItemAnimationDuration" to duration)
        if (autoPlaysAnimation && isAttachedToWindow) frames?.start()
        return true
    }

    private fun animationsEnabled(): Boolean =
        Settings.Global.getFloat(context.contentResolver, Settings.Global.ANIMATOR_DURATION_SCALE, 1f) != 0f

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        // [EN] An animation plays while the view is on screen, as on iOS, unless its owner drives it.
        if (autoPlaysAnimation) playPlaceholderAnimation()
    }

    override fun onDetachedFromWindow() {
        stopPlaceholderAnimation()
        super.onDetachedFromWindow()
    }

    /**
     * A file loaded in the background is in: it plays now if it was asked to play before.
     */
    override fun cyl_animationViewDidLoad(animationView: View) {
        super.cyl_animationViewDidLoad(animationView)
        if (animationView === this.animationView && wantsToPlay) {
            playAnimation()
            scheduleGIFLoop()
        }
    }

    private fun scheduleGIFLoop() {
        removeCallbacks(gifLoop)
        val gif = animationView as? CYLGIFTabBarItemAnimationView ?: return
        // For ever: the engine's GIF view loops by itself (`loops`, CYLTabBarController 4f73209c); a timer restarting
        // it would cut a pass played below 1x short. A count above 1 replays after each pass at the current speed.
        gifPlaysLeft = if (animationRepeatCount <= 0) 0 else animationRepeatCount - 1
        if (gifPlaysLeft > 0) postDelayed(gifLoop, gifPassMillis(gif))
    }

    private fun gifPassMillis(gif: CYLGIFTabBarItemAnimationView): Long =
        (gif.duration / (if (animationSpeed > 0f) animationSpeed else 1f)).toLong().coerceAtLeast(1L)

    private fun replayGIF() {
        val gif = animationView as? CYLGIFTabBarItemAnimationView ?: return
        if (!wantsToPlay || gifPlaysLeft <= 0) return
        gifPlaysLeft--
        animationPlayer?.play()
        if (gifPlaysLeft > 0) postDelayed(gifLoop, gifPassMillis(gif))
    }

    /** Plays the animation or the image sequence (`playPlaceholderAnimation`): the inherited `playAnimation()`. */
    fun playPlaceholderAnimation() {
        wantsToPlay = true
        frames?.start()
        playAnimation()
        scheduleGIFLoop()
    }

    /** Stops the animation or the image sequence (`stopPlaceholderAnimation`): the inherited `stopAnimation()`. */
    fun stopPlaceholderAnimation() {
        wantsToPlay = false
        removeCallbacks(gifLoop)
        stopAnimation()
        frames?.stop()
    }

    /** Shows the animation's last frame (`showPlaceholderAnimationLastFrame`): the inherited `showAnimationLastFrame()`. */
    fun showPlaceholderAnimationLastFrame() {
        wantsToPlay = false
        removeCallbacks(gifLoop)
        showAnimationLastFrame()
        frames?.let { it.stop(); it.selectDrawable(it.numberOfFrames - 1) }
    }

    /** Moves the animation, or the image sequence while it is not playing, to [progress], 0 to 1 (`setPlaceholderAnimationProgress:`). */
    fun setPlaceholderAnimationProgress(progress: Float) {
        animationPlayer?.progress = progress.coerceIn(0f, 1f)
        frames?.let { sequence ->
            if (sequence.numberOfFrames > 0 && !sequence.isRunning) {
                sequence.selectDrawable(((sequence.numberOfFrames - 1) * progress.coerceIn(0f, 1f)).toInt())
            }
        }
    }

    /** Plays the animation at [speed] (`setPlaceholderAnimationSpeed:`): the inherited `animationSpeed`. */
    fun setPlaceholderAnimationSpeed(speed: Float) {
        animationSpeed = speed
    }

    /**
     * The built-in icons and texts, and the animation factories.
     */
    companion object {
        private const val TITLE_SPACING = 12f

        private val factoryAnimators = HashMap<String, CYLPlaceholderFactoryAnimator>()

        /**
         * Plays files ending in [extension] ("json", "pag", "riv", "gif") with [factory] (`registerAnimationFactory:forFileExtension:`):
         * the factory becomes an animator of the CYLAnimatedItem engine, looked up before the engine's own; null removes it.
         */
        @JvmStatic
        fun registerAnimationFactory(factory: CYLPlaceholderAnimationFactory?, extension: String) {
            val key = extension.lowercase().removePrefix(".")
            synchronized(factoryAnimators) {
                factoryAnimators.remove(key)?.let { CYLTabBarItemAnimatorRegistry.unregisterAnimatorWithIdentifier(it.identifier) }
                if (factory != null) {
                    val animator = CYLPlaceholderFactoryAnimator(key, factory)
                    factoryAnimators[key] = animator
                    CYLTabBarItemAnimatorRegistry.registerAnimator(animator)
                }
            }
        }

        /**
         * The resource name of [style]'s icon, "CYLPlaceholderWifiOff" as on iOS (`imageNameForStyle:`).
         */
        @JvmStatic
        fun imageNameForStyle(style: CYLPlaceholderStyle): String = "CYLPlaceholder" + style.name

        /**
         * [style]'s icon (`imageForStyle:`); every one but Empty is meant to be tinted.
         */
        @JvmStatic
        fun imageForStyle(context: Context, style: CYLPlaceholderStyle): Drawable? {
            val name = "cyl_placeholder_" + style.name.replace(Regex("(?<!^)(?=[A-Z])"), "_").lowercase()
            val id = context.resources.getIdentifier(name, "drawable", context.packageName)
            return if (id == 0) null else ContextCompat.getDrawable(context, id)
        }

        /**
         * [message]'s localized text (`localizedTextForMessage:`).
         */
        @JvmStatic
        fun localizedTextForMessage(context: Context, message: CYLPlaceholderMessage): String = CYLPlaceholderLocalization.localizedContext(context).getString(
            when (message) {
                CYLPlaceholderMessage.Empty -> R.string.cyl_placeholder_empty_text
                CYLPlaceholderMessage.NoResults -> R.string.cyl_placeholder_no_results_text
                CYLPlaceholderMessage.NoInternet -> R.string.cyl_placeholder_no_internet_text
                CYLPlaceholderMessage.ServerUnavailable -> R.string.cyl_placeholder_server_unavailable_text
                CYLPlaceholderMessage.Error -> R.string.cyl_placeholder_error_text
                CYLPlaceholderMessage.Loading -> R.string.cyl_placeholder_loading_text
                CYLPlaceholderMessage.NoPermission -> R.string.cyl_placeholder_no_permission_text
                CYLPlaceholderMessage.EmptyCart -> R.string.cyl_placeholder_empty_cart_text
                CYLPlaceholderMessage.NoNotifications -> R.string.cyl_placeholder_no_notifications_text
            },
        )
    }
}
