package com.cyl.refresh

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import com.cyl.refresh.header.BezierCircleHeader
import com.cyl.refresh.header.BezierRadarHeader
import com.cyl.refresh.header.ClassicsHeader
import com.cyl.refresh.header.DeliveryHeader
import com.cyl.refresh.header.DropBoxHeader
import com.cyl.refresh.header.FlyRefreshHeader
import com.cyl.refresh.header.FunGameBattleCityHeader
import com.cyl.refresh.header.FunGameHitBlockHeader
import com.cyl.refresh.header.MaterialHeader
import com.cyl.refresh.header.PhoenixHeader
import com.cyl.refresh.header.StoreHouseHeader
import com.cyl.refresh.header.TaurusHeader
import com.cyl.refresh.header.WaveSwipeHeader
import com.cyl.refresh.header.flyrefresh.FlyView
import com.cyl.refresh.header.flyrefresh.MountainSceneView
import com.cyl.refresh.layout.CYLRefreshLayout
import com.cyl.refresh.layout.api.RefreshHeader

/**
 * A header drawn in code, with the hooks its subclasses override (iOS `CYLRefreshDrawnHeader`). On Android the drawing
 * is done by the CYLRefreshLayout header given as [view]; the hooks tell a subclass what happens.
 */
open class CYLRefreshDrawnHeader(view: RefreshHeader) : CYLRefreshHeader(view) {

    /**
     * The header's width, in pixels (`width`).
     */
    val width: Int get() = view.view.width

    /**
     * The header's height, in pixels (`height`).
     */
    val height: Int get() = view.view.height

    /**
     * The fast animation's duration, in seconds (`durationFast`).
     */
    var durationFast: Double
        get() = fastAnimationDuration
        set(value) { fastAnimationDuration = value }

    /**
     * The normal animation's duration, in seconds (`durationNormal`).
     */
    var durationNormal: Double
        get() = slowAnimationDuration
        set(value) { slowAnimationDuration = value }

    /**
     * The phase (`status`).
     */
    val status: CYLRefreshPhase get() = phase

    /**
     * How far the header is pulled, as a share of its height (`dragPercent`).
     */
    val dragPercent: Float get() = pullingPercent

    /**
     * Whether the last refresh succeeded (`isSuccess`).
     */
    val isSuccess: Boolean get() = lastRefreshSucceeded

    /**
     * Called once the header is attached (`setUpComponent`).
     */
    protected open fun setUpComponent() {}

    /**
     * Called on every phase change (`onStatus:changed:`).
     */
    protected open fun onStatus(oldStatus: CYLRefreshPhase, status: CYLRefreshPhase) {}

    /**
     * Called as the pull moves, with the layout (`scrollView:didScroll:percent:drag:`).
     */
    protected open fun scrollView(scrollView: CYLRefreshLayout, didScroll: Int, percent: Float, drag: Boolean) {}

    /**
     * Called as the pull moves (`onScrollingWithOffset:percent:drag:`).
     */
    protected open fun onScrollingWithOffset(offset: Int, percent: Float, drag: Boolean) {}

    /**
     * Called when the header is released and opens (`onStartAnimationWhenRealeasing`).
     */
    protected open fun onStartAnimationWhenRealeasing() {}

    /**
     * Called when refreshing starts (`onStartAnimationWhenRefreshing`).
     */
    protected open fun onStartAnimationWhenRefreshing() {}

    /**
     * Called when the refresh ends and the header starts closing; the seconds the finished state shows
     * (`onRefreshFinishing:`).
     */
    protected open fun onRefreshFinishing(success: Boolean): Double = finishDuration

    /**
     * Called once the header has closed (`onRefreshFinished:`).
     */
    protected open fun onRefreshFinished(success: Boolean) {}

    /**
     * Called when the header joins or leaves a layout (`scrollView:attached:`).
     */
    protected open fun scrollView(scrollView: CYLRefreshLayout, attached: Boolean) {}

    /**
     * Starts refreshing (`beginRefresh`).
     */
    fun beginRefresh() = beginRefreshing()

    /**
     * Ends refreshing (`finishRefresh`).
     */
    fun finishRefresh() = endRefreshing()

