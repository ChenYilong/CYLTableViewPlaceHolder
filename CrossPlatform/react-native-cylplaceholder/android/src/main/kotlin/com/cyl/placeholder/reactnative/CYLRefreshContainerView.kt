package com.cyl.placeholder.reactnative

import android.content.Context
import android.graphics.Canvas
import android.view.View
import com.cyl.refresh.CYLRefreshAutoNormalFooter
import com.cyl.refresh.CYLRefreshBackFooter
import com.cyl.refresh.CYLRefreshFooter
import com.cyl.refresh.CYLRefreshHeader
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.CYLRefreshStyle
import com.cyl.refresh.cyl_footer
import com.cyl.refresh.cyl_header
import com.cyl.refresh.layout.CYLRefreshLayout

/**
 * The native container a React Native scroll view sits in: a [CYLRefreshLayout] whose first child is the scroll view, with
 * the iOS-named header (`cyl_header`) and footer (`cyl_footer`) attached. The JS side passes `refreshing`, `enabled`,
 * `loadingMore`, `noMoreData` and `loadMoreEnabled` as props and gets [onRefresh] when the user pulls the header and
 * [onLoadMore] when the footer starts loading (docs/Refresh-Library-Parity.md, "Native bridge map"). `headerStyle` / `footerStyle` name a
 * [CYLRefreshStyle] (`rive` also reads `headerRive` / `footerRive`: the `rive...` keys, `riveFile` first); they are applied together by
 * [applyStyles] after a batch of props. Without a style the header is the classic [CYLRefreshNormalHeader] and the footer the auto
 * [CYLRefreshAutoNormalFooter]; a style, `classic` too, makes the style's own header and footer (the classic back footer), as iOS does.
 * `rive` without the optional `:merged-rive` module, a `riveFile` or a readable file is the classic style and one log line says why.
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

    /**
     * Called after a second floor opened from a pull (not when `secondaryOpen` / `footerSecondaryOpen` was set from JS), with the
     * edge it belongs to: [EDGE_HEADER] or [EDGE_FOOTER].
     */
    var onSecondaryOpen: ((String) -> Unit)? = null

    /**
     * Called after a second floor closed from a push or a pull (not when `secondaryOpen` / `footerSecondaryOpen` was set from JS),
     * with the edge as [onSecondaryOpen].
     */
    var onSecondaryClose: ((String) -> Unit)? = null

    private var header: CYLRefreshHeader = CYLRefreshNormalHeader(context)
    private var footer: CYLRefreshFooter = CYLRefreshAutoNormalFooter(context)
    private var headerStyleKey: String? = null
    private var footerStyleKey: String? = null
    private var headerRive: Map<*, *>? = null
    private var footerRive: Map<*, *>? = null
    private var appliedHeaderStyle: Pair<String?, Map<*, *>?> = null to null
    private var appliedFooterStyle: Pair<String?, Map<*, *>?> = null to null
    private var loadMoreOn = false
    private var loadsAfterNoMoreDataOn = false
    private var secondaryTrigger = 0f
    private var secondaryDimensionDp = 0f
    private var secondaryCloseTrigger = 80f
    private var footerSecondaryTrigger = 0f
    private var footerSecondaryDimensionDp = 0f
    private var footerSecondaryCloseTrigger = 80f
    private var footerOpenAskedByJs = false
    private var footerCloseAskedByJs = false
    private var footerFloorChild: View? = null
    // The floor JavaScript asked to open or close runs its blocks later; they must not call the events back.
    private var openAskedByJs = false
    private var closeAskedByJs = false
    // The children React Native knows, in its order: the floor's content (nativeID "cyl.refresh.secondary") is one of them but
    // never a child of this layout (the layout would take it for the scroll view); the core's floor places it over the layout.
    private val reactChildren = ArrayList<View>()
    private var floorChild: View? = null
    // The refresh JavaScript asked for runs its refreshing block later; that block must not call onRefresh back.
    private var askedByJs = false
    private var loadAskedByJs = false

    init {
        installHeader(header)
        installFooter(footer)
    }

    private fun installHeader(new: CYLRefreshHeader) {
        header = new
        new.refreshingBlock = { if (askedByJs) askedByJs = false else onRefresh?.invoke() }
        new.secondaryOpenedBlock = { if (openAskedByJs) openAskedByJs = false else onSecondaryOpen?.invoke(EDGE_HEADER) }
        new.secondaryClosedBlock = { if (closeAskedByJs) closeAskedByJs = false else onSecondaryClose?.invoke(EDGE_HEADER) }
        new.secondaryTriggerOffset = secondaryTrigger
        new.secondaryDimension = secondaryDimensionDp
        new.secondaryCloseTriggerOffset = secondaryCloseTrigger
        new.secondaryView = floorChild
        cyl_header = new
    }

    private fun installFooter(new: CYLRefreshFooter) {
        footer = new
        new.refreshingBlock = { if (loadAskedByJs) loadAskedByJs = false else onLoadMore?.invoke() }
        new.loadsAfterNoMoreData = loadsAfterNoMoreDataOn
        // Only the back footers have a second floor (iOS `CYLRefreshBackFooter`); the auto footer and the others ignore the props.
        (new as? CYLRefreshBackFooter)?.let { back ->
            back.secondaryOpenedBlock = { if (footerOpenAskedByJs) footerOpenAskedByJs = false else onSecondaryOpen?.invoke(EDGE_FOOTER) }
            back.secondaryClosedBlock = { if (footerCloseAskedByJs) footerCloseAskedByJs = false else onSecondaryClose?.invoke(EDGE_FOOTER) }
            back.secondaryTriggerOffset = footerSecondaryTrigger
            back.secondaryDimension = footerSecondaryDimensionDp
            back.secondaryCloseTriggerOffset = footerSecondaryCloseTrigger
            back.secondaryView = footerFloorChild
        }
        cyl_footer = new
        // Off until the `loadMoreEnabled` prop turns it on, so a container without a footer behaves as before.
        setEnableLoadMore(loadMoreOn)
    }

    /** The `headerStyle` prop: a [CYLRefreshStyle] key; null or an unknown name keeps the default header. Applied by [applyStyles]. */
    fun setHeaderStyle(key: String?) {
        headerStyleKey = key
    }

    /** The `footerStyle` prop, as [setHeaderStyle]. */
    fun setFooterStyle(key: String?) {
        footerStyleKey = key
    }

    /** The `headerRive` prop: the `rive...` keys of the `rive` header (a React Native object as a map). Applied by [applyStyles]. */
    fun setHeaderRive(options: Map<*, *>?) {
        headerRive = options
    }

    /** The `footerRive` prop, as [setHeaderRive]. */
    fun setFooterRive(options: Map<*, *>?) {
        footerRive = options
    }

    /**
     * Makes the header and footer the style props name, once for a batch of props (the manager calls it after the update): a header or
     * footer is only replaced when its style key or Rive parameters changed since the last call.
     */
    fun applyStyles() {
        val headerStyle = headerStyleKey?.let { CYLRefreshStyle.fromKey(it) }
        val headerState = headerStyle?.key to (if (headerStyle == CYLRefreshStyle.Rive) headerRive else null)
        if (headerState != appliedHeaderStyle) {
            appliedHeaderStyle = headerState
            header.secondaryView = null
            installHeader(headerStyle?.newHeader(context, headerRive) ?: CYLRefreshNormalHeader(context))
        }
        val footerStyle = footerStyleKey?.let { CYLRefreshStyle.fromKey(it) }
        val footerState = footerStyle?.key to (if (footerStyle == CYLRefreshStyle.Rive) footerRive else null)
        if (footerState != appliedFooterStyle) {
            appliedFooterStyle = footerState
            (footer as? CYLRefreshBackFooter)?.secondaryView = null
            installFooter(footerStyle?.newFooter(context, footerRive) ?: CYLRefreshAutoNormalFooter(context))
        }
    }

    /** The `loadsAfterNoMoreData` prop (default false): a pull past the end loads again after "no more data". */
    fun setLoadsAfterNoMoreData(enabled: Boolean) {
        loadsAfterNoMoreDataOn = enabled
        footer.loadsAfterNoMoreData = enabled
    }

    /**
     * The `secondaryTriggerOffset` prop, in dp: the pull past which a release opens the second floor; 0 (default) is none.
     */
    fun setSecondaryTriggerOffset(offset: Float) {
        secondaryTrigger = offset
        header.secondaryTriggerOffset = offset
    }

    /**
     * The `secondaryDimension` prop, in dp: the open extent of the floor; 0 is the container's height.
     */
    fun setSecondaryDimension(dimension: Float) {
        secondaryDimensionDp = dimension
        header.secondaryDimension = dimension
    }

    /**
     * The `secondaryCloseTriggerOffset` prop, in dp (default 80).
     */
    fun setSecondaryCloseTriggerOffset(offset: Float) {
        secondaryCloseTrigger = offset
        header.secondaryCloseTriggerOffset = offset
    }

    /**
     * The `secondaryOpen` prop, controlled like `refreshing`: true opens the floor, false closes it, without calling the events back.
     * Opening needs the floor's content child and is a no-op while refreshing.
     */
    fun setSecondaryOpenFromJs(open: Boolean) {
        if (open == header.secondaryOpen) return
        if (open) {
            if (header.secondaryView == null || header.isRefreshing) return
            openAskedByJs = true
            header.openSecondary()
        } else {
            closeAskedByJs = true
            header.closeSecondary()
        }
    }

    private val backFooter: CYLRefreshBackFooter? get() = footer as? CYLRefreshBackFooter

    /**
     * The `footerSecondaryTriggerOffset` prop, in dp: the pull up past which a release opens the footer's second floor; 0 (default) is none.
     */
    fun setFooterSecondaryTriggerOffset(offset: Float) {
        footerSecondaryTrigger = offset
        backFooter?.secondaryTriggerOffset = offset
    }

    /** The `footerSecondaryDimension` prop, in dp: the open extent of the footer's floor; 0 is the container's height. */
    fun setFooterSecondaryDimension(dimension: Float) {
        footerSecondaryDimensionDp = dimension
        backFooter?.secondaryDimension = dimension
    }

    /** The `footerSecondaryCloseTriggerOffset` prop, in dp (default 80). */
    fun setFooterSecondaryCloseTriggerOffset(offset: Float) {
        footerSecondaryCloseTrigger = offset
        backFooter?.secondaryCloseTriggerOffset = offset
    }

    /**
     * The `footerSecondaryOpen` prop, controlled like `secondaryOpen`, for the footer's floor. Opening needs the floor's content child and a
     * back footer, and is a no-op while the footer loads.
     */
    fun setFooterSecondaryOpenFromJs(open: Boolean) {
        val back = backFooter ?: return
        if (open == back.secondaryOpen) return
        if (open) {
            if (back.secondaryView == null || back.isRefreshing) return
            footerOpenAskedByJs = true
            back.openSecondary()
        } else {
            footerCloseAskedByJs = true
            back.closeSecondary()
        }
    }

    /**
     * Adds a child at React Native's [index]: the floor's content only becomes the header's `secondaryView`, any other child is
     * added to the layout.
     */
    fun addReactChild(child: View, index: Int) {
        reactChildren.add(index.coerceIn(0, reactChildren.size), child)
        val nativeId = child.getTag(com.facebook.react.R.id.view_tag_native_id)
        if (nativeId == SECONDARY_NATIVE_ID) {
            floorChild = child
            header.secondaryView = child
        } else if (nativeId == FOOTER_SECONDARY_NATIVE_ID) {
            footerFloorChild = child
            backFooter?.secondaryView = child
        } else {
            addView(child)
        }
    }

    /**
     * The number of children React Native counts (the floor's content included).
     */
    val reactChildCount: Int get() = reactChildren.size

    /**
     * The child at React Native's [index].
     */
    fun reactChildAt(index: Int): View? = reactChildren.getOrNull(index)

    /**
     * Removes the child at React Native's [index].
     */
    fun removeReactChildAt(index: Int) {
        val child = reactChildren.removeAt(index)
        if (child === floorChild) {
            header.secondaryView = null
            floorChild = null
            (child.parent as? android.view.ViewGroup)?.removeView(child)
        } else if (child === footerFloorChild) {
            backFooter?.secondaryView = null
            footerFloorChild = null
            (child.parent as? android.view.ViewGroup)?.removeView(child)
        } else {
            removeView(child)
        }
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
        loadMoreOn = enabled
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

    companion object {
        /**
         * The `nativeID` of the child that is the second floor's content.
         */
        const val SECONDARY_NATIVE_ID = "cyl.refresh.secondary"

        /**
         * The `nativeID` of the child that is the footer's second floor content.
         */
        const val FOOTER_SECONDARY_NATIVE_ID = "cyl.refresh.secondary.footer"

        /** The `edge` of an event from the header's second floor. */
        const val EDGE_HEADER = "header"

        /** The `edge` of an event from the footer's second floor. */
        const val EDGE_FOOTER = "footer"
    }
}
