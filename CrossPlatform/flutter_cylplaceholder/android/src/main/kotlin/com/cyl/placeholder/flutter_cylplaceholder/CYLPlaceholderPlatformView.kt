package com.cyl.placeholder.flutter_cylplaceholder

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.cyl.placeholder.CYLPlaceholderView
import com.cyl.placeholder.bridge.CYLPlaceholderBridge
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Creates the platform view of the native `CYLPlaceholderView`. The creation parameters are the item map with the iOS keys
 * (`CYLPlaceholderItemKey`) plus "animationLoops" and "animationSpeed".
 */
class CYLPlaceholderPlatformViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = args as? Map<String, Any?> ?: emptyMap()
        return CYLPlaceholderPlatformView(context, viewId, messenger, params)
    }

    companion object {
        /** The view type the Dart side asks for. */
        const val VIEW_TYPE = "flutter_cylplaceholder/CYLPlaceholderView"
    }
}

/**
 * One native placeholder in a Flutter widget. The channel `flutter_cylplaceholder/CYLPlaceholderView/<id>` carries "update"
 * from Dart (a name and a value, applied by [CYLPlaceholderBridge.updatePlaceholderView]) and "onTap" back.
 */
class CYLPlaceholderPlatformView(context: Context, viewId: Int, messenger: BinaryMessenger, params: Map<String, Any?>) : PlatformView, MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "${CYLPlaceholderPlatformViewFactory.VIEW_TYPE}/$viewId")
    private val container = FrameLayout(context)
    private val placeholder: CYLPlaceholderView? = CYLPlaceholderBridge.placeholderView(context, params)

    init {
        channel.setMethodCallHandler(this)
        placeholder?.let { view ->
            container.addView(view, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
            if (params["tappable"] == true) view.setOnClickListener { channel.invokeMethod("onTap", null) }
        }
    }

    override fun getView(): View = container

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "update") return result.notImplemented()
        val view = placeholder ?: return result.error("no_view", "The item map was not valid.", null)
        val name = call.argument<String>("name") ?: return result.error("bad_arguments", "update needs a name.", null)
        if (CYLPlaceholderBridge.updatePlaceholderView(view, name, call.argument<Any>("value"))) result.success(null) else result.notImplemented()
    }
}
