package com.cyl.placeholder

import android.content.Context
import android.content.res.Configuration
import android.graphics.ImageDecoder
import android.graphics.drawable.AnimatedImageDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import java.io.File
import java.lang.ref.WeakReference

/**
 * An animator's rank when several can play a file (iOS `CYLPlaceholderItemAnimatorPriority`); higher wins.
 */
typealias CYLPlaceholderItemAnimatorPriority = Int

/**
 * The default rank (iOS `CYLPlaceholderItemAnimatorPriorityDefault`).
 */
const val CYLPlaceholderItemAnimatorPriorityDefault: CYLPlaceholderItemAnimatorPriority = 0

/**
 * The rank of an animator used only when no other fits (iOS `CYLPlaceholderItemAnimatorPriorityFallback`).
 */
const val CYLPlaceholderItemAnimatorPriorityFallback: CYLPlaceholderItemAnimatorPriority = -1000

/**
 * An option of an animation file (iOS `CYLPlaceholderAnimationOption`): a key of the options map.
 */
typealias CYLPlaceholderAnimationOption = String

/**
 * The Rive options, with the iOS values (`CYLPlaceholderAnimationOptionRive…`).
 */
object CYLPlaceholderAnimationOptions {
    /** The artboard's name. */
    const val RiveArtboard: CYLPlaceholderAnimationOption = "artboard"

    /** The state machine's name. */
    const val RiveStateMachine: CYLPlaceholderAnimationOption = "stateMachine"

    /** The boolean input that is on while active. */
    const val RiveActiveProperty: CYLPlaceholderAnimationOption = "active"

    /** How long the active input stays on, in seconds. */
    const val RiveActiveDuration: CYLPlaceholderAnimationOption = "duration"

    /** The trigger fired on play (a view-model property). */
    const val RiveTriggerProperty: CYLPlaceholderAnimationOption = "trigger"

    /** The color property. */
    const val RiveColor: CYLPlaceholderAnimationOption = "color"

    /** The state machine's boolean input. */
    const val RiveInput: CYLPlaceholderAnimationOption = "input"

    /** The state machine's trigger input. */
    const val RiveTriggerInput: CYLPlaceholderAnimationOption = "triggerInput"

    /** A linear animation's name. */
    const val RiveAnimation: CYLPlaceholderAnimationOption = "animation"

    /** Whether to use the legacy runtime. */
    const val RiveLegacyRuntime: CYLPlaceholderAnimationOption = "legacy"
}

/**
 * Says which files an animator plays (iOS `CYLPlaceholderItemAnimationFileMatching`). A file is a path, an
 * "asset:<name>" in the app's assets, or a URL string.
 */
interface CYLPlaceholderItemAnimationFileMatching {
    /** The animator's name, unique in a registry (`identifier`). */
    val identifier: String

    /** Whether the animator plays the file at [URL] (`canAnimateFileAtURL:`). */
    fun canAnimateFileAtURL(URL: String): Boolean

    /** The animator's rank (`priority`). */
    val priority: CYLPlaceholderItemAnimatorPriority

    /** The file extensions it plays, lower case, without the dot (`fileExtensions`). */
    val fileExtensions: List<String>

    /** Its own attribute key for each generic key (`attributeKeys`). */
    val attributeKeys: Map<String, String>
}

/**
 * Makes animation views and their players (iOS `CYLPlaceholderItemAnimationViewFactory`).
 */
interface CYLPlaceholderItemAnimationViewFactory {
    /** A view playing the file at [URL], [width] by [height] pixels, or null (`animationViewWithURL:size:contentMode:`). */
    fun animationViewWithURL(context: Context, URL: String, width: Int, height: Int, contentMode: ImageView.ScaleType): View?

    /** The player of a view this factory made, or null (`playerForAnimationView:`). */
    fun playerForAnimationView(view: View): CYLPlaceholderItemAnimationPlayer?
}

