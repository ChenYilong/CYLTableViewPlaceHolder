package com.cyl.refresh.merged.example

import android.annotation.SuppressLint
import android.content.Context
import android.view.View
import com.cyl.animateditem.CYLSize
import com.cyl.placeholder.CYLPlaceholderView
import com.cyl.refresh.CYLRefreshDrawnHeader
import com.cyl.refresh.CYLRefreshPhase
import com.cyl.refresh.CYLRefreshScrollMode
import com.cyl.refresh.layout.api.RefreshHeader
import com.cyl.refresh.layout.simple.SimpleComponent
import kotlin.math.max

/**
 * The SVGA twin of the Rive scene styles (SmartStylesPage, Task-Log "SVGA animations, every Rive demo copied 1:1"):
 * an SVGA scene of scripts/make_svga_scenes.py drawn by the core's CYLPlaceholderView (the CYLAnimatedItem engine and
 * SVGAPlayer-Android). Like CYLRefreshRiveHeader it stretches with the pull and keeps the art laid out in at least
 * [SCENE_HEIGHT] dp at the bottom; SVGA has no state machine, so the pull scrubs the scene and refreshing loops it.
 */
internal class SVGASceneHeader private constructor(private val sceneView: SVGASceneView) : CYLRefreshDrawnHeader(sceneView) {

    constructor(context: Context, path: String) : this(SVGASceneView(context, path))

    private val scene get() = sceneView.scene
    private var playing = false

    override fun setUpComponent() {
        scrollMode = CYLRefreshScrollMode.Stretch
        setExpandHeight(SCENE_HEIGHT)
    }

    override fun onScrollingWithOffset(offset: Int, percent: Float, drag: Boolean) {
        if (!playing) scene.setPlaceholderAnimationProgress(percent.coerceIn(0f, 1f))
    }

    override fun onStatus(oldStatus: CYLRefreshPhase, status: CYLRefreshPhase) {
        when (status) {
            CYLRefreshPhase.Releasing, CYLRefreshPhase.Refreshing -> if (!playing) {
                playing = true
                scene.animationRepeatCount = 0
                scene.playPlaceholderAnimation()
            }
            CYLRefreshPhase.Idle -> if (playing) {
                playing = false
                scene.stopPlaceholderAnimation()
                scene.setPlaceholderAnimationProgress(0f)
            }
            else -> Unit
        }
    }

    companion object {
        /** The scene's height in dp (the files are 375 × 150, shown 300 × 120). */
        const val SCENE_HEIGHT = 130f
    }
}

/** The header view: the scene, centered at the bottom of at least [SVGASceneHeader.SCENE_HEIGHT] dp. */
@SuppressLint("ViewConstructor")
internal class SVGASceneView(context: Context, path: String) : SimpleComponent(context, null, 0), RefreshHeader {

    val scene = CYLPlaceholderView(context).apply {
        iconSizeDp = CYLSize(300f, 120f)
        setAnimationFile(path)
    }

    init {
        addView(scene)
        importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS
        clipChildren = true
    }

    private val minimum get() = (SVGASceneHeader.SCENE_HEIGHT * resources.displayMetrics.density).toInt()

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        scene.measure(MeasureSpec.makeMeasureSpec(measuredWidth, MeasureSpec.EXACTLY),
            MeasureSpec.makeMeasureSpec(minimum, MeasureSpec.EXACTLY))
    }

    // The layout stretches the header without measuring it again: the scene keeps its height at the bottom.
    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        val width = r - l
        val height = b - t
        val target = max(height, minimum)
        if (scene.measuredWidth != width || scene.measuredHeight != target) {
            scene.measure(MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(target, MeasureSpec.EXACTLY))
        }
        scene.layout(0, height - scene.measuredHeight, width, height)
    }
}