    /**
     * Ends refreshing with success or failure (`finishRefreshWithSuccess:`).
     */
    fun finishRefreshWithSuccess(success: Boolean) = endRefreshingWithSuccess(success)

    /**
     * True when the phase is one of [statuses] (`inStatus:`).
     */
    fun inStatus(vararg statuses: CYLRefreshPhase): Boolean = isInAnyPhase(*statuses)

    final override fun didAttachToScrollView(layout: CYLRefreshLayout) {
        setUpComponent()
        scrollView(layout, true)
    }

    final override fun willDetachFromScrollView(layout: CYLRefreshLayout) = scrollView(layout, false)

    final override fun didScrollWithOffset(offset: Int, percent: Float, dragging: Boolean) {
        refreshLayout?.let { scrollView(it, offset, percent, dragging) }
        onScrollingWithOffset(offset, percent, dragging)
    }

    final override fun phaseDidChangeFrom(old: CYLRefreshPhase, new: CYLRefreshPhase) {
        onStatus(old, new)
        when (new) {
            CYLRefreshPhase.Releasing -> onStartAnimationWhenRealeasing()
            CYLRefreshPhase.Refreshing -> onStartAnimationWhenRefreshing()
            CYLRefreshPhase.Finishing -> onRefreshFinishing(lastRefreshSucceeded)
            CYLRefreshPhase.Idle -> if (old == CYLRefreshPhase.Finishing) onRefreshFinished(lastRefreshSucceeded)
            else -> Unit
        }
    }
}

/**
 * The Material circle spinner (iOS `CYLRefreshMaterialHeader`).
 */
open class CYLRefreshMaterialHeader(context: Context) : CYLRefreshDrawnHeader(MaterialHeader(context))

/**
 * The Bezier circle (iOS `CYLRefreshBezierCircleHeader`).
 */
open class CYLRefreshBezierCircleHeader(context: Context) : CYLRefreshDrawnHeader(BezierCircleHeader(context))

/**
 * The Bezier radar (iOS `CYLRefreshBezierRadarHeader`).
 */
open class CYLRefreshBezierRadarHeader(context: Context) : CYLRefreshDrawnHeader(BezierRadarHeader(context))

/**
 * The delivery box and balloon (iOS `CYLRefreshDeliveryHeader`).
 */
open class CYLRefreshDeliveryHeader(context: Context) : CYLRefreshDrawnHeader(DeliveryHeader(context))

/**
 * The drop box (iOS `CYLRefreshDropBoxHeader`).
 */
open class CYLRefreshDropBoxHeader(context: Context) : CYLRefreshDrawnHeader(DropBoxHeader(context))

/**
 * The paper plane (iOS `CYLRefreshFlyHeader`): like iOS, it brings its own scene. Attaching puts a 150 dp mountain
 * scene above the content and the plane on a round button at the scene's bottom left; detaching restores the content.
 */
open class CYLRefreshFlyHeader(context: Context) : CYLRefreshDrawnHeader(FlyRefreshHeader(context)) {

    /**
     * The mountains above the content (`mountainView`).
     */
    val mountainView = MountainSceneView(context)

    /**
     * The paper plane (`flyView`).
     */
    val flyView = FlyView(context)

    /**
     * The round button under the plane, in the primary color (`floatView`).
     */
    val floatView: View = object : View(context) {
        private val paint = Paint(Paint.ANTI_ALIAS_FLAG)

        override fun onDraw(canvas: Canvas) {
            paint.color = if (colorPrimary != 0) colorPrimary else DEFAULT_PRIMARY
            canvas.drawCircle(width / 2f, height / 2f, minOf(width, height) / 2f, paint)
        }
    }

    private var scene: FrameLayout? = null
    private var content: View? = null
    private var baseHeight = 0
    private var stretch = 0

    override fun scrollView(scrollView: CYLRefreshLayout, didScroll: Int, percent: Float, drag: Boolean) {
        val added = maxOf(0, didScroll)
        if (scene == null || added == stretch) return
        val delta = added - stretch
        stretch = added
        mountainView.layoutParams = mountainView.layoutParams.apply { height = baseHeight + added }
        for (child in listOf(floatView, flyView)) {
            child.layoutParams = (child.layoutParams as FrameLayout.LayoutParams).apply { topMargin += delta }
        }
    }

