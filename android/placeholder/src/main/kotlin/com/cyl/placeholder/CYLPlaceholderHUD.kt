package com.cyl.placeholder

import android.content.Context
import android.content.res.Configuration
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.HapticFeedbackConstants
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ProgressBar
import androidx.annotation.ColorInt
import kotlin.math.max
import kotlin.math.min

/**
 * The HUD's colors (iOS `CYLPlaceholderHUDStyle`).
 */
enum class CYLPlaceholderHUDStyle {
    /** Light or dark with the system. */
    Automatic,
    /** Dark content on a light box. */
    Light,
    /** Light content on a dark box. */
    Dark,
    /** [CYLPlaceholderHUD.foregroundColor] on [CYLPlaceholderHUD.hudBackgroundColor]. */
    Custom,
}

/**
 * What covers the screen behind the HUD (iOS `CYLPlaceholderHUDMaskType`).
 */
enum class CYLPlaceholderHUDMaskType {
    /** Nothing; touches reach the content. */
    None,
    /** Nothing visible, but touches are blocked. */
    Clear,
    /** A dim black layer. */
    Black,
    /** A dark gradient. */
    Gradient,
    /** [CYLPlaceholderHUD.backgroundLayerColor]. */
    Custom,
}

/**
 * What the HUD shows (iOS `CYLPlaceholderHUDState`).
 */
enum class CYLPlaceholderHUDState {
    /** Nothing. */
    Hidden,
    /** A spinner. */
    Loading,
    /** A progress bar. */
    Progress,
    /** A success icon. */
    Success,
    /** An error icon. */
    Error,
    /** An info icon. */
    Info,
    /** An image of yours. */
    Image,
    /** Components or a scenario. */
    Custom,
}

/**
 * Called once the HUD has disappeared (iOS `CYLPlaceholderHUDDismissCompletion`).
 */
typealias CYLPlaceholderHUDDismissCompletion = () -> Unit

/**
 * A heads-up display over a container (iOS `CYLPlaceholderHUD`): a spinner, a progress bar, a success / error / info
 * icon or a placeholder scenario, with a status text. [sharedHUD] needs its [containerView] (for example the activity's
 * content view) before the class-level calls show anything.
 */
class CYLPlaceholderHUD(context: Context, containerView: ViewGroup? = null) : FrameLayout(context) {

    private val handler = Handler(Looper.getMainLooper())
    private val density = resources.displayMetrics.density

    private fun dp(value: Float) = (value * density).toInt()

    /** The container the HUD covers (`containerView`). */
    var containerView: ViewGroup? = containerView

