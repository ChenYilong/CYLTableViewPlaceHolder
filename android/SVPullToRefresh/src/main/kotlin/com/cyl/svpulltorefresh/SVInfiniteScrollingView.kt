// SVPullToRefresh (https://github.com/samvermette/SVPullToRefresh, MIT, Copyright (C) 2012 Sam Vermette) in Kotlin.
package com.cyl.svpulltorefresh

import android.content.Context
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.ProgressBar

/**
 * The view after the content that shows loading more (`SVInfiniteScrollingView`). Made by
 * [SVPullToRefreshLayout.addInfiniteScrolling].
 */
class SVInfiniteScrollingView internal constructor(context: Context) : FrameLayout(context) {

    /**
     * The current state. [SVInfiniteScrollingState.ALL] never is.
     */
    var state: SVInfiniteScrollingState = SVInfiniteScrollingState.STOPPED
        internal set(value) {
            if (field == value) return
            field = value
            updateForState()
        }

    /**
     * NO stops infinite scrolling from triggering, for example when there is no more data (`enabled`). Default YES.
     */
    var isInfiniteScrollingEnabled: Boolean = true

    /**
     * The spinner shown while loading.
     */
    val activityIndicatorView = ProgressBar(context).apply {
        isIndeterminate = true
        visibility = GONE
    }

    private val customViews = mutableMapOf<SVInfiniteScrollingState, View?>()
    private var shownCustomView: View? = null
    internal var layout: SVPullToRefreshLayout? = null

    init {
        val dp = resources.displayMetrics.density
        addView(activityIndicatorView, LayoutParams((24 * dp).toInt(), (24 * dp).toInt(), Gravity.CENTER))
        contentDescription = context.getString(R.string.sv_loading_more)
        updateForState()
    }

    /**
     * Shows [view] in [state] instead of the spinner (`setCustomView:forState:`); null removes it;
     * [SVInfiniteScrollingState.ALL] sets every state.
     */
    fun setCustomView(view: View?, state: SVInfiniteScrollingState) {
        if (state == SVInfiniteScrollingState.ALL) {
            listOf(SVInfiniteScrollingState.STOPPED, SVInfiniteScrollingState.TRIGGERED, SVInfiniteScrollingState.LOADING)
                .forEach { customViews[it] = view }
        } else {
            customViews[state] = view
        }
        updateForState()
    }

    /**
     * Starts loading more (`startAnimating`).
     */
    fun startAnimating() {
        layout?.startInfiniteScrolling(byUser = false)
    }

    /**
     * Ends loading more (`stopAnimating`). The content keeps its position; the room for this view is removed (pull
     * request #237).
     */
    fun stopAnimating() {
        layout?.stopInfiniteScrolling()
    }

    private fun updateForState() {
        val custom = customViews[state]
        if (custom !== shownCustomView) {
            shownCustomView?.let { removeView(it) }
            shownCustomView = custom
            custom?.let {
                (it.parent as? android.view.ViewGroup)?.removeView(it)
                addView(it, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT, Gravity.CENTER))
            }
        }
        // The spinner shows while loading even when it hides itself when stopped (pull request #306).
        val loading = state == SVInfiniteScrollingState.LOADING
        activityIndicatorView.visibility = if (custom == null && loading) VISIBLE else GONE
        importantForAccessibility = if (loading) IMPORTANT_FOR_ACCESSIBILITY_YES else IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS
    }
}
