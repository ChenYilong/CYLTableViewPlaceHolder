// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header.waterdrop

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.view.View
import android.view.animation.DecelerateInterpolator
import androidx.annotation.ColorInt
import com.scwang.smart.refresh.layout.util.SmartUtil
import kotlin.math.asin
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.pow
import kotlin.math.sin

/**
 * The water drop in the middle of the header, from WaterDropListView (`WaterDropView`).
 */
open class WaterDropView(context: Context) : View(context) {

    /**
     * The upper circle.
     */
    @JvmField protected var topCircle = Circle()

    /**
     * The lower circle.
     */
    @JvmField protected var bottomCircle = Circle()

    /**
     * The drop's path.
     */
    @JvmField protected var mPath = Path()

    /**
     * The paint.
     */
    @JvmField protected var mPaint = Paint()

    /**
     * The circles' largest radius.
     */
    @JvmField protected var mMaxCircleRadius: Int

    /**
     * The circles' smallest radius.
     */
    @JvmField protected var mMinCircleRadius: Int

    init {
        STROKE_WIDTH = SmartUtil.dp2px(1f)
        mPaint.color = Color.GRAY
        mPaint.isAntiAlias = true
        mPaint.style = Paint.Style.FILL_AND_STROKE
        mPaint.strokeWidth = STROKE_WIDTH.toFloat()
        mPaint.setShadowLayer(STROKE_WIDTH.toFloat(), STROKE_WIDTH / 2f, STROKE_WIDTH.toFloat(), 0x99000000.toInt())
        setLayerType(LAYER_TYPE_SOFTWARE, null)
        val padding = 4 * STROKE_WIDTH
        setPadding(padding, padding, padding, padding)
        mMaxCircleRadius = SmartUtil.dp2px(20f)
        mMinCircleRadius = mMaxCircleRadius / 5
        topCircle.radius = mMaxCircleRadius.toFloat()
        bottomCircle.radius = mMaxCircleRadius.toFloat()
        topCircle.x = (STROKE_WIDTH + mMaxCircleRadius).toFloat()
        topCircle.y = (STROKE_WIDTH + mMaxCircleRadius).toFloat()
        bottomCircle.x = topCircle.x
        bottomCircle.y = topCircle.y
        // A decoration of the header, which carries the accessibility description.
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    /**
     * The circles' largest radius.
     */
    open val maxCircleRadius: Int get() = mMaxCircleRadius

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        // Width: the larger diameter; height: top radius + the centers' distance + bottom radius.
        val width = (mMaxCircleRadius + STROKE_WIDTH) * 2
        val height = ceil(bottomCircle.y + bottomCircle.radius + STROKE_WIDTH * 2).toInt()
        super.setMeasuredDimension(
            width + paddingLeft + paddingRight,
            resolveSize(height + paddingTop + paddingBottom, heightMeasureSpec),
        )
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        super.onLayout(changed, left, top, right, bottom)
        updateCompleteState(height)
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        canvas.save()
        if (height <= topCircle.radius * 2 + paddingTop + paddingBottom) {
            canvas.translate(paddingLeft.toFloat(), height - topCircle.radius * 2 - paddingBottom)
            canvas.drawCircle(topCircle.x, topCircle.y, topCircle.radius, mPaint)
        } else {
            canvas.translate(paddingLeft.toFloat(), paddingTop.toFloat())
            makeBezierPath()
            canvas.drawPath(mPath, mPaint)
        }
        canvas.restore()
    }

