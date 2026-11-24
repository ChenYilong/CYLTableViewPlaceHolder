package com.cyl.placeholder.flutter_cylplaceholder

import android.content.Context
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import com.cyl.refresh.CYLRefreshComponent
import com.cyl.refresh.CYLRefreshDrivenLayout
import com.cyl.refresh.CYLRefreshFooter
import com.cyl.refresh.CYLRefreshHeader
import com.cyl.refresh.CYLRefreshStyle
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
 * kernel) with the header of the creation parameter `style` (`classic` is the `CYLRefreshNormalHeader`; see [CYLRefreshStyle]), or with the
 * footer of that style (`CYLRefreshBackNormalFooter` for classic) when the creation parameters say `footer: true` (and optionally
 * `loadsAfterNoMoreData: true`). A missing or unknown `style` is classic and one warning is logged. The Dart side feeds the pull through the view's channel.
 */
class CYLRefreshPlatformViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<*, *>
        val key = params?.get("style")
        val style = CYLRefreshStyle.fromKey(key) ?: CYLRefreshStyle.Classic.also {
            // An unknown or missing style falls back to classic and is reported once per view, never thrown.
            Log.w(TAG, "Unknown refresh style $key for view $viewId: using classic.")
        }
        return CYLRefreshPlatformView(context, viewId, messenger, footer = params?.get("footer") == true, loadsAfterNoMoreData = params?.get("loadsAfterNoMoreData") == true, style = style)
    }

    companion object {
        /** The view type the Dart side asks for. */
        const val VIEW_TYPE = "flutter_cylplaceholder/CYLRefreshView"

        private const val TAG = "CYLRefreshView"
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
class CYLRefreshPlatformView(context: Context, viewId: Int, messenger: BinaryMessenger, footer: Boolean = false, loadsAfterNoMoreData: Boolean = false, style: CYLRefreshStyle = CYLRefreshStyle.Classic) :
    PlatformView, MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(messenger, "${CYLRefreshPlatformViewFactory.VIEW_TYPE}/$viewId")
    private val density = context.resources.displayMetrics.density
    private val layout = CYLRefreshDrivenLayout(context)
    private val container = FrameLayout(context)

    /** The header, or in footer mode the [CYLRefreshFooter], the view hosts. */
    internal val component: CYLRefreshComponent =
        if (footer) style.newFooter(context).also { it.loadsAfterNoMoreData = loadsAfterNoMoreData } else style.newHeader(context)

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
