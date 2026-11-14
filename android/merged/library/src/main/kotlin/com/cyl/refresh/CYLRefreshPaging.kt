package com.cyl.refresh

import com.cyl.placeholder.CYLPlaceholderLocalization

/**
 * Hands a page's result back to a [CYLRefreshPaging] (iOS `CYLRefreshPagingCompletion`): the page's items, the total
 * number of items and of pages when the server tells them (0 otherwise), and an error or null.
 */
typealias CYLRefreshPagingCompletion = (items: List<Any>?, total: Int, totalPage: Int, error: Throwable?) -> Unit

/**
 * Loads one page for a [CYLRefreshPaging] (iOS `CYLRefreshPagingLoader`).
 */
typealias CYLRefreshPagingLoader = (page: Int, completion: CYLRefreshPagingCompletion) -> Unit

/**
 * Pages a list through a header and a footer (iOS `CYLRefreshPaging`): the header reloads the first page, the footer
 * loads the next one, and the footer shows "no more data" at the end.
 */
class CYLRefreshPaging(
    /**
     * The header that refreshes, or null (`header`).
     */
    val header: CYLRefreshHeader?,
    /**
     * The footer that loads more, or null (`footer`).
     */
    val footer: CYLRefreshFooter?,
    private val loader: CYLRefreshPagingLoader,
) {
    /**
     * The first page's number (`firstPage`).
     */
    var firstPage: Int = 1

    /**
     * The items loaded so far, or null before the first page (`items`).
     */
    var items: List<Any>? = null
        private set

    /**
     * How many items are loaded (`count`).
     */
    val count: Int
        get() = items?.size ?: 0

    /**
     * The last page loaded (`page`).
     */
    var page: Int = 0
        private set

    /**
     * The total number of items, 0 when unknown (`total`).
     */
    var total: Int = 0
        private set

    /**
     * The total number of pages, 0 when unknown (`totalPage`).
     */
    var totalPage: Int = 0
        private set

    /**
     * Whether a page was loaded and there are no items (`isEmpty`).
     */
    val isEmpty: Boolean
        get() = items != null && count == 0

    /**
     * Whether the last page is loaded (`isNoMore`).
     */
    var isNoMore: Boolean = false
        private set

    /**
     * Whether a refresh clears the footer's "no more data" (`resetsFooterAfterRefresh`).
     */
    var resetsFooterAfterRefresh: Boolean = true

    /**
     * Called after the items change (`itemsDidChange`).
     */
    var itemsDidChange: ((CYLRefreshPaging) -> Unit)? = null

    private var loading = false

    init {
        header?.refreshingBlock = { load(firstPage) }
        footer?.refreshingBlock = { load(page + 1) }
    }

    /**
     * Loads the first page, through the header when there is one (`start`).
     */
    fun start() = refresh()

    /**
     * Reloads the first page (`refresh`).
     */
    fun refresh() {
        val header = header
        if (header != null && header.attached) header.beginRefreshing() else load(firstPage)
    }

    /**
     * Loads the next page (`loadMore`); nothing after the last one.
     */
    fun loadMore() {
        if (isNoMore) return
        val footer = footer
        if (footer != null && footer.attached) footer.beginRefreshing() else load(page + 1)
    }

    private fun load(requested: Int) {
        if (loading) return
        loading = true
        val refreshing = requested == firstPage
        loader(requested) { loaded, total, totalPage, error ->
            loading = false
            if (error == null) {
                page = requested
                this.total = total
                this.totalPage = totalPage
                items = if (refreshing) loaded.orEmpty() else items.orEmpty() + loaded.orEmpty()
                isNoMore = when {
                    totalPage > 0 -> page >= firstPage + totalPage - 1
                    total > 0 -> count >= total
                    else -> loaded.isNullOrEmpty()
                }
                itemsDidChange?.invoke(this)
            }
            if (refreshing) {
                header?.endRefreshingWithSuccess(error == null)
                if (error == null) {
                    if (isNoMore) footer?.noticeNoMoreData() else if (resetsFooterAfterRefresh) footer?.resetNoMoreData()
                }
            } else if (error == null && isNoMore) {
                footer?.endRefreshingWithNoMoreData()
            } else {
                footer?.endRefreshingWithSuccess(error == null)
            }
        }
    }
}

/**
 * The refresh components' settings (iOS `CYLRefreshConfig`).
 */
class CYLRefreshConfig private constructor() {
    /**
     * The language of the built-in texts, or null for the system's (`languageCode`). A classic header or footer made
     * after the change shows its built-in texts in this language; this also sets the placeholder texts' language
     * ([CYLPlaceholderLocalization.language]).
     */
    var languageCode: String? = null
        set(value) {
            field = value
            CYLPlaceholderLocalization.language = value
        }

    /**
     * The settings every component uses.
     */
    companion object {
        /**
         * The shared settings (`defaultConfig`).
         */
        @JvmStatic
        val defaultConfig = CYLRefreshConfig()
    }
}
