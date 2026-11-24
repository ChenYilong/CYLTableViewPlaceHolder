package com.cyl.placeholder.reactnative

import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.uimanager.events.RCTEventEmitter

/**
 * The React Native view manager of [CYLPlaceholderStackHostView] ("CYLPlaceholderStack"): props `components` (an array of
 * component dictionaries), `scenario`, `backgroundAction` and `restartToken`, the command `restartAnimation` and the direct
 * event `onAction` ({ action }).
 */
class CYLPlaceholderStackManager : SimpleViewManager<CYLPlaceholderStackHostView>() {
    override fun getName(): String = NAME

    override fun createViewInstance(context: ThemedReactContext): CYLPlaceholderStackHostView =
        CYLPlaceholderStackHostView(context).also { view ->
            view.onAction = { name ->
                val event = Arguments.createMap().apply { putString("action", name) }
                @Suppress("DEPRECATION")
                context.getJSModule(RCTEventEmitter::class.java).receiveEvent(view.id, "topAction", event)
            }
        }

    /** The `components` prop. */
    @ReactProp(name = "components")
    fun setComponents(view: CYLPlaceholderStackHostView, components: ReadableArray?) = view.setComponents(components?.toArrayList())

    /** The `scenario` prop. */
    @ReactProp(name = "scenario")
    fun setScenario(view: CYLPlaceholderStackHostView, scenario: String?) = view.setScenario(scenario)

    /** The `backgroundAction` prop. */
    @ReactProp(name = "backgroundAction")
    fun setBackgroundAction(view: CYLPlaceholderStackHostView, action: String?) = view.setBackgroundAction(action)

    /** The `restartToken` prop: it grows, the animations play again. */
    @ReactProp(name = "restartToken", defaultInt = 0)
    fun setRestartToken(view: CYLPlaceholderStackHostView, token: Int) = view.setRestartToken(token)

    public override fun onAfterUpdateTransaction(view: CYLPlaceholderStackHostView) {
        super.onAfterUpdateTransaction(view)
        view.applyPendingConfiguration()
    }

    override fun receiveCommand(view: CYLPlaceholderStackHostView, commandId: String, args: ReadableArray?) {
        if (commandId == "restartAnimation") view.restartAnimation()
    }

    override fun getCommandsMap(): Map<String, Int> = MapBuilder.of("restartAnimation", 1)

    override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any> =
        MapBuilder.of("topAction", MapBuilder.of("registrationName", "onAction"))

    companion object {
        /** The name JavaScript passes to `requireNativeComponent`. */
        const val NAME = "CYLPlaceholderStack"
    }
}
