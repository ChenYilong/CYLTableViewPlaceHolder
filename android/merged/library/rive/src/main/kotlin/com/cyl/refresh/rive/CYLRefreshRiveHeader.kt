package com.cyl.refresh.rive

import android.animation.ValueAnimator
import android.annotation.SuppressLint
import android.content.Context
import android.graphics.SurfaceTexture
import android.util.Log
import android.view.View
import app.rive.runtime.kotlin.RiveAnimationView
import app.rive.runtime.kotlin.core.Direction
import app.rive.runtime.kotlin.core.Fit
import app.rive.runtime.kotlin.core.Loop
import app.rive.runtime.kotlin.core.Rive
import com.cyl.refresh.CYLRefreshDrawnHeader
import com.cyl.refresh.CYLRefreshPhase
import com.cyl.refresh.CYLRefreshScrollMode
import com.cyl.refresh.layout.api.RefreshHeader
import com.cyl.refresh.layout.simple.SimpleComponent
import java.io.File
import kotlin.math.max
import kotlin.math.min

/*
 * The Rive refresh header, translated from the iOS port (`RiveSwift/CYLRefreshRiveHeader.swift`) to Kotlin on
 * rive-android. The styles are flutter_easy_refresh's Rive style packages (MIT).
 */

/**
 * How a Rive file is driven by the pull, the refresh and its end (iOS `CYLRefreshRiveStyle`). Every name is optional;
 * unset ones are skipped.
 */
class CYLRefreshRiveStyle(
    /**
     * The .riv file: "asset:name" in the app's assets, or a path (`fileURL`).
     */
    val fileURL: String,
) {
    /** The artboard; null uses the default artboard (`artboardName`). */
    var artboardName: String? = null

    /** The state machine that the inputs belong to (`stateMachineName`). */
    var stateMachineName: String? = null

    /** Pull distance in dp that counts as fully pulled; also the header's open height (`triggerOffset`). */
    var triggerOffset: Float = 180f

    /** Smallest height in dp the animation is laid out in while it grows with the pull; 0 uses [triggerOffset]. */
    var minimumHeight: Float = 0f

    /** True fits the artboard to the width (Rive `FIT_WIDTH`); false covers the area (`COVER`, default). */
    var fitsWidth: Boolean = false

    /** Number input set from the pull (`pullInput`). */
    var pullInput: String? = null

    /** Value of [pullInput] just above no pull; no pull is always 0 (`pullInputMinimum`). */
    var pullInputMinimum: Double = 0.0

    /** Value of [pullInput] when fully pulled (`pullInputMaximum`). */
    var pullInputMaximum: Double = 100.0

    /** Fraction of [triggerOffset] pulled before [pullInput] starts to rise (`pullInputStart`). */
    var pullInputStart: Double = 0.0

    /** Value of [pullInput] while refreshing; negative keeps [pullInputMaximum] (`pullInputRefreshingValue`). */
    var pullInputRefreshingValue: Double = -1.0

    /** Trigger fired on release (`releaseTrigger`). */
    var releaseTrigger: String? = null

    /** Trigger fired when the refresh ends (`finishTrigger`). */
    var finishTrigger: String? = null

    /** Trigger fired before the next pull, after the file was reset (`restartTrigger`). */
    var restartTrigger: String? = null

    /**
     * Longest time in seconds the header stays open after the refresh ends so that the end of the animation ([finishTrigger] or the [loadingNumber]
     * finished value) can play; ignored when the style has neither. Default 1.5 (`finishTimeout`).
     */
    var finishTimeout: Double = 1.5

    /** Whether the style has an end part to play: a [finishTrigger] or a [loadingNumber]. */
    val playsFinish: Boolean get() = finishTrigger != null || loadingNumber != null

    /** Boolean input that is true from the release until the header is idle again (`loadingBoolean`). */
    var loadingBoolean: String? = null

    /** Number input that rises to [loadingNumberMaximum] while refreshing (`loadingNumber`). */
    var loadingNumber: String? = null

    /** Top value of [loadingNumber] while refreshing (`loadingNumberMaximum`). */
    var loadingNumberMaximum: Double = 99.0

    /** Value of [loadingNumber] when the refresh ends (`loadingNumberFinished`). */
    var loadingNumberFinished: Double = 100.0

    /** Seconds for [loadingNumber] to reach its top value (`loadingNumberDuration`). */
    var loadingNumberDuration: Double = 2.0

    /** Linear animation scrubbed by the pull: its time in seconds is the pulled fraction (`pullAnimation`). */
    var pullAnimation: String? = null

    /** Linear animation played once on release, before [loadingAnimation] (`triggerAnimation`). */
    var triggerAnimation: String? = null

    /** Linear animation looped while refreshing (`loadingAnimation`). */
    var loadingAnimation: String? = null

    /** Linear animation looped while pulling and idle (`idleAnimation`). */
    var idleAnimation: String? = null

    /**
     * [pullInput] for a pull of [offset] dp (`pullValueWithOffset:`).
     */
    fun pullValue(offset: Float): Double {
        val trigger = max(1f, triggerOffset).toDouble()
        val start = trigger * pullInputStart.coerceIn(0.0, 0.99)
        val progress = ((offset - start) / (trigger - start)).coerceIn(0.0, 1.0)
        if (progress == 0.0) return 0.0
        return pullInputMinimum + progress * (pullInputMaximum - pullInputMinimum)
    }

    internal fun bytes(context: Context): ByteArray? = runCatching {
        if (fileURL.startsWith(ASSET)) context.assets.open(fileURL.removePrefix(ASSET)).use { it.readBytes() }
        else File(fileURL.removePrefix("file://")).readBytes()
    }.getOrNull()

    private companion object {
        const val ASSET = "asset:"
    }
}

