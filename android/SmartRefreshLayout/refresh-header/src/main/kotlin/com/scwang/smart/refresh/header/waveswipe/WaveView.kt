/*
 * Copyright (C) 2015 RECRUIT LIFESTYLE CO., LTD.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
// Translated to Kotlin from SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0).
package com.scwang.smart.refresh.header.waveswipe

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.view.View
import android.view.ViewTreeObserver
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.BounceInterpolator
import androidx.annotation.ColorInt
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow
import kotlin.math.sqrt

/**
 * Draws the wave and the falling circle, by amyu (`WaveView`).
 */
open class WaveView(context: Context) : View(context), ViewTreeObserver.OnPreDrawListener {

    /**
     * The falling circle's radius.
     */
    @JvmField protected var mDropCircleRadius = 100f

    /**
     * The paint for everything.
     */
    @JvmField protected var mPaint = Paint()

    /**
     * The wave.
     */
    @JvmField protected var mWavePath = Path()

    /**
     * The tangents of the falling circle.
     */
    @JvmField protected var mDropTangentPath = Path()

    /**
     * The falling circle.
     */
    @JvmField protected var mDropCirclePath = Path()

    /**
     * The shadow.
     */
    @JvmField protected var mShadowPath = Path()

    /**
     * The falling circle's bounds.
     */
    @JvmField protected var mDropRect = RectF()

    /**
     * The view's width.
     */
    @JvmField protected var mWidth = 0

    /**
     * The circle's center y while it falls.
     */
    @JvmField protected var mCurrentCircleCenterY = 0f

    /**
     * How far the circle falls.
     */
    @JvmField protected var mMaxDropHeight = 0

    /**
     * True while refreshing from code.
     */
    @JvmField protected var mIsManualRefreshing = false

    /**
     * True when the fall height was updated.
     */
    @JvmField protected var mDropHeightUpdated = false

    /**
     * The pending fall height.
     */
    @JvmField protected var mUpdateMaxDropHeight = 0

    /**
     * The top vertex of the triangle following the circle.
     */
    @JvmField protected var mDropVertexAnimator: ValueAnimator = ValueAnimator.ofFloat(0f, 0f)

    /**
     * The fallen circle's horizontal stretch.
     */
    @JvmField protected var mDropBounceVerticalAnimator: ValueAnimator = ValueAnimator.ofFloat(0f, 0f)

    /**
     * The fallen circle's vertical stretch.
     */
    @JvmField protected var mDropBounceHorizontalAnimator: ValueAnimator = ValueAnimator.ofFloat(0f, 0f)

    /**
     * The falling circle's center.
     */
    @JvmField protected var mDropCircleAnimator: ValueAnimator = ValueAnimator.ofFloat(-1000f, -1000f)

    /**
     * Removes the fallen circle.
     */
    @JvmField protected var mDisappearCircleAnimator: ValueAnimator = ValueAnimator.ofFloat(1f, 1f)

    /**
     * The wave going back.
     */
    @JvmField protected var mWaveReverseAnimator: ValueAnimator? = null

    /**
     * Redraws on each animation frame.
     */
    @JvmField protected var mAnimatorUpdateListener = ValueAnimator.AnimatorUpdateListener { postInvalidate() }

    init {
        val density = resources.displayMetrics.density
        mPaint.color = 0xff2196F3.toInt()
        mPaint.isAntiAlias = true
        mPaint.style = Paint.Style.FILL
        mPaint.setShadowLayer((0.5f + 2.0f * density).toInt().toFloat(), 0f, 0f, SHADOW_COLOR)
        resetAnimator()
        setLayerType(LAYER_TYPE_SOFTWARE, null)
        viewTreeObserver.addOnPreDrawListener(this)
        // A decoration of the header, which carries the accessibility description.
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        mWidth = w
        mDropCircleRadius = w / 14.4f
        updateMaxDropHeight(min(min(w, h).toFloat(), height - mDropCircleRadius).toInt())
        super.onSizeChanged(w, h, oldw, oldh)
    }

