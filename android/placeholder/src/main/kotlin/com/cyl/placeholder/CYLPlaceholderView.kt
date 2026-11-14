package com.cyl.placeholder

import android.content.Context
import android.content.res.ColorStateList
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.annotation.ColorInt
import androidx.core.content.ContextCompat
import androidx.core.view.AccessibilityDelegateCompat
import androidx.core.view.ViewCompat
import androidx.core.view.accessibility.AccessibilityNodeInfoCompat
import androidx.core.widget.ImageViewCompat

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

    /** The text's size, in sp (the iOS `font`). */
    var font: Float = 12f

    /** The corner radius, in dp; below 0 makes a capsule. */
    var cornerRadius: Float = -1f

    /** The text's insets, in dp: top, left, bottom, right. */
    var contentInsets: FloatArray = floatArrayOf(1f, 5f, 1f, 5f)

    /** How long a change animates, in seconds. */
    var animationDuration: Double = 0.2

    /** Whether changes animate. */
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
 * Plays a placeholder animation (iOS `CYLPlaceholderAnimationPlayer`). An app gives one per file extension through
 * [CYLPlaceholderView.registerAnimationFactory], for example with lottie-android, libpag or rive-android.
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

/**
 * An icon (or an animation) above a text, with an optional badge and tap (iOS `CYLPlaceholderView`).
 */