    /**
     * Builds the drop: both circles and the curves along their tangents.
     */
    protected open fun makeBezierPath() {
        mPath.reset()
        mPath.addCircle(topCircle.x, topCircle.y, topCircle.radius, Path.Direction.CCW)
        if (bottomCircle.y > topCircle.y + SmartUtil.dp2px(1f)) {
            mPath.addCircle(bottomCircle.x, bottomCircle.y, bottomCircle.radius, Path.Direction.CCW)
            val angle = getAngle()
            val topX1 = (topCircle.x - topCircle.radius * cos(angle)).toFloat()
            val topY1 = (topCircle.y + topCircle.radius * sin(angle)).toFloat()
            val topX2 = (topCircle.x + topCircle.radius * cos(angle)).toFloat()
            val bottomX1 = (bottomCircle.x - bottomCircle.radius * cos(angle)).toFloat()
            val bottomY1 = (bottomCircle.y + bottomCircle.radius * sin(angle)).toFloat()
            val bottomX2 = (bottomCircle.x + bottomCircle.radius * cos(angle)).toFloat()
            mPath.moveTo(topCircle.x, topCircle.y)
            mPath.lineTo(topX1, topY1)
            mPath.quadTo(bottomCircle.x - bottomCircle.radius, (bottomCircle.y + topCircle.y) / 2, bottomX1, bottomY1)
            mPath.lineTo(bottomX2, bottomY1)
            mPath.quadTo(bottomCircle.x + bottomCircle.radius, (bottomCircle.y + topY1) / 2, topX2, topY1)
        }
        mPath.close()
    }

    /**
     * The angle between the circles' tangent and the line through their centers.
     */
    protected open fun getAngle(): Double {
        if (bottomCircle.radius > topCircle.radius) return 0.0
        return asin(((topCircle.radius - bottomCircle.radius) / (bottomCircle.y - topCircle.y)).toDouble())
    }

    /**
     * The bounce back: both radii grow back and the lower circle rises into the upper one.
     */
    open fun createAnimator(): ValueAnimator = ValueAnimator.ofFloat(1f, 0.001f).setDuration(BACK_ANIM_DURATION.toLong()).apply {
        interpolator = DecelerateInterpolator()
        addUpdateListener { animator ->
            updateCompleteState(animator.animatedValue as Float)
            postInvalidate()
        }
    }

    /**
     * Does nothing; kept from the Java version.
     */
    @Suppress("UNUSED_PARAMETER")
    open fun updateCompleteState(offset: Int, maxHeight: Int) {
    }

    /**
     * Sets the drop's stretch from [percent], 0 to 1.
     */
    open fun updateCompleteState(percent: Float) {
        topCircle.radius = (mMaxCircleRadius - 0.25 * percent * mMaxCircleRadius).toFloat()
        bottomCircle.radius = (mMinCircleRadius - mMaxCircleRadius) * percent + mMaxCircleRadius
        bottomCircle.y = topCircle.y + 4 * percent * mMaxCircleRadius
    }

    /**
     * Sets the drop's stretch from the view's [height].
     */
    open fun updateCompleteState(height: Int) {
        val space = (mMaxCircleRadius * 2 + paddingTop + paddingBottom).toFloat()
        if (height < space) {
            topCircle.radius = mMaxCircleRadius.toFloat()
            bottomCircle.radius = mMaxCircleRadius.toFloat()
            bottomCircle.y = topCircle.y
        } else {
            val limit = (mMaxCircleRadius - mMinCircleRadius).toFloat()
            val x = max(0f, height - space)
            val y = (limit * (1 - 100.0.pow((-x / SmartUtil.dp2px(200f)).toDouble()))).toFloat()
            topCircle.radius = mMaxCircleRadius - y / 4
            bottomCircle.radius = mMaxCircleRadius - y
            bottomCircle.y = height - paddingTop - paddingBottom - bottomCircle.radius
        }
    }

    /**
     * The upper circle.
     */
    open fun getTopCircle(): Circle = topCircle

    /**
     * The lower circle.
     */
    open fun getBottomCircle(): Circle = bottomCircle

    /**
     * The drop's color.
     */
    open fun setIndicatorColor(@ColorInt color: Int) {
        mPaint.color = color
    }

    /**
     * The drop's color.
     */
    open fun getIndicatorColor(): Int = mPaint.color

    /**
     * The stroke width and the bounce's duration.
     */
    companion object {
        /**
         * The outline's width; set from 1 dp by each view.
         */
        @JvmStatic protected var STROKE_WIDTH = 2

        /**
         * The bounce back's duration, in milliseconds.
         */
        @JvmStatic protected val BACK_ANIM_DURATION = 180
    }
}
