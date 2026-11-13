// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90; the progress
// drawable is based on the Android Open Source Project's, Apache-2.0) translated to Kotlin; the JVM signatures match
// the Java version.
package com.scwang.smart.refresh.header.material

import android.annotation.SuppressLint
import android.content.Context
import android.content.res.Resources
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.ColorFilter
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PixelFormat
import android.graphics.Rect
import android.graphics.RectF
import android.graphics.drawable.Animatable
import android.graphics.drawable.Drawable
import android.graphics.drawable.ShapeDrawable
import android.graphics.drawable.shapes.OvalShape
import android.view.View
import android.view.animation.Animation
import android.view.animation.Interpolator
import android.view.animation.LinearInterpolator
import android.view.animation.Transformation
import android.widget.ImageView
import androidx.annotation.ColorInt
import androidx.annotation.IntDef
import androidx.interpolator.view.animation.FastOutSlowInInterpolator
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.floor
import kotlin.math.min
import kotlin.math.sin

/**
 * The MaterialHeader's circle: an oval background with the Material elevation (`CircleImageView`).
 */
@SuppressLint("ViewConstructor", "AppCompatCustomView")
open class CircleImageView(context: Context, color: Int) : ImageView(context) {
    /**
     * The shadow radius in pixels.
     */
    @JvmField internal var mShadowRadius: Int

    init {
        val density = resources.displayMetrics.density
        mShadowRadius = (density * SHADOW_RADIUS).toInt()
        elevation = SHADOW_ELEVATION * density
        background = ShapeDrawable(OvalShape()).apply { paint.color = color }
    }

    /**
     * Colors the circle, keeping its oval shape.
     */
    override fun setBackgroundColor(@ColorInt color: Int) {
        (background as? ShapeDrawable)?.paint?.color = color
    }

    /**
     * The shadow's size.
     */
    companion object {
        /**
         * The shadow radius in dp.
         */
        const val SHADOW_RADIUS = 3.5f

        /**
         * The elevation in dp.
         */
        const val SHADOW_ELEVATION = 4
    }
}

/**
 * The Material spinner with an arc, an arrow and color changes (`MaterialProgressDrawable`).
 */
open class MaterialProgressDrawable(private val mParent: View) : Drawable(), Animatable {

    /**
     * The sizes of [updateSizes].
     */
    @Retention(AnnotationRetention.SOURCE)
    @IntDef(LARGE.toInt(), DEFAULT.toInt())
    annotation class ProgressDrawableSize

    private val mRing = Ring()
    private var mRotation = 0f
    private lateinit var mAnimation: Animation
    internal var mRotationCount = 0f
    private var mWidth = 0f
    private var mHeight = 0f
    internal var mFinishing = false
    internal var mIsRunning = false

    init {
        setColorSchemeColors(*COLORS)
        updateSizes(DEFAULT.toInt())
        setupAnimators()
    }

    private fun setSizeParameters(progressCircleWidth: Int, progressCircleHeight: Int, centerRadius: Float, strokeWidth: Float, arrowWidth: Float, arrowHeight: Float) {
        val screenDensity = Resources.getSystem().displayMetrics.density
        mWidth = progressCircleWidth * screenDensity
        mHeight = progressCircleHeight * screenDensity
        mRing.setColorIndex(0)
        mRing.mPaint.strokeWidth = strokeWidth * screenDensity
        mRing.mStrokeWidth = strokeWidth * screenDensity
        mRing.mRingCenterRadius = (centerRadius * screenDensity).toDouble()
        mRing.mArrowWidth = (arrowWidth * screenDensity).toInt()
        mRing.mArrowHeight = (arrowHeight * screenDensity).toInt()
        mRing.setInsets(mWidth.toInt(), mHeight.toInt())
        invalidateSelf()
    }

    /**
     * Sets the size: [LARGE] or [DEFAULT].
     */
    open fun updateSizes(@ProgressDrawableSize size: Int) {
        if (size == LARGE.toInt()) {
            setSizeParameters(CIRCLE_DIAMETER_LARGE, CIRCLE_DIAMETER_LARGE, CENTER_RADIUS_LARGE, STROKE_WIDTH_LARGE, ARROW_WIDTH_LARGE, ARROW_HEIGHT_LARGE)
        } else {
            setSizeParameters(CIRCLE_DIAMETER, CIRCLE_DIAMETER, CENTER_RADIUS, STROKE_WIDTH, ARROW_WIDTH, ARROW_HEIGHT)
        }
    }

