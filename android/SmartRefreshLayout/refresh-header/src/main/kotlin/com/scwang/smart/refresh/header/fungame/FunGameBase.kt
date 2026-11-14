// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header.fungame

import android.annotation.SuppressLint
import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.ViewGroup.MarginLayoutParams
import com.scwang.smart.refresh.header.initRefreshAccessibility
import com.scwang.smart.refresh.header.updateRefreshAccessibility
import com.scwang.smart.refresh.layout.api.RefreshContent
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.simple.SimpleComponent
import com.scwang.smart.refresh.layout.util.SmartUtil
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow

/**
 * The base of the game headers: while refreshing, a drag plays the game instead of moving the content
 * (`FunGameBase`).
 */
@SuppressLint("RestrictedApi")
abstract class FunGameBase(context: Context, attrs: AttributeSet?, defStyleAttr: Int) :
    SimpleComponent(context, attrs, defStyleAttr), RefreshHeader {

    /**
     * The current offset.
     */
    @JvmField protected var mOffset = 0

    /**
     * The header's height.
     */
    @JvmField protected var mHeaderHeight = 0

    /**
     * The screen's height.
     */
    @JvmField protected var mScreenHeightPixels: Int

    /**
     * The touch's raw y, or -1 once lifted.
     */
    @JvmField protected var mTouchY = 0f

    /**
     * True once the refresh finished.
     */
    @JvmField protected var mIsFinish = false

    /**
     * The last finish's success.
     */
    @JvmField protected var mLastFinish = false

    /**
     * True while the user plays.
     */
    @JvmField protected var mManualOperation = false

    /**
     * The layout's state.
     */
    @JvmField protected var mState: RefreshState? = null

    /**
     * The layout's kernel, once initialized.
     */
    @JvmField protected var mRefreshKernel: RefreshKernel? = null

    /**
     * The layout's content, while playing.
     */
    @JvmField protected var mRefreshContent: RefreshContent? = null

    init {
        minimumHeight = SmartUtil.dp2px(100f)
        mScreenHeightPixels = resources.displayMetrics.heightPixels
        mSpinnerStyle = SpinnerStyle.MatchLayout
        initRefreshAccessibility()
    }

    override fun onInterceptTouchEvent(ev: MotionEvent): Boolean =
        mState == RefreshState.Refreshing || super.onInterceptTouchEvent(ev)

    @SuppressLint("ClickableViewAccessibility")
    override fun onTouchEvent(event: MotionEvent): Boolean {
        val kernel = mRefreshKernel
        if (kernel != null && (mState == RefreshState.Refreshing || mState == RefreshState.RefreshFinish)) {
            if (!mManualOperation) onManualOperationStart()
            when (event.action and MotionEvent.ACTION_MASK) {
                MotionEvent.ACTION_DOWN -> {
                    mTouchY = event.rawY
                    kernel.moveSpinner(0, true)
                }
                MotionEvent.ACTION_MOVE -> {
                    val dy = event.rawY - mTouchY
                    if (dy >= 0) {
                        // y = M(1 - 100^(-x/H))
                        val m = mHeaderHeight * 2.0
                        val h = mScreenHeightPixels * 2 / 3.0
                        val x = max(0.0, dy * 0.5)
                        val y = min(m * (1 - 100.0.pow(-x / h)), x)
                        kernel.moveSpinner(max(1, y.toInt()), false)
                    } else {
                        kernel.moveSpinner(1, false)
                    }
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                    onManualOperationRelease()
                    mTouchY = -1f
                    if (mIsFinish) kernel.moveSpinner(mHeaderHeight, true)
                }
            }
            return true
        }
        return super.onTouchEvent(event)
    }

    /**
     * Starts playing: moves the content down by the header's height.
     */
    protected open fun onManualOperationStart() {
        if (!mManualOperation) {
            mManualOperation = true
            val content = mRefreshKernel?.refreshContent ?: return
            mRefreshContent = content
            val contentView = content.view
            val params = contentView.layoutParams as MarginLayoutParams
            params.topMargin += mHeaderHeight
            contentView.layoutParams = params
        }
    }

    /**
     * Moves the player's controller for the drag.
     */
    protected abstract fun onManualOperationMove(percent: Float, offset: Int, height: Int, maxDragHeight: Int)

    /**
     * Stops playing when the refresh finished; otherwise keeps the header open.
     */
    protected open fun onManualOperationRelease() {
        val kernel = mRefreshKernel ?: return
        if (mIsFinish) {
            mManualOperation = false
            if (mTouchY != -1f) {
                // Still touching.
                onFinish(kernel.refreshLayout, mLastFinish)
                kernel.setState(RefreshState.RefreshFinish)
                kernel.animSpinner(0)
            } else {
                kernel.moveSpinner(mHeaderHeight, true)
            }
            mRefreshContent?.view?.let { contentView ->
                val params = contentView.layoutParams as MarginLayoutParams
                params.topMargin -= mHeaderHeight
                contentView.layoutParams = params
            }
        } else {
            kernel.moveSpinner(0, true)
        }
    }

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        if (mManualOperation) {
            onManualOperationMove(percent, offset, height, maxDragHeight)
        } else {
            mOffset = offset
            translationY = (mOffset - mHeaderHeight).toFloat()
        }
    }

    override fun onStartAnimator(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        mIsFinish = false
        translationY = 0f
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        mState = newState
        updateRefreshAccessibility(newState)
    }

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        mRefreshKernel = kernel
        mHeaderHeight = height
        if (!isInEditMode) {
            translationY = (mOffset - mHeaderHeight).toFloat()
            kernel.requestNeedTouchEventFor(this, true)
        }
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        mLastFinish = success
        if (!mIsFinish) {
            mIsFinish = true
            if (mManualOperation) {
                if (mTouchY == -1f) {
                    // Already lifted.
                    onManualOperationRelease()
                    onFinish(refreshLayout, success)
                    return 0
                }
                return Int.MAX_VALUE
            }
        }
        return 0
    }
}
