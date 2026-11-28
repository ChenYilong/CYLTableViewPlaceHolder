package com.cyl.placeholder.reactnative

import android.content.Context
import android.widget.FrameLayout
import com.cyl.placeholder.CYLPlaceholderStackView
import com.cyl.placeholder.bridge.CYLPlaceholderBridge

/**
 * The host view of the native [CYLPlaceholderStackView] in React Native ("CYLPlaceholderStack"). It owns one stack, built
 * through [CYLPlaceholderBridge.stackView] from the configuration dictionary (the "components" of `docs/Placeholder-Scenarios.md`,
 * or a "scenario" name); [onAction] receives the name of every tapped button action.
 */
class CYLPlaceholderStackHostView(context: Context) : FrameLayout(context) {
    /** Called with the action name when a button, an icon or the background of the stack is tapped. */
    var onAction: (String) -> Unit = {}

    /** The stack that is shown now, or null when the configuration was empty or invalid. */
    var stack: CYLPlaceholderStackView? = null
        private set

    private var components: List<Any?>? = null
    private var scenario: String? = null
    private var backgroundAction: String? = null
    private var dirty = false
    private var restartToken = 0

    /** How many times the animations were restarted (the command and the `restartToken` rule), for the tests and for logs (as on iOS). */
    var restartCount = 0
        private set

    /** Sets the component dictionaries (the `components` prop); the stack is rebuilt by [applyPendingConfiguration]. */
    fun setComponents(value: List<Any?>?) { components = value; dirty = true }

    /** Sets the scenario name (the `scenario` prop), used when there are no components. */
    fun setScenario(value: String?) { scenario = value; dirty = true }

    /** Sets the action name of a tap on the background (the `backgroundAction` prop). */
    fun setBackgroundAction(value: String?) { backgroundAction = value; dirty = true }

    /**
     * The `restartToken` prop: a value above the last one plays every animation again from the start (as on iOS: the first value is a
     * baseline, and an equal or smaller value, such as a reset to 0, never replays).
     */
    fun setRestartToken(value: Int) {
        if (value > restartToken && stack != null) restartAnimation()
        restartToken = value
    }

    /** Plays every animation of the stack again from the start (the `restartAnimation` command). */
    fun restartAnimation() {
        restartCount++
        stack?.let { CYLPlaceholderBridge.updateStackView(it, "restartAnimation", null) }
    }

    /**
     * Rebuilds the stack when a configuration prop changed since the last call (the manager calls it after each update batch).
     * Returns whether a native stack is shown.
     */
    fun applyPendingConfiguration(): Boolean {
        if (!dirty) return stack != null
        dirty = false
        removeAllViews()
        stack = null
        val configuration = HashMap<String, Any?>()
        if (!components.isNullOrEmpty()) configuration["components"] = components
        else scenario?.let { configuration["scenario"] = it }
        backgroundAction?.let { configuration["backgroundAction"] = it }
        if (configuration.isEmpty()) return false
        val built = CYLPlaceholderBridge.stackView(context, configuration) { name -> onAction(name) } ?: return false
        addView(built, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        stack = built
        return true
    }
}