    /** The box (`hudView`). */
    val hudView: LinearLayout = LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        gravity = Gravity.CENTER
        accessibilityLiveRegion = ACCESSIBILITY_LIVE_REGION_POLITE
    }

    /** The box's content area (`contentView`). */
    val contentView: FrameLayout = FrameLayout(context)

    /** The icon and status (`placeholderView`). */
    var placeholderView: CYLPlaceholderView? = null
        private set

    private val spinner = ProgressBar(context)
    private val bar = ProgressBar(context, null, android.R.attr.progressBarStyleHorizontal).apply { max = 1000 }

    /** The handlers of the shown components' actions (`actions`). */
    var actions: Map<String, CYLPlaceholderActionHandler> = emptyMap()
        private set

    /** What is shown (`state`). */
    var state: CYLPlaceholderHUDState = CYLPlaceholderHUDState.Hidden
        private set

    /** The status text (`status`). */
    var status: CharSequence? = null
        private set

    /** The progress, 0 to 1 (`progress`). */
    var progress: Float = 0f
        private set

    /** Whether the HUD is on screen (`visible`). */
    val visible: Boolean
        get() = parent != null && state != CYLPlaceholderHUDState.Hidden

    /** How many [show] calls wait for [popActivity] (`activityCount`). */
    var activityCount: Int = 0
        private set

    /** The colors (`style`). */
    var style: CYLPlaceholderHUDStyle = CYLPlaceholderHUDStyle.Automatic

    /** What covers the screen (`maskType`). */
    var maskType: CYLPlaceholderHUDMaskType = CYLPlaceholderHUDMaskType.None

    /** The content color for [CYLPlaceholderHUDStyle.Custom] (`foregroundColor`). */
    @ColorInt var foregroundColor: Int = Color.BLACK

    /** The box color for [CYLPlaceholderHUDStyle.Custom] (`hudBackgroundColor`). */
    @ColorInt var hudBackgroundColor: Int = Color.WHITE

    /** The mask color for [CYLPlaceholderHUDMaskType.Custom] (`backgroundLayerColor`). */
    @ColorInt var backgroundLayerColor: Int = Color.argb(0x66, 0, 0, 0)

    /** The status text size, in sp (`font`). */
    var font: Float = 15f

    /** The box's corner radius, in dp (`cornerRadius`). */
    var cornerRadius: Float = 14f

    /** The box's smallest size, in dp: width and height (`minimumSize`). */
    var minimumSize: FloatArray = floatArrayOf(100f, 100f)

    /** The icon's side, in dp (`animationSize`). */
    var animationSize: Float = 56f

    /** The box's offset from the container's center, in dp: x and y (`offsetFromCenter`). */
    var offsetFromCenter: FloatArray = floatArrayOf(0f, 0f)

    /** The animation shown while loading, played by a registered factory (`loadingAnimationFileName`). */
    var loadingAnimationFileName: String? = null

    /** The animation shown with progress (`progressAnimationFileName`). */
    var progressAnimationFileName: String? = null

    /** The animation shown on success (`successAnimationFileName`). */
    var successAnimationFileName: String? = null

    /** The success icon, or null for the built-in one (`successImage`). */
    var successImage: Drawable? = null

    /** The error icon, or null for the built-in one (`errorImage`). */
    var errorImage: Drawable? = null

    /** The info icon, or null for the built-in one (`infoImage`). */
    var infoImage: Drawable? = null

    /** Seconds a loading HUD waits before it shows, so a quick task shows none (`graceTimeInterval`). */
    var graceTimeInterval: Double = 0.0

    /** The shortest time a success / error / info HUD stays, in seconds (`minimumDismissTimeInterval`). */
    var minimumDismissTimeInterval: Double = 1.5

    /** The longest time it stays, in seconds (`maximumDismissTimeInterval`). */
    var maximumDismissTimeInterval: Double = 5.0

    /** The fade-in duration, in seconds (`fadeInAnimationDuration`). */
    var fadeInAnimationDuration: Double = 0.15

    /** The fade-out duration, in seconds (`fadeOutAnimationDuration`). */
    var fadeOutAnimationDuration: Double = 0.15

    /** Whether success and error vibrate (`hapticsEnabled`). */
    var hapticsEnabled: Boolean = false

    private val dismissRunnable = Runnable { dismiss() }
    private var graceRunnable: Runnable? = null

    init {
        hudView.addView(contentView, LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT))
        addView(hudView, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER))
    }

    override fun onTouchEvent(event: MotionEvent): Boolean = maskType != CYLPlaceholderHUDMaskType.None

    private val dark: Boolean
        get() = when (style) {
            CYLPlaceholderHUDStyle.Dark -> true
            CYLPlaceholderHUDStyle.Light, CYLPlaceholderHUDStyle.Custom -> false
            CYLPlaceholderHUDStyle.Automatic -> (resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
        }

    private val contentColor: Int
        get() = if (style == CYLPlaceholderHUDStyle.Custom) foregroundColor else if (dark) Color.WHITE else Color.BLACK

    private fun applyLook() {
        val boxColor = if (style == CYLPlaceholderHUDStyle.Custom) hudBackgroundColor else if (dark) Color.argb(0xE6, 0x1C, 0x1C, 0x1E) else Color.argb(0xF2, 0xFF, 0xFF, 0xFF)
        hudView.background = GradientDrawable().apply {
            setColor(boxColor)
            cornerRadius = dp(this@CYLPlaceholderHUD.cornerRadius).toFloat()
        }
        // A light box on a light page needs an edge: a soft shadow, as the system's HUD boxes have.
        hudView.elevation = dp(8f).toFloat()
        hudView.minimumWidth = dp(minimumSize[0])
        hudView.minimumHeight = dp(minimumSize[1])
        val padding = dp(16f)
        hudView.setPadding(padding, padding, padding, padding)
        hudView.translationX = offsetFromCenter[0] * density
        hudView.translationY = offsetFromCenter[1] * density
        background = when (maskType) {
            CYLPlaceholderHUDMaskType.None, CYLPlaceholderHUDMaskType.Clear -> null
            CYLPlaceholderHUDMaskType.Black -> GradientDrawable().apply { setColor(Color.argb(0x66, 0, 0, 0)) }
            CYLPlaceholderHUDMaskType.Gradient -> GradientDrawable().apply {
                gradientType = GradientDrawable.RADIAL_GRADIENT
                gradientRadius = max(resources.displayMetrics.widthPixels, resources.displayMetrics.heightPixels) / 2f
                colors = intArrayOf(Color.argb(0x22, 0, 0, 0), Color.argb(0x99, 0, 0, 0))
            }
            CYLPlaceholderHUDMaskType.Custom -> GradientDrawable().apply { setColor(backgroundLayerColor) }
        }
        isClickable = maskType != CYLPlaceholderHUDMaskType.None
    }

    private fun present() {
        val container = containerView ?: return
        applyLook()
        if (parent == null) {
            alpha = 0f
            container.addView(this, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
            animate().alpha(1f).setDuration((fadeInAnimationDuration * 1000).toLong()).start()
        }
        bringToFront()
    }

    private fun showContent(newState: CYLPlaceholderHUDState, content: View?, statusText: CharSequence?, icon: Drawable?, animation: String?) {
        handler.removeCallbacks(dismissRunnable)
        state = newState
        status = statusText
        contentView.removeAllViews()
        placeholderView = null
        val column = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
        }
        content?.let {
            (it.parent as? ViewGroup)?.removeView(it)
            val params = when (it) {
                spinner -> LinearLayout.LayoutParams(dp(animationSize), dp(animationSize))
                bar -> LinearLayout.LayoutParams(dp(160f), LayoutParams.WRAP_CONTENT)
                else -> LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT)
            }
            column.addView(it, params)
        }
        if (icon != null || !statusText.isNullOrEmpty()) {
            val view = CYLPlaceholderView(context, icon, statusText).apply {
                contentMargin = 0f
                defaultTitleColor = contentColor
                defaultIconColor = contentColor
                defaultTitleFont = font
                imageView.layoutParams = imageView.layoutParams.apply { width = dp(animationSize); height = dp(animationSize) }
                animation?.let { setAnimationFile(it); playPlaceholderAnimation() }
            }
            if (icon == null) view.imageView.visibility = GONE
            placeholderView = view
            column.addView(view)
        }
        contentView.addView(column)
        hudView.contentDescription = statusText
        present()
    }

    /** Shows a spinner (`show`); each call counts until [popActivity]. */
    fun show() = showWithStatus(null)

    /** Shows a spinner with [status] (`showWithStatus:`). */
    fun showWithStatus(status: CharSequence?) {
        activityCount++
        val start = Runnable {
            graceRunnable = null
            spinner.indeterminateTintList = android.content.res.ColorStateList.valueOf(contentColor)
            showContent(CYLPlaceholderHUDState.Loading, if (loadingAnimationFileName == null) spinner else null, status, null, loadingAnimationFileName)
        }
        if (graceTimeInterval > 0 && !visible) {
            graceRunnable?.let { handler.removeCallbacks(it) }
            graceRunnable = start
            handler.postDelayed(start, (graceTimeInterval * 1000).toLong())
        } else {
            start.run()
        }
    }

    /** Shows a progress bar at [progress], 0 to 1 (`showProgress:`). */
    fun showProgress(progress: Float) = showProgress(progress, status)

    /** Shows a progress bar at [progress] with [status] (`showProgress:status:`). */
    fun showProgress(progress: Float, status: CharSequence?) {
        this.progress = progress.coerceIn(0f, 1f)
        bar.progress = (this.progress * 1000).toInt()
        showContent(CYLPlaceholderHUDState.Progress, bar, status, null, progressAnimationFileName)
    }

    /** Changes the status text in place (`setStatus:`). */
    fun setStatus(status: CharSequence?) {
        this.status = status
        placeholderView?.textLabel?.apply {
            text = status
            visibility = if (status.isNullOrEmpty()) GONE else VISIBLE
        }
        hudView.contentDescription = status
    }

    private fun showTimed(newState: CYLPlaceholderHUDState, icon: Drawable?, status: CharSequence?, animation: String? = null) {
        activityCount = 0
        graceRunnable?.let { handler.removeCallbacks(it) }
        showContent(newState, null, status, icon, animation)
        if (hapticsEnabled && (newState == CYLPlaceholderHUDState.Success || newState == CYLPlaceholderHUDState.Error)) {
            performHapticFeedback(HapticFeedbackConstants.CONFIRM)
        }
        handler.postDelayed(dismissRunnable, (displayDurationForString(status) * 1000).toLong())
    }

    /** Shows the info icon with [status], then hides (`showInfoWithStatus:`). */
    fun showInfoWithStatus(status: CharSequence?) =
        showTimed(CYLPlaceholderHUDState.Info, infoImage ?: CYLPlaceholderView.imageForStyle(context, CYLPlaceholderStyle.Info), status)

    /** Shows the success icon with [status], then hides (`showSuccessWithStatus:`). */
    fun showSuccessWithStatus(status: CharSequence?) =
        showTimed(CYLPlaceholderHUDState.Success, successImage ?: CYLPlaceholderView.imageForStyle(context, CYLPlaceholderStyle.Info), status, successAnimationFileName)

    /** Shows the error icon with [status], then hides (`showErrorWithStatus:`). */
    fun showErrorWithStatus(status: CharSequence?) =
        showTimed(CYLPlaceholderHUDState.Error, errorImage ?: CYLPlaceholderView.imageForStyle(context, CYLPlaceholderStyle.Error), status)

    /** Shows [image] with [status], then hides (`showImage:status:`). */
    fun showImage(image: Drawable?, status: CharSequence?) = showTimed(CYLPlaceholderHUDState.Image, image, status)

    /** Shows your [components]; [actions] handle their buttons (`showComponents:actions:`). */
    fun showComponents(components: List<CYLPlaceholderComponent>, actions: Map<String, CYLPlaceholderActionHandler>?) {
        this.actions = actions.orEmpty()
        showContent(CYLPlaceholderHUDState.Custom, CYLPlaceholderStackView(context, components, actions), null, null, null)
    }

    /** Shows [scenario]; [actions] handle its buttons (`showScenario:actions:`). */
    fun showScenario(scenario: CYLPlaceholderScenario, actions: Map<String, CYLPlaceholderActionHandler>?) {
        this.actions = actions.orEmpty()
        showContent(CYLPlaceholderHUDState.Custom, CYLPlaceholderStackView(context, scenario, actions), null, null, null)
    }

    /** Ends one [show]; the HUD hides once every one has ended (`popActivity`). */
    fun popActivity() {
        if (activityCount > 0) activityCount--
        if (activityCount == 0) dismiss()
    }

    /** Hides at once (`dismiss`). */
    fun dismiss() = dismissWithDelay(0.0, null)

    /** Hides, then calls [completion] (`dismissWithCompletion:`). */
    fun dismissWithCompletion(completion: CYLPlaceholderHUDDismissCompletion?) = dismissWithDelay(0.0, completion)

    /** Hides after [delay] seconds (`dismissWithDelay:`). */
    fun dismissWithDelay(delay: Double) = dismissWithDelay(delay, null)

    /** Hides after [delay] seconds, then calls [completion] (`dismissWithDelay:completion:`). */
    fun dismissWithDelay(delay: Double, completion: CYLPlaceholderHUDDismissCompletion?) {
        handler.removeCallbacks(dismissRunnable)
        graceRunnable?.let { handler.removeCallbacks(it); graceRunnable = null }
        handler.postDelayed({
            activityCount = 0
            val finish = Runnable {
                (parent as? ViewGroup)?.removeView(this)
                state = CYLPlaceholderHUDState.Hidden
                placeholderView?.stopPlaceholderAnimation()
                completion?.invoke()
            }
            if (parent == null) finish.run() else animate().alpha(0f).setDuration((fadeOutAnimationDuration * 1000).toLong()).withEndAction(finish).start()
        }, (delay * 1000).toLong())
    }

    /** How long a timed HUD with [string] stays, in seconds (`displayDurationForString:`). */
    fun displayDurationForString(string: CharSequence?): Double =
        min(max((string?.length ?: 0) * 0.06 + 0.5, minimumDismissTimeInterval), maximumDismissTimeInterval)

    /**
     * The shared HUD and its class-level calls (the iOS class methods).
     */
    companion object {
        private var shared: CYLPlaceholderHUD? = null

        /**
         * The shared HUD for [containerView]'s window; set its container once (`sharedHUD`).
         */
        @JvmStatic
        fun sharedHUD(containerView: ViewGroup): CYLPlaceholderHUD {
            val hud = shared?.takeIf { it.context === containerView.context } ?: CYLPlaceholderHUD(containerView.context, containerView).also { shared = it }
            hud.containerView = containerView
            return hud
        }

        private fun current() = shared

        /** [show] on the shared HUD. */
        fun show() { current()?.show() }
        /** [showWithStatus] on the shared HUD. */
        fun showWithStatus(status: CharSequence?) { current()?.showWithStatus(status) }
        /** [showProgress] on the shared HUD. */
        fun showProgress(progress: Float) { current()?.showProgress(progress) }
        /** [showProgress] with a status on the shared HUD. */
        fun showProgress(progress: Float, status: CharSequence?) { current()?.showProgress(progress, status) }
        /** [setStatus] on the shared HUD. */
        fun setStatus(status: CharSequence?) { current()?.setStatus(status) }
        /** [showInfoWithStatus] on the shared HUD. */
        fun showInfoWithStatus(status: CharSequence?) { current()?.showInfoWithStatus(status) }
        /** [showSuccessWithStatus] on the shared HUD. */
        fun showSuccessWithStatus(status: CharSequence?) { current()?.showSuccessWithStatus(status) }
        /** [showErrorWithStatus] on the shared HUD. */
        fun showErrorWithStatus(status: CharSequence?) { current()?.showErrorWithStatus(status) }
        /** [showImage] on the shared HUD. */
        fun showImage(image: Drawable?, status: CharSequence?) { current()?.showImage(image, status) }
        /** [popActivity] on the shared HUD. */
        fun popActivity() { current()?.popActivity() }
        /** [dismiss] on the shared HUD. */
        fun dismiss() { current()?.dismiss() }
        /** [dismissWithCompletion] on the shared HUD. */
        fun dismissWithCompletion(completion: CYLPlaceholderHUDDismissCompletion?) { current()?.dismissWithCompletion(completion) }
        /** [dismissWithDelay] on the shared HUD. */
        fun dismissWithDelay(delay: Double) { current()?.dismissWithDelay(delay) }
        /** [dismissWithDelay] with a completion on the shared HUD. */
        fun dismissWithDelay(delay: Double, completion: CYLPlaceholderHUDDismissCompletion?) { current()?.dismissWithDelay(delay, completion) }
        /** Whether the shared HUD is on screen (`isVisible`). */
        @JvmStatic fun isVisible(): Boolean = current()?.visible == true
        /** [displayDurationForString] of the shared HUD (default limits without one). */
        fun displayDurationForString(string: CharSequence?): Double =
            current()?.displayDurationForString(string) ?: min(max((string?.length ?: 0) * 0.06 + 0.5, 1.5), 5.0)
    }
}
