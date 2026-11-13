// android-Ultra-Pull-To-Refresh (https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh, MIT, Copyright (c) 2015
// liaohuqiu.net) translated to Kotlin.
package `in`.srain.cube.views.ptr.util

import android.content.Context
import android.util.Log
import android.view.View

/**
 * The library's log, with a level (`PtrCLog`).
 */
object PtrCLog {
    /**
     * Verbose and above.
     */
    const val LEVEL_VERBOSE = 0

    /**
     * Debug and above.
     */
    const val LEVEL_DEBUG = 1

    /**
     * Info and above.
     */
    const val LEVEL_INFO = 2

    /**
     * Warnings and above.
     */
    const val LEVEL_WARNING = 3

    /**
     * Errors and above.
     */
    const val LEVEL_ERROR = 4

    /**
     * Fatal only.
     */
    const val LEVEL_FATAL = 5

    private var level = LEVEL_VERBOSE

    /**
     * Logs only messages at [level] or above.
     */
    @JvmStatic
    fun setLogLevel(level: Int) {
        this.level = level
    }

    /**
     * A verbose message; [args] format it.
     */
    @JvmStatic
    fun v(tag: String, msg: String, vararg args: Any?) {
        if (level <= LEVEL_VERBOSE) Log.v(tag, format(msg, args))
    }

    /**
     * A debug message; [args] format it.
     */
    @JvmStatic
    fun d(tag: String, msg: String, vararg args: Any?) {
        if (level <= LEVEL_DEBUG) Log.d(tag, format(msg, args))
    }

    /**
     * An info message; [args] format it.
     */
    @JvmStatic
    fun i(tag: String, msg: String, vararg args: Any?) {
        if (level <= LEVEL_INFO) Log.i(tag, format(msg, args))
    }

    /**
     * A warning; [args] format it.
     */
    @JvmStatic
    fun w(tag: String, msg: String, vararg args: Any?) {
        if (level <= LEVEL_WARNING) Log.w(tag, format(msg, args))
    }

    /**
     * An error; [args] format it.
     */
    @JvmStatic
    fun e(tag: String, msg: String, vararg args: Any?) {
        if (level <= LEVEL_ERROR) Log.e(tag, format(msg, args))
    }

    /**
     * A fatal error; [args] format it.
     */
    @JvmStatic
    fun f(tag: String, msg: String, vararg args: Any?) {
        if (level <= LEVEL_FATAL) Log.wtf(tag, format(msg, args))
    }

    private fun format(msg: String, args: Array<out Any?>): String = if (args.isEmpty()) msg else String.format(msg, *args)
}

/**
 * Screen sizes and dp conversions (`PtrLocalDisplay`); call [init] first.
 */
object PtrLocalDisplay {
    /**
     * The screen's width in pixels.
     */
    @JvmField
    var SCREEN_WIDTH_PIXELS = 0

    /**
     * The screen's height in pixels.
     */
    @JvmField
    var SCREEN_HEIGHT_PIXELS = 0

    /**
     * The screen's density.
     */
    @JvmField
    var SCREEN_DENSITY = 1f

    /**
     * The screen's width in dp.
     */
    @JvmField
    var SCREEN_WIDTH_DP = 0

    /**
     * The screen's height in dp.
     */
    @JvmField
    var SCREEN_HEIGHT_DP = 0

    /**
     * Reads the screen's metrics from [context].
     */
    @JvmStatic
    fun init(context: Context?) {
        val dm = context?.resources?.displayMetrics ?: return
        SCREEN_WIDTH_PIXELS = dm.widthPixels
        SCREEN_HEIGHT_PIXELS = dm.heightPixels
        SCREEN_DENSITY = dm.density
        SCREEN_WIDTH_DP = (SCREEN_WIDTH_PIXELS / dm.density).toInt()
        SCREEN_HEIGHT_DP = (SCREEN_HEIGHT_PIXELS / dm.density).toInt()
    }

    /**
     * [dp] in pixels.
     */
    @JvmStatic
    fun dp2px(dp: Float): Int = (dp * SCREEN_DENSITY + 0.5f).toInt()

    /**
     * [designedDp] of a 320 dp wide design, in pixels for this screen's width.
     */
    @JvmStatic
    fun designedDP2px(designedDp: Float): Int {
        val dp = if (SCREEN_WIDTH_DP != 320 && SCREEN_WIDTH_DP != 0) designedDp * SCREEN_WIDTH_DP / 320f else designedDp
        return dp2px(dp)
    }

    /**
     * Sets [view]'s padding: the sides in designed dp, the top and bottom in dp.
     */
    @JvmStatic
    fun setPadding(view: View, left: Float, top: Float, right: Float, bottom: Float) {
        view.setPadding(designedDP2px(left), dp2px(top), designedDP2px(right), dp2px(bottom))
    }
}