    override fun onPreDraw(): Boolean {
        viewTreeObserver.removeOnPreDrawListener(this)
        if (mDropHeightUpdated) updateMaxDropHeight(mUpdateMaxDropHeight)
        return false
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        canvas.drawPath(mWavePath, mPaint)
        if (!isInEditMode) {
            mWavePath.rewind()
            mDropTangentPath.rewind()
            mDropCirclePath.rewind()
        }
        val circleCenterY = mDropCircleAnimator.animatedValue as Float
        val circleCenterX = mWidth / 2f
        val scale = mDisappearCircleAnimator.animatedValue as Float
        val vertical = mDropBounceVerticalAnimator.animatedValue as Float
        val horizontal = mDropBounceHorizontalAnimator.animatedValue as Float
        mDropRect.set(
            circleCenterX - mDropCircleRadius * (1 + vertical) * scale + mDropCircleRadius * horizontal / 2,
            circleCenterY + mDropCircleRadius * (1 + horizontal) * scale - mDropCircleRadius * vertical / 2,
            circleCenterX + mDropCircleRadius * (1 + vertical) * scale - mDropCircleRadius * horizontal / 2,
            circleCenterY - mDropCircleRadius * (1 + horizontal) * scale + mDropCircleRadius * vertical / 2,
        )
        val vertex = mDropVertexAnimator.animatedValue as Float
        mDropTangentPath.moveTo(circleCenterX, vertex)
        // The circle's tangent points (p1, q) and (p2, q), from the quadratic formula.
        val q = (mDropCircleRadius.toDouble().pow(2) + circleCenterY * vertex - circleCenterY.toDouble().pow(2)) / (vertex - circleCenterY)
        val b = -2.0 * mWidth / 2
        val c = (q - circleCenterY).pow(2) + circleCenterX.toDouble().pow(2) - mDropCircleRadius.toDouble().pow(2)
        val p1 = (-b + sqrt(b * b - 4 * c)) / 2
        val p2 = (-b - sqrt(b * b - 4 * c)) / 2
        mDropTangentPath.lineTo(p1.toFloat(), q.toFloat())
        mDropTangentPath.lineTo(p2.toFloat(), q.toFloat())
        mDropTangentPath.close()
        mShadowPath.set(mDropTangentPath)
        mShadowPath.addOval(mDropRect, Path.Direction.CCW)
        mDropCirclePath.addOval(mDropRect, Path.Direction.CCW)
        canvas.drawPath(mDropTangentPath, mPaint)
        canvas.drawPath(mDropCirclePath, mPaint)
    }

    override fun onDetachedFromWindow() {
        for (animator in listOfNotNull(
            mDisappearCircleAnimator, mDropCircleAnimator, mDropVertexAnimator,
            mWaveReverseAnimator, mDropBounceHorizontalAnimator, mDropBounceVerticalAnimator,
        )) {
            animator.end()
            animator.removeAllUpdateListeners()
        }
        super.onDetachedFromWindow()
    }

    /**
     * Puts the circle back above the view.
     */
    protected open fun resetAnimator() {
        mDropVertexAnimator = ValueAnimator.ofFloat(0f, 0f)
        mDropBounceVerticalAnimator = ValueAnimator.ofFloat(0f, 0f)
        mDropBounceHorizontalAnimator = ValueAnimator.ofFloat(0f, 0f)
        mDropCircleAnimator = ValueAnimator.ofFloat(-1000f, -1000f)
        mDropCircleAnimator.start()
        mDisappearCircleAnimator = ValueAnimator.ofFloat(1f, 1f)
        // Finishes at once.
        mDisappearCircleAnimator.duration = 1
        mDisappearCircleAnimator.start()
    }

    /**
     * Stops the wave going back before a new drag.
     */
    protected open fun onPreDragWave() {
        mWaveReverseAnimator?.let { if (it.isRunning) it.cancel() }
    }

    /**
     * Shows the circle fallen, for a refresh started from code.
     */
    open fun manualRefresh() {
        if (mIsManualRefreshing) return
        mIsManualRefreshing = true
        mDropCircleAnimator = ValueAnimator.ofFloat(mMaxDropHeight.toFloat(), mMaxDropHeight.toFloat())
        mDropCircleAnimator.start()
        mDropVertexAnimator = ValueAnimator.ofFloat(mMaxDropHeight - mDropCircleRadius, mMaxDropHeight - mDropCircleRadius)
        mDropVertexAnimator.start()
        mCurrentCircleCenterY = mMaxDropHeight.toFloat()
        postInvalidate()
    }

