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
 * `loadingMore`, `noMoreData`, `loadMoreEnabled` and the second floor's `secondaryTriggerOffset`, `secondaryDimension`,
 * `secondaryCloseTriggerOffset` and `secondaryOpen`, the direct events `onRefresh`, `onLoadMore`, `onSecondaryOpen` and `onSecondaryClose`.
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
            view.onSecondaryOpen = {
                @Suppress("DEPRECATION")
                context.getJSModule(RCTEventEmitter::class.java).receiveEvent(view.id, "topSecondaryOpen", Arguments.createMap())
            }
            view.onSecondaryClose = {
                @Suppress("DEPRECATION")
                context.getJSModule(RCTEventEmitter::class.java).receiveEvent(view.id, "topSecondaryClose", Arguments.createMap())
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
         * The name JavaScript passes to `requireNativeComponent`.
         */
        const val NAME = "CYLRefreshContainer"
    }
}
