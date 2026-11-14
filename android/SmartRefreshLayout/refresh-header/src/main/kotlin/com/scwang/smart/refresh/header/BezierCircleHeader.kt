// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.util.AttributeSet
import android.view.animation.AccelerateInterpolator
import android.view.animation.DecelerateInterpolator
import androidx.annotation.ColorInt
import androidx.core.graphics.ColorUtils
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.simple.SimpleComponent
import com.scwang.smart.refresh.layout.util.SmartUtil
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sqrt

/**
 * A wave that springs a ball up, which spins while refreshing, from CircleRefreshLayout (`BezierCircleHeader`).
 */
open class BezierCircleHeader @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    SimpleComponent(context, attrs, 0), RefreshHeader {

    /**
     * The path being built.
     */
    @JvmField protected var mPath = Path()

    /**
     * The wave's paint.
     */
    @JvmField protected var mBackPaint = Paint().apply {
        color = 0xff11bbff.toInt()
        isAntiAlias = true
    }

    /**
     * The ball's paint.
     */
    @JvmField protected var mFrontPaint = Paint().apply {
        color = 0xffffffff.toInt()
        isAntiAlias = true
    }

    /**
     * The spinning ring's paint.
     */
    @JvmField protected var mOuterPaint = Paint().apply {
        isAntiAlias = true
        color = 0xffffffff.toInt()
        style = Paint.Style.STROKE
        strokeWidth = SmartUtil.dp2px(2f).toFloat()
    }

    /**
     * The current offset.
     */
    @JvmField protected var mHeight = 0

    /**
     * The wave's height.
     */
    @JvmField protected var mWaveHeight = 0f

    /**
     * The header's height.
     */
    @JvmField protected var mHeadHeight = 0f

    /**
     * The spring's progress.
     */
    @JvmField protected var mSpringRatio = 0f

    /**
     * The finish animation's progress.
     */
    @JvmField protected var mFinishRatio = 0f

    /**
     * The ball's y.
     */
    @JvmField protected var mBollY = 0f

    /**
     * The ball's radius.
     */
    @JvmField protected var mBollRadius = 0f

    /**
     * Shows the spinning ring.
     */
    @JvmField protected var mShowOuter = false

    /**
     * Shows the ball.
     */
    @JvmField protected var mShowBoll = false

    /**
     * Shows the ball's tail.
     */
    @JvmField protected var mShowBollTail = false

    /**
     * The ring's end angle.
     */
    @JvmField protected var mRefreshStop = 90

    /**
     * The ring's start angle.
     */
    @JvmField protected var mRefreshStart = 90

    /**
     * True while the ring grows.
     */
    @JvmField protected var mOuterIsStart = true

    /**
     * True while the wave follows the finger.
     */
    @JvmField protected var mWavePulling = false

    /**
     * The layout's kernel, once initialized.
     */
    @JvmField protected var mKernel: RefreshKernel? = null

    init {
        mSpinnerStyle = SpinnerStyle.FixedBehind
        minimumHeight = SmartUtil.dp2px(100f)
        initRefreshAccessibility()
    }

    override fun dispatchDraw(canvas: Canvas) {
        val viewWidth = width
        val viewHeight = mHeight
        val footer = mKernel?.refreshLayout?.refreshFooter?.let { this == it } == true
        if (footer) {
            canvas.save()
            canvas.translate(0f, height.toFloat())
            canvas.scale(1f, -1f)
        }
        if (isInEditMode) {
            mShowBoll = true
            mShowOuter = true
            mHeadHeight = viewHeight.toFloat()
            mRefreshStop = 270
            mBollY = mHeadHeight / 2
            mBollRadius = mHeadHeight / 6
        }
        drawWave(canvas, viewWidth, viewHeight)
        drawSpringUp(canvas, viewWidth)
        drawBoll(canvas, viewWidth)
        drawOuter(canvas, viewWidth)
        drawFinish(canvas, viewWidth)
        if (footer) canvas.restore()
        super.dispatchDraw(canvas)
    }

    /**
     * Draws the wave.
     */
    protected open fun drawWave(canvas: Canvas, viewWidth: Int, viewHeight: Int) {
        val baseHeight = min(mHeadHeight, viewHeight.toFloat())
        if (mWaveHeight != 0f) {
            mPath.reset()
            mPath.lineTo(viewWidth.toFloat(), 0f)
            mPath.lineTo(viewWidth.toFloat(), baseHeight)
            mPath.quadTo(viewWidth / 2f, baseHeight + mWaveHeight * 2, 0f, baseHeight)
            mPath.close()
            canvas.drawPath(mPath, mBackPaint)
        } else {
            canvas.drawRect(0f, 0f, viewWidth.toFloat(), baseHeight, mBackPaint)
        }
    }