/**
 * One animation engine: it says which files it plays and makes their views (iOS `CYLPlaceholderItemAnimator`).
 */
interface CYLPlaceholderItemAnimator : CYLPlaceholderItemAnimationFileMatching, CYLPlaceholderItemAnimationViewFactory

/**
 * Controls one animation view (iOS `CYLPlaceholderItemAnimationPlayer`).
 */
interface CYLPlaceholderItemAnimationPlayer {
    /** The view it controls, while it lives (`animationView`). */
    val animationView: View?

    /** Plays from the start (`play`). */
    fun play()

    /** Shows the last frame (`showLastFrame`). */
    fun showLastFrame()

    /** Stops (`stop`). */
    fun stop()

    /** The position, 0 to 1 (`progress`). */
    var progress: Float

    /** The speed, 1 for normal (`animationSpeed`). */
    var animationSpeed: Float

    /** Repeats [repeatCount] times, 0 for ever; false when the engine cannot (`setAnimationRepeatCount:`). */
    fun setAnimationRepeatCount(repeatCount: Int): Boolean

    /** Recolors for dark mode when [night] (`applyDarkColors:traitCollection:`). */
    fun applyDarkColors(darkColors: Map<String, Int>, night: Boolean)

    /** Recolors; null restores the file's colors (`applyColors:traitCollection:`). */
    fun applyColors(colors: Map<String, Int>?, night: Boolean)
}

/**
 * A player that does nothing, to subclass (iOS `CYLPlaceholderItemAnimationBasePlayer`).
 */
open class CYLPlaceholderItemAnimationBasePlayer(animationView: View) : CYLPlaceholderItemAnimationPlayer {
    private val view = WeakReference(animationView)

    override val animationView: View? get() = view.get()

    override fun play() {}

    override fun showLastFrame() {}

    override fun stop() {}

    override var progress: Float = 0f

    override var animationSpeed: Float = 1f

    override fun setAnimationRepeatCount(repeatCount: Int): Boolean = false

    override fun applyDarkColors(darkColors: Map<String, Int>, night: Boolean) {
        if (night) applyColors(darkColors, night)
    }

    override fun applyColors(colors: Map<String, Int>?, night: Boolean) {}
}

/**
 * What an animation view does for the short path (iOS `CYLPlaceholderItemAnimationPlayableView`): a view that
 * implements it needs no player class.
 */
interface CYLPlaceholderItemAnimationPlayableView {
    /** Plays from the start (`cyl_playAnimationView`). */
    fun cyl_playAnimationView()

    /** Shows the last frame (`cyl_showAnimationViewLastFrame`). */
    fun cyl_showAnimationViewLastFrame()

    /** Stops (`cyl_stopAnimationView`). */
    fun cyl_stopAnimationView()

    /** Recolors; null restores (`cyl_applyAnimationViewColors:`). */
    fun cyl_applyAnimationViewColors(colors: Map<String, Int>?) {}

    /** Repeats [repeatCount] times, 0 for ever; false when it cannot (`cyl_setAnimationViewRepeatCount:`). */
    fun cyl_setAnimationViewRepeatCount(repeatCount: Int): Boolean = false

    /** Whether the animation is loaded (`cyl_isAnimationViewReady`). */
    val cyl_isAnimationViewReady: Boolean get() = true

    /** Called once loaded (`cyl_animationViewReadyHandler`). */
    var cyl_animationViewReadyHandler: (() -> Unit)?

    /** Called when loading fails (`cyl_animationViewErrorHandler`). */
    var cyl_animationViewErrorHandler: ((Throwable) -> Unit)?
}

/**
 * Makes playable views for the short path (iOS `CYLPlaceholderItemAnimationViewProviding`).
 */
fun interface CYLPlaceholderItemAnimationViewProviding {
    /** A playable view for the file, or null (`cyl_animationViewWithFileURL:options:contentMode:`). */
    fun cyl_animationViewWithFileURL(context: Context, fileURL: String, options: Map<String, Any>?, contentMode: ImageView.ScaleType): View?
}