    /**
     * Draws the wave bulging under the pull, before the drop appears.
     */
    open fun beginPhase(move1: Float) {
        val w = mWidth.toFloat()
        onPreDragWave()
        mWavePath.moveTo(0f, 0f)
        // The left half.
        mWavePath.cubicTo(w * BEGIN_PHASE_POINTS[0][0], BEGIN_PHASE_POINTS[0][1],
                w * BEGIN_PHASE_POINTS[1][0], w * (BEGIN_PHASE_POINTS[1][1] + move1),
                w * BEGIN_PHASE_POINTS[2][0], w * (BEGIN_PHASE_POINTS[2][1] + move1))
        mWavePath.cubicTo(w * BEGIN_PHASE_POINTS[3][0],
                w * (BEGIN_PHASE_POINTS[3][1] + move1), w * BEGIN_PHASE_POINTS[4][0],
                w * (BEGIN_PHASE_POINTS[4][1] + move1), w * BEGIN_PHASE_POINTS[5][0],
                w * (BEGIN_PHASE_POINTS[5][1] + move1))
        // The right half.
        mWavePath.cubicTo(w - w * BEGIN_PHASE_POINTS[4][0],
                w * (BEGIN_PHASE_POINTS[4][1] + move1), w - w * BEGIN_PHASE_POINTS[3][0],
                w * (BEGIN_PHASE_POINTS[3][1] + move1), w - w * BEGIN_PHASE_POINTS[2][0],
                w * (BEGIN_PHASE_POINTS[2][1] + move1))
        mWavePath.cubicTo(w - w * BEGIN_PHASE_POINTS[1][0],
                w * (BEGIN_PHASE_POINTS[1][1] + move1), w - w * BEGIN_PHASE_POINTS[0][0],
                BEGIN_PHASE_POINTS[0][1], w, 0f)
        postInvalidateOnAnimation()
    }

    /**
     * Draws the wave as the drop appears.
     */
    open fun appearPhase(move1: Float, move2: Float) {
        val w = mWidth.toFloat()
        onPreDragWave()
        mWavePath.moveTo(0f, 0f)
        // The left half.
        mWavePath.cubicTo(w * APPEAR_PHASE_POINTS[0][0], w * APPEAR_PHASE_POINTS[0][1],
                w * min(BEGIN_PHASE_POINTS[1][0] + move2, APPEAR_PHASE_POINTS[1][0]),
                w * max(BEGIN_PHASE_POINTS[1][1] + move1 - move2, APPEAR_PHASE_POINTS[1][1]),
                w * max(BEGIN_PHASE_POINTS[2][0] - move2, APPEAR_PHASE_POINTS[2][0]),
                w * max(BEGIN_PHASE_POINTS[2][1] + move1 - move2, APPEAR_PHASE_POINTS[2][1]))
        mWavePath.cubicTo(
                w * max(BEGIN_PHASE_POINTS[3][0] - move2, APPEAR_PHASE_POINTS[3][0]),
                w * min(BEGIN_PHASE_POINTS[3][1] + move1 + move2, APPEAR_PHASE_POINTS[3][1]),
                w * max(BEGIN_PHASE_POINTS[4][0] - move2, APPEAR_PHASE_POINTS[4][0]),
                w * min(BEGIN_PHASE_POINTS[4][1] + move1 + move2, APPEAR_PHASE_POINTS[4][1]),
                w * APPEAR_PHASE_POINTS[5][0],
                w * min(BEGIN_PHASE_POINTS[0][1] + move1 + move2, APPEAR_PHASE_POINTS[5][1]))
        // The right half.
        mWavePath.cubicTo(
                w - w * max(BEGIN_PHASE_POINTS[4][0] - move2, APPEAR_PHASE_POINTS[4][0]),
                w * min(BEGIN_PHASE_POINTS[4][1] + move1 + move2, APPEAR_PHASE_POINTS[4][1]),
                w - w * max(BEGIN_PHASE_POINTS[3][0] - move2, APPEAR_PHASE_POINTS[3][0]),
                w * min(BEGIN_PHASE_POINTS[3][1] + move1 + move2, APPEAR_PHASE_POINTS[3][1]),
                w - w * max(BEGIN_PHASE_POINTS[2][0] - move2, APPEAR_PHASE_POINTS[2][0]),
                w * max(BEGIN_PHASE_POINTS[2][1] + move1 - move2, APPEAR_PHASE_POINTS[2][1]))
        mWavePath.cubicTo(
                w - w * min(BEGIN_PHASE_POINTS[1][0] + move2, APPEAR_PHASE_POINTS[1][0]),
                w * max(BEGIN_PHASE_POINTS[1][1] + move1 - move2, APPEAR_PHASE_POINTS[1][1]),
                w - w * APPEAR_PHASE_POINTS[0][0], w * APPEAR_PHASE_POINTS[0][1], w, 0f)
        mCurrentCircleCenterY =
                w * min(BEGIN_PHASE_POINTS[3][1] + move1 + move2, APPEAR_PHASE_POINTS[3][1])
                        + mDropCircleRadius
        postInvalidateOnAnimation()
    }

