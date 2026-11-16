package com.cyl.placeholder.rive

import android.content.ContentProvider
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.net.Uri
import app.rive.runtime.kotlin.RiveAnimationView
import app.rive.runtime.kotlin.core.Loop
import app.rive.runtime.kotlin.core.Rive
import com.cyl.placeholder.CYLPlaceholderItemAnimationPlayableView
import com.cyl.placeholder.CYLPlaceholderItemAnimatorRegistry
import com.cyl.placeholder.CYLPlaceholderItemViewAnimator
import java.io.File

/**
 * Plays Rive files with rive-android (iOS `CYLRivePlaceholderItemAnimator`). The file URL's query picks what plays,
 * like the iOS options: `artboard`, `animation` (a linear animation) or `stateMachine`, e.g.
 * `asset:Animations/CYLRefreshIcon.riv?artboard=refresh&animation=active`. The module registers [animator] at app
 * start; call [register] yourself when that start-up provider is removed.
 */
object CYLRivePlaceholderItemAnimator {
    /**
     * The Rive animator (`animator`).
     */
    @JvmStatic
    val animator: CYLPlaceholderItemViewAnimator = CYLPlaceholderItemViewAnimator(
        "Rive", listOf("riv"),
        mapOf(CYLPlaceholderItemAnimatorRegistry.ANIMATION_FILE_PATH to "CYLPlaceholderItemRiveFilePath"),
    ) { context, fileURL, _, _ ->
        // A file that cannot be read gives no view, so the caller keeps its still image.
        RiveIconView(context, fileURL).takeIf { it.cyl_isAnimationViewReady }
    }

    /**
     * Adds [animator] to the shared registry (`registerAnimator:` on the shared registry).
     */
    @JvmStatic
    fun register() {
        CYLPlaceholderItemAnimatorRegistry.sharedRegistry.registerAnimator(animator)
    }

    /**
     * The options in [fileURL]'s query (`artboard=refresh&animation=active` → a map).
     */
    internal fun options(fileURL: String): Map<String, String> =
        fileURL.substringAfter('?', "").split('&').filter { '=' in it }.associate { it.substringBefore('=') to Uri.decode(it.substringAfter('=')) }

    private fun bytes(context: Context, fileURL: String): ByteArray? = runCatching {
        val name = fileURL.substringBefore('?')
        if (name.startsWith(ASSET)) context.assets.open(name.removePrefix(ASSET)).use { it.readBytes() }
        else File(name.removePrefix("file://")).readBytes()
    }.getOrNull()

    private class RiveIconView(context: Context, fileURL: String) : RiveAnimationView(context), CYLPlaceholderItemAnimationPlayableView {
        override var cyl_animationViewReadyHandler: (() -> Unit)? = null
        override var cyl_animationViewErrorHandler: ((Throwable) -> Unit)? = null
        private val options = options(fileURL)
        private val loaded: Boolean

        init {
            // The placeholder's own button and tap-to-reload keep the taps: RiveAnimationView consumes every touch.
            isClickable = false
            isFocusable = false
            val data = bytes(context, fileURL)
            loaded = data != null && runCatching {
                setRiveBytes(data, artboardName = options["artboard"], animationName = options["animation"],
                    stateMachineName = options["stateMachine"], autoplay = false)
            }.onFailure { error -> post { cyl_animationViewErrorHandler?.invoke(error) } }.isSuccess
        }

        override val cyl_isAnimationViewReady: Boolean get() = loaded

        @android.annotation.SuppressLint("ClickableViewAccessibility")
        override fun onTouchEvent(event: android.view.MotionEvent): Boolean = false

        override fun cyl_playAnimationView() {
            val animation = options["animation"]
            val machine = options["stateMachine"]
            when {
                machine != null -> play(machine, Loop.AUTO, isStateMachine = true)
                animation != null -> play(animation, Loop.LOOP)
                else -> play(Loop.LOOP)
            }
        }

        override fun cyl_showAnimationViewLastFrame() = pause()

        override fun cyl_stopAnimationView() = pause()
    }

    private const val ASSET = "asset:"
}

/**
 * Starts the Rive runtime and registers [CYLRivePlaceholderItemAnimator.animator] when the app starts; declared in
 * this module's manifest.
 */
class CYLRivePlaceholderItemAnimatorInstaller : ContentProvider() {
    override fun onCreate(): Boolean {
        context?.let { runCatching { Rive.init(it) } }
        CYLRivePlaceholderItemAnimator.register()
        return true
    }

    override fun query(uri: Uri, projection: Array<out String>?, selection: String?, selectionArgs: Array<out String>?, sortOrder: String?): Cursor? = null

    override fun getType(uri: Uri): String? = null

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0

    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<out String>?): Int = 0
}