    init {
        colorPrimary = DEFAULT_PRIMARY
        colorAccent = Color.WHITE
    }

    override fun scrollView(scrollView: CYLRefreshLayout, attached: Boolean) {
        if (attached) wrapContent(scrollView) else unwrapContent(scrollView)
    }

    private fun wrapContent(layout: CYLRefreshLayout) {
        if (scene != null) return
        val original = (0 until layout.childCount).map(layout::getChildAt).firstOrNull { it !== view.view && it !== layout.refreshFooter?.view } ?: return
        val density = layout.resources.displayMetrics.density
        val sceneHeight = (SCENE_HEIGHT_DP * density).toInt()
        val size = (FLOAT_SIZE_DP * density).toInt()
        val frame = FrameLayout(layout.context)
        val column = LinearLayout(layout.context).apply { orientation = LinearLayout.VERTICAL }
        frame.addView(column, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        layout.setRefreshContent(frame)
        column.addView(mountainView, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, sceneHeight))
        column.addView(original, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
        // The button sits on the scene's bottom edge, a quarter of its size from the left (iOS FLOAT_VIEW_SIZE * 3 / 4).
        val buttonParams = FrameLayout.LayoutParams(size, size, Gravity.TOP or Gravity.START).apply {
            leftMargin = size / 4
            topMargin = sceneHeight - size / 2
        }
        frame.addView(floatView, buttonParams)
        // The plane keeps its own 25 dp size, centered on the button.
        val plane = (PLANE_SIZE_DP * density).toInt()
        frame.addView(flyView, FrameLayout.LayoutParams(plane, plane, Gravity.TOP or Gravity.START).apply {
            leftMargin = buttonParams.leftMargin + (size - plane) / 2
            topMargin = buttonParams.topMargin + (size - plane) / 2
        })
        // As on iOS, the pull stretches the scene and pushes the content down, instead of moving the whole page.
        layout.setEnableHeaderTranslationContent(false)
        baseHeight = sceneHeight
        (view as FlyRefreshHeader).setUp(mountainView, flyView)
        scene = frame
        content = original
    }

    private fun unwrapContent(layout: CYLRefreshLayout) {
        val original = content ?: return
        for (child in listOf(original, mountainView, floatView, flyView)) (child.parent as? ViewGroup)?.removeView(child)
        layout.setRefreshContent(original)
        layout.setEnableHeaderTranslationContent(true)
        (view as FlyRefreshHeader).setUp(null, null)
        scene = null
        content = null
    }

    private companion object {
        const val DEFAULT_PRIMARY = 0xFF33AAFF.toInt()
        const val SCENE_HEIGHT_DP = 150
        const val FLOAT_SIZE_DP = 56
        const val PLANE_SIZE_DP = 25
    }
}

/**
 * A header with a small game to play while refreshing (iOS `CYLRefreshGameHeader`).
 */
open class CYLRefreshGameHeader(view: RefreshHeader) : CYLRefreshDrawnHeader(view)

/**
 * The tank game (iOS `CYLRefreshGameBattleCityHeader`).
 */
open class CYLRefreshGameBattleCityHeader(context: Context) : CYLRefreshGameHeader(FunGameBattleCityHeader(context))

/**
 * The block-breaking game (iOS `CYLRefreshGameHitBlockHeader`).
 */
open class CYLRefreshGameHitBlockHeader(context: Context) : CYLRefreshGameHeader(FunGameHitBlockHeader(context))

/**
 * The sunrise over a town (iOS `CYLRefreshPhoenixHeader`).
 */
open class CYLRefreshPhoenixHeader(context: Context) : CYLRefreshDrawnHeader(PhoenixHeader(context))

/**
 * The plane among clouds (iOS `CYLRefreshTaurusHeader`).
 */
open class CYLRefreshTaurusHeader(context: Context) : CYLRefreshDrawnHeader(TaurusHeader(context))

/**
 * The wave and drop (iOS `CYLRefreshWaveSwipeHeader`).
 */
open class CYLRefreshWaveSwipeHeader(context: Context) : CYLRefreshDrawnHeader(WaveSwipeHeader(context))

/**
 * CYLRefreshLayout's original classic header (iOS `CYLRefreshOriginalHeader`).
 */
open class CYLRefreshOriginalHeader(context: Context) : CYLRefreshDrawnHeader(ClassicsHeader(context)) {
    /**
     * Whether the header refreshes by itself once attached (`enableAutoRefresh`).
     */
    var enableAutoRefresh: Boolean = false

