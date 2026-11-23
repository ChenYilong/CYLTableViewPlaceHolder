package com.cyl.placeholder.flutter_cylplaceholder

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.cyl.refresh.CYLRefreshBackNormalFooter
import com.cyl.refresh.CYLRefreshComponent
import com.cyl.refresh.CYLRefreshDrivenLayout
import com.cyl.refresh.CYLRefreshFooter
import com.cyl.refresh.CYLRefreshHeader
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.cyl_footer
import com.cyl.refresh.cyl_header
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import kotlin.math.roundToInt

/**
 * Creates the platform view of the native refresh header or footer: a `CYLRefreshDrivenLayout` (the driven mode of the refresh
 * kernel) with a `CYLRefreshNormalHeader`, or with a `CYLRefreshBackNormalFooter` when the creation parameters say
 * `footer: true` (and optionally `loadsAfterNoMoreData: true`). The Dart side feeds the pull through the view's channel.
 */
class CYLRefreshPlatformViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<*, *>
        return CYLRefreshPlatformView(context, viewId, messenger, footer = params?.get("footer") == true, loadsAfterNoMoreData = params?.get("loadsAfterNoMoreData") == true)
    }

    companion object {
        /** The view type the Dart side asks for. */
        const val VIEW_TYPE = "flutter_cylplaceholder/CYLRefreshView"
    }
}

/**
 * One native refresh header or footer in a Flutter widget. The channel `flutter_cylplaceholder/CYLRefreshView/<id>` carries from
 * Dart "drive" (`offset` in logical pixels, negative for a footer, `dragging`, `startedAtEdge`: [CYLRefreshDrivenLayout.drive]),
 * "release" ([CYLRefreshDrivenLayout.release]), "finishRefresh" (`success`: ends the refresh the way the caller always must; a
 * footer's `noMoreData: true` ends the load and shows "no more data") and, footer only, "noMoreData" (`value`: shows it without a
 * load, or clears it), and back "onPhase" (`phase` and `oldPhase`, the lower camel case names of `CYLRefreshPhase`) and
 * "onRefreshing" (the component started to refresh).
 */
class CYLRefreshPlatformView(context: Context, viewId: Int, messenger: BinaryMessenger, footer: Boolean = false, loadsAfterNoMoreData: Boolean = false) :
    PlatformView, MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "${CYLRefreshPlatformViewFactory.VIEW_TYPE}/$viewId")
    private val density = context.resources.displayMetrics.density
    private val layout = CYLRefreshDrivenLayout(context)
    private val container = FrameLayout(context)

    /** The header, or in footer mode the [CYLRefreshFooter], the view hosts. */
    internal val component: CYLRefreshComponent =
        if (footer) CYLRefreshBackNormalFooter(context).also { it.loadsAfterNoMoreData = loadsAfterNoMoreData } else CYLRefreshNormalHeader(context)

    init {
        component.addPhaseObserver { _, old, new -> channel.invokeMethod("onPhase", mapOf("phase" to lowerCamel(new.name), "oldPhase" to lowerCamel(old.name))) }
        component.refreshingHandler = { channel.invokeMethod("onRefreshing", null) }
        when (component) {
            is CYLRefreshFooter -> layout.cyl_footer = component
            is CYLRefreshHeader -> layout.cyl_header = component
        }
        container.addView(layout, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
        channel.setMethodCallHandler(this)
    }

    override fun getView(): View = container

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val footer = component as? CYLRefreshFooter
        when (call.method) {
            "drive" -> {
                val offset = call.argument<Number>("offset") ?: return result.error("bad_arguments", "drive needs an offset.", null)
                layout.drive((offset.toDouble() * density).roundToInt(), call.argument<Boolean>("dragging") == true, call.argument<Boolean>("startedAtEdge") != false)
            }
            "release" -> layout.release()
            "finishRefresh" ->
                if (footer != null && call.argument<Boolean>("noMoreData") == true) footer.endRefreshingWithNoMoreData()
                else component.endRefreshingWithSuccess(call.argument<Boolean>("success") != false)
            "noMoreData" -> {
                if (footer == null) return result.error("not_a_footer", "noMoreData needs a footer view.", null)
                if (call.argument<Boolean>("value") == true) footer.noticeNoMoreData() else footer.resetNoMoreData()
            }
            else -> return result.notImplemented()
        }
        result.success(null)
    }

    private fun lowerCamel(name: String) = name.replaceFirstChar { it.lowercaseChar() }
}
