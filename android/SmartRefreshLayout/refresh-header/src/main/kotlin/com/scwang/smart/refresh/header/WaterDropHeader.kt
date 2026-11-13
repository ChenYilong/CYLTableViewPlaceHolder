// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.content.Context
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.View
import android.view.View.MeasureSpec.AT_MOST
import android.view.View.MeasureSpec.EXACTLY
import android.view.View.MeasureSpec.getSize
import android.view.View.MeasureSpec.makeMeasureSpec
import android.widget.ImageView
import androidx.annotation.ColorInt
import com.scwang.smart.drawable.ProgressDrawable
import com.scwang.smart.refresh.header.material.MaterialProgressDrawable
import com.scwang.smart.refresh.header.waterdrop.WaterDropView
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

/**
 * The header with a stretching water drop, from WaterDropListView (`WaterDropHeader`).
 */
open class WaterDropHeader @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    SimpleComponent(context, attrs, 0), RefreshHeader {

    /**
     * The layout's state.
     */
    @JvmField protected var mState: RefreshState? = null

    /**
     * The arrow's view.
     */
    @JvmField protected var mImageView: ImageView

    /**
     * The drop.
     */
    @JvmField protected var mWaterDropView: WaterDropView

    /**
     * The spinner while refreshing.
     */
    @JvmField protected var mProgressDrawable: ProgressDrawable

    /**
     * The arrow while pulling.
     */
    @JvmField protected var mProgress: MaterialProgressDrawable

    init {
        mSpinnerStyle = SpinnerStyle.values.firstOrNull { it.scale }
        mWaterDropView = WaterDropView(context)
        mWaterDropView.updateCompleteState(0)
        addView(mWaterDropView, LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)
        mProgressDrawable = ProgressDrawable()
        mProgressDrawable.callback = this
        mProgressDrawable.setBounds(0, 0, SmartUtil.dp2px(20f), SmartUtil.dp2px(20f))
        mImageView = ImageView(context)
        mImageView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        mProgress = MaterialProgressDrawable(mImageView)
        mProgress.setColorSchemeColors(
            0xffffffff.toInt(), 0xff0099cc.toInt(), 0xffff4444.toInt(), 0xff669900.toInt(), 0xffaa66cc.toInt(), 0xffff8800.toInt(),
        )
        mImageView.setImageDrawable(mProgress)
        addView(mImageView, SmartUtil.dp2px(30f), SmartUtil.dp2px(30f))
        initRefreshAccessibility()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        val lpImage = mImageView.layoutParams
        mImageView.measure(makeMeasureSpec(lpImage.width, EXACTLY), makeMeasureSpec(lpImage.height, EXACTLY))
        mWaterDropView.measure(makeMeasureSpec(getSize(widthMeasureSpec), AT_MOST), heightMeasureSpec)
        val maxWidth = max(mImageView.measuredWidth, mWaterDropView.measuredWidth)
        val maxHeight = max(mImageView.measuredHeight, mWaterDropView.measuredHeight)
        super.setMeasuredDimension(resolveSize(maxWidth, widthMeasureSpec), resolveSize(maxHeight, heightMeasureSpec))
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        val dropView = mWaterDropView
        val widthWaterDrop = dropView.measuredWidth
        val heightWaterDrop = dropView.measuredHeight
        val leftWaterDrop = measuredWidth / 2 - widthWaterDrop / 2
        dropView.layout(leftWaterDrop, 0, leftWaterDrop + widthWaterDrop, heightWaterDrop)
        val widthImage = mImageView.measuredWidth
        val heightImage = mImageView.measuredHeight
        val leftImage = measuredWidth / 2 - widthImage / 2
        var topImage = widthWaterDrop / 2 - widthImage / 2
        if (topImage + heightImage > dropView.bottom - (widthWaterDrop - widthImage) / 2) {
            topImage = dropView.bottom - (widthWaterDrop - widthImage) / 2 - heightImage
        }
        mImageView.layout(leftImage, topImage, leftImage + widthImage, topImage + heightImage)
    }

    override fun dispatchDraw(canvas: Canvas) {
        super.dispatchDraw(canvas)
        if (mState == RefreshState.Refreshing) {
            val bounds = mProgressDrawable.bounds
            canvas.save()
            canvas.translate(
                width / 2f - bounds.width() / 2f,
                mWaterDropView.maxCircleRadius + mWaterDropView.paddingTop - bounds.height() / 2f,
            )
            mProgressDrawable.draw(canvas)
            canvas.restore()
        }
    }

    override fun invalidateDrawable(drawable: Drawable) {
        invalidate()
    }

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        if (isDragging || (mState != RefreshState.Refreshing && mState != RefreshState.RefreshReleased)) {
            mWaterDropView.updateCompleteState(max(offset, 0), height + maxDragHeight)
            mWaterDropView.postInvalidate()
        }
        if (isDragging) {
            val originalDragPercent = 1f * offset / height
            val dragPercent = min(1f, abs(originalDragPercent))
            val adjustedPercent = max(dragPercent - .4f, 0f) * 5 / 3
            val extraOS = abs(offset).toFloat() - height
            val tensionSlingshotPercent = max(0f, min(extraOS, height.toFloat() * 2) / height.toFloat())
            val tensionPercent = ((tensionSlingshotPercent / 4) - (tensionSlingshotPercent / 4).pow(2)) * 2f
            val strokeStart = adjustedPercent * .8f
            val rotation = (-0.25f + .4f * adjustedPercent + tensionPercent * 2) * .5f
            mProgress.showArrow(true)
            mProgress.setStartEndTrim(0f, min(MAX_PROGRESS_ANGLE, strokeStart))
            mProgress.setArrowScale(min(1f, adjustedPercent))
            mProgress.setProgressRotation(rotation)
        }
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        mState = newState
        when (newState) {
            RefreshState.None, RefreshState.PullDownToRefresh, RefreshState.ReleaseToRefresh -> {
                mWaterDropView.visibility = View.VISIBLE
                mImageView.visibility = View.VISIBLE
            }
            RefreshState.RefreshFinish -> {
                mWaterDropView.visibility = View.GONE
                mImageView.visibility = View.GONE
            }
            else -> Unit
        }
        updateRefreshAccessibility(newState)
    }

    override fun onReleased(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        val dropView = mWaterDropView
        mProgressDrawable.start()
        mImageView.visibility = GONE
        dropView.createAnimator().start()
        dropView.animate().setDuration(150).alpha(0f).setListener(object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                dropView.visibility = GONE
                dropView.alpha = 1f
            }
        })
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        mProgressDrawable.stop()
        return 0
    }

    @Deprecated("Only called by the layout; use RefreshLayout.setPrimaryColorsId.")
    override fun setPrimaryColors(@ColorInt vararg colors: Int) {
        if (colors.isNotEmpty()) mWaterDropView.setIndicatorColor(colors[0])
    }

    /**
     * The arrow's largest sweep.
     */
    companion object {
        /**
         * The arrow's largest sweep, as a share of the circle.
         */
        @JvmStatic protected val MAX_PROGRESS_ANGLE = 0.8f
    }
}
