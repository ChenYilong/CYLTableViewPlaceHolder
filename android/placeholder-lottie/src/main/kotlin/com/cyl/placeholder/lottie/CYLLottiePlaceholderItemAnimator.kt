package com.cyl.placeholder.lottie

import android.content.ContentProvider
import android.content.ContentValues
import android.content.Context
import android.database.Cursor
import android.graphics.PorterDuff
import android.graphics.PorterDuffColorFilter
import android.net.Uri
import android.widget.ImageView
import com.airbnb.lottie.LottieAnimationView
import com.airbnb.lottie.LottieCompositionFactory
import com.airbnb.lottie.LottieDrawable
import com.airbnb.lottie.LottieProperty
import com.airbnb.lottie.model.KeyPath
import com.airbnb.lottie.value.LottieValueCallback
import com.cyl.placeholder.CYLPlaceholderItemAnimationPlayableView
import com.cyl.placeholder.CYLPlaceholderItemAnimatorRegistry
import com.cyl.placeholder.CYLPlaceholderItemViewAnimator
import java.io.File
import java.io.FileInputStream

/**
 * Plays Lottie JSON files with lottie-android (iOS `CYLLottiePlaceholderItemAnimator`). The module registers [animator]
 * in the shared registry at app start; call [register] yourself when that start-up provider is removed.
 */
object CYLLottiePlaceholderItemAnimator {
    /**
     * The Lottie animator (`animator`).
     */
    @JvmStatic
    val animator: CYLPlaceholderItemViewAnimator = CYLPlaceholderItemViewAnimator(
        "Lottie", listOf("json", "lottie"),
        mapOf(CYLPlaceholderItemAnimatorRegistry.ANIMATION_FILE_PATH to "CYLPlaceholderItemLottieFilePath"),
    ) { context, fileURL, _, contentMode ->
        // A file that cannot be read or parsed gives no view, so the caller keeps its still image.
        LottieView(context, fileURL, contentMode).takeIf { it.cyl_isAnimationViewReady }
    }

    /**
     * Adds [animator] to the shared registry (`registerAnimator:` on the shared registry).
     */
    @JvmStatic
    fun register() {
        CYLPlaceholderItemAnimatorRegistry.sharedRegistry.registerAnimator(animator)
    }

    private class LottieView(context: Context, fileURL: String, contentMode: ImageView.ScaleType) :
        LottieAnimationView(context), CYLPlaceholderItemAnimationPlayableView {
        override var cyl_animationViewReadyHandler: (() -> Unit)? = null
        override var cyl_animationViewErrorHandler: ((Throwable) -> Unit)? = null
        private var loaded = false

        init {
            scaleType = contentMode
            repeatCount = LottieDrawable.INFINITE
            val result = runCatching {
                if (fileURL.startsWith(ASSET)) {
                    LottieCompositionFactory.fromAssetSync(context, fileURL.removePrefix(ASSET))
                } else {
                    val path = fileURL.removePrefix("file://")
                    LottieCompositionFactory.fromJsonInputStreamSync(FileInputStream(File(path)), path)
                }
            }.getOrElse { error -> post { cyl_animationViewErrorHandler?.invoke(error) }; null }
            val composition = result?.value
            if (composition != null) {
                setComposition(composition)
                loaded = true
            } else {
                result?.exception?.let { error -> post { cyl_animationViewErrorHandler?.invoke(error) } }
            }
        }

        override val cyl_isAnimationViewReady: Boolean get() = loaded

        override fun cyl_playAnimationView() {
            progress = 0f
            playAnimation()
        }

        override fun cyl_showAnimationViewLastFrame() {
            cancelAnimation()
            progress = 1f
        }

        override fun cyl_stopAnimationView() {
            cancelAnimation()
        }

        override fun cyl_setAnimationViewRepeatCount(repeatCount: Int): Boolean {
            this.repeatCount = if (repeatCount <= 0) LottieDrawable.INFINITE else repeatCount - 1
            return true
        }

        override fun cyl_applyAnimationViewColors(colors: Map<String, Int>?) {
            val color = colors?.values?.firstOrNull()
            addValueCallback(KeyPath("**"), LottieProperty.COLOR_FILTER,
                LottieValueCallback(color?.let { PorterDuffColorFilter(it, PorterDuff.Mode.SRC_ATOP) }))
        }
    }

    private const val ASSET = "asset:"
}

/**
 * Registers [CYLLottiePlaceholderItemAnimator.animator] when the app starts; declared in this module's manifest.
 */
class CYLLottiePlaceholderItemAnimatorInstaller : ContentProvider() {
    override fun onCreate(): Boolean {
        CYLLottiePlaceholderItemAnimator.register()
        return true
    }

    override fun query(uri: Uri, projection: Array<out String>?, selection: String?, selectionArgs: Array<out String>?, sortOrder: String?): Cursor? = null

    override fun getType(uri: Uri): String? = null

    override fun insert(uri: Uri, values: ContentValues?): Uri? = null

    override fun delete(uri: Uri, selection: String?, selectionArgs: Array<out String>?): Int = 0

    override fun update(uri: Uri, values: ContentValues?, selection: String?, selectionArgs: Array<out String>?): Int = 0
}
