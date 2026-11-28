package com.cyl.placeholder.flutter_cylplaceholder

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.cyl.placeholder.CYLPlaceholderStackView
import com.cyl.placeholder.bridge.CYLPlaceholderBridge
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

/**
 * Creates the platform view of the native `CYLPlaceholderStackView`. The creation parameters are the configuration map of
 * `docs/Placeholder-Scenarios.md` ("components", optional "backgroundAction"), which `CYLPlaceholderBridge.stackView` reads.
 */
class CYLPlaceholderStackPlatformViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = args as? Map<String, Any?> ?: emptyMap()
        return CYLPlaceholderStackPlatformView(context, viewId, messenger, params)
    }

    companion object {
        /** The view type the Dart side asks for. */
        const val VIEW_TYPE = "flutter_cylplaceholder/CYLPlaceholderStackView"
    }
}

/**
 * One native placeholder stack in a Flutter widget. The channel `flutter_cylplaceholder/CYLPlaceholderStackView/<id>` carries
 * "update" from Dart (a name and a value, applied by [CYLPlaceholderBridge.updateStackView]) and "onAction" back (the name of
 * the tapped button or background action).
 */
class CYLPlaceholderStackPlatformView(context: Context, viewId: Int, messenger: BinaryMessenger, params: Map<String, Any?>) : PlatformView, MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "${CYLPlaceholderStackPlatformViewFactory.VIEW_TYPE}/$viewId")
    private val container = FrameLayout(context)
    private val stack: CYLPlaceholderStackView? = CYLPlaceholderBridge.stackView(context, params) { action -> channel.invokeMethod("onAction", action) }

    init {
        channel.setMethodCallHandler(this)
        stack?.let { container.addView(it, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT)) }
    }

    override fun getView(): View = container

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != "update") return result.notImplemented()
        val view = stack ?: return result.error("no_view", "The configuration map was not valid.", null)
        val name = call.argument<String>("name") ?: return result.error("bad_arguments", "update needs a name.", null)
        if (CYLPlaceholderBridge.updateStackView(view, name, call.argument<Any>("value"))) result.success(null) else result.notImplemented()
    }
}
