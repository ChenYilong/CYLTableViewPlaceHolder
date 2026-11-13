// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.layout.simple

import android.content.Context
import android.graphics.PointF
import android.util.AttributeSet
import android.view.View
import android.view.ViewGroup
import android.widget.RelativeLayout
import androidx.annotation.ColorInt
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import com.scwang.smart.refresh.layout.api.RefreshComponent
import com.scwang.smart.refresh.layout.api.RefreshFooter
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.listener.OnMultiListener
import com.scwang.smart.refresh.layout.listener.ScrollBoundaryDecider
import com.scwang.smart.refresh.layout.util.SmartUtil

/**
 * The default boundary check: the content (or the scrolling view under the finger) cannot scroll further
 * (`SimpleBoundaryDecider`).
 */
open class SimpleBoundaryDecider : ScrollBoundaryDecider {
    /**
     * Where the finger went down, in the content.
     */
    @JvmField var mActionEvent: PointF? = null

    /**
     * The app's own decider, asked first.
     */
    @JvmField var boundary: ScrollBoundaryDecider? = null

    /**
     * Allows loading more when the content does not fill the layout.
     */
    @JvmField var mEnableLoadMoreWhenContentNotFull = true

    override fun canRefresh(content: View): Boolean =
        boundary?.canRefresh(content) ?: SmartUtil.canRefresh(content, mActionEvent)

    override fun canLoadMore(content: View): Boolean =
        boundary?.canLoadMore(content) ?: SmartUtil.canLoadMore(content, mActionEvent, mEnableLoadMoreWhenContentNotFull)
}

/**
 * A base for headers and footers, or a wrapper around any view (`SimpleComponent`).
 */
abstract class SimpleComponent : RelativeLayout, RefreshComponent {
    /**
     * The wrapped view, or null when this view is the component.
     */
    @JvmField protected var mWrappedView: View? = null

    /**
     * The spinner style, worked out once.
     */
    @JvmField protected var mSpinnerStyle: SpinnerStyle? = null

    /**
     * True during an auto refresh (pull request #1095).
     */
    @JvmField protected var mIsAutoRefresh = false

    /**
     * The wrapped component, when the wrapped view is one.
     */
    @JvmField protected var mWrappedInternal: RefreshComponent? = null

    /**
     * Wraps [wrapped].
     */
    protected constructor(wrapped: View) : this(wrapped, wrapped as? RefreshComponent)

    /**
     * Wraps [wrappedView], which acts as [wrappedInternal]; a header used as a footer (or the reverse) is flipped.
     */
    protected constructor(wrappedView: View, wrappedInternal: RefreshComponent?) : super(wrappedView.context, null, 0) {
        mWrappedView = wrappedView
        mWrappedInternal = wrappedInternal
        if (this is RefreshFooter && wrappedInternal is RefreshHeader && wrappedInternal.spinnerStyle == SpinnerStyle.MatchLayout) {
            wrappedInternal.view.scaleY = -1f
        } else if (this is RefreshHeader && wrappedInternal is RefreshFooter && wrappedInternal.spinnerStyle == SpinnerStyle.MatchLayout) {
            wrappedInternal.view.scaleY = -1f
        }
    }

    /**
     * A component drawn by a subclass.
     */
    protected constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(context, attrs, defStyleAttr)

    override fun equals(other: Any?): Boolean {
        if (!super.equals(other)) {
            return other is RefreshComponent && view === other.view
        }
        return true
    }

    override fun hashCode(): Int = super.hashCode()

    override val view: View
        get() = mWrappedView ?: this

    private val wrapped: RefreshComponent?
        get() = mWrappedInternal?.takeIf { it !== this }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int = wrapped?.onFinish(refreshLayout, success) ?: 0

    override fun onAutoRefresh(isAutoRefresh: Boolean) {
        mIsAutoRefresh = isAutoRefresh
        wrapped?.onAutoRefresh(isAutoRefresh)
    }

    /**
     * True while the current refresh was started by autoRefresh / autoLoadMore, false for a drag (pull request #1095,
     * #1268).
     */
    open fun isAutoRefresh(): Boolean = mIsAutoRefresh

