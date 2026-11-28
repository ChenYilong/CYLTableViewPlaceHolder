package com.cyl.placeholder.reactnative

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.uimanager.events.RCTEventEmitter

/**
 * The React Native view manager of [CYLRefreshContainerView] ("CYLRefreshContainer"): props `refreshing`, `enabled`,
 * `loadingMore`, `noMoreData`, `loadMoreEnabled`, `loadsAfterNoMoreData`, `headerStyle` / `footerStyle` with `headerRive` / `footerRive`
 * (the `rive` style's parameters) and the second floor's `secondaryTriggerOffset`, `secondaryDimension`,
 * `secondaryCloseTriggerOffset` and `secondaryOpen` (the footer's: `footerSecondary...`, child nativeID `cyl.refresh.secondary.footer`), the direct events `onRefresh`, `onLoadMore`, `onSecondaryOpen` and `onSecondaryClose`.
 */
class CYLRefreshContainerManager : ViewGroupManager<CYLRefreshContainerView>() {
    override fun getName(): String = NAME

    override fun createViewInstance(context: ThemedReactContext): CYLRefreshContainerView =
        CYLRefreshContainerView(context).also { view ->
            view.onRefresh = {
                @Suppress("DEPRECATION")
                context.getJSModule(RCTEventEmitter::class.java).receiveEvent(view.id, "topRefresh", Arguments.createMap())
            }
            view.onLoadMore = {
                @Suppress("DEPRECATION")
                context.getJSModule(RCTEventEmitter::class.java).receiveEvent(view.id, "topLoadMore", Arguments.createMap())
            }
            view.onSecondaryOpen = { edge ->
                @Suppress("DEPRECATION")
                context.getJSModule(RCTEventEmitter::class.java).receiveEvent(view.id, "topSecondaryOpen", secondaryEventBody(edge))
            }
            view.onSecondaryClose = { edge ->
                @Suppress("DEPRECATION")
                context.getJSModule(RCTEventEmitter::class.java).receiveEvent(view.id, "topSecondaryClose", secondaryEventBody(edge))
            }
        }

    /**
     * The `refreshing` prop.
     */
    @ReactProp(name = "refreshing")
    fun setRefreshing(view: CYLRefreshContainerView, refreshing: Boolean) = view.setRefreshingFromJs(refreshing)

    /**
     * The `enabled` prop (default true).
     */
    @ReactProp(name = "enabled", defaultBoolean = true)
    fun setEnabled(view: CYLRefreshContainerView, enabled: Boolean) = view.setPullEnabled(enabled)

    /**
     * The `loadingMore` prop: the footer shows its loading state while true.
     */
    @ReactProp(name = "loadingMore")
    fun setLoadingMore(view: CYLRefreshContainerView, loadingMore: Boolean) = view.setLoadingMoreFromJs(loadingMore)

    /**
     * The `noMoreData` prop: the footer shows "no more data" while true.
     */
    @ReactProp(name = "noMoreData")
    fun setNoMoreData(view: CYLRefreshContainerView, noMoreData: Boolean) = view.setNoMoreDataFromJs(noMoreData)

    /**
     * The `loadMoreEnabled` prop (default false).
     */
    @ReactProp(name = "loadMoreEnabled")
    fun setLoadMoreEnabled(view: CYLRefreshContainerView, enabled: Boolean) = view.setLoadMoreEnabled(enabled)

    /**
     * The `loadsAfterNoMoreData` prop (default false): a pull past the end loads again after "no more data".
     */
    @ReactProp(name = "loadsAfterNoMoreData")
    fun setLoadsAfterNoMoreData(view: CYLRefreshContainerView, enabled: Boolean) = view.setLoadsAfterNoMoreData(enabled)

    /**
     * The `headerStyle` prop: a style key (`classic`, `cupertino`, ..., `rive`); applied after the batch of props.
     */
    @ReactProp(name = "headerStyle")
    fun setHeaderStyle(view: CYLRefreshContainerView, style: String?) = view.setHeaderStyle(style)

    /**
     * The `footerStyle` prop, as `headerStyle`.
     */
    @ReactProp(name = "footerStyle")
    fun setFooterStyle(view: CYLRefreshContainerView, style: String?) = view.setFooterStyle(style)

    /**
     * The `headerRive` prop: the `rive...` keys of the `rive` header.
     */
    @ReactProp(name = "headerRive")
    fun setHeaderRive(view: CYLRefreshContainerView, options: ReadableMap?) = view.setHeaderRive(options?.toHashMap())

