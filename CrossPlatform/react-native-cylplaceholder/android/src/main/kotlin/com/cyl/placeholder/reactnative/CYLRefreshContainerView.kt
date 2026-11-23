package com.cyl.placeholder.reactnative

import android.content.Context
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.cyl_header
import com.cyl.refresh.layout.CYLRefreshLayout

/**
 * The native container a React Native scroll view sits in: a [CYLRefreshLayout] whose first child is the scroll view, with
 * the iOS-named header (`cyl_header`) attached. The JS side passes `refreshing` and `enabled` as props and gets [onRefresh]
 * when the user pulls (docs/Refresh-Library-Parity.md, "Native bridge map").
 */
class CYLRefreshContainerView(context: Context) : CYLRefreshLayout(context) {
    /**
     * Called when the header starts refreshing from a pull (not when `refreshing` was set from JS).
     */
    var onRefresh: (() -> Unit)? = null

    private val header = CYLRefreshNormalHeader(context)
    // The refresh JavaScript asked for runs its refreshing block later; that block must not call onRefresh back.
    private var askedByJs = false

    init {
        header.refreshingBlock = { if (askedByJs) askedByJs = false else onRefresh?.invoke() }
        cyl_header = header
    }

    /**
     * Whether the pull is on.
     */
    fun setPullEnabled(enabled: Boolean) {
        setEnableRefresh(enabled)
    }

    /**
     * Shows or hides the refreshing state, as the `refreshing` prop of a React Native `RefreshControl`.
     */
    fun setRefreshingFromJs(refreshing: Boolean) {
        if (refreshing == header.isRefreshing) return
        if (refreshing) {
            askedByJs = true
            header.beginRefreshing()
        } else {
            askedByJs = false
            header.endRefreshing()
        }
    }
}
