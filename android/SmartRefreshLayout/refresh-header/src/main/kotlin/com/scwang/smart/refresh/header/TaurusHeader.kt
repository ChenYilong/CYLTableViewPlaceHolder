// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header

import android.content.Context
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.AccelerateInterpolator
import android.view.animation.Animation
import android.view.animation.Interpolator
import android.view.animation.Transformation
import androidx.annotation.ColorInt
import com.scwang.smart.drawable.PathsDrawable
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.simple.SimpleComponent
import com.scwang.smart.refresh.layout.util.SmartUtil
import java.util.Random
import kotlin.math.abs
import kotlin.math.min
import kotlin.math.pow

/**
 * A plane flying through clouds and wind, from Yalantis' Taurus (`TaurusHeader`).
 */
open class TaurusHeader @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    SimpleComponent(context, attrs, 0), RefreshHeader {

    /**
     * The plane.
     */
    @JvmField protected var mAirplane: Drawable

    /**
     * The clouds.
     */
    @JvmField protected var mCloudCenter: Drawable

    /**
     * The drawings' matrix.
     */
    @JvmField protected var mMatrix = Matrix()

    /**
     * The pull percent.
     */
    @JvmField protected var mPercent = 0f

    /**
     * The current offset.
     */
    @JvmField protected var mHeight = 0

    /**
     * The header's height.
     */
    @JvmField protected var mHeaderHeight = 0

    /**
     * The loading animation.
     */
    @JvmField protected var mAnimation: Animation

    /**
     * True while refreshing.
     */
    @JvmField protected var isRefreshing = false

    /**
     * The loading animation's time.
     */
    @JvmField protected var mLoadingAnimationTime = 0f

    /**
     * The previous frame's loading time, to find the direction.
     */
    @JvmField protected var mLastAnimationTime = 0f

    /**
     * The winds' random source.
     */
    @JvmField protected var mRandom = Random()

    /**
     * The winds: y to x offset.
     */
    @JvmField protected var mWinds: MutableMap<Float, Float> = HashMap()

    /**
     * The winds' paint.
     */
    @JvmField protected var mWindPaint = Paint().apply {
        color = 0xffffffff.toInt()
        strokeWidth = SmartUtil.dp2px(3f).toFloat()
        alpha = 50
    }

    /**
     * The winds' length.
     */
    @JvmField protected var mWindLineWidth = 0f

    /**
     * True when a new set of winds is due.
     */
    @JvmField protected var mNewWindSet = false

    /**
     * True while the loading animation runs backwards.
     */
    @JvmField protected var mInverseDirection = false

    /**
     * The finish animation's progress.
     */
    @JvmField protected var mFinishTransformation = 0f

    /**
     * The background color.
     */
    @JvmField protected var mBackgroundColor: Int

    /**
     * The layout's kernel, once initialized.
     */
    @JvmField protected var mKernel: RefreshKernel? = null

    /**
     * The four parts of the loading animation.
     */
    protected enum class AnimationPart {
        /**
         * The first part.
         */
        FIRST,

        /**
         * The second part.
         */
        SECOND,

        /**
         * The third part.
         */
        THIRD,

        /**
         * The fourth part.
         */
        FOURTH,
    }

