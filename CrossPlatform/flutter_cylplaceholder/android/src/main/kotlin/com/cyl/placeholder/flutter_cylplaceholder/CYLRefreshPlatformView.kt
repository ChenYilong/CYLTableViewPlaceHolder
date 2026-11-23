package com.cyl.placeholder.flutter_cylplaceholder

import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.cyl.refresh.CYLRefreshDrivenLayout
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.cyl_header
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import kotlin.math.roundToInt

/**
 * Creates the platform view of the native refresh header: a `CYLRefreshDrivenLayout` (the driven mode of the refresh kernel)
 * with a `CYLRefreshNormalHeader`. There are no creation parameters yet; the Dart side feeds the pull through the view's channel.
 */
class CYLRefreshPlatformViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView = CYLRefreshPlatformView(context, viewId, messenger)

    companion object {
        /** The view type the Dart side asks for. */
        const val VIEW_TYPE = "flutter_cylplaceholder/CYLRefreshView"
    }
}

/**
 * One native refresh header in a Flutter widget. The channel `flutter_cylplaceholder/CYLRefreshView/<id>` carries from Dart
 * "drive" (`offset` in logical pixels, `dragging`, `startedAtEdge`: [CYLRefreshDrivenLayout.drive]), "release"
 * ([CYLRefreshDrivenLayout.release]) and "finishRefresh" (`success`: ends the refresh the way the caller always must), and back
 * "onPhase" (`phase` and `oldPhase`, the lower camel case names of `CYLRefreshPhase`) and "onRefreshing" (the header started
 * to refresh).
 */
class CYLRefreshPlatformView(context: Context, viewId: Int, messenger: BinaryMessenger) : PlatformView, MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "${CYLRefreshPlatformViewFactory.VIEW_TYPE}/$viewId")
    private val density = context.resources.displayMetrics.density
    private val layout = CYLRefreshDrivenLayout(context)
    private val header = CYLRefreshNormalHeader(context)
    private val container = FrameLayout(context)

    init {
        header.addPhaseObserver { _, old, new -> channel.invokeMethod("onPhase", mapOf("phase" to lowerCamel(new.name), "oldPhase" to lowerCamel(old.name))) }
        header.refreshingHandler = { channel.invokeMethod("onRefreshing", null) }
        // A layout without a content view draws a warning text ("The content view in CYLRefreshLayout is empty"); the content here is Flutter's.
        layout.addView(View(context), ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        layout.cyl_header = header
        container.addView(layout, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
        channel.setMethodCallHandler(this)
    }

    override fun getView(): View = container

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "drive" -> {
                val offset = call.argument<Number>("offset") ?: return result.error("bad_arguments", "drive needs an offset.", null)
                layout.drive((offset.toDouble() * density).roundToInt(), call.argument<Boolean>("dragging") == true, call.argument<Boolean>("startedAtEdge") != false)
            }
            "release" -> layout.release()
            "finishRefresh" -> header.endRefreshingWithSuccess(call.argument<Boolean>("success") != false)
            else -> return result.notImplemented()
        }
        result.success(null)
    }

    private fun lowerCamel(name: String) = name.replaceFirstChar { it.lowercaseChar() }
}
