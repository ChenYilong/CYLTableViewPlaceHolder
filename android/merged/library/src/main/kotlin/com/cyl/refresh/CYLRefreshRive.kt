package com.cyl.refresh

import android.content.Context
import android.util.Log

/**
 * The `rive...` creation parameters of the `rive` refresh style, parsed (iOS `CYLRefreshRiveOptions`; docs/Refresh-Library-Parity.md,
 * "The rive style: creation parameters"). Pure Kotlin: the core links no Rive runtime. A key of another type or an invalid value keeps
 * the default; a key this platform does not know is ignored. Make one with [from]. The Rive header (module `:merged-rive`) turns it into
 * its `CYLRefreshRiveStyle`.
 */
class CYLRefreshRiveOptions private constructor(private val values: Map<*, *>) {
    /** `riveFile` (required by the style): an absolute path, or the name (with or without `.riv`) or relative path of an app asset; null when missing or empty. */
    val file: String? = string("riveFile")

    /** `riveArtboard`: null is the file's default artboard. */
    val artboard: String? = string("riveArtboard")

    /** `riveStateMachine`: the state machine the inputs belong to. */
    val stateMachine: String? = string("riveStateMachine")

    /** `riveTriggerOffset` in dp: the pull that counts as fully pulled, also the open height (default 180; a value of 0 or less keeps it). */
    val triggerOffset: Float = positive("riveTriggerOffset", 180f)

    /** `riveMinimumHeight` in dp: the smallest layout height of the art (default 0, the trigger offset). */
    val minimumHeight: Float = positive("riveMinimumHeight", 0f)

    /** `riveFitsWidth`: true fits the artboard to the width, otherwise it covers. */
    val fitsWidth: Boolean = values["riveFitsWidth"] == true

    /** `rivePullInput`: the number input set from the pull. */
    val pullInput: String? = string("rivePullInput")

    /** `rivePullInputMinimum` (default 0). */
    val pullInputMinimum: Double = number("rivePullInputMinimum", 0.0)

    /** `rivePullInputMaximum` (default 100). */
    val pullInputMaximum: Double = number("rivePullInputMaximum", 100.0)

    /** `rivePullInputStart`: the fraction of the trigger offset where the input starts to rise (default 0). */
    val pullInputStart: Double = number("rivePullInputStart", 0.0)

    /** `rivePullInputRefreshingValue`: the input's value while refreshing; a negative or missing value is -1 (keep the maximum). */
    val pullInputRefreshingValue: Double = number("rivePullInputRefreshingValue", -1.0).let { if (it >= 0) it else -1.0 }

    /** `riveReleaseTrigger`. */
    val releaseTrigger: String? = string("riveReleaseTrigger")

    /** `riveFinishTrigger`. */
    val finishTrigger: String? = string("riveFinishTrigger")

    /** `riveRestartTrigger`. */
    val restartTrigger: String? = string("riveRestartTrigger")

    /**
     * `riveFinishTimeout` in seconds (the finish rule, docs/Refresh-Library-Parity.md): the longest the header stays at its refreshing height after the
     * refresh ends so that the end of the animation (`riveFinishTrigger` or the `riveLoadingNumber` finished value) can play (default 1.5; 0 or less keeps it).
     */
    val finishTimeout: Double = number("riveFinishTimeout", 1.5).let { if (it > 0) it else 1.5 }

    /** `riveLoadingBoolean`. */
    val loadingBoolean: String? = string("riveLoadingBoolean")

    /** `riveLoadingNumber`. */
    val loadingNumber: String? = string("riveLoadingNumber")

    /** `riveLoadingNumberMaximum` (default 99). */
    val loadingNumberMaximum: Double = number("riveLoadingNumberMaximum", 99.0)

    /** `riveLoadingNumberFinished` (default 100). */
    val loadingNumberFinished: Double = number("riveLoadingNumberFinished", 100.0)

    /** `riveLoadingNumberDuration` in seconds (default 2; 0 or less keeps it). */
    val loadingNumberDuration: Double = number("riveLoadingNumberDuration", 2.0).let { if (it > 0) it else 2.0 }

    /** `rivePullAnimation`. */
    val pullAnimation: String? = string("rivePullAnimation")

    /** `riveTriggerAnimation`. */
    val triggerAnimation: String? = string("riveTriggerAnimation")

    /** `riveLoadingAnimation`. */
    val loadingAnimation: String? = string("riveLoadingAnimation")

    /** `riveIdleAnimation`. */
    val idleAnimation: String? = string("riveIdleAnimation")

    /** Whether [file] is a path (absolute, or a `file://` URL) rather than the name of an app asset. */
    val fileIsPath: Boolean get() = file?.let { it.startsWith("/") || it.startsWith("file://") } == true

