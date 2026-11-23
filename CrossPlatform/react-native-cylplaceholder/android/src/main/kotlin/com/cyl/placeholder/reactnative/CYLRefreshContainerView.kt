package com.cyl.placeholder.reactnative

import android.content.Context
import android.graphics.Canvas
import com.cyl.refresh.CYLRefreshAutoNormalFooter
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.cyl_footer
import com.cyl.refresh.cyl_header
import com.cyl.refresh.layout.CYLRefreshLayout

/**
 * The native container a React Native scroll view sits in: a [CYLRefreshLayout] whose first child is the scroll view, with
 * the iOS-named header (`cyl_header`) and footer (`cyl_footer`) attached. The JS side passes `refreshing`, `enabled`,
 * `loadingMore`, `noMoreData` and `loadMoreEnabled` as props and gets [onRefresh] when the user pulls the header and
 * [onLoadMore] when the footer starts loading (docs/Refresh-Library-Parity.md, "Native bridge map").
 */
class CYLRefreshContainerView(context: Context) : CYLRefreshLayout(context) {
    /**
     * Called when the header starts refreshing from a pull (not when `refreshing` was set from JS).
     */
    var onRefresh: (() -> Unit)? = null

    /**
     * Called when the footer starts loading more (not when `loadingMore` was set from JS).
     */
    var onLoadMore: (() -> Unit)? = null

    private val header = CYLRefreshNormalHeader(context)
    private val footer = CYLRefreshAutoNormalFooter(context)
    // The refresh JavaScript asked for runs its refreshing block later; that block must not call onRefresh back.
    private var askedByJs = false
    private var loadAskedByJs = false

    init {
        header.refreshingBlock = { if (askedByJs) askedByJs = false else onRefresh?.invoke() }
        cyl_header = header
        footer.refreshingBlock = { if (loadAskedByJs) loadAskedByJs = false else onLoadMore?.invoke() }
        cyl_footer = footer
        // Off until the `loadMoreEnabled` prop turns it on, so a container without a footer behaves as before.
        setEnableLoadMore(false)
    }

    // [EN] The header rests above the container, and React Native lets children draw outside their parent, so the resting
    //      header showed over the title above the list (found on the emulator); clip the drawing to the container.
    // [CN] 头部静止时在容器上方，而 React Native 允许子视图画到父视图外面，于是静止的头部盖在列表上方的标题上（在模拟器上发现）；
    //      所以把绘制裁剪在容器内。
    override fun dispatchDraw(canvas: Canvas) {
        canvas.save()
        canvas.clipRect(0, 0, width, height)
        super.dispatchDraw(canvas)
        canvas.restore()
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

    /**
     * Whether loading more is on (default off).
     */
    fun setLoadMoreEnabled(enabled: Boolean) {
        setEnableLoadMore(enabled)
    }

    /**
     * Shows or hides the loading state of the footer, as `refreshing` does for the header.
     */
    fun setLoadingMoreFromJs(loading: Boolean) {
        if (loading == footer.isRefreshing) return
        if (loading) {
            loadAskedByJs = true
            footer.beginRefreshing()
        } else {
            loadAskedByJs = false
            footer.endRefreshing()
        }
    }

    /**
     * Shows "no more data" in the footer (true) or loads again (false); true while loading ends the load with it.
     */
    fun setNoMoreDataFromJs(noMoreData: Boolean) {
        if (noMoreData == footer.noMoreData) return
        if (!noMoreData) footer.resetNoMoreData()
        else if (footer.isRefreshing) footer.endRefreshingWithNoMoreData()
        else footer.noticeNoMoreData()
    }
}