    /**
     * Shows the arrow at the arc's end.
     */
    open fun showArrow(show: Boolean) {
        if (mRing.mShowArrow != show) {
            mRing.mShowArrow = show
            invalidateSelf()
        }
    }

    /**
     * The arrow's scale, 0 to 1.
     */
    open fun setArrowScale(scale: Float) {
        if (mRing.mArrowScale != scale) {
            mRing.mArrowScale = scale
            invalidateSelf()
        }
    }

    /**
     * The arc's start and end, as fractions of a turn.
     */
    open fun setStartEndTrim(startAngle: Float, endAngle: Float) {
        mRing.mStartTrim = startAngle
        mRing.mEndTrim = endAngle
        invalidateSelf()
    }

    /**
     * The arc's rotation, as a fraction of a turn.
     */
    open fun setProgressRotation(rotation: Float) {
        mRing.mRotation = rotation
        invalidateSelf()
    }

    /**
     * The arc's colors, in turn.
     */
    open fun setColorSchemeColors(@ColorInt vararg colors: Int) {
        mRing.mColors = colors
        mRing.setColorIndex(0)
    }

    override fun getIntrinsicHeight(): Int = mHeight.toInt()

    override fun getIntrinsicWidth(): Int = mWidth.toInt()

    override fun draw(c: Canvas) {
        val saveCount = c.save()
        c.rotate(mRotation, bounds.exactCenterX(), bounds.exactCenterY())
        mRing.draw(c, bounds)
        c.restoreToCount(saveCount)
    }

    override fun setAlpha(alpha: Int) {}

    override fun setColorFilter(colorFilter: ColorFilter?) {
        mRing.mPaint.colorFilter = colorFilter
        invalidateSelf()
    }

    internal fun setRotation(rotation: Float) {
        mRotation = rotation
        invalidateSelf()
    }

    @Deprecated("Deprecated in Drawable")
    override fun getOpacity(): Int = PixelFormat.TRANSLUCENT

    /**
     * Running only while the parent still holds the animation: the system can drop a view animation (issue #1600), and
     * a drawable that still said "running" was never started again, so its arc froze.
     */
    override fun isRunning(): Boolean = mIsRunning && mParent.animation === mAnimation


    override fun start() {
        if (isRunning) return
        mAnimation.reset()
        mRing.storeOriginals()
        if (mRing.mEndTrim != mRing.mStartTrim) {
            mFinishing = true
            mAnimation.duration = (ANIMATION_DURATION / 2).toLong()
        } else {
            mRing.setColorIndex(0)
            mRing.resetOriginals()
            mAnimation.duration = ANIMATION_DURATION.toLong()
        }
        mParent.startAnimation(mAnimation)
        mIsRunning = true
    }

    override fun stop() {
        if (!mIsRunning) return
        mParent.clearAnimation()
        mRing.setColorIndex(0)
        mRing.resetOriginals()
        showArrow(false)
        setRotation(0f)
        mIsRunning = false
    }

    internal fun getMinProgressArc(ring: Ring): Float = Math.toRadians(ring.mStrokeWidth / (2 * Math.PI * ring.mRingCenterRadius)).toFloat()

    private fun evaluateColorChange(fraction: Float, startValue: Int, endValue: Int): Int {
        val startA = startValue shr 24 and 0xff
        val startR = startValue shr 16 and 0xff
        val startG = startValue shr 8 and 0xff
        val startB = startValue and 0xff
        val endA = endValue shr 24 and 0xff
        val endR = endValue shr 16 and 0xff
        val endG = endValue shr 8 and 0xff
        val endB = endValue and 0xff
        return ((startA + (fraction * (endA - startA)).toInt()) shl 24) or
            ((startR + (fraction * (endR - startR)).toInt()) shl 16) or
            ((startG + (fraction * (endG - startG)).toInt()) shl 8) or
            (startB + (fraction * (endB - startB)).toInt())
    }

    internal fun updateRingColor(interpolatedTime: Float, ring: Ring) {
        if (interpolatedTime > COLOR_START_DELAY_OFFSET) {
            ring.mCurrentColor = evaluateColorChange(
                (interpolatedTime - COLOR_START_DELAY_OFFSET) / (1.0f - COLOR_START_DELAY_OFFSET), ring.startingColor, ring.nextColor,
            )
        }
    }