/**
 * The header view: a Rive view laid out in at least the style's minimum height, aligned to the bottom, so the art
 * grows with the pull.
 */
@SuppressLint("ViewConstructor")
internal class CYLRiveHeaderView(context: Context, private val style: CYLRefreshRiveStyle) :
    SimpleComponent(context, null, 0), RefreshHeader {

    /**
     * Called when the Rive surface appears or changes size: rive-android draws only while something plays, so a state
     * machine that has settled leaves a new surface black until it is played again.
     */
    var surfaceChanged: (() -> Unit)? = null

    val rive: RiveAnimationView = object : RiveAnimationView(context, null) {
        override fun onSurfaceTextureAvailable(surface: SurfaceTexture, width: Int, height: Int) {
            super.onSurfaceTextureAvailable(surface, width, height)
            post { surfaceChanged?.invoke() }
        }

        override fun onSurfaceTextureSizeChanged(surface: SurfaceTexture, width: Int, height: Int) {
            super.onSurfaceTextureSizeChanged(surface, width, height)
            post { surfaceChanged?.invoke() }
        }

        // The pull gesture belongs to the list: RiveAnimationView consumes every touch.
        @android.annotation.SuppressLint("ClickableViewAccessibility")
        override fun onTouchEvent(event: android.view.MotionEvent): Boolean = false
    }

    /** Milliseconds the layout keeps the header open after the refresh ended (set by the header: the finish rule). */
    var finishHold: (Boolean) -> Int = { 0 }

    // The layout waits this long before it collapses the header and the header goes idle (which resets the state machine).
    override fun onFinish(refreshLayout: com.cyl.refresh.layout.api.RefreshLayout, success: Boolean): Int = finishHold(success)

    init {
        addView(rive)
        importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS
        clipChildren = true
    }

    private val minimum: Int
        get() = ((if (style.minimumHeight > 0) style.minimumHeight else style.triggerOffset) * resources.displayMetrics.density).toInt()

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        measureRive(measuredWidth, measuredHeight)
    }

    // The layout stretches the header by laying it out taller or shorter without measuring it again, so the Rive view is
    // sized here from the bounds it actually gets: at least the minimum height, aligned to the bottom.
    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        val width = r - l
        val height = b - t
        measureRive(width, height)
        rive.layout(0, height - rive.measuredHeight, width, height)
    }

    private fun measureRive(width: Int, height: Int) {
        val target = max(height, minimum)
        if (rive.measuredWidth == width && rive.measuredHeight == target && !rive.isLayoutRequested) return
        rive.measure(MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(target, MeasureSpec.EXACTLY))
    }
}

/**
 * A refresh header drawn by a Rive file (iOS `CYLRefreshRiveHeader`, flutter_easy_refresh's Rive styles). It grows
 * with the pull and keeps the art laid out in at least [CYLRefreshRiveStyle.minimumHeight]. Make it with [create],
 * which returns null when the file cannot be read.
 */
