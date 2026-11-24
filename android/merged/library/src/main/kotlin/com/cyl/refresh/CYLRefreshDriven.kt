package com.cyl.refresh

import android.content.Context
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.ViewTreeObserver
import com.cyl.refresh.layout.CYLRefreshLayout
import com.cyl.refresh.layout.constant.RefreshState
import com.cyl.refresh.layout.constant.SpinnerStyle
import kotlin.math.abs
import kotlin.math.max
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
        onBeforeDraw?.invoke()
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

    /**
     * The pull the layout shows now, in pixels (>= 0): the spinner's size, or the footer's height while "no more data" holds it
     * in. The Flutter slot reads it before every frame, because the rebound after a release moves the spinner without any call.
     */
    val shownPull: Int
        get() = max(abs(mSpinner), if (cyl_footer?.noMoreData == true) mFooterHeight else 0)

    /**
     * The indicator's own (intrinsic) height in pixels: the footer's for a layout with a footer, else the header's.
     */
    val indicatorExtent: Int get() = if (cyl_footer != null) mFooterHeight else mHeaderHeight

    /**
     * Called before every frame this layout draws (the hook that holds the "no more data" footer): the host re-fits its slot.
     */
    var onBeforeDraw: (() -> Unit)? = null

    companion object {
        /**
         * The height, in pixels, a driven layout takes in a slot that is [slotHeight] tall and shows only the pulled part of the
         * indicator (the Flutter plugin's slot, anchored at the bottom edge for a header and the top edge for a footer): the
         * pull ([offset], either sign), or while the indicator is [held] open the indicator's own height [extent] (the whole slot
         * when [extent] is 0, unknown), whichever is larger; at least 1, never 0. The layout is thus never shorter than the
         * indicator while refreshing. The indicator sits at the pull inside the layout, so the host also moves the layout by
         * [anchorShift] to keep it at the slot's edge (a layout as tall as the slot once scrolled the indicator by the pull a
         * second time, which left the classic header blank until the pull passed half of it).
         */
        @JvmStatic
        @JvmOverloads
        fun slotHeight(slotHeight: Int, offset: Int, held: Boolean, extent: Int = 0): Int =
            max(1, max(abs(offset), if (held) (if (extent > 0) extent else slotHeight) else 0))

        /**
         * How far, in pixels, the host moves a layout of [height] pixels so an indicator that sits [shown] pixels into it ends
         * at the slot's edge: down for a header, up (negative) for a [footer]. Zero when the layout is as tall as the pull.
         */
        @JvmStatic
        fun anchorShift(height: Int, shown: Int, footer: Boolean): Int = max(0, height - shown).let { if (footer) -it else it }

        /**
         * The same for a slot whose indicator stays put while the content moves over it (Flutter's `behind` scroll mode): the
         * layout is as tall as the whole slot and the indicator ends at the slot's FAR edge (top for a header, bottom for a
         * [footer]), at its [extent], whatever the pull [shown]; the moving content uncovers it from that edge.
         */
        @JvmStatic
        fun behindShift(shown: Int, extent: Int, footer: Boolean): Int = if (footer) shown - extent else extent - shown
    }
}
