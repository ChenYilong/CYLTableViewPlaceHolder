// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.layout.wrapper

import android.animation.ValueAnimator
import android.animation.ValueAnimator.AnimatorUpdateListener
import android.annotation.SuppressLint
import android.graphics.PointF
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.AbsListView
import android.widget.FrameLayout
import android.widget.Space
import androidx.core.view.NestedScrollingChild
import androidx.core.view.NestedScrollingParent
import androidx.viewpager.widget.ViewPager
import androidx.viewpager2.widget.ViewPager2
import com.scwang.smart.refresh.layout.api.RefreshContent
import com.scwang.smart.refresh.layout.api.RefreshFooter
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.kernel.R
import com.scwang.smart.refresh.layout.listener.CoordinatorLayoutListener
import com.scwang.smart.refresh.layout.listener.ScrollBoundaryDecider
import com.scwang.smart.refresh.layout.simple.SimpleBoundaryDecider
import com.scwang.smart.refresh.layout.simple.SimpleComponent
import com.scwang.smart.refresh.layout.util.DesignUtil
import com.scwang.smart.refresh.layout.util.SmartUtil
import java.util.LinkedList

/**
 * Wraps the content: finds its scrolling view, moves it with the pull and decides its boundaries
 * (`RefreshContentWrapper`).
 */
open class RefreshContentWrapper(view: View) : RefreshContent, CoordinatorLayoutListener, AnimatorUpdateListener {
    /**
     * The content view (a FrameLayout around it once fixed views are added).
     */
    @JvmField protected var mContentView: View = view

    /**
     * The original content view.
     */
    @JvmField protected var mOriginalContentView: View = view

    /**
     * The view that scrolls.
     */
    @JvmField protected var mScrollableView: View = view

    /**
     * The fixed header view inside the content.
     */
    @JvmField protected var mFixedHeader: View? = null

    /**
     * The fixed footer view inside the content.
     */
    @JvmField protected var mFixedFooter: View? = null

    /**
     * The last value of the closing scroll.
     */
    @JvmField protected var mLastSpinner = 0

    /**
     * False while a CoordinatorLayout's app bar is not fully expanded.
     */
    @JvmField protected var mEnableRefresh = true

    /**
     * False while a CoordinatorLayout's app bar is not fully collapsed.
     */
    @JvmField protected var mEnableLoadMore = true

    /**
     * The boundary check.
     */
    @JvmField protected var mBoundaryAdapter = SimpleBoundaryDecider()

    /**
     * Finds the scrolling view inside [content], descending through nested-scrolling parents.
     */
    protected open fun findScrollableView(content: View, kernel: RefreshKernel) {
        var current = content
        var scrollableView: View? = null
        val isInEditMode = mContentView.isInEditMode
        while (scrollableView == null || (scrollableView is NestedScrollingParent && scrollableView !is NestedScrollingChild)) {
            current = findScrollableViewInternal(current, scrollableView == null)
            if (current === scrollableView) break
            if (!isInEditMode) DesignUtil.checkCoordinatorLayout(current, kernel, this)
            scrollableView = current
        }
        if (scrollableView != null) mScrollableView = scrollableView
    }

    override fun onCoordinatorUpdate(enableRefresh: Boolean, enableLoadMore: Boolean) {
        mEnableRefresh = enableRefresh
        mEnableLoadMore = enableLoadMore
    }

    /**
     * The first content view found breadth-first in [content] (itself only when [selfAble]).
     */
    protected open fun findScrollableViewInternal(content: View, selfAble: Boolean): View {
        val views = LinkedList<View>()
        views.add(content)
        while (views.isNotEmpty()) {
            val view = views.poll() ?: continue
            if ((selfAble || view !== content) && SmartUtil.isContentView(view)) return view
            if (view is ViewGroup) for (j in 0 until view.childCount) views.add(view.getChildAt(j))
        }
        return content
    }

    /**
     * The scrolling view under [event] in [content], or [orgScrollableView].
     */
    protected open fun findScrollableViewByPoint(content: View, event: PointF?, orgScrollableView: View): View {
        if (content is ViewGroup && event != null) {
            val point = PointF()
            for (i in content.childCount downTo 1) {
                var child = content.getChildAt(i - 1)
                if (SmartUtil.isTransformedTouchPointInView(content, child, event.x, event.y, point)) {
                    if (child is ViewPager || child is ViewPager2 || !SmartUtil.isContentView(child)) {
                        event.offset(point.x, point.y)
                        child = findScrollableViewByPoint(child, event, orgScrollableView)
                        event.offset(-point.x, -point.y)
                    }
                    return child
                }
            }
        }
        return orgScrollableView
    }

    override val view: View
        get() = mContentView

    override val scrollableView: View
        get() = mScrollableView

