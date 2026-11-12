// SVPullToRefresh (https://github.com/samvermette/SVPullToRefresh, MIT, Copyright (C) 2012 Sam Vermette) in Kotlin.
package com.cyl.svpulltorefresh

/**
 * Where a pull-to-refresh view sits: above the content (pull down) or below it (pull up)
 * (`SVPullToRefreshPosition`).
 */
enum class SVPullToRefreshPosition { TOP, BOTTOM }

/**
 * The pull-to-refresh view's state (`SVPullToRefreshState`). [ALL] is only used to set a title, subtitle or custom view
 * for every state at once.
 */
enum class SVPullToRefreshState { STOPPED, TRIGGERED, LOADING, ALL }

/**
 * The infinite-scrolling view's state (`SVInfiniteScrollingState`). [ALL] is only used to set a custom view for every
 * state at once.
 */
enum class SVInfiniteScrollingState { STOPPED, TRIGGERED, LOADING, ALL }

/**
 * The direction infinite scrolling loads in (pull requests #146, #180 and #203): down (vertical, the default) or to the
 * right (horizontal).
 */
enum class SVInfiniteScrollingDirection { VERTICAL, HORIZONTAL }

/**
 * Receives a pull-to-refresh view's changes (pull requests #159 and #175: state changes for custom views; #223: the
 * dragging progress).
 */
interface SVPullToRefreshViewListener {
    /**
     * The state changed from [oldState] to [state].
     */
    fun onStateChanged(view: SVPullToRefreshView, oldState: SVPullToRefreshState, state: SVPullToRefreshState) {}

    /**
     * The view was pulled [distance] pixels; [progress] is the distance over the trigger distance (1 = triggers).
     */
    fun onPull(view: SVPullToRefreshView, distance: Float, progress: Float) {}
}
