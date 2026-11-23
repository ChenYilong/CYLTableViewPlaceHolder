package com.cyl.placeholder.reactnative

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.uimanager.events.RCTEventEmitter

/**
 * The React Native view manager of [CYLRefreshContainerView] ("CYLRefreshContainer"): props `refreshing`, `enabled`,
 * `loadingMore`, `noMoreData` and `loadMoreEnabled`, the direct events `onRefresh` and `onLoadMore`.
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

    override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any> =
        MapBuilder.of(
            "topRefresh", MapBuilder.of("registrationName", "onRefresh"),
            "topLoadMore", MapBuilder.of("registrationName", "onLoadMore"),
        )

    companion object {
        /**
         * The name JavaScript passes to `requireNativeComponent`.
         */
        const val NAME = "CYLRefreshContainer"
    }
}
