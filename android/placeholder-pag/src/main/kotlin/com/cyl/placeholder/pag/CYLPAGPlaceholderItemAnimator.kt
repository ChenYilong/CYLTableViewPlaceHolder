package com.cyl.placeholder.pag

import android.content.ContentProvider
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.widget.ImageView
import com.cyl.placeholder.CYLPlaceholderItemAnimationPlayableView
import com.cyl.placeholder.CYLPlaceholderItemAnimatorRegistry
import com.cyl.placeholder.CYLPlaceholderItemViewAnimator
import org.libpag.PAGFile
import org.libpag.PAGScaleMode
import org.libpag.PAGView

/**
 * Plays PAG files with libpag (iOS `CYLPAGPlaceholderItemAnimator`). The module registers [animator] in the shared
 * registry at app start; call [register] yourself when that start-up provider is removed.
 */
object CYLPAGPlaceholderItemAnimator {
    /**
     * The PAG animator (`animator`).
     */
    @JvmStatic
    val animator: CYLPlaceholderItemViewAnimator = CYLPlaceholderItemViewAnimator(
        "PAG", listOf("pag"),
        mapOf(CYLPlaceholderItemAnimatorRegistry.ANIMATION_FILE_PATH to "CYLPlaceholderItemPAGFilePath"),
    ) { context, fileURL, _, _ ->
        // A file that cannot be read gives no view, so the caller keeps its still image.
        PAGIconView(context, fileURL).takeIf { it.cyl_isAnimationViewReady }
    }

    /**
     * Adds [animator] to the shared registry (`registerAnimator:` on the shared registry).
     */
    @JvmStatic
    fun register() {
        CYLPlaceholderItemAnimatorRegistry.sharedRegistry.registerAnimator(animator)
    }

    /**
     * Loads "asset:name" from the app's assets, anything else as a file path; a "?query" is ignored.
     */
    internal fun load(context: Context, fileURL: String): PAGFile? = runCatching {
        val name = fileURL.substringBefore('?')
        if (name.startsWith(ASSET)) PAGFile.Load(context.assets, name.removePrefix(ASSET)) else PAGFile.Load(name.removePrefix("file://"))
    }.getOrNull()

    private class PAGIconView(context: Context, fileURL: String) : PAGView(context), CYLPlaceholderItemAnimationPlayableView {
        override var cyl_animationViewReadyHandler: (() -> Unit)? = null
        override var cyl_animationViewErrorHandler: ((Throwable) -> Unit)? = null
        private val file = load(context, fileURL)

        init {
            file?.let { composition = it }
            setScaleMode(PAGScaleMode.LetterBox)
            setRepeatCount(0)
        }

        override val cyl_isAnimationViewReady: Boolean get() = file != null

        private var playsWhenAttached = false

        override fun cyl_playAnimationView() {
            progress = 0.0
            // libpag only plays a view that is in a window: a view still being built starts once attached.
            if (isAttachedToWindow) play() else playsWhenAttached = true
        }

        override fun onAttachedToWindow() {
            super.onAttachedToWindow()
            if (playsWhenAttached) {
                playsWhenAttached = false
                post { play() }
            }
        }

        override fun cyl_showAnimationViewLastFrame() {
            playsWhenAttached = false
            stop()
            progress = 1.0
            flush()
        }

        override fun cyl_stopAnimationView() {
            playsWhenAttached = false
            stop()
        }

        override fun cyl_setAnimationViewRepeatCount(repeatCount: Int): Boolean {
            setRepeatCount(maxOf(0, repeatCount))
            return true
        }
    }

    private const val ASSET = "asset:"
}

/**
 * Registers [CYLPAGPlaceholderItemAnimator.animator] when the app starts; declared in this module's manifest.
 */
class CYLPAGPlaceholderItemAnimatorInstaller : ContentProvider() {
    override fun onCreate(): Boolean {
        CYLPAGPlaceholderItemAnimator.register()
        return true
    }

    override fun query(uri: Uri, projection: Array<out String>?, selection: String?, selectionArgs: Array<out String>?, sortOrder: String?): Cursor? = null

    override fun getType(uri: Uri): String? = null

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0

    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<out String>?): Int = 0
}