    /**
     * Draws the wave as the drop grows.
     */
    open fun expandPhase(move1: Float, move2: Float, move3: Float) {
        val w = mWidth.toFloat()
        onPreDragWave()
        mWavePath.moveTo(0f, 0f)
        // The left half.
        mWavePath.cubicTo(w * EXPAND_PHASE_POINTS[0][0], w * EXPAND_PHASE_POINTS[0][1],
                w * min(
                        min(BEGIN_PHASE_POINTS[1][0] + move2, APPEAR_PHASE_POINTS[1][0]) + move3,
                        EXPAND_PHASE_POINTS[1][0]), w * max(
                        max(BEGIN_PHASE_POINTS[1][1] + move1 - move2, APPEAR_PHASE_POINTS[1][1]) - move3,
                        EXPAND_PHASE_POINTS[1][1]),
                w * max(BEGIN_PHASE_POINTS[2][0] - move2, EXPAND_PHASE_POINTS[2][0]),
                w * min(
                        max(BEGIN_PHASE_POINTS[2][1] + move1 - move2, APPEAR_PHASE_POINTS[2][1]) + move3,
                        EXPAND_PHASE_POINTS[2][1]))
        mWavePath.cubicTo(w * min(
                max(BEGIN_PHASE_POINTS[3][0] - move2, APPEAR_PHASE_POINTS[3][0]) + move3,
                EXPAND_PHASE_POINTS[3][0]), w * min(
                min(BEGIN_PHASE_POINTS[3][1] + move1 + move2, APPEAR_PHASE_POINTS[3][1]) + move3,
                EXPAND_PHASE_POINTS[3][1]),
                w * max(BEGIN_PHASE_POINTS[4][0] - move2, EXPAND_PHASE_POINTS[4][0]),
                w * min(
                        min(BEGIN_PHASE_POINTS[4][1] + move1 + move2, APPEAR_PHASE_POINTS[4][1]) + move3,
                        EXPAND_PHASE_POINTS[4][1]), w * EXPAND_PHASE_POINTS[5][0], w * min(
                        min(BEGIN_PHASE_POINTS[0][1] + move1 + move2, APPEAR_PHASE_POINTS[5][1]) + move3,
                        EXPAND_PHASE_POINTS[5][1]))

        // The right half.
        mWavePath.cubicTo(
                w - w * max(BEGIN_PHASE_POINTS[4][0] - move2, EXPAND_PHASE_POINTS[4][0]),
                w * min(
                        min(BEGIN_PHASE_POINTS[4][1] + move1 + move2, APPEAR_PHASE_POINTS[4][1]) + move3,
                        EXPAND_PHASE_POINTS[4][1]), w - w * min(
                        max(BEGIN_PHASE_POINTS[3][0] - move2, APPEAR_PHASE_POINTS[3][0]) + move3,
                        EXPAND_PHASE_POINTS[3][0]), w * min(
                        min(BEGIN_PHASE_POINTS[3][1] + move1 + move2, APPEAR_PHASE_POINTS[3][1]) + move3,
                        EXPAND_PHASE_POINTS[3][1]),
                w - w * max(BEGIN_PHASE_POINTS[2][0] - move2, EXPAND_PHASE_POINTS[2][0]),
                w * min(
                        max(BEGIN_PHASE_POINTS[2][1] + move1 - move2, APPEAR_PHASE_POINTS[2][1]) + move3,
                        EXPAND_PHASE_POINTS[2][1]))
        mWavePath.cubicTo(w - w * min(
                min(BEGIN_PHASE_POINTS[1][0] + move2, APPEAR_PHASE_POINTS[1][0]) + move3,
                EXPAND_PHASE_POINTS[1][0]), w * max(
                max(BEGIN_PHASE_POINTS[1][1] + move1 - move2, APPEAR_PHASE_POINTS[1][1]) - move3,
                EXPAND_PHASE_POINTS[1][1]), w - w * EXPAND_PHASE_POINTS[0][0],
                w * EXPAND_PHASE_POINTS[0][1], w, 0f)
        mCurrentCircleCenterY = w * min(
                min(BEGIN_PHASE_POINTS[3][1] + move1 + move2, APPEAR_PHASE_POINTS[3][1]) + move3,
                EXPAND_PHASE_POINTS[3][1]) + mDropCircleRadius
        postInvalidateOnAnimation()
    }
    /**
     * Updates how far the circle falls, from the view's [height].
     */
    protected open fun updateMaxDropHeight(height: Int) {
        if (500 * (mWidth / 1440f) > height) return
        mMaxDropHeight = min(height.toFloat(), getHeight() - mDropCircleRadius).toInt()
        if (mIsManualRefreshing) {
            mIsManualRefreshing = false
            manualRefresh()
        }
    }