/**
 * An animator made from a view provider: the short path to add an engine (iOS `CYLPlaceholderItemViewAnimator`).
 */
class CYLPlaceholderItemViewAnimator(
    override val identifier: String,
    fileExtensions: List<String>,
    override val attributeKeys: Map<String, String>,
    /** Makes the views (`viewProvider`). */
    var viewProvider: CYLPlaceholderItemAnimationViewProviding,
) : CYLPlaceholderItemAnimator {

    override val fileExtensions: List<String> = fileExtensions.map { it.lowercase().removePrefix(".") }

    override val priority: CYLPlaceholderItemAnimatorPriority = CYLPlaceholderItemAnimatorPriorityDefault

    /** Options passed to the provider for every file. */
    var options: Map<String, Any>? = null

    override fun canAnimateFileAtURL(URL: String): Boolean = URL.substringBefore('?').substringAfterLast('.', "").lowercase() in fileExtensions

    override fun animationViewWithURL(context: Context, URL: String, width: Int, height: Int, contentMode: ImageView.ScaleType): View? =
        viewProvider.cyl_animationViewWithFileURL(context, URL, options, contentMode)?.takeIf { it is CYLPlaceholderItemAnimationPlayableView }

    override fun playerForAnimationView(view: View): CYLPlaceholderItemAnimationPlayer? {
        val playable = view as? CYLPlaceholderItemAnimationPlayableView ?: return null
        return object : CYLPlaceholderItemAnimationBasePlayer(view) {
            override fun play() = playable.cyl_playAnimationView()
            override fun showLastFrame() = playable.cyl_showAnimationViewLastFrame()
            override fun stop() = playable.cyl_stopAnimationView()
            override fun setAnimationRepeatCount(repeatCount: Int) = playable.cyl_setAnimationViewRepeatCount(repeatCount)
            override fun applyColors(colors: Map<String, Int>?, night: Boolean) = playable.cyl_applyAnimationViewColors(colors)
        }
    }
}

/**
 * Keeps animators (iOS `CYLPlaceholderItemAnimatorRegistering`).
 */
interface CYLPlaceholderItemAnimatorRegistering {
    /** Adds [animator], replacing one with the same identifier (`registerAnimator:`). */
    fun registerAnimator(animator: CYLPlaceholderItemAnimator)

    /** Removes the animator called [identifier] (`unregisterAnimatorWithIdentifier:`). */
    fun unregisterAnimatorWithIdentifier(identifier: String)

    /** Every animator, highest rank first (`animators`). */
    fun animators(): List<CYLPlaceholderItemAnimator>

    /** The animator called [identifier], or null (`animatorWithIdentifier:`). */
    fun animatorWithIdentifier(identifier: String): CYLPlaceholderItemAnimator?

    /** The animator for the file at [URL], or null (`animatorForURL:`). */
    fun animatorForURL(URL: String?): CYLPlaceholderItemAnimator?

    /** The animator for the file named in [attributes], or null (`animatorForAttributes:`). */
    fun animatorForAttributes(attributes: Map<String, Any>?): CYLPlaceholderItemAnimator?

    /** The key in [attributes] that stands for [genericKey], or null (`attributeKeyForGenericKey:inAttributes:`). */
    fun attributeKeyForGenericKey(genericKey: String, attributes: Map<String, Any>?): String?

    /** Plays the file at [URL] with [animator] whatever its extension; null undoes it (`bindURL:toAnimator:`). */
    fun bindURL(URL: String, animator: CYLPlaceholderItemAnimator?)

    /** Every animator's key for [genericKey], then the generic key (`attributeKeysForGenericKey:`). */
    fun attributeKeysForGenericKey(genericKey: String): List<String>

    /** Every file extension an animator plays (`fileExtensions`). */
    fun fileExtensions(): List<String>
}

