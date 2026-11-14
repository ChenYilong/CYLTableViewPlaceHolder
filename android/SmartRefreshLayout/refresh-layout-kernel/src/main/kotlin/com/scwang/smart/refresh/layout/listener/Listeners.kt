// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.layout.listener

import android.content.Context
import android.view.View
import com.scwang.smart.refresh.layout.api.RefreshFooter
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState

/**
 * Hears a CoordinatorLayout's app bar (`CoordinatorLayoutListener`).
 */
fun interface CoordinatorLayoutListener {
    /**
     * Whether refreshing and loading more are possible with the app bar's offset.
     */
    fun onCoordinatorUpdate(enableRefresh: Boolean, enableLoadMore: Boolean)
}

/**
 * Makes the default footer of every layout (`DefaultRefreshFooterCreator`).
 */
fun interface DefaultRefreshFooterCreator {
    /**
     * A new footer for [layout].
     */
    fun createRefreshFooter(context: Context, layout: RefreshLayout): RefreshFooter
}

/**
 * Makes the default header of every layout (`DefaultRefreshHeaderCreator`).
 */
fun interface DefaultRefreshHeaderCreator {
    /**
     * A new header for [layout].
     */
    fun createRefreshHeader(context: Context, layout: RefreshLayout): RefreshHeader
}

/**
 * Sets up every new layout (`DefaultRefreshInitializer`).
 */
fun interface DefaultRefreshInitializer {
    /**
     * Sets up [layout].
     */
    fun initialize(context: Context, layout: RefreshLayout)
}

/**
 * Called to load more (`OnLoadMoreListener`).
 */
fun interface OnLoadMoreListener {
    /**
     * Load more, then call finishLoadMore.
     */
    fun onLoadMore(refreshLayout: RefreshLayout)
}

/**
 * Called to refresh (`OnRefreshListener`).
 */
fun interface OnRefreshListener {
    /**
     * Refresh, then call finishRefresh.
     */
    fun onRefresh(refreshLayout: RefreshLayout)
}

/**
 * Called to refresh and to load more (`OnRefreshLoadMoreListener`).
 */
interface OnRefreshLoadMoreListener : OnRefreshListener, OnLoadMoreListener

/**
 * Hears state changes (`OnStateChangedListener`).
 */
fun interface OnStateChangedListener {
    /**
     * The state changed from [oldState] to [newState].
     */
    fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState)
}

/**
 * Hears every step of the header and footer (`OnMultiListener`).
 */
interface OnMultiListener : OnRefreshLoadMoreListener, OnStateChangedListener {
    /**
     * The header moved.
     */
    fun onHeaderMoving(header: RefreshHeader?, isDragging: Boolean, percent: Float, offset: Int, headerHeight: Int, maxDragHeight: Int)

    /**
     * The header was released.
     */
    fun onHeaderReleased(header: RefreshHeader?, headerHeight: Int, maxDragHeight: Int)

    /**
     * The header started its animation.
     */
    fun onHeaderStartAnimator(header: RefreshHeader?, headerHeight: Int, maxDragHeight: Int)

    /**
     * The header finished.
     */
    fun onHeaderFinish(header: RefreshHeader?, success: Boolean)

    /**
     * The footer moved.
     */
    fun onFooterMoving(footer: RefreshFooter?, isDragging: Boolean, percent: Float, offset: Int, footerHeight: Int, maxDragHeight: Int)

    /**
     * The footer was released.
     */
    fun onFooterReleased(footer: RefreshFooter?, footerHeight: Int, maxDragHeight: Int)

    /**
     * The footer started its animation.
     */
    fun onFooterStartAnimator(footer: RefreshFooter?, footerHeight: Int, maxDragHeight: Int)

    /**
     * The footer finished.
     */
    fun onFooterFinish(footer: RefreshFooter?, success: Boolean)
}

/**
 * Decides when the content is at its top or end (`ScrollBoundaryDecider`).
 */
interface ScrollBoundaryDecider {
    /**
     * True when [content] can refresh.
     */
    fun canRefresh(content: View): Boolean

    /**
     * True when [content] can load more.
     */
    fun canLoadMore(content: View): Boolean
}
