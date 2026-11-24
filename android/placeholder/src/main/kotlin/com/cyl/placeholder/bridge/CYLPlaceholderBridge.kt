package com.cyl.placeholder.bridge

import android.content.Context
import android.view.ViewGroup
import com.cyl.placeholder.CYLPlaceholderComponent
import com.cyl.placeholder.CYLPlaceholderStackView
import com.cyl.placeholder.componentWithDictionary
import com.cyl.placeholder.CYLPlaceholderView
import com.cyl.placeholder.fromConfiguration
import com.cyl.placeholder.fromItemAttributes
import com.cyl.placeholder.CYLPlaceholderHUD
import com.cyl.placeholder.CYLPlaceholderScenarioCatalog

/*
 * The map-driven entry points the Flutter and React Native Android halves call (docs/Refresh-Library-Parity.md, "Native
 * bridge map"). A host passes plain maps and strings (what a method channel or a React Native prop carries); the views and the
 * HUD are the real ones of this module, so there is no second implementation behind the bridges. No Flutter or React Native class
 * is used here, so the Android unit tests cover it.
 */

/**
 * Builds and updates the placeholder views of a bridge from the item and configuration maps with the iOS keys.
 */
object CYLPlaceholderBridge {
    /**
     * A placeholder view from an item map (the `CYLPlaceholderItem*` keys of `docs/Placeholder-Scenarios.md`), or null when the
     * map is invalid. The optional keys "animationLoops" (a boolean) and "animationSpeed" (a number above 0) are applied too.
     */
    @JvmStatic
    fun placeholderView(context: Context, params: Map<String, Any?>): CYLPlaceholderView? {
        val view = CYLPlaceholderView.fromItemAttributes(context, params - setOf("animationLoops", "animationSpeed")) ?: return null
        (params["animationLoops"] as? Boolean)?.let { view.animationLoops = it }
        (params["animationSpeed"] as? Number)?.toFloat()?.takeIf { it > 0f && it.isFinite() }?.let { view.animationSpeed = it }
        return view
    }

    /**
     * Applies one live update to a placeholder view: "animationLoops" (a boolean), "animationSpeed" (a number above 0) or
     * "restartAnimation" (any value, plays again from the start). Returns whether the name and the value were understood.
     */
    @JvmStatic
    fun updatePlaceholderView(view: CYLPlaceholderView, name: String, value: Any?): Boolean = when (name) {
        "animationLoops" -> (value as? Boolean)?.let { view.animationLoops = it; true } ?: false
        "animationSpeed" -> (value as? Number)?.toFloat()?.takeIf { it > 0f && it.isFinite() }?.let { view.animationSpeed = it; true } ?: false
        "restartAnimation" -> { view.restartAnimation(); true }
        else -> false
    }

    /**
     * A placeholder stack from a configuration map (the "scenario" or "components" of `docs/Placeholder-Scenarios.md`, whose
     * components may carry "animationLoops" and "animationSpeed"), or null when it is invalid. [onAction] receives the name of
     * every button action that is tapped.
     */
    @JvmStatic
    fun stackView(context: Context, configuration: Map<String, Any?>, onAction: (String) -> Unit): CYLPlaceholderStackView? {
        val names = LinkedHashSet<String>()
        (configuration["components"] as? List<*>)?.forEach { entry ->
            ((entry as? Map<*, *>)?.get("action") as? String)?.takeIf { it.isNotEmpty() }?.let(names::add)
        }
        (configuration["backgroundAction"] as? String)?.takeIf { it.isNotEmpty() }?.let(names::add)
        // [EN] A catalog name ("retry") is stored by the component as its constant, so the handler is keyed by that constant. [CN] 目录名称（"retry"）在组件中以常量保存，处理器按该常量登记。
        val actions: Map<String, (String) -> Unit> = names.associate { name -> CYLPlaceholderScenarioCatalog.actionNamed(name) to { _: String -> onAction(name) } }
        return CYLPlaceholderStackView.fromConfiguration(context, configuration, actions)
    }

    /**
     * Applies one live update to a stack: "restartAnimation" plays every animation again from the start. Returns whether the
     * name was understood.
     */
    @JvmStatic
    fun updateStackView(view: CYLPlaceholderStackView, name: String, @Suppress("UNUSED_PARAMETER") value: Any?): Boolean = when (name) {
        "restartAnimation" -> { view.restartAnimation(); true }
        else -> false
    }
}

/**
 * Drives a [CYLPlaceholderHUD] from method names and argument maps, the way a method channel or a React Native module delivers
 * them. The HUD lays itself over [container], the host's content view.
 */
class CYLPlaceholderHUDBridge(context: Context, container: ViewGroup, onAction: (String) -> Unit = {}) {
    /** The HUD that is driven. */
    val hud: CYLPlaceholderHUD = CYLPlaceholderHUD(context, container)

    private val context: Context = context
    private val onAction: (String) -> Unit = onAction

    /**
     * Runs [method] with [arguments]: "show", "showWithStatus" ("status"), "showProgress" ("progress", "status"), "setStatus",
     * "showInfoWithStatus", "showSuccessWithStatus", "showErrorWithStatus" ("status"), "showComponents" ("components": the component maps of the configuration),
     * "popActivity", "dismiss" and "dismissWithDelay" ("delay" in seconds). Returns whether the method is known.
     */
    fun handle(method: String, arguments: Map<String, Any?>?): Boolean {
        val status = arguments?.get("status") as? String
        when (method) {
            "show" -> hud.show()
            "showWithStatus" -> hud.showWithStatus(status)
            "showProgress" -> hud.showProgress(((arguments?.get("progress") as? Number)?.toFloat() ?: 0f).coerceIn(0f, 1f), status)
            "setStatus" -> hud.setStatus(status)
            "showInfoWithStatus" -> hud.showInfoWithStatus(status)
            "showSuccessWithStatus" -> hud.showSuccessWithStatus(status)
            "showErrorWithStatus" -> hud.showErrorWithStatus(status)
            "showComponents" -> {
                val entries = arguments?.get("components") as? List<*> ?: return false
                val components = entries.map { entry ->
                    @Suppress("UNCHECKED_CAST")
                    CYLPlaceholderComponent.componentWithDictionary(context, entry as? Map<String, Any?>) ?: return false
                }
                val names = entries.mapNotNull { ((it as? Map<*, *>)?.get("action") as? String)?.takeIf(String::isNotEmpty) }.toSet()
                hud.showComponents(components, names.associate { name -> CYLPlaceholderScenarioCatalog.actionNamed(name) to { _: String -> onAction(name) } })
            }
            "popActivity" -> hud.popActivity()
            "dismiss" -> hud.dismiss()
            "dismissWithDelay" -> hud.dismissWithDelay((arguments?.get("delay") as? Number)?.toDouble() ?: 0.0)
            else -> return false
        }
        return true
    }
}