class CYLPlaceholderView @JvmOverloads constructor(
    context: Context,
    image: Drawable? = null,
    text: CharSequence? = null,
) : FrameLayout(context) {

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

    private val column = LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        gravity = Gravity.CENTER_HORIZONTAL
    }

    /** The icon (`imageView`). */
    val imageView: ImageView = ImageView(context).apply {
        scaleType = ImageView.ScaleType.FIT_CENTER
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    /** The text (`textLabel`). */
    val textLabel: TextView = TextView(context).apply {
        gravity = Gravity.CENTER
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 17f)
    }

    /** The badge's label (`badgeLabel`). */
    val badgeLabel: TextView = TextView(context).apply {
        gravity = Gravity.CENTER
        visibility = GONE
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    private var tintsIcon = true
    private var player: CYLPlaceholderAnimationPlayer? = null

    /** The text color (`defaultTitleColor`). */
    @ColorInt var defaultTitleColor: Int = Color.rgb(0x8E, 0x8E, 0x93)
        set(value) { field = value; refreshColors() }

    /** The icon color (`defaultIconColor`). */
    @ColorInt var defaultIconColor: Int = ACCENT
        set(value) { field = value; refreshColors() }

    /** The background color (`defaultBackgroundColor`). */
    @ColorInt var defaultBackgroundColor: Int = Color.TRANSPARENT
        set(value) { field = value; refreshColors() }

    /** The text size in sp (`defaultTitleFont`). */
    var defaultTitleFont: Float = 17f
        set(value) { field = value; refreshColors() }

    /** The text's offset in dp, x and y (`defaultTitlePositionAdjustment`). */
    var defaultTitlePositionAdjustment: FloatArray = floatArrayOf(0f, 0f)
        set(value) {
            field = value
            textLabel.translationX = value[0] * density
            textLabel.translationY = value[1] * density
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

    /** Whether the placeholder is selected (`selected`). */
    var selectedState: Boolean = false
        set(value) { field = value; isSelected = value; refreshColors() }

    /** The margin around the content, in dp (`contentMargin`). */
    var contentMargin: Float = 16f
        set(value) { field = value; (column.layoutParams as? LayoutParams)?.let { it.setMargins(dp(value), dp(value), dp(value), dp(value)); column.layoutParams = it } }

    /** The widest the text lays out, in px, or 0 for no limit (`preferredMaxLayoutWidth`). */
    var preferredMaxLayoutWidth: Int = 0
        set(value) { field = value; textLabel.maxWidth = if (value > 0) value else Int.MAX_VALUE }

    /** Whether the view measures to its content rather than filling its parent (`reportsContentSize`). */
    var reportsContentSize: Boolean = false

    /** The badge's value: null for none, "" for a dot, else the text (`badgeValue`). */
    var badgeValue: String? = null
        set(value) {
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
            column.alpha = if (pressed && tapHighlightStyle == CYLPlaceholderTapHighlightStyle.Dim) 0.5f else 1f
            val scale = if (pressed && tapHighlightStyle == CYLPlaceholderTapHighlightStyle.Shrink) 0.95f else 1f
            column.scaleX = scale
            column.scaleY = scale
        }

    /** Whether a tap does something now (`tapInteractive`). */
    val tapInteractive: Boolean
        get() = tapHandler != null && tapInteractionEnabled

    /** How often the animation repeats, 0 for ever (`animationRepeatCount`). */
    var animationRepeatCount: Int = 0
        set(value) { field = value; player?.setAnimationRepeatCount(value) }

    /** The description the view was made from, with the iOS keys (`itemAttributes`). */
    var itemAttributes: Map<String, Any> = emptyMap()
        private set

    init {
        imageView.setImageDrawable(image)
        imageView.visibility = if (image == null) GONE else VISIBLE
        textLabel.text = text
        textLabel.visibility = if (text.isNullOrEmpty()) GONE else VISIBLE
        val iconBox = FrameLayout(context).apply {
            clipChildren = false
            addView(imageView, LayoutParams(dp(ICON_SIDE), dp(ICON_SIDE)))
            addView(badgeLabel, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, Gravity.TOP or Gravity.END))
        }
        column.addView(iconBox, LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT))
        column.addView(textLabel, LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT).apply { topMargin = dp(12f) })
        clipChildren = false
        addView(column, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER).apply {
            setMargins(dp(contentMargin), dp(contentMargin), dp(contentMargin), dp(contentMargin))
        })
        itemAttributes = buildMap {
            text?.let { put("CYLPlaceholderItemTitle", it) }
            image?.let { put("CYLPlaceholderItemImage", it) }
        }
        refreshColors()
    }

    private fun refreshColors() {
        val selected = selectedState
        val title = if (selected && defaultSelectedTitleColor != 0) defaultSelectedTitleColor else defaultTitleColor
        val icon = if (selected && defaultSelectedIconColor != 0) defaultSelectedIconColor else defaultIconColor
        val backgroundColor = if (selected && defaultSelectedBackgroundColor != 0) defaultSelectedBackgroundColor else defaultBackgroundColor
        val size = if (selected && defaultSelectedTitleFont != 0f) defaultSelectedTitleFont else defaultTitleFont
        textLabel.setTextColor(title)
        textLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, size)
        if (tintsIcon) ImageViewCompat.setImageTintList(imageView, ColorStateList.valueOf(icon)) else ImageViewCompat.setImageTintList(imageView, null)
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
            return
        }
        badgeLabel.text = if (style == CYLPlaceholderBadgeStyle.Dot) "" else value
        badgeLabel.setTextColor(appearance.textColor)
        badgeLabel.setTextSize(TypedValue.COMPLEX_UNIT_SP, appearance.font)
        val insets = appearance.contentInsets
        if (style == CYLPlaceholderBadgeStyle.Dot) {
            badgeLabel.setPadding(0, 0, 0, 0)
            badgeLabel.minWidth = dp(8f)
            badgeLabel.minHeight = dp(8f)
            badgeLabel.layoutParams = (badgeLabel.layoutParams as LayoutParams).apply { width = dp(8f); height = dp(8f) }
        } else {
            badgeLabel.setPadding(dp(insets[1]), dp(insets[0]), dp(insets[3]), dp(insets[2]))
            badgeLabel.layoutParams = (badgeLabel.layoutParams as LayoutParams).apply { width = LayoutParams.WRAP_CONTENT; height = LayoutParams.WRAP_CONTENT }
        }
        badgeLabel.background = GradientDrawable().apply {
            setColor(appearance.backgroundColor)
            cornerRadius = if (appearance.cornerRadius < 0) dp(999f).toFloat() else dp(appearance.cornerRadius).toFloat()
        }
        badgeLabel.visibility = VISIBLE
        positionBadge()
        // [EN] The badge is part of the placeholder's spoken description.
        contentDescription = listOfNotNull(textLabel.text?.toString()?.takeIf { it.isNotEmpty() }, value?.takeIf { it.isNotEmpty() }).joinToString(", ")
    }

    private fun positionBadge() {
        badgeLabel.translationX = badgeCenterOffset[0] * density
        badgeLabel.translationY = badgeCenterOffset[1] * density
    }

    private fun refreshTap() {
        val interactive = tapInteractive
        isClickable = interactive
        isFocusable = interactive
        setOnClickListener(if (interactive) View.OnClickListener { performTap() } else null)
        ViewCompat.setAccessibilityDelegate(this, object : AccessibilityDelegateCompat() {
            override fun onInitializeAccessibilityNodeInfo(host: View, info: AccessibilityNodeInfoCompat) {
                super.onInitializeAccessibilityNodeInfo(host, info)
                if (tapHandler != null) {
                    info.className = android.widget.Button::class.java.name
                    info.isEnabled = tapInteractionEnabled
                }
            }
        })
    }

    override fun onTouchEvent(event: MotionEvent): Boolean {
        if (tapInteractive) {
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> tapHighlighted = true
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> tapHighlighted = false
            }
        }
        return super.onTouchEvent(event)
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
     * Shows the animation at [path] instead of the icon, through the factory registered for its extension; false when
     * none is registered or it cannot load (the icon stays).
     */
    fun setAnimationFile(path: String): Boolean {
        // A factory registered for the extension first, then the animator registry (CYLPlaceholderItemAnimatorRegistry).
        val side = imageView.layoutParams
        val made = factories[path.substringAfterLast('.', "").lowercase()]?.invoke(context, path)
            ?: CYLPlaceholderAnimationView.withFileURL(context, path, maxOf(1, side.width), maxOf(1, side.height))
            ?: return false
        player?.let { (it.view.parent as? ViewGroup)?.removeView(it.view) }
        player = made
        made.setAnimationRepeatCount(animationRepeatCount)
        val box = imageView.parent as FrameLayout
        box.addView(made.view, 0, LayoutParams(imageView.layoutParams.width, imageView.layoutParams.height))
        imageView.visibility = GONE
        itemAttributes = itemAttributes + ("CYLPlaceholderItemAnimationFilePath" to path)
        return true
    }

    /** Plays the animation (`playPlaceholderAnimation`). */
    fun playPlaceholderAnimation() { player?.play() }

    /** Stops the animation (`stopPlaceholderAnimation`). */
    fun stopPlaceholderAnimation() { player?.stop() }

    /** Shows the animation's last frame (`showPlaceholderAnimationLastFrame`). */
    fun showPlaceholderAnimationLastFrame() { player?.showLastFrame() }

    /** Moves the animation to [progress], 0 to 1 (`setPlaceholderAnimationProgress:`). */
    fun setPlaceholderAnimationProgress(progress: Float) { player?.setAnimationProgress(progress) }

    /** Plays the animation at [speed] (`setPlaceholderAnimationSpeed:`). */
    fun setPlaceholderAnimationSpeed(speed: Float) { player?.setAnimationSpeed(speed) }

    /**
     * The built-in icons and texts, and the animation factories.
     */
    companion object {
        private val factories = HashMap<String, CYLPlaceholderAnimationFactory>()

        /**
         * Plays files ending in [extension] ("json", "pag", "riv", "gif") with [factory] (`registerAnimationFactory:forFileExtension:`).
         */
        @JvmStatic
        fun registerAnimationFactory(factory: CYLPlaceholderAnimationFactory?, extension: String) {
            val key = extension.lowercase().removePrefix(".")
            if (factory == null) factories.remove(key) else factories[key] = factory
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