    /**
     * Draws the ball springing up.
     */
    protected open fun drawSpringUp(canvas: Canvas, viewWidth: Int) {
        if (mSpringRatio > 0) {
            val leftX = viewWidth / 2f - 4 * mBollRadius + mSpringRatio * 3 * mBollRadius
            if (mSpringRatio < 0.9) {
                mPath.reset()
                mPath.moveTo(leftX, mBollY)
                mPath.quadTo(viewWidth / 2f, mBollY - mBollRadius * mSpringRatio * 2, viewWidth - leftX, mBollY)
                canvas.drawPath(mPath, mFrontPaint)
            } else {
                canvas.drawCircle(viewWidth / 2f, mBollY, mBollRadius, mFrontPaint)
            }
        }
    }

    /**
     * Draws the ball.
     */
    protected open fun drawBoll(canvas: Canvas, viewWidth: Int) {
        if (mShowBoll) {
            canvas.drawCircle(viewWidth / 2f, mBollY, mBollRadius, mFrontPaint)
            drawBollTail(canvas, viewWidth, (mHeadHeight + mWaveHeight) / mHeadHeight)
        }
    }

    /**
     * Draws the ball's tail down to the wave.
     */
    protected open fun drawBollTail(canvas: Canvas, viewWidth: Int, fraction: Float) {
        if (mShowBollTail) {
            val bottom = mHeadHeight + mWaveHeight
            val startY = mBollY + mBollRadius * fraction / 2
            val startX = viewWidth / 2f + sqrt(mBollRadius * mBollRadius * (1 - fraction * fraction / 4))
            val bezier1x = viewWidth / 2f + (mBollRadius * 3 / 4) * (1 - fraction)
            val bezier2x = bezier1x + mBollRadius
            mPath.reset()
            mPath.moveTo(startX, startY)
            mPath.quadTo(bezier1x, bottom, bezier2x, bottom)
            mPath.lineTo(viewWidth - bezier2x, bottom)
            mPath.quadTo(viewWidth - bezier1x, bottom, viewWidth - startX, startY)
            canvas.drawPath(mPath, mFrontPaint)
        }
    }

    /**
     * Draws the spinning ring and schedules the next frame.
     */
    protected open fun drawOuter(canvas: Canvas, viewWidth: Int) {
        if (mShowOuter) {
            val outerR = mBollRadius + mOuterPaint.strokeWidth * 2
            mRefreshStart = (mRefreshStart + if (mOuterIsStart) 3 else 10) % 360
            mRefreshStop = (mRefreshStop + if (mOuterIsStart) 10 else 3) % 360
            var swipe = mRefreshStop - mRefreshStart
            if (swipe < 0) swipe += 360
            canvas.drawArc(
                RectF(viewWidth / 2f - outerR, mBollY - outerR, viewWidth / 2f + outerR, mBollY + outerR),
                mRefreshStart.toFloat(), swipe.toFloat(), false, mOuterPaint,
            )
            if (swipe >= TARGET_DEGREE) mOuterIsStart = false else if (swipe <= 10) mOuterIsStart = true
            invalidate()
        }
    }