    /**
     * Drops the circle and bounces it.
     */
    open fun startDropAnimation() {
        // Show the circle again.
        mDisappearCircleAnimator = ValueAnimator.ofFloat(1f, 1f)
        mDisappearCircleAnimator.duration = 1
        mDisappearCircleAnimator.start()
        mDropCircleAnimator = ValueAnimator.ofFloat(500 * (mWidth / 1440f), mMaxDropHeight.toFloat()).apply {
            duration = DROP_CIRCLE_ANIMATOR_DURATION
            addUpdateListener {
                mCurrentCircleCenterY = it.animatedValue as Float
                postInvalidateOnAnimation()
            }
            interpolator = AccelerateDecelerateInterpolator()
            start()
        }
        mDropVertexAnimator = ValueAnimator.ofFloat(0f, mMaxDropHeight - mDropCircleRadius).apply {
            duration = DROP_VERTEX_ANIMATION_DURATION
            addUpdateListener(mAnimatorUpdateListener)
            start()
        }
        mDropBounceVerticalAnimator = ValueAnimator.ofFloat(0f, 1f).apply {
            duration = DROP_BOUNCE_ANIMATOR_DURATION
            addUpdateListener(mAnimatorUpdateListener)
            interpolator = DropBounceInterpolator()
            startDelay = DROP_VERTEX_ANIMATION_DURATION
            start()
        }
        mDropBounceHorizontalAnimator = ValueAnimator.ofFloat(0f, 1f).apply {
            duration = DROP_BOUNCE_ANIMATOR_DURATION
            addUpdateListener(mAnimatorUpdateListener)
            interpolator = DropBounceInterpolator()
            startDelay = (DROP_VERTEX_ANIMATION_DURATION + DROP_BOUNCE_ANIMATOR_DURATION * 0.25).toLong()
            start()
        }
    }

