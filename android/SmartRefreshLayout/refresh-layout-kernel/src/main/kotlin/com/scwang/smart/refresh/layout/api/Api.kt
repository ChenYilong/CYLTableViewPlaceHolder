// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.layout.api

import android.animation.Animator
import android.animation.ValueAnimator
import android.animation.ValueAnimator.AnimatorUpdateListener
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.animation.Interpolator
import androidx.annotation.ColorInt
import androidx.annotation.ColorRes
import androidx.annotation.FloatRange
import androidx.annotation.IdRes
import androidx.annotation.RestrictTo
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.listener.OnLoadMoreListener
import com.scwang.smart.refresh.layout.listener.OnMultiListener
import com.scwang.smart.refresh.layout.listener.OnRefreshListener
import com.scwang.smart.refresh.layout.listener.OnRefreshLoadMoreListener
import com.scwang.smart.refresh.layout.listener.OnStateChangedListener
import com.scwang.smart.refresh.layout.listener.ScrollBoundaryDecider

/**
 * A header or a footer of the refresh layout (`RefreshComponent`); the layout calls these methods.
 */
interface RefreshComponent : OnStateChangedListener {
    /**
     * The view shown for this component.
     */
    val view: View

    /**
     * How the component moves with the pull.
     */
    val spinnerStyle: SpinnerStyle

    /**
     * The layout's primary colors (srlPrimaryColor, srlAccentColor).
     */
    fun setPrimaryColors(@ColorInt vararg colors: Int)

    /**
     * True when autoRefresh / autoLoadMore starts, false when it ends (pull request #1095), so a component can tell an
     * auto refresh from a drag (#1268). A default method, so existing components keep compiling.
     */
    @RestrictTo(RestrictTo.Scope.LIBRARY, RestrictTo.Scope.LIBRARY_GROUP, RestrictTo.Scope.SUBCLASSES)
    fun onAutoRefresh(isAutoRefresh: Boolean) {}

    /**
     * The size is known; called once, and again when the height changes.
     */
    fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int)

    /**
     * The pull moved: [percent] of the trigger height, [offset] pixels.
     */
    fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int)

    /**
     * Released past the trigger height.
     */
    fun onReleased(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int)

    /**
     * Refreshing (or loading) started; start the animation.
     */
    fun onStartAnimator(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int)

    /**
     * Finished; returns the milliseconds to wait before closing (Int.MAX_VALUE: do not close).
     */
    fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int

    /**
     * A sideways move while pulled.
     */
    fun onHorizontalDrag(percentX: Float, offsetX: Int, offsetMax: Int)

    /**
     * True when the component follows sideways moves.
     */
    val isSupportHorizontalDrag: Boolean

    /**
     * Opens the component itself for an auto refresh; false lets the layout animate it.
     */
    fun autoOpen(duration: Int, dragRate: Float, animationOnly: Boolean): Boolean
}

/**
 * A refresh header (`RefreshHeader`).
 */
interface RefreshHeader : RefreshComponent

/**
 * A refresh footer (`RefreshFooter`).
 */
interface RefreshFooter : RefreshComponent {
    /**
     * Shows or hides the no-more-data state; false when the footer does not support it.
     */
    fun setNoMoreData(noMoreData: Boolean): Boolean
}

/**
 * The content wrapper of the refresh layout (`RefreshContent`).
 */
interface RefreshContent {
    /**
     * The content view.
     */
    val view: View

    /**
     * The view that scrolls inside the content.
     */
    val scrollableView: View

    /**
     * A finger went down, to find the scrolling view under it.
     */
    fun onActionDown(e: MotionEvent)

    /**
     * Sets up the scrolling view and the fixed header and footer views.
     */
    fun setUpComponent(kernel: RefreshKernel, fixedHeader: View?, fixedFooter: View?)

    /**
     * Decides when the content can refresh or load more.
     */
    fun setScrollBoundaryDecider(boundary: ScrollBoundaryDecider?)

    /**
     * Allows loading more when the content does not fill the layout.
     */
    fun setEnableLoadMoreWhenContentNotFull(enable: Boolean)

    /**
     * Moves the content (or its translation views) by [spinner].
     */
    fun moveSpinner(spinner: Int, headerTranslationViewId: Int, footerTranslationViewId: Int)