    /**
     * Draws the finish: the ring fades, the ball drops back into the wave.
     */
    protected open fun drawFinish(canvas: Canvas, viewWidth: Int) {
        if (mFinishRatio > 0) {
            val beforeColor = mOuterPaint.color
            if (mFinishRatio < 0.3) {
                canvas.drawCircle(viewWidth / 2f, mBollY, mBollRadius, mFrontPaint)
                val outerR = (mBollRadius + mOuterPaint.strokeWidth * 2 * (1 + mFinishRatio / 0.3f)).toInt()
                mOuterPaint.color = ColorUtils.setAlphaComponent(beforeColor, (0xff * (1 - mFinishRatio / 0.3f)).toInt())
                canvas.drawArc(RectF(viewWidth / 2f - outerR, mBollY - outerR, viewWidth / 2f + outerR, mBollY + outerR), 0f, 360f, false, mOuterPaint)
            }
            mOuterPaint.color = beforeColor
            if (mFinishRatio >= 0.3 && mFinishRatio < 0.7) {
                val fraction = (mFinishRatio - 0.3f) / 0.4f
                mBollY = (mHeadHeight / 2 + (mHeadHeight - mHeadHeight / 2) * fraction).toInt().toFloat()
                canvas.drawCircle(viewWidth / 2f, mBollY, mBollRadius, mFrontPaint)
                if (mBollY >= mHeadHeight - mBollRadius * 2) {
                    mShowBollTail = true
                    drawBollTail(canvas, viewWidth, fraction)
                }
                mShowBollTail = false
            }
            if (mFinishRatio >= 0.7 && mFinishRatio <= 1) {
                val fraction = (mFinishRatio - 0.7f) / 0.3f
                val leftX = (viewWidth / 2f - mBollRadius - 2 * mBollRadius * fraction).toInt().toFloat()
                mPath.reset()
                mPath.moveTo(leftX, mHeadHeight)
                mPath.quadTo(viewWidth / 2f, mHeadHeight - mBollRadius * (1 - fraction), viewWidth - leftX, mHeadHeight)
                canvas.drawPath(mPath, mFrontPaint)
            }
        }
    }

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        mKernel = kernel
    }

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        mHeight = offset
        if (isDragging || mWavePulling) {
            mWavePulling = true
            mHeadHeight = height.toFloat()
            mWaveHeight = max(offset - height, 0) * .8f
        }
        invalidate()
    }

    override fun onReleased(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        mWavePulling = false
        mHeadHeight = height.toFloat()
        mBollRadius = height / 6f
        val reboundHeight = min(mWaveHeight * 0.8f, mHeadHeight / 2)
        val waveAnimator = ValueAnimator.ofFloat(mWaveHeight, 0f, -reboundHeight, 0f, -(reboundHeight * 0.4f), 0f)
        waveAnimator.addUpdateListener(object : ValueAnimator.AnimatorUpdateListener {
            var speed = 0f
            var springBollY = 0f
            var springRatio = 0f

            // 0: not sprung yet; 1: springing up; 2: stopped at the top.
            var status = 0

            override fun onAnimationUpdate(animation: ValueAnimator) {
                val curValue = animation.animatedValue as Float
                if (status == 0 && curValue <= 0) {
                    status = 1
                    speed = abs(curValue - mWaveHeight)
                }
                if (status == 1) {
                    springRatio = -curValue / reboundHeight
                    if (springRatio >= mSpringRatio) {
                        mSpringRatio = springRatio
                        mBollY = mHeadHeight + curValue
                        speed = abs(curValue - mWaveHeight)
                    } else {
                        status = 2
                        mSpringRatio = 0f
                        mShowBoll = true
                        mShowBollTail = true
                        springBollY = mBollY
                    }
                }
                if (status == 2 && mBollY > mHeadHeight / 2) {
                    mBollY = max(mHeadHeight / 2, mBollY - speed)
                    val bally = animation.animatedFraction * (mHeadHeight / 2 - springBollY) + springBollY
                    if (mBollY > bally) mBollY = bally
                }
                if (mShowBollTail && curValue < mWaveHeight) {
                    mShowOuter = true
                    mShowBollTail = false
                    mOuterIsStart = true
                    mRefreshStart = 90
                    mRefreshStop = 90
                }
                if (!mWavePulling) {
                    mWaveHeight = curValue
                    invalidate()
                }
            }
        })
        waveAnimator.interpolator = DecelerateInterpolator()
        waveAnimator.duration = 1000
        waveAnimator.start()
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        // Clear the finish, so the next pull does not draw the last frame of the previous one (the Java version kept
        // it).
        if (newState == RefreshState.None) mFinishRatio = 0f
        updateRefreshAccessibility(newState)
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        mShowBoll = false
        mShowOuter = false
        val durationFinish = 800
        ValueAnimator.ofFloat(0f, 1f).apply {
            addUpdateListener {
                mFinishRatio = it.animatedValue as Float
                invalidate()
            }
            interpolator = AccelerateInterpolator()
            duration = durationFinish.toLong()
            start()
        }
        return durationFinish
    }

    @Deprecated("Only called by the layout; use RefreshLayout.setPrimaryColorsId.")
    override fun setPrimaryColors(@ColorInt vararg colors: Int) {
        if (colors.isNotEmpty()) {
            mBackPaint.color = colors[0]
            if (colors.size > 1) {
                mFrontPaint.color = colors[1]
                mOuterPaint.color = colors[1]
            }
        }
    }

    /**
     * The ring's largest sweep.
     */
    companion object {
        /**
         * The ring's largest sweep, in degrees.
         */
        @JvmStatic protected val TARGET_DEGREE = 270
    }
}