/**
 * The animators of the app (iOS `CYLPlaceholderItemAnimatorRegistry`); the companion's calls act on [sharedRegistry].
 */
class CYLPlaceholderItemAnimatorRegistry : CYLPlaceholderItemAnimatorRegistering {
    private val registered = LinkedHashMap<String, CYLPlaceholderItemAnimator>()
    private val bound = HashMap<String, CYLPlaceholderItemAnimator>()

    @Synchronized
    override fun registerAnimator(animator: CYLPlaceholderItemAnimator) {
        registered[animator.identifier] = animator
    }

    @Synchronized
    override fun unregisterAnimatorWithIdentifier(identifier: String) {
        registered.remove(identifier)
    }

    @Synchronized
    override fun animators(): List<CYLPlaceholderItemAnimator> = registered.values.sortedByDescending { it.priority }

    @Synchronized
    override fun animatorWithIdentifier(identifier: String): CYLPlaceholderItemAnimator? = registered[identifier]

    @Synchronized
    override fun animatorForURL(URL: String?): CYLPlaceholderItemAnimator? {
        if (URL.isNullOrEmpty()) return null
        return bound[URL] ?: animators().firstOrNull { it.canAnimateFileAtURL(URL) }
    }

    override fun animatorForAttributes(attributes: Map<String, Any>?): CYLPlaceholderItemAnimator? {
        val key = attributeKeyForGenericKey(ANIMATION_FILE_PATH, attributes) ?: return null
        return animatorForURL(attributes?.get(key) as? String)
    }

    override fun attributeKeyForGenericKey(genericKey: String, attributes: Map<String, Any>?): String? =
        attributeKeysForGenericKey(genericKey).firstOrNull { attributes?.containsKey(it) == true }

    @Synchronized
    override fun bindURL(URL: String, animator: CYLPlaceholderItemAnimator?) {
        if (animator == null) bound.remove(URL) else bound[URL] = animator
    }

    override fun attributeKeysForGenericKey(genericKey: String): List<String> =
        (animators().mapNotNull { it.attributeKeys[genericKey] } + genericKey).distinct()

    override fun fileExtensions(): List<String> = animators().flatMap { it.fileExtensions }.distinct()

    /**
     * The shared registry and its class-level calls.
     */
    companion object {
        /** The generic attribute key of an animation file. */
        const val ANIMATION_FILE_PATH = "CYLPlaceholderItemAnimationFilePath"

        /**
         * The app's registry (`sharedRegistry`); the GIF animator is in it from the start.
         */
        @JvmStatic
        val sharedRegistry: CYLPlaceholderItemAnimatorRegistry by lazy {
            CYLPlaceholderItemAnimatorRegistry().also { it.registerAnimator(CYLGIFPlaceholderItemAnimator.animator) }
        }

        /** [registerAnimator] on [sharedRegistry]. */
        fun registerAnimator(animator: CYLPlaceholderItemAnimator) = sharedRegistry.registerAnimator(animator)

        /** [unregisterAnimatorWithIdentifier] on [sharedRegistry]. */
        fun unregisterAnimatorWithIdentifier(identifier: String) = sharedRegistry.unregisterAnimatorWithIdentifier(identifier)

        /** [animators] of [sharedRegistry]. */
        fun animators(): List<CYLPlaceholderItemAnimator> = sharedRegistry.animators()

        /** [animatorWithIdentifier] on [sharedRegistry]. */
        fun animatorWithIdentifier(identifier: String): CYLPlaceholderItemAnimator? = sharedRegistry.animatorWithIdentifier(identifier)

        /** [animatorForURL] on [sharedRegistry]. */
        fun animatorForURL(URL: String?): CYLPlaceholderItemAnimator? = sharedRegistry.animatorForURL(URL)

        /** [animatorForAttributes] on [sharedRegistry]. */
        fun animatorForAttributes(attributes: Map<String, Any>?): CYLPlaceholderItemAnimator? = sharedRegistry.animatorForAttributes(attributes)

        /** [attributeKeyForGenericKey] on [sharedRegistry]. */
        fun attributeKeyForGenericKey(genericKey: String, attributes: Map<String, Any>?): String? = sharedRegistry.attributeKeyForGenericKey(genericKey, attributes)

        /** [bindURL] on [sharedRegistry]. */
        fun bindURL(URL: String, animator: CYLPlaceholderItemAnimator?) = sharedRegistry.bindURL(URL, animator)

        /** [attributeKeysForGenericKey] on [sharedRegistry]. */
        fun attributeKeysForGenericKey(genericKey: String): List<String> = sharedRegistry.attributeKeysForGenericKey(genericKey)

        /** [fileExtensions] of [sharedRegistry]. */
        fun fileExtensions(): List<String> = sharedRegistry.fileExtensions()
    }
}