    /**
     * True when the content is at its top.
     */
    fun canRefresh(): Boolean

    /**
     * True when the content is at its end.
     */
    fun canLoadMore(): Boolean

    /**
     * A listener that scrolls the content while the layout closes, or null.
     */
    fun scrollContentWhenFinished(spinner: Int): AnimatorUpdateListener?
}

/**
 * The layout's interface for its components (`RefreshKernel`).
 */
interface RefreshKernel {
    /**
     * The layout.
     */
    val refreshLayout: RefreshLayout

    /**
     * The content.
     */
    val refreshContent: RefreshContent

    /**
     * Moves the layout to [state].
     */
    fun setState(state: RefreshState): RefreshKernel?

    /**
     * Opens (or cancels) the second floor.
     */
    fun startTwoLevel(open: Boolean): RefreshKernel

    /**
     * Closes the second floor.
     */
    fun finishTwoLevel(): RefreshKernel

    /**
     * Moves the pull to [spinner].
     */
    fun moveSpinner(spinner: Int, isDragging: Boolean): RefreshKernel

    /**
     * Animates the pull to [endSpinner]; null when it is already there.
     */
    fun animSpinner(endSpinner: Int): ValueAnimator?

    /**
     * Draws a background color behind [internal].
     */
    fun requestDrawBackgroundFor(internal: RefreshComponent, backgroundColor: Int): RefreshKernel

    /**
     * Lets [internal] get touches while open.
     */
    fun requestNeedTouchEventFor(internal: RefreshComponent, request: Boolean): RefreshKernel

    /**
     * The default for moving the content with [internal], unless the app set it.
     */
    fun requestDefaultTranslationContentFor(internal: RefreshComponent, translation: Boolean): RefreshKernel

    /**
     * Measures [internal]'s height again.
     */
    fun requestRemeasureHeightFor(internal: RefreshComponent): RefreshKernel

    /**
     * The second floor's open and close duration.
     */
    fun requestFloorDuration(duration: Int): RefreshKernel

    /**
     * The bottom share of the second floor where a pull up closes it.
     */
    fun requestFloorBottomPullUpToCloseRate(rate: Float): RefreshKernel

    /**
     * An auto refresh's open animation ended.
     */
    fun onAutoRefreshAnimationEnd(animation: Animator?, animationOnly: Boolean): RefreshKernel

    /**
     * An auto load more's open animation ended.
     */
    fun onAutoLoadMoreAnimationEnd(animation: Animator?, animationOnly: Boolean): RefreshKernel
}

/**
 * The refresh layout's API (`RefreshLayout`). Rates below 10 are multiples of the header's (footer's) height; 10 and
 * above are pixels.
 */
interface RefreshLayout {
    /**
     * The footer's height in dp.
     */
    fun setFooterHeight(dp: Float): RefreshLayout

    /**
     * The footer's height in pixels.
     */
    fun setFooterHeightPx(px: Int): RefreshLayout

    /**
     * The header's height in dp.
     */
    fun setHeaderHeight(dp: Float): RefreshLayout

    /**
     * The header's height in pixels.
     */
    fun setHeaderHeightPx(px: Int): RefreshLayout

    /**
     * The header's start inset in dp.
     */
    fun setHeaderInsetStart(dp: Float): RefreshLayout

    /**
     * The header's start inset in pixels.
     */
    fun setHeaderInsetStartPx(px: Int): RefreshLayout

    /**
     * The footer's start inset in dp.
     */
    fun setFooterInsetStart(dp: Float): RefreshLayout

    /**
     * The footer's start inset in pixels.
     */
    fun setFooterInsetStartPx(px: Int): RefreshLayout

    /**
     * Pull distance per finger distance (0 to 1).
     */
    fun setDragRate(@FloatRange(from = 0.0, to = 1.0) rate: Float): RefreshLayout

    /**
     * The longest header pull.
     */
    fun setHeaderMaxDragRate(@FloatRange(from = 1.0, to = 10.0) rate: Float): RefreshLayout

    /**
     * The longest footer pull.
     */
    fun setFooterMaxDragRate(@FloatRange(from = 1.0, to = 10.0) rate: Float): RefreshLayout

    /**
     * The header pull that triggers a refresh.
     */
    fun setHeaderTriggerRate(@FloatRange(from = 0.0, to = 1.0) rate: Float): RefreshLayout

