// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header

import android.animation.Animator
import android.animation.AnimatorSet
import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.util.AttributeSet
import android.view.animation.AccelerateDecelerateInterpolator
import androidx.annotation.ColorInt
import androidx.annotation.ColorRes
import androidx.core.content.ContextCompat
import com.scwang.smart.refresh.header.radar.R
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.simple.SimpleComponent
import com.scwang.smart.refresh.layout.util.SmartUtil
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sqrt

/**
 * The header with a Bezier wave, a row of dots and a radar while refreshing (`BezierRadarHeader`).
 */
open class BezierRadarHeader @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    SimpleComponent(context, attrs, 0), RefreshHeader {

    /**
     * The dots', radar's and ripple's color.
     */
    @JvmField protected var mAccentColor = 0

    /**
     * The wave's color.
     */
    @JvmField protected var mPrimaryColor = 0

    /**
     * True once the app set the primary color.
     */
    @JvmField protected var mManualPrimaryColor = false

    /**
     * True once the app set the accent color.
     */
    @JvmField protected var mManualAccentColor = false

    /**
     * True while the wave follows the finger.
     */
    @JvmField protected var mWavePulling = false

    /**
     * Moves the wave's peak with a horizontal drag. Default false.
     */
    @JvmField protected var mEnableHorizontalDrag = false

    /**
     * The wave's path.
     */
    @JvmField protected var mPath = Path()

    /**
     * The paint.
     */
    @JvmField protected var mPaint = Paint().apply { isAntiAlias = true }

    /**
     * The wave's top.
     */
    @JvmField protected var mWaveTop = 0

    /**
     * The wave's height.
     */
    @JvmField protected var mWaveHeight = 0

    /**
     * The wave peak's x, or -1 for the center.
     */
    @JvmField protected var mWaveOffsetX = -1

    /**
     * The header's offset.
     */
    @JvmField protected var mWaveOffsetY = 0

    /**
     * The dots' alpha, 0 to 1.
     */
    @JvmField protected var mDotAlpha = 0f

    /**
     * The dots' spread.
     */
    @JvmField protected var mDotFraction = 0f

    /**
     * The dots' radius.
     */
    @JvmField protected var mDotRadius: Float

    /**
     * The finishing ripple's radius.
     */
    @JvmField protected var mRippleRadius = 0f

    /**
     * The radar sweep's angle.
     */
    @JvmField protected var mRadarAngle = 0

    /**
     * The radar's radius.
     */
    @JvmField protected var mRadarRadius: Float

    /**
     * The radar ring's width.
     */
    @JvmField protected var mRadarCircle: Float

    /**
     * The radar's scale, 0 to 1.
     */
    @JvmField protected var mRadarScale = 0f

    /**
     * The radar animation while refreshing.
     */
    @JvmField protected var mAnimatorSet: Animator? = null

    /**
     * The radar's bounds.
     */
    @JvmField protected var mRadarRect = RectF(0f, 0f, 0f, 0f)

    init {
        mSpinnerStyle = SpinnerStyle.FixedBehind
        mDotRadius = SmartUtil.dp2px(7f).toFloat()
        mRadarRadius = SmartUtil.dp2px(20f).toFloat()
        mRadarCircle = SmartUtil.dp2px(7f).toFloat()
        mPaint.strokeWidth = SmartUtil.dp2px(3f).toFloat()
        minimumHeight = SmartUtil.dp2px(100f)
        if (isInEditMode) {
            mWaveTop = 1000
            mRadarScale = 1f
            mRadarAngle = 270
        }
        val ta = context.obtainStyledAttributes(attrs, R.styleable.BezierRadarHeader)
        mEnableHorizontalDrag = ta.getBoolean(R.styleable.BezierRadarHeader_srlEnableHorizontalDrag, mEnableHorizontalDrag)
        setAccentColor(ta.getColor(R.styleable.BezierRadarHeader_srlAccentColor, 0xFFffffff.toInt()))
        setPrimaryColor(ta.getColor(R.styleable.BezierRadarHeader_srlPrimaryColor, 0xFF222222.toInt()))
        mManualAccentColor = ta.hasValue(R.styleable.BezierRadarHeader_srlAccentColor)
        mManualPrimaryColor = ta.hasValue(R.styleable.BezierRadarHeader_srlPrimaryColor)
        ta.recycle()
        // Accessibility: a polite live region that reads "Refreshing" / "Refreshed"; hidden while idle.
        accessibilityLiveRegion = ACCESSIBILITY_LIVE_REGION_POLITE
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        endRadar()
    }

    private fun endRadar() {
        mAnimatorSet?.let {
            it.removeAllListeners()
            it.end()
        }
        mAnimatorSet = null
    }