    /**
     * The asset names to try, in order, for an asset [file]: the name as given and with `.riv` added, each as is, inside `flutter_assets/`
     * (a Flutter app's assets) and under `assets/animations/` (the Flutter example's folder), so `Bow`, `Bow.riv` and
     * `assets/animations/Bow.riv` all find `assets/animations/Bow.riv`. Empty for a missing file or a path.
     */
    fun assetCandidates(): List<String> {
        val name = file?.takeUnless { fileIsPath } ?: return emptyList()
        val names = if (name.endsWith(".riv")) listOf(name) else listOf(name, "$name.riv")
        val prefixes = listOf("", "flutter_assets/", "flutter_assets/assets/animations/", "assets/animations/")
        return prefixes.flatMap { prefix -> names.map { prefix + it } }.distinct()
    }

    private fun string(key: String): String? = (values[key] as? String)?.takeIf { it.isNotEmpty() }

    private fun number(key: String, default: Double): Double = (values[key] as? Number)?.toDouble() ?: default

    private fun positive(key: String, default: Float): Float = ((values[key] as? Number)?.toFloat() ?: default).let { if (it > 0f) it else default }

    companion object {
        /** Options from a creation parameter map (a Flutter map, or a React Native `headerRive` / `footerRive` object); null is an empty map. */
        @JvmStatic
        fun from(parameters: Map<*, *>?): CYLRefreshRiveOptions = CYLRefreshRiveOptions(parameters ?: emptyMap<String, Any?>())
    }
}

/**
 * What the optional module `:merged-rive` provides (iOS `CYLRefreshRiveBuilding`): the Rive header and footer for options. A builder
 * returns null when it cannot make the view (the file is not found or cannot be read).
 */
interface CYLRefreshRiveBuilding {
    /** The Rive header, or null when [options] name a file that cannot be read. */
    fun header(context: Context, options: CYLRefreshRiveOptions): CYLRefreshHeader?

    /** The Rive footer (the header drawn upside down by [CYLRefreshDrawnFooter]), or null as for [header]. */
    fun footer(context: Context, options: CYLRefreshRiveOptions): CYLRefreshFooter?
}

/**
 * The seam between the core and the optional Rive module (iOS `CYLRefreshStyleFactory.riveBuilder`): the core finds the builder
 * `com.cyl.refresh.rive.CYLRefreshRiveBuilder` by name at run time, so it needs no Rive runtime. Without it, with no `riveFile`, or with a
 * file that cannot be read, [header] and [footer] return the classic style and report one reason through `onFallback`.
 */
object CYLRefreshRiveSupport {
    /** The class of the builder in the module `:merged-rive`. */
    const val BUILDER_CLASS = "com.cyl.refresh.rive.CYLRefreshRiveBuilder"

    /** The reason when no builder is found (the module or the Rive runtime is not on the class path). */
    const val NOT_LINKED = "rive runtime not linked (add the :merged-rive module)"

    /** The reason when the creation parameters have no `riveFile`. */
    const val NO_FILE = "rive needs the creation parameter riveFile"

    /** A builder set by the app or a test; null finds [BUILDER_CLASS] by name. */
    @JvmStatic
    var builder: CYLRefreshRiveBuilding? = null

    /** The reason when [file] cannot be found or read. */
    fun unreadable(file: String): String = "rive file $file not found or unreadable"

    /** Writes the one log line of a fallback: `CYLRefresh: <reason>, using classic`. */
    @JvmStatic
    fun logFallback(reason: String) {
        Log.w("CYLRefresh", "CYLRefresh: $reason, using classic")
    }

    private fun resolvedBuilder(): CYLRefreshRiveBuilding? = builder ?: try {
        Class.forName(BUILDER_CLASS).getDeclaredConstructor().newInstance() as? CYLRefreshRiveBuilding
    } catch (_: Throwable) {
        // ClassNotFoundException, or NoClassDefFoundError when the module is there but the Rive runtime is not.
        null
    }

    private fun <T> make(parameters: Map<*, *>?, onFallback: (String) -> Unit, classic: () -> T, build: (CYLRefreshRiveBuilding, CYLRefreshRiveOptions) -> T?): T {
        val options = CYLRefreshRiveOptions.from(parameters)
        val file = options.file
        val builder = resolvedBuilder()
        val reason = when {
            builder == null -> NOT_LINKED
            file == null -> NO_FILE
            else -> {
                val made = try { build(builder, options) } catch (_: Throwable) { null }
                if (made != null) return made
                unreadable(file)
            }
        }
        onFallback(reason)
        return classic()
    }

    /** The Rive header for [parameters], or the classic header after one [onFallback] call. */
    @JvmStatic
    @JvmOverloads
    fun header(context: Context, parameters: Map<*, *>?, onFallback: (String) -> Unit = ::logFallback): CYLRefreshHeader =
        make(parameters, onFallback, { CYLRefreshNormalHeader(context) }) { builder, options -> builder.header(context, options) }

    /** The Rive footer for [parameters], or the classic back footer after one [onFallback] call. */
    @JvmStatic
    @JvmOverloads
    fun footer(context: Context, parameters: Map<*, *>?, onFallback: (String) -> Unit = ::logFallback): CYLRefreshFooter =
        make(parameters, onFallback, { CYLRefreshBackNormalFooter(context) }) { builder, options -> builder.footer(context, options) }
}
