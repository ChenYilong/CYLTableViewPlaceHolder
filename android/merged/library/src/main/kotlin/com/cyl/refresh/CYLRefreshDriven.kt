package com.cyl.refresh

import android.content.Context
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import com.cyl.refresh.layout.CYLRefreshLayout
import com.cyl.refresh.layout.constant.RefreshState

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

    /**
     * Ignores touches: the host feeds the pull through [drive].
     */
    override fun dispatchTouchEvent(e: MotionEvent): Boolean = false
}