    /**
     * Shrinks the fallen circle away.
     */
    open fun startDisappearCircleAnimation() {
        mDisappearCircleAnimator = ValueAnimator.ofFloat(1f, 0f).apply {
            addUpdateListener(mAnimatorUpdateListener)
            duration = DROP_REMOVE_ANIMATOR_DURATION.toLong()
            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animator: Animator) {
                    // Back to the start: the circle waits above the view.
                    resetAnimator()
                    mIsManualRefreshing = false
                }
            })
            start()
        }
    }

    /**
     * Lets the wave bounce back from [h], a share of the width.
     */
    open fun startWaveAnimation(h: Float) {
        val height = min(h, MAX_WAVE_HEIGHT) * mWidth
        mWaveReverseAnimator = ValueAnimator.ofFloat(height, 0f).apply {
            duration = WAVE_ANIMATOR_DURATION.toLong()
            addUpdateListener {
                val h1 = it.animatedValue as Float
                mWavePath.moveTo(0f, 0f)
                mWavePath.quadTo(0.25f * mWidth, 0f, 0.333f * mWidth, h1 * 0.5f)
                mWavePath.quadTo(mWidth * 0.5f, h1 * 1.4f, 0.666f * mWidth, h1 * 0.5f)
                mWavePath.quadTo(0.75f * mWidth, 0f, mWidth.toFloat(), 0f)
                postInvalidate()
            }
            interpolator = BounceInterpolator()
            start()
        }
    }

    /**
     * Drops the circle with a small wave, unless the circle is still shrinking away.
     */
    open fun animationDropCircle() {
        if (mDisappearCircleAnimator.isRunning) return
        startDropAnimation()
        startWaveAnimation(0.1f)
    }

    /**
     * The circle's center y.
     */
    open fun getCurrentCircleCenterY(): Float = mCurrentCircleCenterY

    /**
     * The shadow's [radius] and [color].
     */
    open fun setShadow(radius: Int, color: Int) {
        mPaint.setShadowLayer(radius.toFloat(), 0f, 0f, color)
    }

    /**
     * The wave's color, alpha included.
     */
    open fun setWaveColor(@ColorInt color: Int) {
        mPaint.color = color
        invalidate()
    }

    /**
     * The animation constants and the wave's Bezier points.
     */
    companion object {
        /**
         * The circle's fall, in milliseconds.
         */
        @JvmStatic protected val DROP_CIRCLE_ANIMATOR_DURATION = 500L

        /**
         * The triangle's vertex, in milliseconds.
         */
        @JvmStatic protected val DROP_VERTEX_ANIMATION_DURATION = 500L

        /**
         * The circle's bounce, in milliseconds.
         */
        @JvmStatic protected val DROP_BOUNCE_ANIMATOR_DURATION = 500L

        /**
         * The circle's removal, in milliseconds.
         */
        @JvmStatic protected val DROP_REMOVE_ANIMATOR_DURATION = 200

        /**
         * The wave's wobble, in milliseconds.
         */
        @JvmStatic protected val WAVE_ANIMATOR_DURATION = 1000

        /**
         * The wave's largest height, as a share of the width.
         */
        @JvmStatic protected val MAX_WAVE_HEIGHT = 0.2f

        /**
         * The shadow's color.
         */
        @JvmStatic protected val SHADOW_COLOR = 0x99000000.toInt()

        /**
         * The wave's points before the circle: handle, handle, anchor, twice; the right half mirrors them.
         */
        @JvmStatic protected val BEGIN_PHASE_POINTS = arrayOf(
            floatArrayOf(0.1655f, 0f), floatArrayOf(0.4188f, -0.0109f), floatArrayOf(0.4606f, -0.0049f),
            floatArrayOf(0.4893f, 0f), floatArrayOf(0.4893f, 0f), floatArrayOf(0.5f, 0f),
        )

        /**
         * The wave's points as the circle appears.
         */
        @JvmStatic protected val APPEAR_PHASE_POINTS = arrayOf(
            floatArrayOf(0.1655f, 0f), floatArrayOf(0.5237f, 0.0553f), floatArrayOf(0.4557f, 0.0936f),
            floatArrayOf(0.3908f, 0.1302f), floatArrayOf(0.4303f, 0.2173f), floatArrayOf(0.5f, 0.2173f),
        )

        /**
         * The wave's points as the circle grows.
         */
        @JvmStatic protected val EXPAND_PHASE_POINTS = arrayOf(
            floatArrayOf(0.1655f, 0f), floatArrayOf(0.5909f, 0.0000f), floatArrayOf(0.4557f, 0.1642f),
            floatArrayOf(0.3941f, 0.2061f), floatArrayOf(0.4303f, 0.2889f), floatArrayOf(0.5f, 0.2889f),
        )
    }
}
