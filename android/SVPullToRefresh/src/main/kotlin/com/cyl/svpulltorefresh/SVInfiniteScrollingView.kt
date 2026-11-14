// SVPullToRefresh (https://github.com/samvermette/SVPullToRefresh, MIT, Copyright (C) 2012 Sam Vermette) in Kotlin.
package com.cyl.svpulltorefresh

import android.content.Context
import android.graphics.Color
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.accessibility.AccessibilityNodeInfo
import android.widget.Button
import android.widget.FrameLayout
import android.widget.ProgressBar
import android.widget.TextView

/**
 * The view after the content that shows loading more (`SVInfiniteScrollingView`). Made by
 * [SVPullToRefreshLayout.addInfiniteScrolling]. Open, so an app can subclass it and pass a factory there (issue #195);
 * a subclass overrides [updateForState] and calls super.
 */
open class SVInfiniteScrollingView(context: Context) : FrameLayout(context) {

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
     * YES shows "No more data" after the content and stops infinite scrolling from triggering until it is NO again
     * (issue #246). Default NO.
     */
    var showsNoMoreData: Boolean = false
        set(value) {
            if (field == value) return
            field = value
            if (value) stopAnimating()
            updateForState()
            layout?.updateInfiniteScrollingRoom()
        }

    /**
     * The spinner shown while loading.
     */
    val activityIndicatorView = ProgressBar(context).apply {
        isIndeterminate = true
        visibility = GONE
    }

    /**
     * The text after the content: "Load more" (a button) when infinite scrolling does not trigger by itself
     * ([SVPullToRefreshLayout.automaticallyTriggersInfiniteScrolling], issues #217 and #246), "No more data" with
     * [showsNoMoreData]; hidden otherwise.
     */
    val titleLabel = TextView(context).apply {
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
        setTextColor(Color.DKGRAY)
        gravity = Gravity.CENTER
        visibility = GONE
    }

    private val customViews = mutableMapOf<SVInfiniteScrollingState, View?>()
    private var shownCustomView: View? = null
    internal var layout: SVPullToRefreshLayout? = null

    init {
        val dp = resources.displayMetrics.density
        addView(activityIndicatorView, LayoutParams((24 * dp).toInt(), (24 * dp).toInt(), Gravity.CENTER))
        addView(titleLabel, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT, Gravity.CENTER))
        titleLabel.setOnClickListener { layout?.triggerInfiniteScrolling() }
        // Accessibility: "Load more" reads as a button.
        titleLabel.accessibilityDelegate = object : AccessibilityDelegate() {
            override fun onInitializeAccessibilityNodeInfo(host: View, info: AccessibilityNodeInfo) {
                super.onInitializeAccessibilityNodeInfo(host, info)
                if (host.isClickable) info.className = Button::class.java.name
            }
        }
        applyState()
    }

    /**
     * Shows [view] in [state] instead of the spinner (`setCustomView:forState:`); null removes it;
     * [SVInfiniteScrollingState.ALL] sets every state. A STOPPED view (for example a "Load more" button) shows when
     * infinite scrolling does not trigger by itself.
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

    /**
     * Shows the view for [state]: the custom view, the spinner or the text. A subclass that draws its own content
     * overrides it and calls super. The constructor does not call it, since a subclass is not initialized yet then.
     */
    protected open fun updateForState() = applyState()

    private fun applyState() {
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
        val manual = layout?.automaticallyTriggersInfiniteScrolling == false
        val text = when {
            loading || custom != null -> null
            showsNoMoreData -> context.getString(R.string.sv_no_more_data)
            manual -> context.getString(R.string.sv_load_more)
            else -> null
        }
        titleLabel.text = text
        titleLabel.visibility = if (text == null) GONE else VISIBLE
        titleLabel.isClickable = text != null && !showsNoMoreData
        contentDescription = if (loading) context.getString(R.string.sv_loading_more) else null
        importantForAccessibility = if (loading || text != null || custom != null) IMPORTANT_FOR_ACCESSIBILITY_AUTO
        else IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS
    }

    internal fun refresh() = updateForState()

    /** The view takes room after the content: while loading, with "No more data", or as a "Load more" button. */
    internal val needsRoom: Boolean
        get() = state == SVInfiniteScrollingState.LOADING || showsNoMoreData ||
            layout?.automaticallyTriggersInfiniteScrolling == false
}
