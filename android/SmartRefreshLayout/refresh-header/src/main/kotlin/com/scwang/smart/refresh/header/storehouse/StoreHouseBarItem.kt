// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header.storehouse

import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.PointF
import android.view.animation.Animation
import android.view.animation.Transformation
import java.util.Random

/**
 * One bar of the StoreHouse header, with its fade animation (`StoreHouseBarItem`).
 */
open class StoreHouseBarItem(
    /**
     * The bar's index.
     */
    @JvmField var index: Int,
    start: PointF,
    end: PointF,
    color: Int,
    lineWidth: Int,
) : Animation() {

    /**
     * The bar's middle.
     */
    @JvmField var midPoint = PointF((start.x + end.x) / 2, (start.y + end.y) / 2)

    /**
     * The bar's horizontal offset before it drops in.
     */
    @JvmField var translationX = 0f

    /**
     * The paint.
     */
    @JvmField protected val mPaint = Paint()

    /**
     * The fade's start alpha.
     */
    @JvmField protected var mFromAlpha = 1.0f

    /**
     * The fade's end alpha.
     */
    @JvmField protected var mToAlpha = 0.4f

    /**
     * The start, relative to the middle.
     */
    @JvmField protected var mCStartPoint = PointF(start.x - midPoint.x, start.y - midPoint.y)

    /**
     * The end, relative to the middle.
     */
    @JvmField protected var mCEndPoint = PointF(end.x - midPoint.x, end.y - midPoint.y)

    init {
        setColor(color)
        setLineWidth(lineWidth)
        mPaint.isAntiAlias = true
        mPaint.style = Paint.Style.STROKE
    }

    /**
     * The bar's width.
     */
    open fun setLineWidth(width: Int) {
        mPaint.strokeWidth = width.toFloat()
    }

    /**
     * The bar's color.
     */
    open fun setColor(color: Int) {
        mPaint.color = color
    }

    /**
     * Picks a new random horizontal offset, up to [horizontalRandomness].
     */
    open fun resetPosition(horizontalRandomness: Int) {
        translationX = (-Random().nextInt(horizontalRandomness) + horizontalRandomness).toFloat()
    }

    override fun applyTransformation(interpolatedTime: Float, t: Transformation) {
        setAlpha(mFromAlpha + (mToAlpha - mFromAlpha) * interpolatedTime)
    }

    /**
     * Fades the bar from [fromAlpha] to [toAlpha].
     */
    open fun start(fromAlpha: Float, toAlpha: Float) {
        mFromAlpha = fromAlpha
        mToAlpha = toAlpha
        super.start()
    }

    /**
     * The bar's alpha, 0 to 1.
     */
    open fun setAlpha(alpha: Float) {
        mPaint.alpha = (alpha * 255).toInt()
    }

    /**
     * Draws the bar around the canvas origin.
     */
    open fun draw(canvas: Canvas) {
        canvas.drawLine(mCStartPoint.x, mCStartPoint.y, mCEndPoint.x, mCEndPoint.y, mPaint)
    }
}
