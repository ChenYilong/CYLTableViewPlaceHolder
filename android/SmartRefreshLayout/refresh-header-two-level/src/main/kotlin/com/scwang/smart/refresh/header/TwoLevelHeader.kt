// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header

import android.content.Context
import android.util.AttributeSet
import android.view.View
import android.view.ViewGroup
import androidx.core.view.NestedScrollingParent2
import com.scwang.smart.refresh.header.listener.OnTwoLevelListener
import com.scwang.smart.refresh.header.two.level.R
import com.scwang.smart.refresh.layout.api.RefreshComponent
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.simple.SimpleComponent
import kotlin.math.max

/**
 * The second-floor header: wraps a header and opens a second floor when pulled far enough (`TwoLevelHeader`).
 */
open class TwoLevelHeader @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    SimpleComponent(context, attrs, 0), RefreshHeader, NestedScrollingParent2 {

    /**
     * The current offset.
     */
    @JvmField protected var mSpinner = 0

    /**
     * The last drag percent.
     */
    @JvmField protected var mPercent = 0f

    /**
     * The maximum drag, as a multiple of the header height. Default 2.5.
     */
    @JvmField protected var mMaxRate = 2.5f

    /**
     * The drag that opens the second floor. Default 1.9.
     */
    @JvmField protected var mFloorRate = 1.9f

    /**
     * The drag that refreshes. Default 1.
     */
    @JvmField protected var mRefreshRate = 1f

    /**
     * The pull up, as a part of the height, that closes the second floor. Default 1/6.
     */
    @JvmField protected var mBottomPullUpToCloseRate = 1 / 6f

    /**
     * The header height.
     */
    @JvmField protected var mHeaderHeight = 0

    /**
     * The second floor's open and close duration in ms. Default 1000.
     */
    @JvmField protected var mFloorDuration = 1000

    /**
     * Allows refreshing. Default true.
     */
    @JvmField protected var mEnableRefresh = true

    /**
     * Allows the second floor. Default true.
     */
    @JvmField protected var mEnableTwoLevel = true

    /**
     * Lets a pull up close the second floor. Default true.
     */
    @JvmField protected var mEnablePullToCloseTwoLevel = true

    /**
     * The layout's kernel, once initialized.
     */
    @JvmField protected var mRefreshKernel: RefreshKernel? = null

    /**
     * The wrapped header.
     */
    @JvmField protected var mRefreshHeader: RefreshComponent? = null

    /**
     * The second-floor listener.
     */
    @JvmField protected var mTwoLevelListener: OnTwoLevelListener? = null

    private var mNestedScrollAxes = 0

    init {
        mSpinnerStyle = SpinnerStyle.FixedBehind
        val ta = context.obtainStyledAttributes(attrs, R.styleable.TwoLevelHeader)
        mMaxRate = ta.getFloat(R.styleable.TwoLevelHeader_srlMaxRate, mMaxRate)
        mFloorRate = ta.getFloat(R.styleable.TwoLevelHeader_srlFloorRate, mFloorRate)
        mRefreshRate = ta.getFloat(R.styleable.TwoLevelHeader_srlRefreshRate, mRefreshRate)
        mFloorDuration = ta.getInt(R.styleable.TwoLevelHeader_srlFloorDuration, mFloorDuration)
        mEnableRefresh = ta.getBoolean(R.styleable.TwoLevelHeader_srlEnableRefresh, mEnableRefresh)
        mEnableTwoLevel = ta.getBoolean(R.styleable.TwoLevelHeader_srlEnableTwoLevel, mEnableTwoLevel)
        mBottomPullUpToCloseRate = ta.getFloat(R.styleable.TwoLevelHeader_srlBottomPullUpToCloseRate, mBottomPullUpToCloseRate)
        mEnablePullToCloseTwoLevel = ta.getBoolean(R.styleable.TwoLevelHeader_srlEnablePullToCloseTwoLevel, mEnablePullToCloseTwoLevel)
        ta.recycle()
    }

    override fun onFinishInflate() {
        super.onFinishInflate()
        for (i in 0 until childCount) {
            val child = getChildAt(i)
            if (child is RefreshHeader) {
                mRefreshHeader = child
                mWrappedInternal = child
                bringChildToFront(child)
                break
            }
        }
        if (mRefreshHeader == null) setRefreshHeader(ClassicsHeader(context))
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        mSpinnerStyle = SpinnerStyle.MatchLayout
        if (mRefreshHeader == null) setRefreshHeader(ClassicsHeader(context))
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        mSpinnerStyle = SpinnerStyle.FixedBehind
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val refreshHeader = mRefreshHeader
        if (refreshHeader != null && MeasureSpec.getMode(heightMeasureSpec) == MeasureSpec.AT_MOST) {
            refreshHeader.view.measure(widthMeasureSpec, heightMeasureSpec)
            super.setMeasuredDimension(View.resolveSize(suggestedMinimumWidth, widthMeasureSpec), refreshHeader.view.measuredHeight)
        } else {
            super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        }
    }

