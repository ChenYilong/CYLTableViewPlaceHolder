// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.animation.ValueAnimator
import android.content.Context
import android.util.AttributeSet
import android.view.View
import android.view.animation.AccelerateInterpolator
import android.view.animation.DecelerateInterpolator
import androidx.annotation.ColorInt
import androidx.core.view.animation.PathInterpolatorCompat
import com.scwang.smart.refresh.header.flyrefresh.MountainSceneView
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.util.SmartUtil

/**
 * A paper plane over hills, from FlyRefresh (`FlyRefreshHeader`). The app lays out the scene and the plane and
 * passes them to [setUp]; this header has no height of its own.
 */
open class FlyRefreshHeader @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    FalsifyHeader(context, attrs), RefreshHeader {

    /**
     * The paper plane.
     */
    @JvmField protected var mFlyView: View? = null

    /**
     * The plane's current animation.
     */
    @JvmField protected var mFlyAnimator: AnimatorSet? = null

    /**
     * The refresh layout, once initialized.
     */
    @JvmField protected var mRefreshLayout: RefreshLayout? = null

    /**
     * The hills.
     */
    @JvmField protected var mSceneView: MountainSceneView? = null

    /**
     * The latest offset.
     */
    @JvmField protected var mOffset = 0

    /**
     * The latest pull percent.
     */
    @JvmField protected var mCurrentPercent = 0f

    /**
     * True while the plane is away.
     */
    @JvmField protected var mIsRefreshing = false

    /**
     * The header's measured height, used as the trigger distance.
     */
    @JvmField protected var mMeasureHeight = 0