    override fun dispatchDraw(canvas: Canvas) {
        val height = if (isInEditMode) height else mWaveOffsetY
        drawWave(canvas, width)
        drawDot(canvas, width, height)
        drawRadar(canvas, width, height)
        drawRipple(canvas, width, height)
        super.dispatchDraw(canvas)
    }

    /**
     * Draws the wave.
     */
    protected open fun drawWave(canvas: Canvas, width: Int) {
        mPath.reset()
        mPath.lineTo(0f, mWaveTop.toFloat())
        mPath.quadTo(if (mWaveOffsetX >= 0) mWaveOffsetX.toFloat() else width / 2f, (mWaveTop + mWaveHeight).toFloat(), width.toFloat(), mWaveTop.toFloat())
        mPath.lineTo(width.toFloat(), 0f)
        mPaint.color = mPrimaryColor
        canvas.drawPath(mPath, mPaint)
    }

    /**
     * Draws the row of dots while pulling.
     */
    protected open fun drawDot(canvas: Canvas, width: Int, height: Int) {
        if (mDotAlpha <= 0) return
        mPaint.color = mAccentColor
        val num = 7
        val x = SmartUtil.px2dp(height)
        val wide = (1f * width / num) * mDotFraction - if (mDotFraction > 1) (mDotFraction - 1) * (1f * width / num) / mDotFraction else 0f
        val high = height - if (mDotFraction > 1) (mDotFraction - 1) * height / 2 / mDotFraction else 0f
        for (i in 0 until num) {
            // Centered index: -3 … 3; alpha falls off to the sides and with the drag; the radius grows with it.
            val index = 1f + i - (1f + num) / 2
            val alpha = 255 * (1 - 2 * (abs(index) / num))
            mPaint.alpha = (mDotAlpha * alpha * (1.0 - 1.0 / (x / 800.0 + 1.0).pow(15))).toInt()
            val radius = mDotRadius * (1 - 1 / (x / 10 + 1))
            canvas.drawCircle(width / 2f - radius / 2 + wide * index, high / 2, radius, mPaint)
        }
        mPaint.alpha = 255
    }

    /**
     * Draws the radar while refreshing.
     */
    protected open fun drawRadar(canvas: Canvas, width: Int, height: Int) {
        if (mAnimatorSet == null && !isInEditMode) return
        var radius = mRadarRadius * mRadarScale
        val circle = mRadarCircle * mRadarScale
        mPaint.color = mAccentColor
        mPaint.style = Paint.Style.FILL
        canvas.drawCircle(width / 2f, height / 2f, radius, mPaint)
        mPaint.style = Paint.Style.STROKE
        canvas.drawCircle(width / 2f, height / 2f, radius + circle, mPaint)
        mPaint.color = mPrimaryColor and 0x00ffffff or 0x55000000
        mPaint.style = Paint.Style.FILL
        mRadarRect.set(width / 2f - radius, height / 2f - radius, width / 2f + radius, height / 2f + radius)
        canvas.drawArc(mRadarRect, 270f, mRadarAngle.toFloat(), true, mPaint)
        radius += circle
        mPaint.style = Paint.Style.STROKE
        mRadarRect.set(width / 2f - radius, height / 2f - radius, width / 2f + radius, height / 2f + radius)
        canvas.drawArc(mRadarRect, 270f, mRadarAngle.toFloat(), false, mPaint)
        mPaint.style = Paint.Style.FILL
    }

