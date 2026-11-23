package com.cyl.placeholder.reactnative

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewGroupManager
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.uimanager.events.RCTEventEmitter

/**
 * The React Native view manager of [CYLRefreshContainerView] ("CYLRefreshContainer"): props `refreshing` and `enabled`,
 * the direct event `onRefresh`.
 */
class CYLRefreshContainerManager : ViewGroupManager<CYLRefreshContainerView>() {
    override fun getName(): String = NAME

    override fun createViewInstance(context: ThemedReactContext): CYLRefreshContainerView =
        CYLRefreshContainerView(context).also { view ->
            view.onRefresh = {
                @Suppress("DEPRECATION")
                context.getJSModule(RCTEventEmitter::class.java).receiveEvent(view.id, "topRefresh", Arguments.createMap())
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

    override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any> =
        MapBuilder.of("topRefresh", MapBuilder.of("registrationName", "onRefresh"))

    companion object {
        /**
         * The name JavaScript passes to `requireNativeComponent`.
         */
        const val NAME = "CYLRefreshContainer"
    }
}