    /**
     * The `footerRive` prop: the `rive...` keys of the `rive` footer.
     */
    @ReactProp(name = "footerRive")
    fun setFooterRive(view: CYLRefreshContainerView, options: ReadableMap?) = view.setFooterRive(options?.toHashMap())

    // The style props arrive one by one; the header and footer are made once from all of them.
    override fun onAfterUpdateTransaction(view: CYLRefreshContainerView) {
        super.onAfterUpdateTransaction(view)
        view.applyStyles()
    }

    /**
     * The `secondaryTriggerOffset` prop (dp, default 0: no second floor).
     */
    @ReactProp(name = "secondaryTriggerOffset", defaultFloat = 0f)
    fun setSecondaryTriggerOffset(view: CYLRefreshContainerView, offset: Float) = view.setSecondaryTriggerOffset(offset)

    /**
     * The `secondaryDimension` prop (dp, default 0: the container's height).
     */
    @ReactProp(name = "secondaryDimension", defaultFloat = 0f)
    fun setSecondaryDimension(view: CYLRefreshContainerView, dimension: Float) = view.setSecondaryDimension(dimension)

    /**
     * The `secondaryCloseTriggerOffset` prop (dp, default 80).
     */
    @ReactProp(name = "secondaryCloseTriggerOffset", defaultFloat = 80f)
    fun setSecondaryCloseTriggerOffset(view: CYLRefreshContainerView, offset: Float) = view.setSecondaryCloseTriggerOffset(offset)

    /**
     * The `secondaryOpen` prop (controlled, default false).
     */
    @ReactProp(name = "secondaryOpen")
    fun setSecondaryOpen(view: CYLRefreshContainerView, open: Boolean) = view.setSecondaryOpenFromJs(open)

    /**
     * The `footerSecondaryTriggerOffset` prop (dp, default 0: no footer second floor; needs a back footer style, as iOS).
     */
    @ReactProp(name = "footerSecondaryTriggerOffset", defaultFloat = 0f)
    fun setFooterSecondaryTriggerOffset(view: CYLRefreshContainerView, offset: Float) = view.setFooterSecondaryTriggerOffset(offset)

    /**
     * The `footerSecondaryDimension` prop (dp, default 0: the container's height).
     */
    @ReactProp(name = "footerSecondaryDimension", defaultFloat = 0f)
    fun setFooterSecondaryDimension(view: CYLRefreshContainerView, dimension: Float) = view.setFooterSecondaryDimension(dimension)

    /**
     * The `footerSecondaryCloseTriggerOffset` prop (dp, default 80).
     */
    @ReactProp(name = "footerSecondaryCloseTriggerOffset", defaultFloat = 80f)
    fun setFooterSecondaryCloseTriggerOffset(view: CYLRefreshContainerView, offset: Float) = view.setFooterSecondaryCloseTriggerOffset(offset)

    /**
     * The `footerSecondaryOpen` prop (controlled, default false).
     */
    @ReactProp(name = "footerSecondaryOpen")
    fun setFooterSecondaryOpen(view: CYLRefreshContainerView, open: Boolean) = view.setFooterSecondaryOpenFromJs(open)

    // The floor's content (nativeID "cyl.refresh.secondary") is a child for React Native but not for the layout, see the view.
    override fun addView(parent: CYLRefreshContainerView, child: android.view.View, index: Int) = parent.addReactChild(child, index)

    override fun getChildCount(parent: CYLRefreshContainerView): Int = parent.reactChildCount

    override fun getChildAt(parent: CYLRefreshContainerView, index: Int): android.view.View? = parent.reactChildAt(index)

    override fun removeViewAt(parent: CYLRefreshContainerView, index: Int) = parent.removeReactChildAt(index)

    override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any> =
        MapBuilder.of(
            "topRefresh", MapBuilder.of("registrationName", "onRefresh"),
            "topLoadMore", MapBuilder.of("registrationName", "onLoadMore"),
            "topSecondaryOpen", MapBuilder.of("registrationName", "onSecondaryOpen"),
            "topSecondaryClose", MapBuilder.of("registrationName", "onSecondaryClose"),
        )

    companion object {
        /**
         * The body of `onSecondaryOpen` / `onSecondaryClose`: the footer's floor says `{edge: 'footer'}`; the header's body stays empty
         * (JavaScript reads a missing edge as the header).
         */
        internal fun secondaryEventBody(edge: String): com.facebook.react.bridge.WritableMap =
            Arguments.createMap().also { if (edge == CYLRefreshContainerView.EDGE_FOOTER) it.putString("edge", edge) }

        /**
         * The name JavaScript passes to `requireNativeComponent`.
         */
        const val NAME = "CYLRefreshContainer"
    }
}