    init {
        minimumHeight = SmartUtil.dp2px(100f)
        mSpinnerStyle = SpinnerStyle.FixedBehind
        mAnimation = object : Animation() {
            override fun applyTransformation(interpolatedTime: Float, t: Transformation) {
                mLoadingAnimationTime = LOADING_ANIMATION_COEFFICIENT * (interpolatedTime / SLOW_DOWN_ANIMATION_COEFFICIENT)
                invalidate()
            }
        }.apply {
            repeatCount = Animation.INFINITE
            repeatMode = Animation.REVERSE
            interpolator = ACCELERATE_DECELERATE_INTERPOLATOR
            duration = ANIMATION_DURATION.toLong()
        }
        mAirplane = PathsDrawable().apply {
            if (!parserPaths(*airplanePaths)) declareOriginal(3, 3, 257, 79)
            parserColors(*airplaneColors)
            setBounds(0, 0, SmartUtil.dp2px(65f), SmartUtil.dp2px(20f))
        }
        mCloudCenter = PathsDrawable().apply {
            if (!parserPaths(*cloudPaths)) declareOriginal(-1, 1, 761, 121)
            parserColors(*cloudColors)
            setBounds(0, 0, SmartUtil.dp2px(260f), SmartUtil.dp2px(45f))
        }
        val ta = context.obtainStyledAttributes(attrs, R.styleable.TaurusHeader)
        val primaryColor = ta.getColor(R.styleable.TaurusHeader_thPrimaryColor, 0)
        mBackgroundColor = if (primaryColor != 0) primaryColor else 0xff11bbff.toInt()
        ta.recycle()
        initRefreshAccessibility()
    }

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        mKernel = kernel
        kernel.requestDrawBackgroundFor(this, mBackgroundColor)
    }

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        mHeight = offset
        mPercent = percent
        mHeaderHeight = height
        if (isDragging) mFinishTransformation = 0f
        invalidate()
    }

    override fun onStartAnimator(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        isRefreshing = true
        mFinishTransformation = 0f
        startAnimation(mAnimation)
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        updateRefreshAccessibility(newState)
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        clearAnimation()
        if (success) {
            startAnimation(object : Animation() {
                init {
                    duration = 100
                    interpolator = AccelerateInterpolator()
                }

                override fun applyTransformation(interpolatedTime: Float, t: Transformation) {
                    if (interpolatedTime == 1f) isRefreshing = false
                    mFinishTransformation = interpolatedTime
                    invalidate()
                }
            })
            return 200
        }
        isRefreshing = false
        return 0
    }

    @Deprecated("Only called by the layout; use RefreshLayout.setPrimaryColorsId.")
    override fun setPrimaryColors(@ColorInt vararg colors: Int) {
        // An empty array is ignored (the Java version threw).
        if (colors.isEmpty()) return
        mBackgroundColor = colors[0]
        mKernel?.requestDrawBackgroundFor(this, mBackgroundColor)
    }

    override fun dispatchDraw(canvas: Canvas) {
        val width = width
        val height = mHeight
        val footer = mKernel?.refreshLayout?.refreshFooter?.let { this == it } == true
        if (footer) {
            canvas.save()
            canvas.translate(0f, (getHeight() - mHeight).toFloat())
        }
        drawWinds(canvas, width)
        drawAirplane(canvas, width, height)
        drawSideClouds(canvas, width, height)
        drawCenterClouds(canvas, width, height)
        if (footer) canvas.restore()
        super.dispatchDraw(canvas)
    }

    /**
     * Draws the winds while refreshing.
     */
    protected open fun drawWinds(canvas: Canvas, width: Int) {
        // No header height yet: every wind would land on y = 0 and the loop below would never end (the Java version
        // hung there).
        if (!isRefreshing || mHeaderHeight <= 0) return
        while (mWinds.size < WIND_SET_AMOUNT) {
            var y = (mHeaderHeight / (Math.random() * RANDOM_Y_COEFFICIENT)).toFloat()
            val x = random(MIN_WIND_X_OFFSET, MAX_WIND_X_OFFSET)
            // Keep the winds more than a fifth of the header apart.
            if (mWinds.size > 1) {
                y = 0f
                while (y == 0f) {
                    val tmp = (mHeaderHeight / (Math.random() * RANDOM_Y_COEFFICIENT)).toFloat()
                    y = if (mWinds.keys.all { abs(it - tmp) > 1f * mHeaderHeight / RANDOM_Y_COEFFICIENT }) tmp else 0f
                }
            }
            mWinds[y] = x
            drawWind(canvas, y, x, width)
        }
        if (mWinds.size >= WIND_SET_AMOUNT) {
            for ((y, x) in mWinds) drawWind(canvas, y, x, width)
        }
        if (mInverseDirection && mNewWindSet) {
            mWinds.clear()
            mNewWindSet = false
            mWindLineWidth = random(MIN_WIND_LINE_WIDTH, MAX_WIND_LINE_WIDTH)
        }
        mLastAnimationTime = mLoadingAnimationTime
    }

    /**
     * Draws one wind at [y], [xOffset] behind the right edge.
     */
    protected open fun drawWind(canvas: Canvas, y: Float, xOffset: Float, width: Int) {
        val span = 1f * LOADING_ANIMATION_COEFFICIENT / SLOW_DOWN_ANIMATION_COEFFICIENT
        val cof = (width + xOffset) / span
        var time = mLoadingAnimationTime
        // The animation reverses; run the winds as if it restarted.
        if (mLastAnimationTime - mLoadingAnimationTime > 0) {
            mInverseDirection = true
            time = span - mLoadingAnimationTime
        } else {
            mNewWindSet = true
            mInverseDirection = false
        }
        val x = (width - time * cof) + xOffset - mWindLineWidth
        canvas.drawLine(x, y, x + mWindLineWidth, y, mWindPaint)
    }

    /**
     * Draws the clouds at both sides.
     */
    protected open fun drawSideClouds(canvas: Canvas, width: Int, height: Int) {
        val matrix = mMatrix
        matrix.reset()
        val cloud = mCloudCenter
        var dragPercent = min(1f, abs(mPercent))
        if (isInEditMode) {
            dragPercent = 1f
            mHeaderHeight = height
        }
        val scalePercentDelta = dragPercent - SCALE_START_PERCENT
        val scale = if (scalePercentDelta > 0) {
            SIDE_CLOUDS_INITIAL_SCALE + (SIDE_CLOUDS_FINAL_SCALE - SIDE_CLOUDS_INITIAL_SCALE) * scalePercentDelta / (1.0f - SCALE_START_PERCENT)
        } else {
            SIDE_CLOUDS_INITIAL_SCALE
        }
        val dragYOffset = mHeaderHeight * (1.0f - dragPercent)
        var offsetLeftX = 0 - cloud.bounds.width() / 2f
        var offsetLeftY = dragYOffset
        var offsetRightX = width - cloud.bounds.width() / 2f
        var offsetRightY = dragYOffset
        if (isRefreshing) {
            when {
                checkCurrentAnimationPart(AnimationPart.FIRST) -> {
                    offsetLeftX -= 2 * getAnimationPartValue(AnimationPart.FIRST) / Y_SIDE_CLOUDS_SLOW_DOWN_COF
                    offsetRightX += getAnimationPartValue(AnimationPart.FIRST) / X_SIDE_CLOUDS_SLOW_DOWN_COF
                }
                checkCurrentAnimationPart(AnimationPart.SECOND) -> {
                    offsetLeftX -= 2 * getAnimationPartValue(AnimationPart.SECOND) / Y_SIDE_CLOUDS_SLOW_DOWN_COF
                    offsetRightX += getAnimationPartValue(AnimationPart.SECOND) / X_SIDE_CLOUDS_SLOW_DOWN_COF
                }
                checkCurrentAnimationPart(AnimationPart.THIRD) -> {
                    offsetLeftX -= getAnimationPartValue(AnimationPart.THIRD) / Y_SIDE_CLOUDS_SLOW_DOWN_COF
                    offsetRightX += 2 * getAnimationPartValue(AnimationPart.THIRD) / X_SIDE_CLOUDS_SLOW_DOWN_COF
                }
                checkCurrentAnimationPart(AnimationPart.FOURTH) -> {
                    offsetLeftX -= getAnimationPartValue(AnimationPart.FOURTH) / X_SIDE_CLOUDS_SLOW_DOWN_COF
                    offsetRightX += 2 * getAnimationPartValue(AnimationPart.FOURTH) / Y_SIDE_CLOUDS_SLOW_DOWN_COF
                }
            }
        }
        if (offsetLeftY + scale * cloud.bounds.height() < height + 2) offsetLeftY = height + 2 - scale * cloud.bounds.height()
        if (offsetRightY + scale * cloud.bounds.height() < height + 2) offsetRightY = height + 2 - scale * cloud.bounds.height()
        val saveCount = canvas.saveCount
        canvas.save()
        canvas.translate(offsetLeftX, offsetLeftY)
        matrix.postScale(scale, scale, cloud.bounds.width() * 3 / 4f, cloud.bounds.height().toFloat())
        canvas.concat(matrix)
        cloud.alpha = 100
        cloud.draw(canvas)
        cloud.alpha = 255
        canvas.restoreToCount(saveCount)
        canvas.save()
        canvas.translate(offsetRightX, offsetRightY)
        matrix.postScale(scale, scale, 0f, cloud.bounds.height().toFloat())
        canvas.concat(matrix)
        cloud.alpha = 100
        cloud.draw(canvas)
        cloud.alpha = 255
        canvas.restoreToCount(saveCount)
    }

    /**
     * Draws the clouds in the middle.
     */
    protected open fun drawCenterClouds(canvas: Canvas, width: Int, height: Int) {
        val matrix = mMatrix
        matrix.reset()
        val cloud = mCloudCenter
        var dragPercent = min(1f, abs(mPercent))
        if (isInEditMode) {
            dragPercent = 1f
            mHeaderHeight = height
        }
        val overDrag = mPercent > 1.0f
        val overDragPercent = if (overDrag) abs(1.0f - mPercent) else 0f
        val scalePercentDelta = dragPercent - SCALE_START_PERCENT
        val scale = if (scalePercentDelta > 0) {
            CENTER_CLOUDS_INITIAL_SCALE + (CENTER_CLOUDS_FINAL_SCALE - CENTER_CLOUDS_INITIAL_SCALE) * scalePercentDelta / (1.0f - SCALE_START_PERCENT)
        } else {
            CENTER_CLOUDS_INITIAL_SCALE
        }
        val dragYOffset = mHeaderHeight * dragPercent
        val startParallaxHeight = mHeaderHeight - cloud.bounds.height() / 2
        val parallax = dragYOffset > startParallaxHeight
        val parallaxPercent = if (parallax) dragYOffset - startParallaxHeight else 0f
        val offsetX = width / 2f - cloud.bounds.width() / 2f
        var offsetY = dragYOffset - (if (parallax) cloud.bounds.height() / 2f + parallaxPercent else cloud.bounds.height() / 2f)
        var sx = if (overDrag) scale + overDragPercent / 4 else scale
        var sy = if (overDrag) scale + overDragPercent / 2 else scale
        if (isRefreshing && !overDrag) {
            sx = when {
                checkCurrentAnimationPart(AnimationPart.FIRST) -> scale - (getAnimationPartValue(AnimationPart.FIRST) / LOADING_ANIMATION_COEFFICIENT) / 8
                checkCurrentAnimationPart(AnimationPart.SECOND) -> scale - (getAnimationPartValue(AnimationPart.SECOND) / LOADING_ANIMATION_COEFFICIENT) / 8
                checkCurrentAnimationPart(AnimationPart.THIRD) -> scale + (getAnimationPartValue(AnimationPart.THIRD) / LOADING_ANIMATION_COEFFICIENT) / 6
                checkCurrentAnimationPart(AnimationPart.FOURTH) -> scale + (getAnimationPartValue(AnimationPart.FOURTH) / LOADING_ANIMATION_COEFFICIENT) / 6
                else -> sx
            }
            sy = sx
        }
        matrix.postScale(sx, sy, cloud.bounds.width() / 2f, 0f)
        if (offsetY + sy * cloud.bounds.height() < height + 2) offsetY = height + 2 - sy * cloud.bounds.height()
        val saveCount = canvas.saveCount
        canvas.save()
        canvas.translate(offsetX, offsetY)
        canvas.concat(matrix)
        cloud.draw(canvas)
        canvas.restoreToCount(saveCount)
    }

    /**
     * Draws the plane.
     */
    protected open fun drawAirplane(canvas: Canvas, width: Int, height: Int) {
        val matrix = mMatrix
        matrix.reset()
        var dragPercent = mPercent
        var rotateAngle = 0f
        if (isInEditMode) {
            dragPercent = 1f
            mHeaderHeight = height
        }
        if (dragPercent > 1.0f) {
            rotateAngle = 20 * (1 - 100.0.pow((-(dragPercent - 1) / 2).toDouble())).toFloat()
            dragPercent = 1.0f
        }
        val bounds = mAirplane.bounds
        var offsetX = (width * dragPercent) / 2 - bounds.width() / 2f
        var offsetY = mHeaderHeight * (1 - dragPercent / 2) - bounds.height() / 2f
        if (mFinishTransformation > 0) {
            offsetY += (0 - offsetY) * mFinishTransformation
            offsetX += (width + bounds.width() - offsetX) * mFinishTransformation
        }
        if (isRefreshing) {
            when {
                checkCurrentAnimationPart(AnimationPart.FIRST) -> offsetY -= getAnimationPartValue(AnimationPart.FIRST)
                checkCurrentAnimationPart(AnimationPart.SECOND) -> offsetY -= getAnimationPartValue(AnimationPart.SECOND)
                checkCurrentAnimationPart(AnimationPart.THIRD) -> offsetY += getAnimationPartValue(AnimationPart.THIRD)
                checkCurrentAnimationPart(AnimationPart.FOURTH) -> offsetY += getAnimationPartValue(AnimationPart.FOURTH)
            }
        }
        if (rotateAngle > 0) matrix.postRotate(rotateAngle, bounds.width() / 2f, bounds.height() / 2f)
        val saveCount = canvas.saveCount
        canvas.save()
        canvas.translate(offsetX, offsetY)
        canvas.concat(matrix)
        mAirplane.draw(canvas)
        canvas.restoreToCount(saveCount)
    }

    /**
     * A random number from [min] to [max], both included.
     */
    protected open fun random(min: Int, max: Int): Float = (mRandom.nextInt(max - min + 1) + min).toFloat()

    /**
     * The value of the loading animation within [part].
     */
    protected open fun getAnimationPartValue(part: AnimationPart): Float = when (part) {
        AnimationPart.FIRST -> mLoadingAnimationTime
        AnimationPart.SECOND -> getAnimationTimePart(AnimationPart.FOURTH) - (mLoadingAnimationTime - getAnimationTimePart(AnimationPart.FOURTH))
        AnimationPart.THIRD -> mLoadingAnimationTime - getAnimationTimePart(AnimationPart.SECOND)
        AnimationPart.FOURTH -> getAnimationTimePart(AnimationPart.THIRD) - (mLoadingAnimationTime - getAnimationTimePart(AnimationPart.FOURTH))
    }

    /**
     * True while the loading animation is in [part].
     */
    protected open fun checkCurrentAnimationPart(part: AnimationPart): Boolean = when (part) {
        AnimationPart.FIRST -> mLoadingAnimationTime < getAnimationTimePart(AnimationPart.FOURTH)
        AnimationPart.SECOND, AnimationPart.THIRD -> mLoadingAnimationTime < getAnimationTimePart(part)
        AnimationPart.FOURTH -> mLoadingAnimationTime > getAnimationTimePart(AnimationPart.THIRD)
    }

    /**
     * The length of [part] of the loading animation.
     */
    protected open fun getAnimationTimePart(part: AnimationPart): Int = when (part) {
        AnimationPart.SECOND -> LOADING_ANIMATION_COEFFICIENT / 2
        AnimationPart.THIRD -> getAnimationTimePart(AnimationPart.FOURTH) * 3
        AnimationPart.FOURTH -> LOADING_ANIMATION_COEFFICIENT / 4
        AnimationPart.FIRST -> 0
    }

    /**
     * The animation constants and the drawings' SVG paths and colors.
     */
    companion object {
        /**
         * The pull at which the clouds start to grow.
         */
        @JvmStatic protected val SCALE_START_PERCENT = 0.5f

        /**
         * One loading loop, in milliseconds.
         */
        @JvmStatic protected val ANIMATION_DURATION = 1000

        /**
         * The side clouds' first scale.
         */
        @JvmStatic protected val SIDE_CLOUDS_INITIAL_SCALE = 0.6f

        /**
         * The side clouds' last scale.
         */
        @JvmStatic protected val SIDE_CLOUDS_FINAL_SCALE = 1f

        /**
         * The center clouds' first scale.
         */
        @JvmStatic protected val CENTER_CLOUDS_INITIAL_SCALE = 0.8f

        /**
         * The center clouds' last scale.
         */
        @JvmStatic protected val CENTER_CLOUDS_FINAL_SCALE = 1f

        /**
         * The loading animation's interpolator.
         */
        @JvmStatic protected val ACCELERATE_DECELERATE_INTERPOLATOR: Interpolator = AccelerateDecelerateInterpolator()

        /**
         * Multiplies the loading animation's time.
         */
        @JvmStatic protected val LOADING_ANIMATION_COEFFICIENT = 80

        /**
         * Slows the loading animation down.
         */
        @JvmStatic protected val SLOW_DOWN_ANIMATION_COEFFICIENT = 6

        /**
         * The number of winds.
         */
        @JvmStatic protected val WIND_SET_AMOUNT = 10

        /**
         * Slows the side clouds vertically.
         */
        @JvmStatic protected val Y_SIDE_CLOUDS_SLOW_DOWN_COF = 4

        /**
         * Slows the side clouds horizontally.
         */
        @JvmStatic protected val X_SIDE_CLOUDS_SLOW_DOWN_COF = 2

        /**
         * The shortest wind.
         */
        @JvmStatic protected val MIN_WIND_LINE_WIDTH = 50

        /**
         * The longest wind.
         */
        @JvmStatic protected val MAX_WIND_LINE_WIDTH = 300

        /**
         * The smallest wind offset.
         */
        @JvmStatic protected val MIN_WIND_X_OFFSET = 1000

        /**
         * The largest wind offset.
         */
        @JvmStatic protected val MAX_WIND_X_OFFSET = 2000

        /**
         * Spreads the winds vertically.
         */
        @JvmStatic protected val RANDOM_Y_COEFFICIENT = 5

        /**
         * The airplanePaths (from the Java version).
         */
        @JvmStatic protected var airplanePaths = arrayOf(
            "m23 81c0 0 0 -1 0 -1 0 -0.5 0 -1 1.5 -1 2 -1 2.6 -2 2 -2.5 -0.5 -1 -2 -1 -11.6 -2.5 -5 -1 -10 -1 -11 -1.5l-1 0 1 -1c1 -1 1 -1 2 -1 0.6 0 6 0 13 1 6 0 12 1 12.6 0.6l1 0 -1 -2C30 67 16 42 15 40.6l-0.5 -1 4 -1c2 -0.6 4 -1 4 -1 0 0 6 4 13 8.5 14.6 10 17 11 20 12 4.6 2 6 1.6 13 -0.6 13 -5 25 -9 26 -9 0.6 0 3.6 1 -24 -14L51 23 47 16 43 10 43.6 9c1 -1 1 -1 1 -0.5 0 0 4 3 7.5 6 4 3 7 6 7.5 6 0 0 13.6 3 29.5 6 16 3 32 6 35 7l6 1 3 -1c41.6 -14.6 68 -23 85 -28 15 -4 24 -5 32 -2.5 7 2 10 5 8 8 -1.6 2.5 -4.6 4.6 -10.6 7.5 -6 3 -10 4 -25 9 -8 2.6 -16.6 6 -39 14 -67 25 -88 31 -121.6 36 -14.5 2 -24 3 -34 3 -5 0 -5.5 0 -6 -0.5z"
        )

        /**
         * The airplaneColors (from the Java version).
         */
        @JvmStatic protected var airplaneColors = intArrayOf(
            0xffffffff.toInt()
        )

        /**
         * The cloudPaths (from the Java version).
         */
        @JvmStatic protected var cloudPaths = arrayOf(
            "M552 1A65 65 0 0 0 504 22A51 51 0 0 0 492 20A51 51 0 0 0 442 71A51 51 0 0 0 492 121A51 51 0 0 0 511 118A65 65 0 0 0 517 122L586 122A65 65 0 0 0 600 111A60 60 0 0 0 608 122L696 122A60 60 0 0 0 712 82A60 60 0 0 0 652 22A60 60 0 0 0 611 39A65 65 0 0 0 552 1zM246 2A55 55 0 0 0 195 37A47 47 0 0 0 168 28A47 47 0 0 0 121 75A47 47 0 0 0 168 121A47 47 0 0 0 209 97A55 55 0 0 0 246 111A55 55 0 0 0 269 107A39 39 0 0 0 281 122L328 122A39 39 0 0 0 343 91A39 39 0 0 0 304 52A39 39 0 0 0 301 52A55 55 0 0 0 246 2z",
            "m507 31a53 53 0 0 0 -53 53 53 53 0 0 0 16 38h75a53 53 0 0 0 2 -2 28 28 0 0 0 1 2h213a97 97 0 0 0 -87 -54.8 97 97 0 0 0 -73 34 28 28 0 0 0 -27 -19 28 28 0 0 0 -13 3 53 53 0 0 0 0 -1 53 53 0 0 0 -53 -53zM206 32a54 54 0 0 0 -50 34 74.9 74.9 0 0 0 -47 -17 74.9 74.9 0 0 0 -74 61 31 31 0 0 0 -10 -2 31 31 0 0 0 -26 14L301 122a38 38 0 0 0 0 -4 38 38 0 0 0 -38 -38 38 38 0 0 0 -4 0 54 54 0 0 0 -54 -49z",
            "m424 37a53 53 0 0 0 -41 19 53 53 0 0 0 -1 2 63 63 0 0 0 -5 0 63 63 0 0 0 -61 50 63 63 0 0 0 -1 4 16 16 0 0 0 -10 -4 16 16 0 0 0 -8 2 21 21 0 0 0 -18 -11 21 21 0 0 0 -19 13 22 22 0 0 0 -7 -1 22 22 0 0 0 -19 11L523 122a44 44 0 0 0 -43 -37 44 44 0 0 0 -3 0 53 53 0 0 0 -53 -48zM129 38a50 50 0 0 0 -50 50 50 50 0 0 0 2 15 15 16 0 0 0 -6 2 15 16 0 0 0 -1 1 17 16 0 0 0 -12 -5 17 16 0 0 0 -16 14 20 16 0 0 0 -15 7L224 122a43 43 0 0 0 1 -10 43 43 0 0 0 -43 -43 43 43 0 0 0 -7 1 50 50 0 0 0 -47 -32zM632 83a64 64 0 0 0 -45 18 27 27 0 0 0 -11 -2 27 27 0 0 0 -23 13 17 17 0 0 0 -7 -1 17 17 0 0 0 -16 12h160a64 64 0 0 0 -59 -39z"
        )

        /**
         * The cloudColors (from the Java version).
         */
        @JvmStatic protected var cloudColors = intArrayOf(
            0xaac7dcf1.toInt(),0xdde8f3fd.toInt(),0xfffdfdfd.toInt()
        )
    }
}