    internal fun applyFinishTranslation(interpolatedTime: Float, ring: Ring) {
        updateRingColor(interpolatedTime, ring)
        val targetRotation = (floor(ring.mStartingRotation / MAX_PROGRESS_ARC) + 1f).toFloat()
        val minProgressArc = getMinProgressArc(ring)
        val startTrim = ring.mStartingStartTrim + (ring.mStartingEndTrim - minProgressArc - ring.mStartingStartTrim) * interpolatedTime
        setStartEndTrim(startTrim, ring.mStartingEndTrim)
        setProgressRotation(ring.mStartingRotation + (targetRotation - ring.mStartingRotation) * interpolatedTime)
    }

    private fun setupAnimators() {
        val ring = mRing
        val animation = object : Animation() {
            override fun applyTransformation(interpolatedTime: Float, t: Transformation) {
                if (mFinishing) {
                    applyFinishTranslation(interpolatedTime, ring)
                    return
                }
                val minProgressArc = getMinProgressArc(ring)
                val startingEndTrim = ring.mStartingEndTrim
                val startingTrim = ring.mStartingStartTrim
                val startingRotation = ring.mStartingRotation
                updateRingColor(interpolatedTime, ring)
                if (interpolatedTime <= START_TRIM_DURATION_OFFSET) {
                    val scaledTime = interpolatedTime / (1.0f - START_TRIM_DURATION_OFFSET)
                    ring.mStartTrim = startingTrim + (MAX_PROGRESS_ARC - minProgressArc) * MATERIAL_INTERPOLATOR.getInterpolation(scaledTime)
                }
                if (interpolatedTime > END_TRIM_START_DELAY_OFFSET) {
                    val minArc = MAX_PROGRESS_ARC - minProgressArc
                    val scaledTime = (interpolatedTime - START_TRIM_DURATION_OFFSET) / (1.0f - START_TRIM_DURATION_OFFSET)
                    ring.mEndTrim = startingEndTrim + minArc * MATERIAL_INTERPOLATOR.getInterpolation(scaledTime)
                }
                setProgressRotation(startingRotation + 0.25f * interpolatedTime)
                setRotation(FULL_ROTATION / NUM_POINTS * interpolatedTime + FULL_ROTATION * (mRotationCount / NUM_POINTS))
            }
        }
        animation.repeatCount = Animation.INFINITE
        animation.repeatMode = Animation.RESTART
        animation.interpolator = LINEAR_INTERPOLATOR
        animation.setAnimationListener(object : Animation.AnimationListener {
            override fun onAnimationStart(animation: Animation) {
                mRotationCount = 0f
            }

            override fun onAnimationEnd(animation: Animation) {}

            override fun onAnimationRepeat(animation: Animation) {
                ring.storeOriginals()
                ring.goToNextColor()
                ring.mStartTrim = ring.mEndTrim
                if (mFinishing) {
                    mFinishing = false
                    animation.duration = ANIMATION_DURATION.toLong()
                    showArrow(false)
                } else {
                    mRotationCount = (mRotationCount + 1) % NUM_POINTS
                }
            }
        })
        mAnimation = animation
    }

    internal class Ring {
        val mTempBounds = RectF()
        val mPaint = Paint().apply {
            strokeCap = Paint.Cap.SQUARE
            isAntiAlias = true
            style = Paint.Style.STROKE
        }
        val mArrowPaint = Paint().apply {
            style = Paint.Style.FILL
            isAntiAlias = true
        }
        var mStartTrim = 0.0f
        var mEndTrim = 0.0f
        var mRotation = 0.0f
        var mStrokeWidth = 5.0f
        var mStrokeInset = 2.5f
        var mColors: IntArray = COLORS
        var mColorIndex = 0
        var mStartingStartTrim = 0f
        var mStartingEndTrim = 0f
        var mStartingRotation = 0f
        var mShowArrow = false
        var mArrow: Path? = null
        var mArrowScale = 0f
        var mRingCenterRadius = 0.0
        var mArrowWidth = 0
        var mArrowHeight = 0
        var mCurrentColor = 0