    init {
        // Unlike the empty FalsifyHeader, this header refreshes: it reads "Refreshing" / "Refreshed".
        initRefreshAccessibility()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        if (mMeasureHeight == 0) {
            super.onMeasure(widthMeasureSpec, heightMeasureSpec)
            mMeasureHeight = super.getMeasuredHeight()
        }
        super.setMeasuredDimension(resolveSize(MeasureSpec.getSize(widthMeasureSpec), widthMeasureSpec), 0)
    }

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        if (mRefreshKernel == null) {
            mRefreshKernel = kernel
            mRefreshLayout = kernel.refreshLayout.apply {
                setEnableOverScrollDrag(false)
                setHeaderHeightPx(0)
                setHeaderTriggerRate(mMeasureHeight.toFloat())
                setHeaderMaxDragRate(mMeasureHeight * 2.5f)
            }
        }
    }

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        if (isDragging || !mIsRefreshing) {
            var percentNow = percent
            var offsetNow = offset
            if (offsetNow < 0) {
                if (mOffset > 0) {
                    offsetNow = 0
                    percentNow = 0f
                } else {
                    return
                }
            }
            mOffset = offsetNow
            mCurrentPercent = percentNow
            mSceneView?.let {
                it.updatePercent(percentNow)
                it.postInvalidate()
            }
            mFlyView?.rotation = if (height + maxDragHeight > 0) -45f * offsetNow / (height + maxDragHeight) else -45f * percentNow
        }
    }

    override fun onReleased(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        if (mCurrentPercent > 0) {
            ValueAnimator.ofFloat(mCurrentPercent, 0f).apply {
                duration = 300
                addUpdateListener { onMoving(true, it.animatedValue as Float, 0, 0, 0) }
                start()
            }
            mCurrentPercent = 0f
        }
        val flyView = mFlyView
        if (flyView != null && !mIsRefreshing) {
            mFlyAnimator?.let {
                it.end()
                flyView.clearAnimation()
            }
            mIsRefreshing = true
            refreshLayout.setEnableRefresh(false)
            val offDistX = refreshLayout.layout.width - flyView.left
            val offDistY = -(flyView.top - mOffset) * 2 / 3
            val transX = ObjectAnimator.ofFloat(flyView, "translationX", 0f, offDistX.toFloat())
            val transY = ObjectAnimator.ofFloat(flyView, "translationY", 0f, offDistY.toFloat())
            transY.interpolator = PathInterpolatorCompat.create(0.7f, 1f)
            val rotation = ObjectAnimator.ofFloat(flyView, "rotation", flyView.rotation, 0f)
            rotation.interpolator = DecelerateInterpolator()
            val rotationX = ObjectAnimator.ofFloat(flyView, "rotationX", flyView.rotationX, 50f)
            rotationX.interpolator = DecelerateInterpolator()
            mFlyAnimator = AnimatorSet().apply {
                duration = 800
                playTogether(
                    transX, transY, rotation, rotationX,
                    ObjectAnimator.ofFloat(flyView, "scaleX", flyView.scaleX, 0.5f),
                    ObjectAnimator.ofFloat(flyView, "scaleY", flyView.scaleY, 0.5f),
                )
                start()
            }
        }
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        updateRefreshAccessibility(newState)
    }

    @Deprecated("Only called by the layout; use RefreshLayout.setPrimaryColorsId.")
    override fun setPrimaryColors(@ColorInt vararg colors: Int) {
        if (colors.isNotEmpty()) mSceneView?.setPrimaryColor(colors[0])
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        if (mIsRefreshing) finishRefresh()
        return super.onFinish(refreshLayout, success)
    }

    override fun onDetachedFromWindow() {
        // Land the plane, so its animators do not outlive the page and refreshing is enabled again (the Java version left
        // them running).
        mFlyAnimator?.end()
        mFlyAnimator = null
        super.onDetachedFromWindow()
    }

    /**
     * The hills and the paper plane this header animates.
     */
    open fun setUp(sceneView: MountainSceneView?, flyView: View?) {
        mFlyView = flyView
        mSceneView = sceneView
    }

    /**
     * Brings the plane back and ends the refresh.
     */
    open fun finishRefresh() = finishRefresh(null)

    /**
     * Brings the plane back and ends the refresh; [listenerAdapter] hears when the plane is back.
     */
    open fun finishRefresh(listenerAdapter: AnimatorListenerAdapter?) {
        val flyView = mFlyView ?: return
        val refreshLayout = mRefreshLayout ?: return
        if (!mIsRefreshing) return
        mFlyAnimator?.let {
            it.end()
            flyView.clearAnimation()
        }
        mIsRefreshing = false
        refreshLayout.finishRefresh(0)
        val offDistX = -flyView.right.toFloat()
        val offDistY = -SmartUtil.dp2px(10f).toFloat()
        val flyDownAnim = AnimatorSet()
        flyDownAnim.duration = 800
        val transX1 = ObjectAnimator.ofFloat(flyView, "translationX", flyView.translationX, offDistX)
        val transY1 = ObjectAnimator.ofFloat(flyView, "translationY", flyView.translationY, offDistY)
        transY1.interpolator = PathInterpolatorCompat.create(0.1f, 1f)
        val rotation1 = ObjectAnimator.ofFloat(flyView, "rotation", flyView.rotation, 0f)
        val rotationX1 = ObjectAnimator.ofFloat(flyView, "rotationX", flyView.rotationX, 30f)
        rotation1.interpolator = AccelerateInterpolator()
        flyDownAnim.playTogether(
            transX1, transY1, rotation1, rotationX1,
            ObjectAnimator.ofFloat(flyView, "scaleX", flyView.scaleX, 0.9f),
            ObjectAnimator.ofFloat(flyView, "scaleY", flyView.scaleY, 0.9f),
        )
        flyDownAnim.addListener(object : AnimatorListenerAdapter() {
            override fun onAnimationStart(animation: Animator) {
                mFlyView?.rotationY = 180f
            }
        })
        val flyInAnim = AnimatorSet()
        flyInAnim.duration = 800
        flyInAnim.interpolator = DecelerateInterpolator()
        flyInAnim.playTogether(
            ObjectAnimator.ofFloat(flyView, "translationX", offDistX, 0f),
            ObjectAnimator.ofFloat(flyView, "translationY", offDistY, 0f),
            ObjectAnimator.ofFloat(flyView, "rotationX", 30f, 0f),
            ObjectAnimator.ofFloat(flyView, "scaleX", 0.9f, 1f),
            ObjectAnimator.ofFloat(flyView, "scaleY", 0.9f, 1f),
        )
        flyInAnim.startDelay = 100
        flyInAnim.addListener(object : AnimatorListenerAdapter() {
            override fun onAnimationStart(animation: Animator) {
                mFlyView?.rotationY = 0f
            }

            override fun onAnimationEnd(animation: Animator) {
                mRefreshLayout?.setEnableRefresh(true)
                listenerAdapter?.onAnimationEnd(animation)
            }
        })
        mFlyAnimator = AnimatorSet().apply {
            playSequentially(flyDownAnim, flyInAnim)
            start()
        }
    }
}