class CYLRefreshRiveHeader private constructor(
    private val headerView: CYLRiveHeaderView,
    /**
     * The style this header was made with (`riveStyle`).
     */
    val riveStyle: CYLRefreshRiveStyle,
) : CYLRefreshDrawnHeader(headerView) {

    private val rive get() = headerView.rive
    private var rivePlaysRefresh = false
    private var loadingAnimator: ValueAnimator? = null
    private val density get() = headerView.resources.displayMetrics.density

    init {
        headerView.surfaceChanged = ::redraw
        headerView.finishHold = { success -> (finishingDurationWithSuccess(success) * 1000).toInt().coerceAtLeast(0) }
    }

    /**
     * Plays the state machine (or the looping animation) again, so the new surface gets frames.
     */
    private fun redraw() {
        val machine = riveStyle.stateMachineName
        val idle = riveStyle.idleAnimation
        val loading = riveStyle.loadingAnimation
        runCatching {
            when {
                machine != null -> rive.play(machine, Loop.AUTO, Direction.AUTO, true, false)
                rivePlaysRefresh && loading != null -> playLinear(loading, Loop.LOOP)
                idle != null -> playLinear(idle, Loop.LOOP)
                else -> rive.controller.advance(0f)
            }
        }
    }

    override fun setUpComponent() {
        scrollMode = CYLRefreshScrollMode.Stretch
        setExpandHeight(riveStyle.triggerOffset)
    }

    override fun onScrollingWithOffset(offset: Int, percent: Float, drag: Boolean) {
        if (rivePlaysRefresh) return
        val dp = offset / density
        if (Log.isLoggable(TAG, Log.DEBUG)) Log.d(TAG, "rive pull offset=${offset}px ${dp}dp input=${riveStyle.pullValue(dp)} view=${headerView.width}x${headerView.height}@${loc(headerView)} rive=${rive.width}x${rive.height}@${loc(rive)}")
        riveStyle.pullInput?.let { number(it, riveStyle.pullValue(dp)) }
        val pull = riveStyle.pullAnimation
        if (pull != null && riveStyle.idleAnimation == null) scrub(pull, (dp / max(1f, riveStyle.triggerOffset)).coerceIn(0f, 1f))
    }

    private fun loc(view: View): String = IntArray(2).also { view.getLocationOnScreen(it) }.let { "${it[0]},${it[1]}" }

    /** The finish rule: [CYLRefreshRiveStyle.finishTimeout] (at least the host's `finishDuration`) when the style has an end part, else `finishDuration`. */
    override fun finishingDurationWithSuccess(success: Boolean): Double =
        if (riveStyle.playsFinish) max(riveStyle.finishTimeout, finishDuration) else finishDuration

    override fun onStatus(oldStatus: CYLRefreshPhase, status: CYLRefreshPhase) {
        val style = riveStyle
        if (Log.isLoggable(TAG, Log.DEBUG)) Log.d(TAG, "rive status $oldStatus -> $status playsRefresh=$rivePlaysRefresh")
        when (status) {
            CYLRefreshPhase.Releasing, CYLRefreshPhase.Refreshing -> {
                if (rivePlaysRefresh) return
                rivePlaysRefresh = true
                style.pullInput?.let { number(it, if (style.pullInputRefreshingValue >= 0) style.pullInputRefreshingValue else style.pullInputMaximum) }
                style.releaseTrigger?.let(::fire)
                style.loadingBoolean?.let { boolean(it, true) }
                if (style.loadingNumber != null) startLoadingNumber()
                val trigger = style.triggerAnimation
                val loading = style.loadingAnimation
                if (trigger != null) {
                    playLinear(trigger, Loop.ONESHOT)
                    val seconds = rive.controller.animations.firstOrNull { it.name == trigger }?.effectiveDurationInSeconds ?: 0.5f
                    headerView.postDelayed({ if (rivePlaysRefresh && loading != null) playLinear(loading, Loop.LOOP) }, (seconds * 1000).toLong())
                } else if (loading != null) {
                    playLinear(loading, Loop.LOOP)
                }
            }
            CYLRefreshPhase.Finishing -> {
                stopLoadingNumber()
                style.loadingNumber?.let { number(it, style.loadingNumberFinished) }
                style.finishTrigger?.let(::fire)
            }
            CYLRefreshPhase.Idle -> {
                if (!rivePlaysRefresh) return
                rivePlaysRefresh = false
                reset()
            }
            else -> Unit
        }
    }

    private fun reset() {
        val style = riveStyle
        stopLoadingNumber()
        runCatching { rive.reset() }
        style.loadingBoolean?.let { boolean(it, false) }
        style.pullInput?.let { number(it, 0.0) }
        style.loadingNumber?.let { number(it, 0.0) }
        style.restartTrigger?.let(::fire)
        val idle = style.idleAnimation
        val pull = style.pullAnimation
        when {
            idle != null -> playLinear(idle, Loop.LOOP)
            pull != null -> scrub(pull, 0f)
            else -> runCatching { rive.play(Loop.AUTO, Direction.AUTO, true) }
        }
    }

    private fun startLoadingNumber() {
        val input = riveStyle.loadingNumber ?: return
        stopLoadingNumber()
        loadingAnimator = ValueAnimator.ofFloat(0f, riveStyle.loadingNumberMaximum.toFloat()).apply {
            duration = (riveStyle.loadingNumberDuration * 1000).toLong()
            addUpdateListener { number(input, (it.animatedValue as Float).toDouble()) }
            start()
        }
    }

    private fun stopLoadingNumber() {
        loadingAnimator?.cancel()
        loadingAnimator = null
    }

    // State machine inputs: a missing input or state machine is skipped, as RiveRuntime only logs on iOS.

    private fun number(input: String, value: Double) {
        val machine = riveStyle.stateMachineName ?: return
        runCatching { rive.setNumberState(machine, input, value.toFloat()) }
    }

    private fun boolean(input: String, value: Boolean) {
        val machine = riveStyle.stateMachineName ?: return
        runCatching { rive.setBooleanState(machine, input, value) }
    }

    private fun fire(input: String) {
        val machine = riveStyle.stateMachineName ?: return
        runCatching { rive.fireState(machine, input) }
    }

    private fun playLinear(animation: String, loop: Loop) {
        runCatching { rive.play(animation, loop, Direction.AUTO, false, true) }
    }

    /**
     * Shows [animation] at [time] seconds, paused.
     */
    private fun scrub(animation: String, time: Float) {
        runCatching {
            val controller = rive.controller
            if (controller.animations.none { it.name == animation }) rive.play(animation, Loop.ONESHOT, Direction.AUTO, false, true)
            rive.pause()
            controller.animations.firstOrNull { it.name == animation }?.let { instance ->
                instance.time(min(time, instance.effectiveDurationInSeconds))
                instance.apply()
            }
            controller.advance(0f)
        }
    }

    companion object {
        /** The permanent diagnostic log tag (`adb shell setprop log.tag.CYLRefreshView DEBUG`). */
        private const val TAG = "CYLRefreshView"

        @Volatile private var riveInitialized = false

        // rive-android needs Rive.init before its first view; its androidx.startup initializer is not in every app
        // (the module that used to call it, placeholder-rive, is gone): called once here.
        private fun initializeRive(context: Context) {
            if (riveInitialized) return
            riveInitialized = true
            runCatching { Rive.init(context.applicationContext) }
        }

        /**
         * A header drawn by [style]; null when the file cannot be read (iOS `initWithStyle:`).
         */
        @JvmStatic
        fun create(context: Context, style: CYLRefreshRiveStyle): CYLRefreshRiveHeader? {
            val bytes = style.bytes(context) ?: return null
            initializeRive(context)
            val view = CYLRiveHeaderView(context, style)
            val fit = if (style.fitsWidth) Fit.FIT_WIDTH else Fit.COVER
            val loaded = runCatching {
                if (style.stateMachineName != null) {
                    view.rive.setRiveBytes(bytes, artboardName = style.artboardName, stateMachineName = style.stateMachineName,
                        autoplay = true, fit = fit)
                } else {
                    view.rive.setRiveBytes(bytes, artboardName = style.artboardName, animationName = style.idleAnimation ?: style.pullAnimation,
                        autoplay = style.idleAnimation != null, fit = fit)
                }
            }.isSuccess
            return if (loaded) CYLRefreshRiveHeader(view, style) else null
        }
    }
}
