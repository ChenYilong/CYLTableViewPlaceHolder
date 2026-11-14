package com.cyl.refresh.merged.example

import android.content.Context
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ScrollView
import com.cyl.placeholder.CYLPlaceholderComponent
import com.cyl.placeholder.CYLPlaceholderButtonStyle
import com.cyl.placeholder.CYLPlaceholderHUD
import com.cyl.placeholder.CYLPlaceholderHUDMaskType
import com.cyl.placeholder.CYLPlaceholderHUDStyle
import com.cyl.placeholder.CYLPlaceholderScenario
import com.cyl.placeholder.CYLPlaceholderScenarioCatalog
import com.cyl.placeholder.CYLPlaceholderStyle
import com.cyl.placeholder.CYLPlaceholderView

/**
 * The HUD page (iOS `CYLHUDViewController`): every way to show the HUD, how it looks, and its life cycle. The rows of
 * the second section change a setting and show a preview.
 */
internal fun ScenariosPage.hudPage(): View {
    val context = requireContext()
    val frame = FrameLayout(context)
    val hud = CYLPlaceholderHUD.sharedHUD(frame).apply { minimumDismissTimeInterval = 1.5 }
    val handler = Handler(Looper.getMainLooper())
    val styles = listOf(
        CYLPlaceholderHUDStyle.Automatic to R.string.merged_hud_style_automatic, CYLPlaceholderHUDStyle.Light to R.string.merged_hud_style_light,
        CYLPlaceholderHUDStyle.Dark to R.string.merged_hud_style_dark, CYLPlaceholderHUDStyle.Custom to R.string.merged_hud_style_custom,
    )
    val masks = listOf(
        CYLPlaceholderHUDMaskType.None to R.string.merged_hud_mask_none, CYLPlaceholderHUDMaskType.Clear to R.string.merged_hud_mask_clear,
        CYLPlaceholderHUDMaskType.Black to R.string.merged_hud_mask_black, CYLPlaceholderHUDMaskType.Gradient to R.string.merged_hud_mask_gradient,
        CYLPlaceholderHUDMaskType.Custom to R.string.merged_hud_style_custom,
    )
    val animations = CYLPlaceholderScenarioCatalog.animationFileNamesForScenario(CYLPlaceholderScenario.HUD)
    var styleIndex = 0
    var maskIndex = 0
    var animationIndex = 0
    var progressStep: Runnable? = null
    val column = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
    val values = HashMap<String, android.widget.TextView>()

    fun stopProgress() { progressStep?.let { handler.removeCallbacks(it) }; progressStep = null }
    fun preview() {
        hud.showWithStatus(context.t(R.string.merged_hud_status_loading))
        hud.dismissWithDelay(1.5)
    }
    fun showProgress() {
        var progress = 0f
        hud.showProgress(0f, context.t(R.string.merged_hud_status_downloading))
        val step = object : Runnable {
            override fun run() {
                progress += 0.05f
                if (progress >= 1f) {
                    progressStep = null
                    hud.showSuccessWithStatus(context.t(R.string.merged_hud_status_saved))
                } else {
                    hud.showProgress(progress, context.t(R.string.merged_hud_status_downloading))
                    handler.postDelayed(this, 100)
                }
            }
        }
        progressStep = step
        handler.postDelayed(step, 100)
    }
    fun showComponents() {
        val cancel = "cancel"
        val components = CYLPlaceholderScenarioCatalog.componentsForScenario(context, CYLPlaceholderScenario.HUD) +
            CYLPlaceholderComponent.buttonComponentWithTitle(context.t(R.string.merged_hud_cancel), CYLPlaceholderButtonStyle.Outlined, cancel)
        hud.showComponents(components, mapOf(cancel to { _: String -> hud.showInfoWithStatus(context.t(R.string.merged_hud_cancelled)) }))
    }

    fun add(id: String, title: Int, value: (() -> String?)? = null, action: () -> Unit) {
        val row = row(context, context.t(title), value?.invoke(), "hud-$id") {
            stopProgress()
            action()
            values[id]?.text = value?.invoke()
        }
        values[id] = (row as ViewGroup).getChildAt(1) as? android.widget.TextView ?: android.widget.TextView(context)
        column.addView(row)
    }

    column.addView(header(context, context.t(R.string.merged_hud_section_show)))
    add("show", R.string.merged_hud_show) { hud.show(); hud.dismissWithDelay(2.0) }
    add("status", R.string.merged_hud_show_status) { hud.showWithStatus(context.t(R.string.merged_hud_status_loading)); hud.dismissWithDelay(2.0) }
    add("progress", R.string.merged_hud_show_progress) { showProgress() }
    add("success", R.string.merged_hud_show_success) { hud.showSuccessWithStatus(context.t(R.string.merged_hud_status_saved)) }
    add("error", R.string.merged_hud_show_error) { hud.showErrorWithStatus(context.t(R.string.merged_hud_status_failed)) }
    add("info", R.string.merged_hud_show_info) { hud.showInfoWithStatus(context.t(R.string.merged_hud_status_info)) }
    add("image", R.string.merged_hud_show_image) {
        CYLPlaceholderView.imageForStyle(context, CYLPlaceholderStyle.Cloud)?.let { hud.showImage(it, context.t(R.string.merged_hud_status_image)) }
    }
    add("components", R.string.merged_hud_show_components) { showComponents() }
    add("scenario", R.string.merged_hud_show_scenario) { hud.showScenario(CYLPlaceholderScenario.Uploading, null); hud.dismissWithDelay(2.0) }
    add("pop", R.string.merged_hud_pop_activity) {
        repeat(3) { hud.showWithStatus(context.t(R.string.merged_hud_status_loading)) }
        listOf(1000L, 2000L, 3000L).forEach { handler.postDelayed({ hud.popActivity() }, it) }
    }
    add("dismiss", R.string.merged_hud_dismiss) { hud.dismiss() }

    column.addView(header(context, context.t(R.string.merged_hud_section_look)))
    add("style", R.string.merged_hud_style, { context.t(styles[styleIndex].second) }) {
        styleIndex = (styleIndex + 1) % styles.size
        if (styles[styleIndex].first == CYLPlaceholderHUDStyle.Custom) {
            hud.foregroundColor = Color.WHITE
            hud.hudBackgroundColor = Color.rgb(0x30, 0xB0, 0xC7)
        }
        hud.style = styles[styleIndex].first
        preview()
    }
    add("mask", R.string.merged_hud_mask, { context.t(masks[maskIndex].second) }) {
        maskIndex = (maskIndex + 1) % masks.size
        hud.maskType = masks[maskIndex].first
        hud.backgroundLayerColor = Color.argb(0x4D, 0x30, 0xB0, 0xC7)
        preview()
    }
    add("animation", R.string.merged_hud_animation, { animations.getOrNull(animationIndex) }) {
        if (animations.isNotEmpty()) {
            animationIndex = (animationIndex + 1) % animations.size
            hud.loadingAnimationFileName = animations[animationIndex]
            preview()
        }
    }
    add("haptics", R.string.merged_hud_haptics, { if (hud.hapticsEnabled) "✓" else "–" }) {
        hud.hapticsEnabled = !hud.hapticsEnabled
        hud.showSuccessWithStatus(context.t(R.string.merged_hud_status_saved))
    }

    column.addView(header(context, context.t(R.string.merged_hud_section_lifecycle)))
    add("lifecycle", R.string.merged_hud_lifecycle) { push(hudLifecyclePage()) }

    frame.addView(ScrollView(context).apply { addView(column) }, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
    frame.tag = "hudDemo"
    frame.addOnAttachStateChangeListener(object : View.OnAttachStateChangeListener {
        override fun onViewAttachedToWindow(v: View) = Unit

        override fun onViewDetachedFromWindow(v: View) {
            stopProgress()
            hud.dismiss()
        }
    })
    return page(context, bar(context, context.t(R.string.merged_title_hud)), frame)
}
