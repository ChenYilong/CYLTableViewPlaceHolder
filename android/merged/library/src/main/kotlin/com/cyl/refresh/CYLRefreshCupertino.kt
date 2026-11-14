package com.cyl.refresh

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.os.SystemClock
import android.view.View
import android.view.ViewGroup
import android.widget.RelativeLayout
import com.scwang.smart.refresh.layout.api.RefreshFooter
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.simple.SimpleComponent

/**
 * The twelve-spoke spinner of the iOS system (`UIActivityIndicatorView`): spokes appear as you pull and one fading tail
 * turns while it animates.
 */
class CYLActivityIndicatorView(context: Context) : View(context) {
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { strokeCap = Paint.Cap.ROUND }
    private var startTime = 0L

    /**
     * Whether the tail is turning (`isAnimating`).
     */
    var isAnimating: Boolean = false
        private set

    /**
     * How much of the spokes shows while pulling, 0 to 1 (`progress`).
     */
    var progress: Float = 0f
        set(value) {
            field = value.coerceIn(0f, 1f)
            invalidate()
        }

    /**
     * The spokes' color (`color`).
     */
    var color: Int = 0xFF8E8E93.toInt()
        set(value) {
            field = value
            invalidate()
        }

    /**
     * Starts turning (`startAnimating`).
     */
    fun startAnimating() {
        if (isAnimating) return
        isAnimating = true
        startTime = SystemClock.uptimeMillis()
        postInvalidateOnAnimation()
    }

    /**
     * Stops turning (`stopAnimating`).
     */
    fun stopAnimating() {
        isAnimating = false
        invalidate()
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        isAnimating = false
    }

    override fun onDraw(canvas: Canvas) {
        val side = minOf(width, height).toFloat()
        if (side <= 0f) return
        val cx = width / 2f
        val cy = height / 2f
        val inner = side * 0.28f
        val outer = side * 0.5f
        paint.strokeWidth = side * 0.09f
        val head = if (isAnimating) (((SystemClock.uptimeMillis() - startTime) / 83) % SPOKES).toInt() else 0
        val shown = if (isAnimating) SPOKES else (progress * SPOKES).toInt()
        for (i in 0 until shown) {
            // The tail trails the head: the head is the brightest spoke.
            val age = if (isAnimating) (head - i + SPOKES) % SPOKES else 0
            val alpha = if (isAnimating) 1f - age / SPOKES.toFloat() * 0.85f else 0.85f
            paint.color = color
            paint.alpha = (alpha * 255).toInt()
            canvas.save()
            canvas.rotate(i * 360f / SPOKES, cx, cy)
            canvas.drawLine(cx, cy - inner, cx, cy - outer, paint)
            canvas.restore()
        }
        if (isAnimating) postInvalidateOnAnimation()
    }

    private companion object {
        const val SPOKES = 12
    }
}

private fun cupertinoLayout(host: RelativeLayout, indicator: CYLActivityIndicatorView) {
    val side = (24 * host.resources.displayMetrics.density).toInt()
    host.addView(indicator, RelativeLayout.LayoutParams(side, side).apply { addRule(RelativeLayout.CENTER_IN_PARENT) })
}

/**
 * The header view of [CYLRefreshCupertinoHeader].
 */
internal class CYLCupertinoHeaderView(context: Context) : SimpleComponent(context, null, 0), RefreshHeader {
    val indicator = CYLActivityIndicatorView(context)

    init {
        cupertinoLayout(this, indicator)
    }

    override val spinnerStyle: SpinnerStyle get() = SpinnerStyle.Translate

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        if (!indicator.isAnimating) indicator.progress = percent
    }

    override fun onStartAnimator(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) = indicator.startAnimating()

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        indicator.stopAnimating()
        return 0
    }
}

/**
 * The footer view of [CYLRefreshCupertinoFooter].
 */
internal class CYLCupertinoFooterView(context: Context) : SimpleComponent(context, null, 0), RefreshFooter {
    val indicator = CYLActivityIndicatorView(context)
    private var noMoreData = false

    init {
        cupertinoLayout(this, indicator)
    }

    override val spinnerStyle: SpinnerStyle get() = SpinnerStyle.Translate

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        if (!indicator.isAnimating) indicator.progress = percent
    }

    override fun onStartAnimator(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        if (!noMoreData) indicator.startAnimating()
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        indicator.stopAnimating()
        return 0
    }

    override fun setNoMoreData(noMoreData: Boolean): Boolean {
        this.noMoreData = noMoreData
        indicator.visibility = if (noMoreData) INVISIBLE else VISIBLE
        return true
    }
}

/**
 * A header with the system spinner (iOS `CYLRefreshCupertinoHeader`).
 */