/**
 * Makes animation views through a registry (iOS `CYLPlaceholderItemAnimationViewMaking`).
 */
interface CYLPlaceholderItemAnimationViewMaking {
    /** A view playing the file, or null when no animator plays it (`animationViewWithURL:size:contentMode:`). */
    fun animationViewWithURL(context: Context, URL: String, width: Int, height: Int, contentMode: ImageView.ScaleType): View?

    /** The player of a view this factory made, or null (`playerForView:`). */
    fun playerForView(view: View?): CYLPlaceholderItemAnimationPlayer?

    /** Whether this factory made [view] (`isAnimationView:`). */
    fun isAnimationView(view: View?): Boolean
}

/**
 * The factory of animation views (iOS `CYLPlaceholderItemAnimationFactory`); the companion's calls act on
 * [sharedFactory].
 */
class CYLPlaceholderItemAnimationFactory @JvmOverloads constructor(
    /** The animators it uses (`registry`). */
    val registry: CYLPlaceholderItemAnimatorRegistering = CYLPlaceholderItemAnimatorRegistry.sharedRegistry,
) : CYLPlaceholderItemAnimationViewMaking {

    override fun animationViewWithURL(context: Context, URL: String, width: Int, height: Int, contentMode: ImageView.ScaleType): View? {
        val animator = registry.animatorForURL(URL) ?: return null
        val view = animator.animationViewWithURL(context, URL, width, height, contentMode) ?: return null
        view.setTag(R.id.cyl_placeholder_state, animator.identifier)
        return view
    }

    override fun playerForView(view: View?): CYLPlaceholderItemAnimationPlayer? {
        val identifier = view?.getTag(R.id.cyl_placeholder_state) as? String ?: return null
        return registry.animatorWithIdentifier(identifier)?.playerForAnimationView(view)
    }

    override fun isAnimationView(view: View?): Boolean = view?.getTag(R.id.cyl_placeholder_state) is String

    /**
     * The shared factory and its class-level calls.
     */
    companion object {
        /** The factory on the shared registry (`sharedFactory`). */
        @JvmStatic
        val sharedFactory: CYLPlaceholderItemAnimationFactory by lazy { CYLPlaceholderItemAnimationFactory() }

        /** [animationViewWithURL] on [sharedFactory]. */
        fun animationViewWithURL(context: Context, URL: String, width: Int, height: Int, contentMode: ImageView.ScaleType): View? =
            sharedFactory.animationViewWithURL(context, URL, width, height, contentMode)

        /** [playerForView] on [sharedFactory]. */
        fun playerForView(view: View?): CYLPlaceholderItemAnimationPlayer? = sharedFactory.playerForView(view)

        /** [isAnimationView] on [sharedFactory]. */
        fun isAnimationView(view: View?): Boolean = sharedFactory.isAnimationView(view)
    }
}

/**
 * The engine behind an animation view (iOS `CYLPlaceholderAnimationBackend`).
 */
