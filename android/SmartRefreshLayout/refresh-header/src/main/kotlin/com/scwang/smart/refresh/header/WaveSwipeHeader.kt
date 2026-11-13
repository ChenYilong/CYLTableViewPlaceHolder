// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header

import android.animation.ValueAnimator
import android.content.Context
import android.content.res.Resources
import android.util.AttributeSet
import android.view.View.MeasureSpec.EXACTLY
import android.view.View.MeasureSpec.getSize
import android.view.View.MeasureSpec.makeMeasureSpec
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.Animation
import android.view.animation.Transformation
import androidx.annotation.ColorInt
import androidx.annotation.ColorRes
import androidx.appcompat.widget.AppCompatImageView
import androidx.core.content.ContextCompat
import com.scwang.smart.refresh.header.material.MaterialProgressDrawable
import com.scwang.smart.refresh.header.waveswipe.WaveView
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.simple.SimpleComponent
import com.scwang.smart.refresh.layout.util.SmartUtil
import kotlin.math.max
import kotlin.math.min

/**
 * A full-screen wave that drops a spinning circle, from WaveSwipeRefreshLayout (`WaveSwipeHeader`).
 */
open class WaveSwipeHeader @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    SimpleComponent(context, attrs, 0), RefreshHeader {

    /**
     * The drag thresholds between the wave's phases.
     */
    protected enum class VERTICAL_DRAG_THRESHOLD(
        /**
         * The threshold, as a share of the view.
         */
        @JvmField val `val`: Float,
    ) {
        /**
         * The circle appears.
         */
        FIRST(0.1f),

        /**
         * The wave expands.
         */
        SECOND(0.16f + 0.1f),

        /**
         * The circle drops.
         */
        THIRD(0.5f + 0.1f),
    }

    /**
     * The wave.
     */
    @JvmField protected var mWaveView: WaveView

    /**
     * The layout's state.
     */
    @JvmField protected var mState: RefreshState? = null

    /**
     * The spinner in the circle.
     */
    protected lateinit var mProgress: MaterialProgressDrawable

    /**
     * The circle's view.
     */
    @JvmField protected var mCircleView: ProgressAnimationImageView

    /**
     * The latest drag bound, for the wave going back.
     */
    @JvmField protected var mLastFirstBounds = 0f

    init {
        mSpinnerStyle = SpinnerStyle.MatchLayout
        mWaveView = WaveView(context)
        addView(mWaveView)
        mCircleView = ProgressAnimationImageView(context)
        addView(mCircleView)
        val ta = context.obtainStyledAttributes(attrs, R.styleable.WaveSwipeHeader)
        var primaryColor = ta.getColor(R.styleable.WaveSwipeHeader_srlPrimaryColor, 0)
        var accentColor = ta.getColor(R.styleable.WaveSwipeHeader_srlAccentColor, 0)
        if (ta.hasValue(R.styleable.WaveSwipeHeader_wshPrimaryColor)) primaryColor = ta.getColor(R.styleable.WaveSwipeHeader_wshPrimaryColor, 0)
        if (ta.hasValue(R.styleable.WaveSwipeHeader_wshAccentColor)) accentColor = ta.getColor(R.styleable.WaveSwipeHeader_wshAccentColor, 0)
        if (primaryColor != 0) mWaveView.setWaveColor(primaryColor)
        mProgress.setColorSchemeColors(if (accentColor != 0) accentColor else 0xffffffff.toInt())
        if (ta.hasValue(R.styleable.WaveSwipeHeader_srlShadowRadius)) {
            mWaveView.setShadow(
                ta.getDimensionPixelOffset(R.styleable.WaveSwipeHeader_srlShadowRadius, 0),
                ta.getColor(R.styleable.WaveSwipeHeader_srlShadowColor, 0xff000000.toInt()),
            )
        }
        if (ta.hasValue(R.styleable.WaveSwipeHeader_wshShadowRadius)) {
            mWaveView.setShadow(
                ta.getDimensionPixelOffset(R.styleable.WaveSwipeHeader_wshShadowRadius, 0),
                ta.getColor(R.styleable.WaveSwipeHeader_wshShadowColor, 0xff000000.toInt()),
            )
        }
        ta.recycle()
        initRefreshAccessibility()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.setMeasuredDimension(getSize(widthMeasureSpec), getSize(heightMeasureSpec))
        val spec = makeMeasureSpec(mProgress.intrinsicWidth, EXACTLY)
        mCircleView.measure(spec, spec)
        mWaveView.measure(makeMeasureSpec(getSize(widthMeasureSpec), EXACTLY), makeMeasureSpec(getSize(heightMeasureSpec), EXACTLY))
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        mWaveView.layout(0, 0, measuredWidth, measuredHeight)
        val thisWidth = measuredWidth
        val circleWidth = mCircleView.measuredWidth
        val circleHeight = mCircleView.measuredHeight
        mCircleView.layout((thisWidth - circleWidth) / 2, -circleHeight, (thisWidth + circleWidth) / 2, 0)
        if (isInEditMode) onMoving(true, 0.99f, SmartUtil.dp2px(99f), SmartUtil.dp2px(100f), SmartUtil.dp2px(100f))
    }

