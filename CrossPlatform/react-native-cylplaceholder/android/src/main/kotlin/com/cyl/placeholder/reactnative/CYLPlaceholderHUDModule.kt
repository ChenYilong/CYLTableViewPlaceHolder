package com.cyl.placeholder.reactnative

import android.app.Activity
import android.view.ViewGroup
import com.cyl.placeholder.bridge.CYLPlaceholderHUDBridge
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.bridge.UiThreadUtil
import com.facebook.react.modules.core.DeviceEventManagerModule

/**
 * Drives one [CYLPlaceholderHUDBridge] over an activity's content view, from method names and argument maps. Kept apart from
 * the module so the Android unit tests cover it without a React context.
 */
class CYLPlaceholderHUDController(private val activity: () -> Activity?, private val onAction: (String) -> Unit) {
    private var bridge: CYLPlaceholderHUDBridge? = null
    private var bridgeActivity: Activity? = null

    /** The HUD that is driven now, or null before the first call. */
    val hud: com.cyl.placeholder.CYLPlaceholderHUD? get() = bridge?.hud

    /**
     * Runs [method] on the HUD of the current activity (a new HUD when the activity changed). False when there is no activity
     * or the method or its arguments are not known.
     */
    fun handle(method: String, arguments: Map<String, Any?>?): Boolean {
        val host = activity() ?: return false
        val content = host.findViewById<ViewGroup>(android.R.id.content) ?: return false
        if (bridge == null || bridgeActivity !== host) {
            bridge?.hud?.dismiss()
            bridge = CYLPlaceholderHUDBridge(host, content, onAction)
            bridgeActivity = host
        }
        return bridge!!.handle(method, arguments)
    }
}

/**
 * The React Native native module "CYLPlaceholderHUD": `call(method, arguments)` runs a [CYLPlaceholderHUDBridge] method on the
 * UI thread; a tapped button of `showComponents` comes back as the event "CYLPlaceholderHUDAction" (the action name).
 */
class CYLPlaceholderHUDModule(private val reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    private val controller = CYLPlaceholderHUDController({ reactContext.currentActivity }) { name ->
        reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java).emit(EVENT_ACTION, name)
    }

    override fun getName(): String = NAME

    /** Runs a HUD method by name; the JavaScript wrapper `CYLPlaceholderHUD` is the typed API over it. */
    @ReactMethod
    fun call(method: String, arguments: ReadableMap?) {
        val map = arguments?.toHashMap()
        UiThreadUtil.runOnUiThread { controller.handle(method, map) }
    }

    /** Required by `NativeEventEmitter`. */
    @ReactMethod
    fun addListener(@Suppress("UNUSED_PARAMETER") eventName: String) = Unit

    /** Required by `NativeEventEmitter`. */
    @ReactMethod
    fun removeListeners(@Suppress("UNUSED_PARAMETER") count: Double) = Unit

    companion object {
        /** The module name, `NativeModules.CYLPlaceholderHUD`. */
        const val NAME = "CYLPlaceholderHUD"

        /** The event of a tapped HUD button. */
        const val EVENT_ACTION = "CYLPlaceholderHUDAction"
    }
}