    override fun setPrimaryColors(@ColorInt vararg colors: Int) {
        wrapped?.setPrimaryColors(*colors)
    }

    override val spinnerStyle: SpinnerStyle
        get() {
            mSpinnerStyle?.let { return it }
            wrapped?.let { return it.spinnerStyle }
            mWrappedView?.layoutParams?.let { params ->
                if (params is SmartRefreshLayout.LayoutParams) {
                    params.spinnerStyle?.let { mSpinnerStyle = it; return it }
                }
                if (params.height == 0 || params.height == ViewGroup.LayoutParams.MATCH_PARENT) {
                    SpinnerStyle.values.firstOrNull { it.scale }?.let { mSpinnerStyle = it; return it }
                }
            }
            return SpinnerStyle.Translate.also { mSpinnerStyle = it }
        }

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        val inner = wrapped
        if (inner != null) {
            inner.onInitialized(kernel, height, maxDragHeight)
        } else {
            (mWrappedView?.layoutParams as? SmartRefreshLayout.LayoutParams)?.let {
                kernel.requestDrawBackgroundFor(this, it.backgroundColor)
            }
        }
    }

    override val isSupportHorizontalDrag: Boolean
        get() = wrapped?.isSupportHorizontalDrag == true

    override fun onHorizontalDrag(percentX: Float, offsetX: Int, offsetMax: Int) {
        wrapped?.onHorizontalDrag(percentX, offsetX, offsetMax)
    }

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        wrapped?.onMoving(isDragging, percent, offset, height, maxDragHeight)
    }

    override fun onReleased(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        wrapped?.onReleased(refreshLayout, height, maxDragHeight)
    }

    override fun onStartAnimator(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        wrapped?.onStartAnimator(refreshLayout, height, maxDragHeight)
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        val inner = wrapped ?: return
        var old = oldState
        var new = newState
        if (this is RefreshFooter && inner is RefreshHeader) {
            if (old.isFooter) old = old.toHeader()
            if (new.isFooter) new = new.toHeader()
        } else if (this is RefreshHeader && inner is RefreshFooter) {
            if (old.isHeader) old = old.toFooter()
            if (new.isHeader) new = new.toFooter()
        }
        inner.onStateChanged(refreshLayout, old, new)
    }

    /**
     * Passes no-more-data to a wrapped footer; false when there is none.
     */
    open fun setNoMoreData(noMoreData: Boolean): Boolean = (mWrappedInternal as? RefreshFooter)?.setNoMoreData(noMoreData) == true

    override fun autoOpen(duration: Int, dragRate: Float, animationOnly: Boolean): Boolean = false
}

/**
 * An [OnMultiListener] whose methods do nothing; override the ones needed (`SimpleMultiListener`).
 */
open class SimpleMultiListener : OnMultiListener {
    override fun onHeaderMoving(header: RefreshHeader?, isDragging: Boolean, percent: Float, offset: Int, headerHeight: Int, maxDragHeight: Int) {}
    override fun onHeaderReleased(header: RefreshHeader?, headerHeight: Int, maxDragHeight: Int) {}
    override fun onHeaderStartAnimator(header: RefreshHeader?, headerHeight: Int, maxDragHeight: Int) {}
    override fun onHeaderFinish(header: RefreshHeader?, success: Boolean) {}
    override fun onFooterMoving(footer: RefreshFooter?, isDragging: Boolean, percent: Float, offset: Int, footerHeight: Int, maxDragHeight: Int) {}
    override fun onFooterReleased(footer: RefreshFooter?, footerHeight: Int, maxDragHeight: Int) {}
    override fun onFooterStartAnimator(footer: RefreshFooter?, footerHeight: Int, maxDragHeight: Int) {}
    override fun onFooterFinish(footer: RefreshFooter?, success: Boolean) {}
    override fun onRefresh(refreshLayout: RefreshLayout) {}
    override fun onLoadMore(refreshLayout: RefreshLayout) {}
    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {}
}
