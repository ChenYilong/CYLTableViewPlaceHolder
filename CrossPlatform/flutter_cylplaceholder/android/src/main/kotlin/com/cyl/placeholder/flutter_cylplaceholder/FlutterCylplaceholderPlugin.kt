package com.cyl.placeholder.flutter_cylplaceholder

import android.app.Activity
import android.view.ViewGroup
import com.cyl.placeholder.bridge.CYLPlaceholderHUDBridge
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * The Android half of flutter_cylplaceholder: it registers the platform view factory of the native `CYLPlaceholderView` and the
 * method channel that drives the native `CYLPlaceholderHUD`. Everything they show is the native component of this repository
 * (`com.cyl.placeholder`), reached through `com.cyl.placeholder.bridge`; there is no second implementation here.
 */
class FlutterCylplaceholderPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {
    private var hudChannel: MethodChannel? = null
    private var activity: Activity? = null
    private var hud: CYLPlaceholderHUDBridge? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        binding.platformViewRegistry.registerViewFactory(CYLPlaceholderPlatformViewFactory.VIEW_TYPE, CYLPlaceholderPlatformViewFactory(binding.binaryMessenger))
        hudChannel = MethodChannel(binding.binaryMessenger, HUD_CHANNEL).also { it.setMethodCallHandler(this) }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        hudChannel?.setMethodCallHandler(null)
        hudChannel = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() = onDetachedFromActivity()

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) = onAttachedToActivity(binding)

    override fun onDetachedFromActivity() {
        hud?.hud?.dismiss()
        hud = null
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val host = activity ?: return result.error("no_activity", "The HUD needs a foreground activity.", null)
        val bridge = hud ?: CYLPlaceholderHUDBridge(host, host.findViewById<ViewGroup>(android.R.id.content)) { action ->
            hudChannel?.invokeMethod("onAction", action)
        }.also { hud = it }
        @Suppress("UNCHECKED_CAST")
        val arguments = call.arguments as? Map<String, Any?>
        if (bridge.handle(call.method, arguments)) result.success(null) else result.notImplemented()
    }

    private companion object {
        const val HUD_CHANNEL = "flutter_cylplaceholder/hud"
    }
}