enum class CYLPlaceholderAnimationBackend {
    /** Lottie. */
    Lottie,
    /** PAG. */
    PAG,
    /** Rive. */
    Rive,
    /** GIF. */
    GIF,
    /** Another animator. */
    Custom,
}

/**
 * Called when an animation cannot load (iOS `CYLPlaceholderAnimationErrorHandler`).
 */
typealias CYLPlaceholderAnimationErrorHandler = (Throwable) -> Unit

/**
 * A view that plays one animation file with the registered animator for it (iOS `CYLPlaceholderAnimationView`). Make
 * one with [withFileURL], which gives null when no animator plays the file.
 */
class CYLPlaceholderAnimationView private constructor(
    context: Context,
    /** The engine's view (`animationView`). */
    val animationView: View,
    /** The engine's player (`player`). */
    val player: CYLPlaceholderItemAnimationPlayer,
    /** The animator that made it (`animatorIdentifier`). */
    val animatorIdentifier: String,
) : FrameLayout(context), CYLPlaceholderAnimationPlayer {

    override val view: View get() = this

    /** The engine (`backend`). */
    val backend: CYLPlaceholderAnimationBackend
        get() = when (animatorIdentifier.lowercase()) {
            "lottie" -> CYLPlaceholderAnimationBackend.Lottie
            "pag" -> CYLPlaceholderAnimationBackend.PAG
            "rive" -> CYLPlaceholderAnimationBackend.Rive
            "gif" -> CYLPlaceholderAnimationBackend.GIF
            else -> CYLPlaceholderAnimationBackend.Custom
        }

    /** Whether it is playing (`playing`). */
    var playing: Boolean = false
        private set

    override val ready: Boolean
        get() = (animationView as? CYLPlaceholderItemAnimationPlayableView)?.cyl_isAnimationViewReady ?: true

    override var errorHandler: ((Throwable) -> Unit)? = null
        set(value) {
            field = value
            (animationView as? CYLPlaceholderItemAnimationPlayableView)?.cyl_animationViewErrorHandler = value
        }

    override var readyHandler: (() -> Unit)? = null
        set(value) {
            field = value
            (animationView as? CYLPlaceholderItemAnimationPlayableView)?.cyl_animationViewReadyHandler = value
        }

    init {
        // Decorative by default: the text next to it says what is going on.
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS
        addView(animationView, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
    }

    override fun play() {
        playing = true
        player.play()
    }

    override fun stop() {
        playing = false
        player.stop()
    }

    override fun showLastFrame() {
        playing = false
        player.showLastFrame()
    }

    override fun setAnimationProgress(progress: Float) {
        player.progress = progress.coerceIn(0f, 1f)
    }

    override fun setAnimationSpeed(speed: Float) {
        player.animationSpeed = speed
    }

    override fun setAnimationRepeatCount(count: Int) {
        player.setAnimationRepeatCount(count)
    }

    override fun setAnimationColors(colors: List<Int>) {
        val night = (resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
        player.applyColors(colors.mapIndexed { index, color -> index.toString() to color }.toMap(), night)
    }

    /**
     * Makes animation views.
     */
    companion object {
        /**
         * A view playing the file at [fileURL], [width] by [height] pixels, with [options] for its engine
         * (`initWithFileURL:size:contentMode:options:error:`); null, after calling [errorHandler], when the size is
         * empty or no registered animator plays the file.
         */
        @JvmStatic
        @JvmOverloads
        fun withFileURL(
            context: Context,
            fileURL: String,
            width: Int,
            height: Int,
            contentMode: ImageView.ScaleType = ImageView.ScaleType.FIT_CENTER,
            options: Map<String, Any>? = null,
            errorHandler: CYLPlaceholderAnimationErrorHandler? = null,
        ): CYLPlaceholderAnimationView? {
            if (width <= 0 || height <= 0) {
                errorHandler?.invoke(IllegalArgumentException("CYLPlaceholderAnimationErrorInvalidSize: $width x $height"))
                return null
            }
            val registry = CYLPlaceholderItemAnimatorRegistry.sharedRegistry
            val animator = registry.animatorForURL(fileURL)
            if (animator == null) {
                errorHandler?.invoke(IllegalArgumentException("CYLPlaceholderAnimationErrorUnsupportedFormat: $fileURL"))
                return null
            }
            (animator as? CYLPlaceholderItemViewAnimator)?.options = options
            val view = animator.animationViewWithURL(context, fileURL, width, height, contentMode)
            val player = view?.let { animator.playerForAnimationView(it) }
            if (view == null || player == null) {
                errorHandler?.invoke(IllegalStateException("CYLPlaceholderAnimationErrorAssetLoadFailed: $fileURL"))
                return null
            }
            return CYLPlaceholderAnimationView(context, view, player, animator.identifier).apply {
                layoutParams = LayoutParams(width, height)
            }
        }
    }
}

/**
 * Plays GIF files with the platform's decoder (iOS `CYLGIFPlaceholderItemAnimator`): animated on Android 9 and later,
 * the first frame before.
 */
object CYLGIFPlaceholderItemAnimator {
    /**
     * The GIF animator (`animator`), registered in the shared registry from the start.
     */
    @JvmStatic
    val animator: CYLPlaceholderItemViewAnimator = CYLPlaceholderItemViewAnimator(
        "GIF", listOf("gif"), mapOf(CYLPlaceholderItemAnimatorRegistry.ANIMATION_FILE_PATH to "CYLPlaceholderItemGIFFilePath"),
    ) { context, fileURL, _, contentMode ->
        // A file that cannot be read or decoded gives no view, so the caller keeps its static icon.
        GIFView(context, fileURL, contentMode).takeIf { it.cyl_isAnimationViewReady }
    }

    private class GIFView(context: Context, fileURL: String, contentMode: ScaleType) : ImageView(context), CYLPlaceholderItemAnimationPlayableView {
        override var cyl_animationViewReadyHandler: (() -> Unit)? = null
        override var cyl_animationViewErrorHandler: ((Throwable) -> Unit)? = null
        private var loaded = false
        private var repeat = 0

        init {
            scaleType = contentMode
            runCatching { decode(fileURL) }
                .onSuccess { drawable ->
                    setImageDrawable(drawable)
                    loaded = drawable != null
                }
                .onFailure { error -> post { cyl_animationViewErrorHandler?.invoke(error) } }
        }

        private fun decode(fileURL: String): Drawable? {
            if (Build.VERSION.SDK_INT >= 28) {
                val source = if (fileURL.startsWith("asset:")) ImageDecoder.createSource(context.assets, fileURL.removePrefix("asset:"))
                else ImageDecoder.createSource(File(fileURL.removePrefix("file://")))
                return ImageDecoder.decodeDrawable(source)
            }
            return if (fileURL.startsWith("asset:")) context.assets.open(fileURL.removePrefix("asset:")).use { Drawable.createFromStream(it, fileURL) }
            else Drawable.createFromPath(fileURL.removePrefix("file://"))
        }

        override val cyl_isAnimationViewReady: Boolean get() = loaded

        override fun cyl_playAnimationView() {
            if (Build.VERSION.SDK_INT >= 28) (drawable as? AnimatedImageDrawable)?.let {
                it.repeatCount = if (repeat <= 0) AnimatedImageDrawable.REPEAT_INFINITE else repeat - 1
                it.stop()
                it.start()
            }
        }

        override fun cyl_showAnimationViewLastFrame() = cyl_stopAnimationView()

        override fun cyl_stopAnimationView() {
            if (Build.VERSION.SDK_INT >= 28) (drawable as? AnimatedImageDrawable)?.stop()
        }

        override fun cyl_setAnimationViewRepeatCount(repeatCount: Int): Boolean {
            repeat = repeatCount
            return Build.VERSION.SDK_INT >= 28
        }
    }
}