    override fun setUpComponent() {
        if (enableAutoRefresh) beginRefreshing()
    }
}

/**
 * Text drawn as line segments that assemble as you pull (iOS `CYLRefreshStoreHouseHeader`).
 */
open class CYLRefreshStoreHouseHeader(context: Context) : CYLRefreshDrawnHeader(StoreHouseHeader(context)) {

    private val storeHouse: StoreHouseHeader get() = view as StoreHouseHeader

    /**
     * The lines' width, in pixels (`lineWidth`).
     */
    var lineWidth: Float = 2f
        set(value) {
            field = value
            storeHouse.setLineWidth(value.toInt())
        }

    /**
     * Whether the loading flash runs back and forth (`enableReverseFlash`). Default false.
     */
    var enableReverseFlash: Boolean
        get() = storeHouse.mReverseFlash
        set(value) { storeHouse.mReverseFlash = value }

    /**
     * Whether the lines fade in as they assemble with the pull (`enableFadeAnimation`); false shows them at full
     * alpha. Default true.
     */
    var enableFadeAnimation: Boolean
        get() = storeHouse.mFadeAnimation
        set(value) { storeHouse.mFadeAnimation = value }

    /**
     * Draws [string] at the default size (`initLinesWithString:`).
     */
    fun initLinesWithString(string: String) = initLinesWithString(string, 1f)

    /**
     * Draws [string] scaled by [scale] (`initLinesWithString:scale:`).
     */
    fun initLinesWithString(string: String, scale: Float) {
        storeHouse.initWithString(string, (25 * scale).toInt().coerceAtLeast(1))
    }

    /**
     * Draws [string] scaled by [scale]; [padding] is the drop height above the text, in pixels
     * (`initLinesWithString:scale:padding:`).
     */
    fun initLinesWithString(string: String, scale: Float, padding: Float) {
        storeHouse.setDropHeight(padding.toInt())
        initLinesWithString(string, scale)
    }

    /**
     * Draws lines given as "x1,y1,x2,y2" strings (`initLinesWithArray:`).
     */
    fun initLinesWithArray(array: List<String>) {
        val points = array.mapNotNull { line ->
            val numbers = line.split(',').mapNotNull { it.trim().toFloatOrNull() }
            if (numbers.size == 4) numbers.toFloatArray() else null
        }
        if (points.isNotEmpty()) storeHouse.initWithPointList(points)
    }

    /**
     * Draws lines given as "x1,y1,x2,y2" strings, with [padding] as the drop height (`initLinesWithArray:padding:`).
     */
    fun initLinesWithArray(array: List<String>, padding: Float) {
        storeHouse.setDropHeight(padding.toInt())
        initLinesWithArray(array)
    }

    /**
     * Makes headers with the iOS factory names.
     */
    companion object {
        /**
         * A header drawing [string] (`newWithString:`).
         */
        @JvmStatic
        fun newWithString(context: Context, string: String): CYLRefreshStoreHouseHeader = newWithString(context, string, 1f)

        /**
         * A header drawing [string] scaled by [scale] (`newWithString:scale:`).
         */
        @JvmStatic
        fun newWithString(context: Context, string: String, scale: Float): CYLRefreshStoreHouseHeader =
            CYLRefreshStoreHouseHeader(context).apply { initLinesWithString(string, scale) }

        /**
         * A header drawing [string] scaled by [scale], with [padding] (`newWithString:scale:padding:`).
         */
        @JvmStatic
        fun newWithString(context: Context, string: String, scale: Float, padding: Float): CYLRefreshStoreHouseHeader =
            CYLRefreshStoreHouseHeader(context).apply { initLinesWithString(string, scale, padding) }
    }
}