    override fun moveSpinner(spinner: Int, headerTranslationViewId: Int, footerTranslationViewId: Int) {
        var translated = false
        if (headerTranslationViewId != View.NO_ID) {
            mOriginalContentView.findViewById<View>(headerTranslationViewId)?.let {
                if (spinner > 0) {
                    translated = true
                    it.translationY = spinner.toFloat()
                } else if (it.translationY > 0) {
                    it.translationY = 0f
                }
            }
        }
        if (footerTranslationViewId != View.NO_ID) {
            mOriginalContentView.findViewById<View>(footerTranslationViewId)?.let {
                if (spinner < 0) {
                    translated = true
                    it.translationY = spinner.toFloat()
                } else if (it.translationY < 0) {
                    it.translationY = 0f
                }
            }
        }
        mOriginalContentView.translationY = if (!translated) spinner.toFloat() else 0f
        mFixedHeader?.translationY = maxOf(0, spinner).toFloat()
        mFixedFooter?.translationY = minOf(0, spinner).toFloat()
    }

    override fun canRefresh(): Boolean = mEnableRefresh && mBoundaryAdapter.canRefresh(mContentView)

    override fun canLoadMore(): Boolean = mEnableLoadMore && mBoundaryAdapter.canLoadMore(mContentView)

    override fun onActionDown(e: MotionEvent) {
        val point = PointF(e.x, e.y)
        point.offset(-mContentView.left.toFloat(), -mContentView.top.toFloat())
        if (mScrollableView !== mContentView) mScrollableView = findScrollableViewByPoint(mContentView, point, mScrollableView)
        mBoundaryAdapter.mActionEvent = if (mScrollableView === mContentView) null else point
    }

    override fun setUpComponent(kernel: RefreshKernel, fixedHeader: View?, fixedFooter: View?) {
        findScrollableView(mContentView, kernel)
        if (fixedHeader == null && fixedFooter == null) return
        mFixedHeader = fixedHeader
        mFixedFooter = fixedFooter
        val frameLayout = FrameLayout(mContentView.context)
        val layout = kernel.refreshLayout.layout
        var index = layout.indexOfChild(mContentView)
        layout.removeView(mContentView)
        frameLayout.addView(mContentView, 0, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        layout.addView(frameLayout, index, mContentView.layoutParams)
        mContentView = frameLayout
        if (fixedHeader != null) {
            fixedHeader.setTag(R.id.srl_tag, "fixed-top")
            frameLayout.addView(fixedHeader, 1, holdPlace(fixedHeader, Gravity.TOP))
        }
        if (fixedFooter != null) {
            fixedFooter.setTag(R.id.srl_tag, "fixed-bottom")
            frameLayout.addView(fixedFooter, 1, holdPlace(fixedFooter, Gravity.BOTTOM))
        }
    }

    /**
     * Moves [fixed] out of its parent, leaving a Space of its height, and returns its layout parameters for the frame.
     * Issue #1138: the fixed view keeps its own height (a wrapping TextView gets all its lines), and the Space follows
     * the height it is laid out at, instead of a height measured once before layout without the real width.
     */
    private fun holdPlace(fixed: View, gravity: Int): FrameLayout.LayoutParams {
        val lp = fixed.layoutParams
        val parent = fixed.parent as ViewGroup
        val index = parent.indexOfChild(fixed)
        parent.removeView(fixed)
        val flp = if (lp is ViewGroup.MarginLayoutParams) FrameLayout.LayoutParams(lp) else FrameLayout.LayoutParams(lp)
        flp.gravity = gravity
        lp.height = SmartUtil.measureViewHeight(fixed)
        val space = Space(mContentView.context)
        parent.addView(space, index, lp)
        fixed.addOnLayoutChangeListener { v, _, _, _, _, _, _, _, _ ->
            val params = space.layoutParams
            if (params.height != v.height) {
                params.height = v.height
                space.layoutParams = params
            }
        }
        return flp
    }

    override fun setScrollBoundaryDecider(boundary: ScrollBoundaryDecider?) {
        if (boundary is SimpleBoundaryDecider) mBoundaryAdapter = boundary else mBoundaryAdapter.boundary = boundary
    }

    override fun setEnableLoadMoreWhenContentNotFull(enable: Boolean) {
        mBoundaryAdapter.mEnableLoadMoreWhenContentNotFull = enable
    }

    override fun scrollContentWhenFinished(spinner: Int): AnimatorUpdateListener? {
        if (spinner != 0 && ((spinner < 0 && mScrollableView.canScrollVertically(1)) || (spinner > 0 && mScrollableView.canScrollVertically(-1)))) {
            mLastSpinner = spinner
            return this
        }
        return null
    }

    override fun onAnimationUpdate(animation: ValueAnimator) {
        val value = animation.animatedValue as Int
        try {
            val dy = (value - mLastSpinner) * mScrollableView.scaleY
            val view = mScrollableView
            if (view is AbsListView) SmartUtil.scrollListBy(view, dy.toInt()) else view.scrollBy(0, dy.toInt())
        } catch (e: Throwable) {
            e.printStackTrace()
        }
        mLastSpinner = value
    }
}

/**
 * Any view used as a footer (`RefreshFooterWrapper`).
 */
@SuppressLint("ViewConstructor")
open class RefreshFooterWrapper(wrapper: View) : SimpleComponent(wrapper), RefreshFooter

/**
 * Any view used as a header (`RefreshHeaderWrapper`).
 */
@SuppressLint("ViewConstructor")
open class RefreshHeaderWrapper(wrapper: View) : SimpleComponent(wrapper), RefreshHeader