open class CYLRefreshCupertinoHeader(context: Context) : CYLRefreshHeader(CYLCupertinoHeaderView(context)) {
    /**
     * The spinner (`activityIndicator`).
     */
    val activityIndicator: CYLActivityIndicatorView get() = (view as CYLCupertinoHeaderView).indicator
}

/**
 * A footer with the system spinner that loads when the end is reached (iOS `CYLRefreshCupertinoFooter`).
 */
open class CYLRefreshCupertinoFooter(context: Context) : CYLRefreshAutoFooter(CYLCupertinoFooterView(context)) {
    /**
     * The spinner (`activityIndicator`).
     */
    val activityIndicator: CYLActivityIndicatorView get() = (view as CYLCupertinoFooterView).indicator
}

/**
 * Forwards a footer's events to a header's view drawn upside down (iOS draws the header styles below the list the
 * same way): the layout's footer states become the header states they mirror.
 */
internal class CYLDrawnFooterView(private val styleHeader: RefreshHeader) : SimpleComponent(styleHeader.view.context, null, 0), RefreshFooter {

    init {
        // The header draws upside down, so its drawing grows from the footer's edge.
        styleHeader.view.scaleY = -1f
        (styleHeader.view.parent as? ViewGroup)?.removeView(styleHeader.view)
        addView(styleHeader.view, RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
    }

    override val spinnerStyle: SpinnerStyle get() = styleHeader.spinnerStyle

    override fun setPrimaryColors(vararg colors: Int) = styleHeader.setPrimaryColors(*colors)

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) = styleHeader.onInitialized(kernel, height, maxDragHeight)

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) =
        styleHeader.onMoving(isDragging, percent, offset, height, maxDragHeight)

    override fun onReleased(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) = styleHeader.onReleased(refreshLayout, height, maxDragHeight)

    override fun onStartAnimator(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) = styleHeader.onStartAnimator(refreshLayout, height, maxDragHeight)

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int = styleHeader.onFinish(refreshLayout, success)

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) =
        styleHeader.onStateChanged(refreshLayout, headerStateOf(oldState), headerStateOf(newState))

    override fun setNoMoreData(noMoreData: Boolean): Boolean = false

    private fun headerStateOf(state: RefreshState): RefreshState = when (state) {
        RefreshState.PullUpToLoad -> RefreshState.PullDownToRefresh
        RefreshState.ReleaseToLoad -> RefreshState.ReleaseToRefresh
        RefreshState.LoadReleased -> RefreshState.RefreshReleased
        RefreshState.Loading -> RefreshState.Refreshing
        RefreshState.LoadFinish -> RefreshState.RefreshFinish
        RefreshState.PullUpCanceled -> RefreshState.PullDownCanceled
        else -> state
    }
}

/**
 * A back footer drawn like a header style, upside down (iOS `CYLRefreshDrawnFooter`).
 */
open class CYLRefreshDrawnFooter(
    /**
     * The header whose drawing the footer shows (`style`).
     */
    val style: CYLRefreshDrawnHeader,
) : CYLRefreshBackFooter(CYLDrawnFooterView(style.view as RefreshHeader)) {
    /**
     * The header styles a footer class draws, by footer class (`styleClass`).
     */
    companion object {
        /**
         * The style header class a subclass draws, or null for a footer given its style (`styleClass`).
         */
        @JvmStatic
        val styleClass: Class<out CYLRefreshDrawnHeader>? = null
    }
}

/**
 * The Bezier radar below the list (iOS `CYLRefreshBezierRadarFooter`).
 */
open class CYLRefreshBezierRadarFooter(context: Context) : CYLRefreshDrawnFooter(CYLRefreshBezierRadarHeader(context))

/**
 * The Material spinner below the list (iOS `CYLRefreshMaterialFooter`).
 */
open class CYLRefreshMaterialFooter(context: Context) : CYLRefreshDrawnFooter(CYLRefreshMaterialHeader(context))

/**
 * The delivery box below the list (iOS `CYLRefreshDeliveryFooter`).
 */
open class CYLRefreshDeliveryFooter(context: Context) : CYLRefreshDrawnFooter(CYLRefreshDeliveryHeader(context))

/**
 * The sunrise below the list (iOS `CYLRefreshPhoenixFooter`).
 */
open class CYLRefreshPhoenixFooter(context: Context) : CYLRefreshDrawnFooter(CYLRefreshPhoenixHeader(context))

/**
 * The plane among clouds below the list (iOS `CYLRefreshTaurusFooter`).
 */
open class CYLRefreshTaurusFooter(context: Context) : CYLRefreshDrawnFooter(CYLRefreshTaurusHeader(context))