    /**
     * The footer pull that triggers loading more.
     */
    fun setFooterTriggerRate(@FloatRange(from = 0.0, to = 1.0) rate: Float): RefreshLayout

    /**
     * The interpolator of the bounce back.
     */
    fun setReboundInterpolator(interpolator: Interpolator): RefreshLayout

    /**
     * The duration of the bounce back in milliseconds.
     */
    fun setReboundDuration(duration: Int): RefreshLayout

    /**
     * Sets the footer.
     */
    fun setRefreshFooter(footer: RefreshFooter): RefreshLayout

    /**
     * Sets the footer with its size.
     */
    fun setRefreshFooter(footer: RefreshFooter, width: Int, height: Int): RefreshLayout

    /**
     * Sets the header.
     */
    fun setRefreshHeader(header: RefreshHeader): RefreshLayout

    /**
     * Sets the header with its size.
     */
    fun setRefreshHeader(header: RefreshHeader, width: Int, height: Int): RefreshLayout

    /**
     * Sets the content.
     */
    fun setRefreshContent(content: View): RefreshLayout

    /**
     * Sets the content with its size.
     */
    fun setRefreshContent(content: View, width: Int, height: Int): RefreshLayout

    /**
     * Enables pull to refresh.
     */
    fun setEnableRefresh(enabled: Boolean): RefreshLayout

    /**
     * Enables load more.
     */
    fun setEnableLoadMore(enabled: Boolean): RefreshLayout

    /**
     * Loads more by itself when the content's end is reached.
     */
    fun setEnableAutoLoadMore(enabled: Boolean): RefreshLayout

    /**
     * Moves the content with the header.
     */
    fun setEnableHeaderTranslationContent(enabled: Boolean): RefreshLayout

    /**
     * Moves the content with the footer.
     */
    fun setEnableFooterTranslationContent(enabled: Boolean): RefreshLayout

    /**
     * Bounces when a fling reaches the edge.
     */
    fun setEnableOverScrollBounce(enabled: Boolean): RefreshLayout

    /**
     * Pure scroll mode: pulls bounce both ways without refreshing (issues #1109, #1199).
     */
    fun setEnablePureScrollMode(enabled: Boolean): RefreshLayout

    /**
     * Scrolls the content to show new data after loading more.
     */
    fun setEnableScrollContentWhenLoaded(enabled: Boolean): RefreshLayout

    /**
     * Scrolls the content after refreshing.
     */
    fun setEnableScrollContentWhenRefreshed(enabled: Boolean): RefreshLayout

    /**
     * Loads more when the content does not fill the layout.
     */
    fun setEnableLoadMoreWhenContentNotFull(enabled: Boolean): RefreshLayout

    /**
     * Allows pulling past the edges without refreshing.
     */
    fun setEnableOverScrollDrag(enabled: Boolean): RefreshLayout

    /**
     * Keeps the footer after the content when there is no more data.
     */
    fun setEnableFooterFollowWhenNoMoreData(enabled: Boolean): RefreshLayout

    /**
     * Clips a FixedBehind header.
     */
    fun setEnableClipHeaderWhenFixedBehind(enabled: Boolean): RefreshLayout

    /**
     * Clips a FixedBehind footer.
     */
    fun setEnableClipFooterWhenFixedBehind(enabled: Boolean): RefreshLayout

    /**
     * Enables nested scrolling.
     */
    fun setEnableNestedScroll(enabled: Boolean): RefreshLayout

    /**
     * A view inside the content that stays at the top.
     */
    fun setFixedHeaderViewId(@IdRes id: Int): RefreshLayout

    /**
     * A view inside the content that stays at the bottom.
     */
    fun setFixedFooterViewId(@IdRes id: Int): RefreshLayout

    /**
     * The view that moves with the header instead of the content.
     */
    fun setHeaderTranslationViewId(@IdRes id: Int): RefreshLayout

    /**
     * The view that moves with the footer instead of the content.
     */
    fun setFooterTranslationViewId(@IdRes id: Int): RefreshLayout

    /**
     * Ignores touches on the content while refreshing.
     */
    fun setDisableContentWhenRefresh(disable: Boolean): RefreshLayout

    /**
     * Ignores touches on the content while loading.
     */
    fun setDisableContentWhenLoading(disable: Boolean): RefreshLayout

