// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.drawable

import android.animation.ValueAnimator
import android.graphics.Canvas
import android.graphics.ColorFilter
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PixelFormat
import android.graphics.drawable.Animatable
import android.graphics.drawable.Drawable
import kotlin.math.max

/**
 * A drawable that draws with one paint of one color (`PaintDrawable`).
 */
abstract class PaintDrawable protected constructor() : Drawable() {
    /**
     * The paint: filled, anti-aliased, gray by default.
     */
    @JvmField protected var mPaint = Paint().apply {
        style = Paint.Style.FILL
        isAntiAlias = true
        color = 0xffaaaaaa.toInt()
    }

    /**
     * The color to draw with.
     */
    open fun setColor(color: Int) {
        mPaint.color = color
    }

    override fun setAlpha(alpha: Int) {
        mPaint.alpha = alpha
    }

    override fun setColorFilter(colorFilter: ColorFilter?) {
        mPaint.colorFilter = colorFilter
    }

    @Deprecated("Deprecated in Drawable")
    override fun getOpacity(): Int = PixelFormat.TRANSLUCENT
}

/**
 * The classic spinner: twelve bars turning in steps (`ProgressDrawable`).
 */
open class ProgressDrawable : PaintDrawable(), Animatable, ValueAnimator.AnimatorUpdateListener {
    /**
     * The width the path was made for.
     */
    @JvmField protected var mWidth = 0

    /**
     * The height the path was made for.
     */
    @JvmField protected var mHeight = 0

    /**
     * The current turn, in steps of 30 degrees.
     */
    @JvmField protected var mProgressDegree = 0

    /**
     * The animator of the turn.
     */
    @JvmField protected var mValueAnimator: ValueAnimator = ValueAnimator.ofInt(30, 3600).apply {
        duration = 10000
        interpolator = null
        repeatCount = ValueAnimator.INFINITE
        repeatMode = ValueAnimator.RESTART
    }

    /**
     * One bar.
     */
    @JvmField protected var mPath = Path()

    override fun onAnimationUpdate(animation: ValueAnimator) {
        val value = animation.animatedValue as Int
        mProgressDegree = 30 * (value / 30)
        invalidateSelf()
    }

    override fun draw(canvas: Canvas) {
        val width = bounds.width()
        val height = bounds.height()
        val r = max(1f, width / 22f)
        if (mWidth != width || mHeight != height) {
            mPath.reset()
            mPath.addCircle(width - r, height / 2f, r, Path.Direction.CW)
            mPath.addRect(width - 5 * r, height / 2f - r, width - r, height / 2f + r, Path.Direction.CW)
            mPath.addCircle(width - 5 * r, height / 2f, r, Path.Direction.CW)
            mWidth = width
            mHeight = height
        }
        canvas.save()
        canvas.rotate(mProgressDegree.toFloat(), width / 2f, height / 2f)
        for (i in 0 until 12) {
            mPaint.alpha = (i + 5) * 0x11
            canvas.rotate(30f, width / 2f, height / 2f)
            canvas.drawPath(mPath, mPaint)
        }
        canvas.restore()
    }

    override fun start() {
        if (!mValueAnimator.isRunning) {
            mValueAnimator.addUpdateListener(this)
            mValueAnimator.start()
        }
    }

    override fun stop() {
        if (mValueAnimator.isRunning) {
            mValueAnimator.removeAllListeners()
            mValueAnimator.removeAllUpdateListeners()
            mValueAnimator.cancel()
        }
    }

    override fun isRunning(): Boolean = mValueAnimator.isRunning
}
