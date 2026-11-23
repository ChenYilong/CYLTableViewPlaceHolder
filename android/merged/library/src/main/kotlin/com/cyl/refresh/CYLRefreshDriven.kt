package com.cyl.refresh

import android.content.Context
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import com.cyl.refresh.layout.CYLRefreshLayout
import com.cyl.refresh.layout.constant.RefreshState
import com.cyl.refresh.layout.constant.SpinnerStyle
import kotlin.math.min

/**
 * The driven mode of the refresh kernel (docs/Refresh-Library-Parity.md, native bridge map): a [CYLRefreshLayout] that
 * is driven from outside. A host that owns the scrolling and the touches (Flutter's `ListView`) feeds it the pull
 * distance with [drive] and the lifted finger with [release]; the layout runs the same phase machine and calls the
 * attached header's and footer's callbacks as a touch would, so the native header views draw and a [CYLRefreshComponent]
 * reports its phases. It has no scrolling content and ignores touches.
 */
class CYLRefreshDrivenLayout(context: Context) : CYLRefreshLayout(context) {

    init {
        // The content is the host's (Flutter's); without a content view the base layout draws its orange "content view is
        // empty" warning text on attach, so the driven layout supplies an empty content of its own.
        addView(View(context), ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
    }

    /**
     * Feeds the pull: [offset] pixels past the edge (positive pulls the header, negative the footer, 0 is rest);
     * [dragging] says whether a finger holds the content; [startedAtEdge] whether the drag began at the edge, which a
     * [CYLRefreshTriggerMode.OnEdge] header requires (`handlePull`).
     */
    fun drive(offset: Int, dragging: Boolean, startedAtEdge: Boolean = true) {
        if (dragging && !startedAtEdge && cyl_header?.triggerMode == CYLRefreshTriggerMode.OnEdge) return
        // loadsAfterNoMoreData: a pull up clears "no more data" first, so it can arm and load again (the Dart footer's
        // handlePull). Touches never reach this: the base layout ignores a pull up while "no more data" is set.
        if (dragging && offset < 0) cyl_footer?.takeIf { it.loadsAfterNoMoreData && it.noMoreData }?.resetNoMoreData()
        if (dragging && mState == RefreshState.None && offset != 0) {
            mKernel.setState(if (offset > 0) RefreshState.PullDownToRefresh else RefreshState.PullUpToLoad)
        }
        // A drag back to the edge cancels the pull, as lifting the finger there would.
        if (dragging && offset == 0 && mState.isDragging) mKernel.setState(if (mState.isHeader) RefreshState.PullDownCanceled else RefreshState.PullUpCanceled)
        mKernel.moveSpinner(offset, dragging)
    }

    /**
     * Feeds the lifted finger: an armed component starts refreshing, a short pull is canceled (`handleRelease`).
     */
    fun release() = overSpinner()

    private var footerHeldVisible = false

    /**
     * "No more data" has to stay readable: the host (Flutter) keeps the footer's space open after the last page, but the
     * footer is a translating view that rests just below the layout and only moves in with the pull, so at rest it was
     * outside the host's space and drew nothing. While [CYLRefreshFooter.noMoreData] is set the footer is held fully in
     * (or further in while it is pulled) and returns to the pull's position when it is cleared.
     */
    private fun holdNoMoreDataFooter() {
        val footer = mRefreshFooter?.takeIf { it.spinnerStyle == SpinnerStyle.Translate } ?: return
        val view = footer.view
        val target = if (cyl_footer?.noMoreData == true) min(mSpinner, -view.height).toFloat() else if (footerHeldVisible) min(mSpinner, 0).toFloat() else return
        footerHeldVisible = cyl_footer?.noMoreData == true
        if (view.translationY != target) view.translationY = target
    }

    // Before every frame: a child that only invalidates itself (the footer's text) does not redraw this layout, so a
    // draw hook would miss the moment "no more data" is set.
    private val holdBeforeDraw = ViewTreeObserver.OnPreDrawListener {
        holdNoMoreDataFooter()
        true
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        viewTreeObserver.addOnPreDrawListener(holdBeforeDraw)
    }

    override fun onDetachedFromWindow() {
        viewTreeObserver.removeOnPreDrawListener(holdBeforeDraw)
        super.onDetachedFromWindow()
    }

    /**
     * Ignores touches: the host feeds the pull through [drive].
     */
    override fun dispatchTouchEvent(e: MotionEvent): Boolean = false
}