    /**
     * Called to refresh.
     */
    fun setOnRefreshListener(listener: OnRefreshListener?): RefreshLayout

    /**
     * Called to load more.
     */
    fun setOnLoadMoreListener(listener: OnLoadMoreListener?): RefreshLayout

    /**
     * Called to refresh and to load more.
     */
    fun setOnRefreshLoadMoreListener(listener: OnRefreshLoadMoreListener?): RefreshLayout

    /**
     * Called for every step.
     */
    fun setOnMultiListener(listener: OnMultiListener?): RefreshLayout

    /**
     * Decides when the content can refresh or load more.
     */
    fun setScrollBoundaryDecider(boundary: ScrollBoundaryDecider?): RefreshLayout

    /**
     * The components' primary colors.
     */
    fun setPrimaryColors(@ColorInt vararg primaryColors: Int): RefreshLayout

    /**
     * The components' primary colors, as resources.
     */
    fun setPrimaryColorsId(@ColorRes vararg primaryColorId: Int): RefreshLayout

    /**
     * Ends refreshing.
     */
    fun finishRefresh(): RefreshLayout

    /**
     * Ends refreshing after [delayed] milliseconds.
     */
    fun finishRefresh(delayed: Int): RefreshLayout

    /**
     * Ends refreshing, succeeded or failed.
     */
    fun finishRefresh(success: Boolean): RefreshLayout

    /**
     * Ends refreshing; [noMoreData] null leaves it unchanged.
     */
    fun finishRefresh(delayed: Int, success: Boolean, noMoreData: Boolean?): RefreshLayout

    /**
     * Ends refreshing and marks no more data.
     */
    fun finishRefreshWithNoMoreData(): RefreshLayout

    /**
     * Ends loading more.
     */
    fun finishLoadMore(): RefreshLayout

    /**
     * Ends loading more after [delayed] milliseconds.
     */
    fun finishLoadMore(delayed: Int): RefreshLayout

    /**
     * Ends loading more, succeeded or failed.
     */
    fun finishLoadMore(success: Boolean): RefreshLayout

    /**
     * Ends loading more.
     */
    fun finishLoadMore(delayed: Int, success: Boolean, noMoreData: Boolean): RefreshLayout

    /**
     * Ends loading more and marks no more data.
     */
    fun finishLoadMoreWithNoMoreData(): RefreshLayout

    /**
     * Closes the open header or footer.
     */
    fun closeHeaderOrFooter(): RefreshLayout

    /**
     * Marks (or clears) no more data.
     */
    fun setNoMoreData(noMoreData: Boolean): RefreshLayout

    /**
     * Clears no more data.
     */
    fun resetNoMoreData(): RefreshLayout

    /**
     * The header, or null.
     */
    val refreshHeader: RefreshHeader?

    /**
     * The footer, or null.
     */
    val refreshFooter: RefreshFooter?

    /**
     * The state.
     */
    val state: RefreshState

    /**
     * The layout's view.
     */
    val layout: ViewGroup

    /**
     * Refreshes as if pulled; false when it cannot now.
     */
    fun autoRefresh(): Boolean

    /**
     * Refreshes as if pulled, after [delayed] milliseconds.
     */
    fun autoRefresh(delayed: Int): Boolean

    /**
     * Shows refreshing without calling the refresh listener.
     */
    fun autoRefreshAnimationOnly(): Boolean

    /**
     * Refreshes as if pulled, with the open duration and pull rate.
     */
    fun autoRefresh(delayed: Int, duration: Int, dragRate: Float, animationOnly: Boolean): Boolean

    /**
     * Loads more as if pulled up.
     */
    fun autoLoadMore(): Boolean

    /**
     * Loads more as if pulled up, after [delayed] milliseconds.
     */
    fun autoLoadMore(delayed: Int): Boolean

    /**
     * Shows loading more without calling the load-more listener.
     */
    fun autoLoadMoreAnimationOnly(): Boolean

    /**
     * Loads more as if pulled up, with the open duration and pull rate.
     */
    fun autoLoadMore(delayed: Int, duration: Int, dragRate: Float, animationOnly: Boolean): Boolean

    /**
     * True while refreshing.
     */
    val isRefreshing: Boolean

    /**
     * True while loading more.
     */
    val isLoading: Boolean
}