    /**
     * The spinner's colors.
     */
    open fun setColorSchemeColors(vararg colors: Int) {
        mProgress.setColorSchemeColors(*colors)
    }

    /**
     * The spinner's colors, as color resources.
     */
    open fun setColorSchemeColorIds(@ColorRes vararg resources: Int) {
        // Each resource in turn (the Java version read resources[1] for every color, and threw for a single one).
        mProgress.setColorSchemeColors(*IntArray(resources.size) { ContextCompat.getColor(context, resources[it]) })
    }

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        if (isDragging) {
            if (mState == RefreshState.Refreshing) return
            val dragPercent = min(1f, percent)
            val adjustedPercent = max(dragPercent - .4f, 0f) * 5 / 3
            // 0 to 2.
            val tensionSlingshotPercent = if (percent > 3f) 2f else if (percent > 1f) percent - 1f else 0f
            val tensionPercent = (4f - tensionSlingshotPercent) * tensionSlingshotPercent / 8f
            if (percent < 1f) {
                mProgress.setStartEndTrim(0f, min(MAX_PROGRESS_ROTATION_RATE, adjustedPercent * .8f))
                mProgress.setArrowScale(min(1f, adjustedPercent))
            }
            mProgress.setProgressRotation((-0.25f + .4f * adjustedPercent + tensionPercent * 2) * .5f)
            mCircleView.translationY = mWaveView.getCurrentCircleCenterY()
            // max(1, …): an unmeasured header divided by zero in the Java version.
            val seed = 1f * offset / max(1, min(measuredWidth, measuredHeight))
            val firstBounds = seed * (5f - 2 * seed) / 3.5f
            val secondBounds = firstBounds - VERTICAL_DRAG_THRESHOLD.FIRST.`val`
            val finalBounds = (firstBounds - VERTICAL_DRAG_THRESHOLD.SECOND.`val`) / 5
            mLastFirstBounds = firstBounds
            when {
                // A wave without a circle.
                firstBounds < VERTICAL_DRAG_THRESHOLD.FIRST.`val` -> mWaveView.beginPhase(firstBounds)
                // A circle with a wave.
                firstBounds < VERTICAL_DRAG_THRESHOLD.SECOND.`val` -> mWaveView.appearPhase(firstBounds, secondBounds)
                // A circle with an expanding wave.
                else -> mWaveView.expandPhase(firstBounds, secondBounds, finalBounds)
            }
        } else if (mLastFirstBounds != 0f && mState == RefreshState.None) {
            mProgress.showArrow(false)
            mProgress.setProgressRotation(0f)
            mProgress.setStartEndTrim(0f, 0f)
            mWaveView.startWaveAnimation(mLastFirstBounds)
            mLastFirstBounds = 0f
        }
    }

    override fun onReleased(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        mLastFirstBounds = 0f
        mWaveView.animationDropCircle()
        mProgress.alpha = 0xff
        mProgress.start()
        ValueAnimator.ofFloat(0f, 0f).apply {
            duration = 500
            interpolator = AccelerateDecelerateInterpolator()
            addUpdateListener { mCircleView.translationY = mWaveView.getCurrentCircleCenterY() + mCircleView.height / 2f }
            start()
        }
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        mState = newState
        when (newState) {
            RefreshState.PullDownToRefresh -> {
                mProgress.showArrow(true)
                mCircleView.scaleX = 1f
                mCircleView.scaleY = 1f
                mProgress.alpha = 0xff
            }
            RefreshState.PullDownCanceled -> {
                mProgress.showArrow(false)
                mProgress.setProgressRotation(0f)
                mProgress.setStartEndTrim(0f, 0f)
                mWaveView.startWaveAnimation(mLastFirstBounds)
                mLastFirstBounds = 0f
            }
            else -> Unit
        }
        updateRefreshAccessibility(newState)
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        val circleView = mCircleView
        val scaleDownAnimation = object : Animation() {
            override fun applyTransformation(interpolatedTime: Float, t: Transformation) {
                circleView.scaleX = 1 - interpolatedTime
                circleView.scaleY = 1 - interpolatedTime
            }
        }
        scaleDownAnimation.duration = 200
        circleView.setAnimationListener(object : Animation.AnimationListener {
            override fun onAnimationStart(animation: Animation?) {}
            override fun onAnimationRepeat(animation: Animation?) {}
            override fun onAnimationEnd(animation: Animation?) {
                mProgress.stop()
                mProgress.alpha = 0xff
                mWaveView.startDisappearCircleAnimation()
            }
        })
        circleView.clearAnimation()
        circleView.startAnimation(scaleDownAnimation)
        return 0
    }

    @Deprecated("Only called by the layout; use RefreshLayout.setPrimaryColorsId.")
    override fun setPrimaryColors(@ColorInt vararg colors: Int) {
        if (colors.isNotEmpty()) {
            mWaveView.setWaveColor(colors[0])
            if (colors.size > 1) mProgress.setColorSchemeColors(colors[1])
        }
    }

    /**
     * The circle with the spinner; reports its view animation's start and end (`ProgressAnimationImageView`, by
     * jmatsu).
     */
    protected open inner class ProgressAnimationImageView(context: Context) : AppCompatImageView(context) {

        /**
         * Hears the view animation's start and end.
         */
        @JvmField protected var mListener: Animation.AnimationListener? = null

        init {
            mProgress = MaterialProgressDrawable(this@WaveSwipeHeader)
            // A bigger spinner on large screens.
            if (isOver600dp()) mProgress.updateSizes(MaterialProgressDrawable.LARGE.toInt())
            super.setImageDrawable(mProgress)
            importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        }

        /**
         * The listener for the view animation's start and end.
         */
        open fun setAnimationListener(listener: Animation.AnimationListener?) {
            mListener = listener
        }

        override fun onAnimationStart() {
            super.onAnimationStart()
            mListener?.onAnimationStart(animation)
        }

        override fun onAnimationEnd() {
            super.onAnimationEnd()
            mListener?.onAnimationEnd(animation)
        }
    }

    /**
     * The spinner's largest arc and the screen-size check.
     */
    companion object {
        /**
         * The arrow's largest sweep before the drop.
         */
        @JvmStatic protected val MAX_PROGRESS_ROTATION_RATE = 0.8f

        /**
         * True when the screen is at least 600 dp wide.
         */
        @JvmStatic
        fun isOver600dp(): Boolean {
            val displayMetrics = Resources.getSystem().displayMetrics
            return displayMetrics.widthPixels / displayMetrics.density >= 600
        }
    }
}