        fun draw(c: Canvas, bounds: Rect) {
            val arcBounds = mTempBounds
            arcBounds.set(bounds)
            arcBounds.inset(mStrokeInset, mStrokeInset)
            val startAngle = (mStartTrim + mRotation) * 360
            val endAngle = (mEndTrim + mRotation) * 360
            val sweepAngle = endAngle - startAngle
            if (sweepAngle != 0f) {
                mPaint.color = mCurrentColor
                c.drawArc(arcBounds, startAngle, sweepAngle, false, mPaint)
            }
            drawTriangle(c, startAngle, sweepAngle, bounds)
        }

        private fun drawTriangle(c: Canvas, startAngle: Float, sweepAngle: Float, bounds: Rect) {
            if (!mShowArrow) return
            val arrow = mArrow?.apply { reset() } ?: Path().apply { fillType = Path.FillType.EVEN_ODD }.also { mArrow = it }
            val inset = (mStrokeInset.toInt() / 2).toFloat() * mArrowScale
            val x = (mRingCenterRadius * cos(0.0) + bounds.exactCenterX()).toFloat()
            val y = (mRingCenterRadius * sin(0.0) + bounds.exactCenterY()).toFloat()
            arrow.moveTo(0f, 0f)
            arrow.lineTo(mArrowWidth * mArrowScale, 0f)
            arrow.lineTo(mArrowWidth * mArrowScale / 2, mArrowHeight * mArrowScale)
            arrow.offset(x - inset, y)
            arrow.close()
            mArrowPaint.color = mCurrentColor
            c.rotate(startAngle + sweepAngle - ARROW_OFFSET_ANGLE, bounds.exactCenterX(), bounds.exactCenterY())
            c.drawPath(arrow, mArrowPaint)
        }

        fun setColorIndex(index: Int) {
            mColorIndex = index
            mCurrentColor = mColors[mColorIndex]
        }

        val nextColor: Int
            get() = mColors[nextColorIndex]

        private val nextColorIndex: Int
            get() = (mColorIndex + 1) % mColors.size

        fun goToNextColor() = setColorIndex(nextColorIndex)

        val startingColor: Int
            get() = mColors[mColorIndex]

        fun setInsets(width: Int, height: Int) {
            val minEdge = min(width, height).toFloat()
            mStrokeInset = if (mRingCenterRadius <= 0 || minEdge < 0) ceil(mStrokeWidth / 2.0f) else (minEdge / 2.0f - mRingCenterRadius).toFloat()
        }

        fun storeOriginals() {
            mStartingStartTrim = mStartTrim
            mStartingEndTrim = mEndTrim
            mStartingRotation = mRotation
        }

        fun resetOriginals() {
            mStartingStartTrim = 0f
            mStartingEndTrim = 0f
            mStartingRotation = 0f
            mStartTrim = 0f
            mEndTrim = 0f
            mRotation = 0f
        }
    }

    /**
     * The sizes and the animation constants.
     */
    companion object {
        /**
         * The large size.
         */
        const val LARGE: Byte = 0

        /**
         * The default size.
         */
        const val DEFAULT: Byte = 1

        private val LINEAR_INTERPOLATOR: Interpolator = LinearInterpolator()
        internal val MATERIAL_INTERPOLATOR: Interpolator = FastOutSlowInInterpolator()
        private const val FULL_ROTATION = 1080.0f
        private const val CIRCLE_DIAMETER = 40
        private const val CENTER_RADIUS = 8.75f
        private const val STROKE_WIDTH = 2.5f
        private const val CIRCLE_DIAMETER_LARGE = 56
        private const val CENTER_RADIUS_LARGE = 12.5f
        private const val STROKE_WIDTH_LARGE = 3f
        private val COLORS = intArrayOf(Color.BLACK)
        private const val COLOR_START_DELAY_OFFSET = 0.75f
        private const val END_TRIM_START_DELAY_OFFSET = 0.5f
        private const val START_TRIM_DURATION_OFFSET = 0.5f
        private const val ANIMATION_DURATION = 1332
        private const val NUM_POINTS = 5
        private const val ARROW_WIDTH = 10f
        private const val ARROW_HEIGHT = 5f
        private const val ARROW_OFFSET_ANGLE = 5f
        private const val ARROW_WIDTH_LARGE = 12f
        private const val ARROW_HEIGHT_LARGE = 6f
        private const val MAX_PROGRESS_ARC = .8f
    }
}