    /**
     * Draws the finishing ripple.
     */
    protected open fun drawRipple(canvas: Canvas, width: Int, height: Int) {
        if (mRippleRadius > 0) {
            mPaint.color = mAccentColor
            canvas.drawCircle(width / 2f, height / 2f, mRippleRadius, mPaint)
        }
    }

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        mWaveOffsetY = offset
        if (isDragging || mWavePulling) {
            mWavePulling = true
            mWaveTop = min(height, offset)
            mWaveHeight = (1.9f * max(0, offset - height)).toInt()
            mDotFraction = percent
            invalidate()
        }
    }

    override fun onReleased(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        // One pixel less, so no line shows at the edge.
        mWaveTop = height - 1
        mWavePulling = false
        val decelerate = SmartUtil(SmartUtil.INTERPOLATOR_DECELERATE)
        val dotAlpha = ValueAnimator.ofFloat(1f, 0f).apply {
            interpolator = decelerate
            addUpdateListener(AnimatorUpdater(PROPERTY_DOT_ALPHA))
        }
        val radarScale = ValueAnimator.ofFloat(0f, 1f).apply { addUpdateListener(AnimatorUpdater(PROPERTY_RADAR_SCALE)) }
        val radar = ValueAnimator.ofInt(0, 360).apply {
            duration = 720
            repeatCount = ValueAnimator.INFINITE
            interpolator = AccelerateDecelerateInterpolator()
            addUpdateListener(AnimatorUpdater(PROPERTY_RADAR_ANGLE))
        }
        val set = AnimatorSet()
        set.playSequentially(dotAlpha, radarScale, radar)
        set.start()
        ValueAnimator.ofInt(mWaveHeight, 0, -(mWaveHeight * 0.8f).toInt(), 0, -(mWaveHeight * 0.4f).toInt(), 0).apply {
            addUpdateListener(AnimatorUpdater(PROPERTY_WAVE_HEIGHT))
            interpolator = SmartUtil(SmartUtil.INTERPOLATOR_DECELERATE)
            duration = 800
            start()
        }
        mAnimatorSet = set
        contentDescription = context.getString(R.string.srl_radar_refreshing)
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        endRadar()
        val duration = 400
        val height = mWaveOffsetY
        val bigRadius = sqrt((width * width + height * height).toDouble()).toFloat()
        ValueAnimator.ofFloat(mRadarRadius, bigRadius).apply {
            this.duration = duration.toLong()
            addUpdateListener(AnimatorUpdater(PROPERTY_RIPPLE_RADIUS))
            start()
        }
        contentDescription = context.getString(R.string.srl_radar_refreshed)
        return duration
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        if (newState == RefreshState.None || newState == RefreshState.PullDownToRefresh) {
            mDotAlpha = 1f
            mRadarScale = 0f
            mRippleRadius = 0f
            if (newState == RefreshState.None) importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        }
    }

    @Deprecated("Only called by the layout; use setPrimaryColor and setAccentColor.")
    override fun setPrimaryColors(@ColorInt vararg colors: Int) {
        if (colors.isNotEmpty() && !mManualPrimaryColor) {
            setPrimaryColor(colors[0])
            mManualPrimaryColor = false
        }
        if (colors.size > 1 && !mManualAccentColor) {
            setAccentColor(colors[1])
            mManualAccentColor = false
        }
    }

    override val isSupportHorizontalDrag: Boolean
        get() = mEnableHorizontalDrag

    override fun onHorizontalDrag(percentX: Float, offsetX: Int, offsetMax: Int) {
        mWaveOffsetX = offsetX
        invalidate()
    }

    /**
     * The wave's color.
     */
    open fun setPrimaryColor(@ColorInt color: Int): BezierRadarHeader {
        mPrimaryColor = color
        mManualPrimaryColor = true
        return this
    }

    /**
     * The dots', radar's and ripple's color.
     */
    open fun setAccentColor(@ColorInt color: Int): BezierRadarHeader {
        mAccentColor = color
        mManualAccentColor = true
        return this
    }

    /**
     * The wave's color, as a resource.
     */
    open fun setPrimaryColorId(@ColorRes colorId: Int): BezierRadarHeader = setPrimaryColor(ContextCompat.getColor(context, colorId))

    /**
     * The accent color, as a resource.
     */
    open fun setAccentColorId(@ColorRes colorId: Int): BezierRadarHeader = setAccentColor(ContextCompat.getColor(context, colorId))

    /**
     * Moves the wave's peak with a horizontal drag.
     */
    open fun setEnableHorizontalDrag(enable: Boolean): BezierRadarHeader {
        mEnableHorizontalDrag = enable
        if (!enable) mWaveOffsetX = -1
        return this
    }

    /**
     * Applies an animated value to one property and redraws.
     */
    protected inner class AnimatorUpdater internal constructor(@JvmField internal var propertyName: Byte) : ValueAnimator.AnimatorUpdateListener {
        override fun onAnimationUpdate(animation: ValueAnimator) {
            when (propertyName) {
                PROPERTY_RADAR_SCALE -> mRadarScale = animation.animatedValue as Float
                PROPERTY_WAVE_HEIGHT -> {
                    if (mWavePulling) {
                        animation.cancel()
                        return
                    }
                    mWaveHeight = animation.animatedValue as Int / 2
                }
                PROPERTY_DOT_ALPHA -> mDotAlpha = animation.animatedValue as Float
                PROPERTY_RIPPLE_RADIUS -> mRippleRadius = animation.animatedValue as Float
                PROPERTY_RADAR_ANGLE -> mRadarAngle = animation.animatedValue as Int
            }
            invalidate()
        }
    }

    /**
     * The animated properties.
     */
    companion object {
        /**
         * The radar's scale.
         */
        const val PROPERTY_RADAR_SCALE: Byte = 0

        /**
         * The wave's height.
         */
        const val PROPERTY_WAVE_HEIGHT: Byte = 1

        /**
         * The dots' alpha.
         */
        const val PROPERTY_DOT_ALPHA: Byte = 2

        /**
         * The ripple's radius.
         */
        const val PROPERTY_RIPPLE_RADIUS: Byte = 3

        /**
         * The radar sweep's angle.
         */
        const val PROPERTY_RADAR_ANGLE: Byte = 4
    }
}