    override fun equals(other: Any?): Boolean {
        val header: Any? = mRefreshHeader
        return (header != null && header == other) || super.equals(other)
    }

    override fun hashCode(): Int = super.hashCode()

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        val refreshHeader = mRefreshHeader ?: return
        if (1f * (maxDragHeight + height) / height != mMaxRate && mHeaderHeight == 0) {
            mHeaderHeight = height
            mRefreshHeader = null
            kernel.refreshLayout.setHeaderMaxDragRate(mMaxRate)
            mRefreshHeader = refreshHeader
        }
        // First initialization: a translating header starts one height above.
        if (mRefreshKernel == null && refreshHeader.spinnerStyle == SpinnerStyle.Translate && !isInEditMode) {
            val params = refreshHeader.view.layoutParams as MarginLayoutParams
            params.topMargin -= height
            refreshHeader.view.layoutParams = params
        }
        mHeaderHeight = height
        mRefreshKernel = kernel
        kernel.requestFloorDuration(mFloorDuration)
        kernel.requestFloorBottomPullUpToCloseRate(mBottomPullUpToCloseRate)
        kernel.requestNeedTouchEventFor(this, !mEnablePullToCloseTwoLevel)
        refreshHeader.onInitialized(kernel, height, maxDragHeight)
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        val refreshHeader = mRefreshHeader ?: return
        val state = if (newState == RefreshState.ReleaseToRefresh && !mEnableRefresh) RefreshState.PullDownToRefresh else newState
        refreshHeader.onStateChanged(refreshLayout, oldState, state)
        val view = refreshHeader.view
        when (state) {
            RefreshState.TwoLevelReleased -> {
                if (view !== this) view.animate().alpha(0f).duration = (mFloorDuration / 2).toLong()
                mRefreshKernel?.let { kernel ->
                    val listener = mTwoLevelListener
                    kernel.startTwoLevel(listener == null || listener.onTwoLevel(refreshLayout))
                }
            }
            RefreshState.TwoLevelFinish -> {
                if (view !== this) view.animate().alpha(1f).duration = (mFloorDuration / 2).toLong()
            }
            RefreshState.PullDownToRefresh -> {
                if (view.alpha == 0f && view !== this) view.alpha = 1f
            }
            else -> {}
        }
    }

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        moveSpinner(offset)
        mRefreshHeader?.onMoving(isDragging, percent, offset, height, maxDragHeight)
        if (!isDragging) return
        mRefreshKernel?.let { kernel ->
            if (mPercent < mFloorRate && percent >= mFloorRate && mEnableTwoLevel) {
                kernel.setState(RefreshState.ReleaseToTwoLevel)
            } else if (mPercent >= mFloorRate && percent < mRefreshRate) {
                kernel.setState(RefreshState.PullDownToRefresh)
            } else if (mPercent >= mFloorRate && percent < mFloorRate && mEnableRefresh) {
                kernel.setState(RefreshState.ReleaseToRefresh)
            } else if (!mEnableRefresh && kernel.refreshLayout.state != RefreshState.ReleaseToTwoLevel) {
                kernel.setState(RefreshState.PullDownToRefresh)
            }
        }
        mPercent = percent
    }

    /**
     * Moves the wrapped header to [spinner].
     */
    protected open fun moveSpinner(spinner: Int) {
        val refreshHeader = mRefreshHeader ?: return
        if (mSpinner == spinner) return
        mSpinner = spinner
        val style = refreshHeader.spinnerStyle
        if (style == SpinnerStyle.Translate) {
            refreshHeader.view.translationY = spinner.toFloat()
        } else if (style != null && style.scale) {
            val view = refreshHeader.view
            view.layout(view.left, view.top, view.right, view.top + max(0, spinner))
        }
    }

    // Nested scrolling: the header accepts and ignores nested scrolls of its second-floor content.
    override fun onStartNestedScroll(child: View, target: View, nestedScrollAxes: Int): Boolean = true

    override fun onNestedScrollAccepted(child: View, target: View, nestedScrollAxes: Int) {
        mNestedScrollAxes = nestedScrollAxes
    }

    override fun onStopNestedScroll(target: View) {}

    override fun onNestedScroll(target: View, dxConsumed: Int, dyConsumed: Int, dxUnconsumed: Int, dyUnconsumed: Int) {}

    override fun onNestedPreScroll(target: View, dx: Int, dy: Int, consumed: IntArray) {}

    override fun onNestedFling(target: View, velocityX: Float, velocityY: Float, consumed: Boolean): Boolean = false

    override fun onNestedPreFling(target: View, velocityX: Float, velocityY: Float): Boolean = false

    override fun getNestedScrollAxes(): Int = mNestedScrollAxes

    override fun onStartNestedScroll(child: View, target: View, axes: Int, type: Int): Boolean = true

    override fun onNestedScrollAccepted(child: View, target: View, axes: Int, type: Int) {
        mNestedScrollAxes = axes
    }

    override fun onStopNestedScroll(target: View, type: Int) {}

    override fun onNestedScroll(target: View, dxConsumed: Int, dyConsumed: Int, dxUnconsumed: Int, dyUnconsumed: Int, type: Int) {}

    override fun onNestedPreScroll(target: View, dx: Int, dy: Int, consumed: IntArray, type: Int) {}

    /**
     * Wraps [header], full width and its own height.
     */
    open fun setRefreshHeader(header: RefreshHeader?): TwoLevelHeader = setRefreshHeader(header, 0, 0)

    /**
     * Wraps [header] with the size [width] by [height] (0: match parent / wrap content).
     */
    open fun setRefreshHeader(header: RefreshHeader?, width: Int, height: Int): TwoLevelHeader {
        if (header == null) return this
        val olp = header.view.layoutParams
        val lp = olp as? LayoutParams ?: LayoutParams(
            if (width == 0) ViewGroup.LayoutParams.MATCH_PARENT else width,
            if (height == 0) ViewGroup.LayoutParams.WRAP_CONTENT else height,
        )
        mRefreshHeader?.let { removeView(it.view) }
        if (header.spinnerStyle == SpinnerStyle.FixedBehind) {
            addView(header.view, 0, lp)
        } else {
            addView(header.view, childCount, lp)
        }
        mRefreshHeader = header
        mWrappedInternal = header
        return this
    }

    /**
     * The maximum drag, as a multiple of the header height.
     */
    open fun setMaxRate(rate: Float): TwoLevelHeader {
        if (mMaxRate != rate) {
            mMaxRate = rate
            mRefreshKernel?.let {
                mHeaderHeight = 0
                it.refreshLayout.setHeaderMaxDragRate(mMaxRate)
            }
        }
        return this
    }

    /**
     * Lets a pull up close the second floor.
     */
    open fun setEnablePullToCloseTwoLevel(enabled: Boolean): TwoLevelHeader {
        mEnablePullToCloseTwoLevel = enabled
        mRefreshKernel?.requestNeedTouchEventFor(this, !enabled)
        return this
    }

    /**
     * Allows refreshing.
     */
    open fun setEnableRefresh(enabled: Boolean): TwoLevelHeader {
        mEnableRefresh = enabled
        return this
    }

    /**
     * The drag that opens the second floor.
     */
    open fun setFloorRate(rate: Float): TwoLevelHeader {
        mFloorRate = rate
        return this
    }

    /**
     * The drag that refreshes.
     */
    open fun setRefreshRate(rate: Float): TwoLevelHeader {
        mRefreshRate = rate
        return this
    }

    /**
     * Allows the second floor.
     */
    open fun setEnableTwoLevel(enabled: Boolean): TwoLevelHeader {
        mEnableTwoLevel = enabled
        return this
    }

    /**
     * The second floor's open and close duration in ms.
     */
    open fun setFloorDuration(duration: Int): TwoLevelHeader {
        mFloorDuration = duration
        return this
    }

    /**
     * The pull up, as a part of the height, that closes the second floor.
     */
    open fun setBottomPullUpToCloseRate(rate: Float): TwoLevelHeader {
        mBottomPullUpToCloseRate = rate
        return this
    }

    /**
     * The second-floor listener.
     */
    open fun setOnTwoLevelListener(listener: OnTwoLevelListener?): TwoLevelHeader {
        mTwoLevelListener = listener
        return this
    }

    /**
     * Closes the second floor.
     */
    open fun finishTwoLevel(): TwoLevelHeader {
        mRefreshKernel?.finishTwoLevel()
        return this
    }

    /**
     * Opens the second floor; with [widthOnTwoLevelListener], only if the listener agrees.
     */
    open fun openTwoLevel(widthOnTwoLevelListener: Boolean): TwoLevelHeader {
        mRefreshKernel?.let { kernel ->
            val listener = mTwoLevelListener
            kernel.startTwoLevel(!widthOnTwoLevelListener || listener == null || listener.onTwoLevel(kernel.refreshLayout))
        }
        return this
    }
}
