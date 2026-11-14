// android-Ultra-Pull-To-Refresh (https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh, MIT, Copyright (c) 2015
// liaohuqiu.net) translated to Kotlin, with the open pull requests taken in docs/Android-Port.md.
package `in`.srain.cube.views.ptr.header

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.PointF
import android.util.AttributeSet
import android.view.View
import android.view.animation.Animation
import android.view.animation.Transformation
import `in`.srain.cube.views.ptr.PtrFrameLayout
import `in`.srain.cube.views.ptr.PtrUIHandler
import `in`.srain.cube.views.ptr.R
import `in`.srain.cube.views.ptr.indicator.PtrIndicator
import `in`.srain.cube.views.ptr.util.PtrLocalDisplay
import kotlin.math.ceil
import kotlin.math.max
import kotlin.math.min
import kotlin.random.Random

/**
 * One line of the [StoreHouseHeader]: it flies in with the pull and fades while refreshing (`StoreHouseBarItem`).
 */
class StoreHouseBarItem(
    /**
     * The line's index in the text.
     */
    @JvmField val index: Int,
    start: PointF,
    end: PointF,
    color: Int,
    lineWidth: Int,
) : Animation() {

    /**
     * The line's middle.
     */
    @JvmField
    val midPoint = PointF((start.x + end.x) / 2, (start.y + end.y) / 2)

    /**
     * The sideways distance the line flies in from.
     */
    @JvmField
    var translationX = 0f

    private val paint = Paint()
    private var fromAlpha = 1.0f
    private var toAlpha = 0.4f
    private val cStartPoint = PointF(start.x - midPoint.x, start.y - midPoint.y)
    private val cEndPoint = PointF(end.x - midPoint.x, end.y - midPoint.y)

    init {
        setColor(color)
        setLineWidth(lineWidth)
        paint.isAntiAlias = true
        paint.style = Paint.Style.STROKE
    }

    /**
     * The line's width in pixels.
     */
    fun setLineWidth(width: Int) {
        paint.strokeWidth = width.toFloat()
    }

    /**
     * The line's color.
     */
    fun setColor(color: Int) {
        paint.color = color
    }

    /**
     * Picks a new random distance to fly in from, up to [horizontalRandomness].
     */
    fun resetPosition(horizontalRandomness: Int) {
        translationX = if (horizontalRandomness > 0) (-Random.nextInt(horizontalRandomness) + horizontalRandomness).toFloat() else 0f
    }

    override fun applyTransformation(interpolatedTime: Float, t: Transformation) {
        setAlpha(fromAlpha + (toAlpha - fromAlpha) * interpolatedTime)
    }

    /**
     * Fades from [fromAlpha] to [toAlpha].
     */
    fun start(fromAlpha: Float, toAlpha: Float) {
        this.fromAlpha = fromAlpha
        this.toAlpha = toAlpha
        super.start()
    }

    /**
     * The line's opacity, 0 to 1.
     */
    fun setAlpha(alpha: Float) {
        paint.alpha = (alpha * 255).toInt()
    }

    /**
     * Draws the line around the canvas's origin.
     */
    fun draw(canvas: Canvas) {
        canvas.drawLine(cStartPoint.x, cStartPoint.y, cEndPoint.x, cEndPoint.y, paint)
    }
}

/**
 * The StoreHouse header: the letters of a text fly in as lines with the pull and shimmer while refreshing
 * (`StoreHouseHeader`). Call [initWithString] (or [initWithStringArray] / [initWithPointList]) first.
 */
class StoreHouseHeader @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : View(context, attrs, defStyleAttr), PtrUIHandler {

    /**
     * The lines.
     */
    @JvmField
    val mItemList = ArrayList<StoreHouseBarItem>()

    private var lineWidth: Int
    private var scale = 1f
    private var dropHeight: Int
    private val internalAnimationFactor = 0.7f
    private val horizontalRandomness: Int
    private var progress = 0f
    private var drawZoneWidth = 0
    private var drawZoneHeight = 0
    private var offsetX = 0
    private var offsetY = 0
    private val barDarkAlpha = 0.4f
    private val fromAlpha = 1.0f
    private val toAlpha = 0.4f
    private var loadingAniDuration = 1000
    private var loadingAniSegDuration = 1000
    private val loadingAniItemDuration = 400
    private val transformation = Transformation()
    private var isInLoading = false
    private val aniController = AniController()
    private var textColor = Color.WHITE
    private var text: String? = null

    init {
        PtrLocalDisplay.init(context)
        lineWidth = PtrLocalDisplay.dp2px(1f)
        dropHeight = PtrLocalDisplay.dp2px(40f)
        horizontalRandomness = PtrLocalDisplay.SCREEN_WIDTH_PIXELS / 2
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    /**
     * The duration of one shimmer, in milliseconds.
     */
    fun getLoadingAniDuration(): Int = loadingAniDuration

    /**
     * Sets the duration of one shimmer, in milliseconds.
     */
    fun setLoadingAniDuration(duration: Int) {
        loadingAniDuration = duration
        loadingAniSegDuration = duration
    }

    /**
     * The lines' width in pixels.
     */
    fun setLineWidth(width: Int): StoreHouseHeader {
        lineWidth = width
        mItemList.forEach { it.setLineWidth(width) }
        return this
    }

    /**
     * The lines' color (issue #306).
     */
    fun setTextColor(color: Int): StoreHouseHeader {
        textColor = color
        mItemList.forEach { it.setColor(color) }
        return this
    }

    /**
     * The height the lines drop from.
     */
    fun setDropHeight(height: Int): StoreHouseHeader {
        dropHeight = height
        return this
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val height = topOffset + drawZoneHeight + bottomOffset
        super.onMeasure(widthMeasureSpec, MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
        offsetX = (measuredWidth - drawZoneWidth) / 2
        offsetY = topOffset
        dropHeight = topOffset
    }

    private val topOffset: Int
        get() = paddingTop + PtrLocalDisplay.dp2px(10f)

    private val bottomOffset: Int
        get() = paddingBottom + PtrLocalDisplay.dp2px(10f)

    /**
     * Shows [str] at font size 25.
     */
    fun initWithString(str: String) = initWithString(str, 25)

    /**
     * Shows [str] at [fontSize].
     */
    fun initWithString(str: String, fontSize: Int) {
        text = str
        initWithPointList(StoreHousePath.getPath(str, fontSize * 0.01f, 14))
    }

    /**
     * Shows the lines of a string array resource, each item "x1,y1,x2,y2".
     */
    fun initWithStringArray(id: Int) {
        val points = resources.getStringArray(id)
        initWithPointList(ArrayList(points.map { line -> FloatArray(4) { j -> line.split(",")[j].trim().toFloat() } }))
    }

    /**
     * The lines' scale; set it before [initWithString].
     */
    fun getScale(): Float = scale

    /**
     * Sets the lines' scale; set it before [initWithString].
     */
    fun setScale(scale: Float) {
        this.scale = scale
    }

    /**
     * Shows lines, each {x1, y1, x2, y2} in dp.
     */
    fun initWithPointList(pointList: ArrayList<FloatArray>) {
        var drawWidth = 0f
        var drawHeight = 0f
        val shouldLayout = mItemList.isNotEmpty()
        mItemList.clear()
        pointList.forEachIndexed { i, line ->
            val startPoint = PointF(PtrLocalDisplay.dp2px(line[0]) * scale, PtrLocalDisplay.dp2px(line[1]) * scale)
            val endPoint = PointF(PtrLocalDisplay.dp2px(line[2]) * scale, PtrLocalDisplay.dp2px(line[3]) * scale)
            drawWidth = max(drawWidth, max(startPoint.x, endPoint.x))
            drawHeight = max(drawHeight, max(startPoint.y, endPoint.y))
            val item = StoreHouseBarItem(i, startPoint, endPoint, textColor, lineWidth)
            item.resetPosition(horizontalRandomness)
            mItemList += item
        }
        drawZoneWidth = ceil(drawWidth).toInt()
        drawZoneHeight = ceil(drawHeight).toInt()
        if (shouldLayout) requestLayout()
    }

    private fun beginLoading() {
        isInLoading = true
        aniController.start()
        invalidate()
    }

    private fun loadFinish() {
        isInLoading = false
        aniController.stop()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        val c1 = canvas.save()
        val len = mItemList.size
        for (i in 0 until len) {
            canvas.save()
            val item = mItemList[i]
            var ox = offsetX + item.midPoint.x
            var oy = offsetY + item.midPoint.y
            if (isInLoading) {
                item.getTransformation(drawingTime, transformation)
                canvas.translate(ox, oy)
            } else {
                if (progress == 0f) {
                    item.resetPosition(horizontalRandomness)
                    canvas.restore()
                    continue
                }
                val startPadding = (1 - internalAnimationFactor) * i / len
                val endPadding = 1 - internalAnimationFactor - startPadding
                if (progress == 1f || progress >= 1 - endPadding) {
                    canvas.translate(ox, oy)
                    item.setAlpha(barDarkAlpha)
                } else {
                    val realProgress = if (progress <= startPadding) 0f else min(1f, (progress - startPadding) / internalAnimationFactor)
                    ox += item.translationX * (1 - realProgress)
                    oy += -dropHeight * (1 - realProgress)
                    val matrix = Matrix()
                    matrix.postRotate(360 * realProgress)
                    matrix.postScale(realProgress, realProgress)
                    matrix.postTranslate(ox, oy)
                    item.setAlpha(barDarkAlpha * realProgress)
                    canvas.concat(matrix)
                }
            }
            item.draw(canvas)
            canvas.restore()
        }
        if (isInLoading) invalidate()
        canvas.restoreToCount(c1)
    }

    private fun resetItems() {
        mItemList.forEach { it.resetPosition(horizontalRandomness) }
    }

    override fun onUIReset(frame: PtrFrameLayout) {
        loadFinish()
        resetItems()
        // Redraw after a reset, so the next pull starts from the scattered lines (pull request #177).
        progress = 0f
        invalidate()
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    override fun onUIRefreshPrepare(frame: PtrFrameLayout) {
        // An auto refresh right after the last one starts from the scattered lines, not the last frame (issue #141).
        loadFinish()
        resetItems()
        invalidate()
    }

    override fun onUIRefreshBegin(frame: PtrFrameLayout) {
        beginLoading()
        contentDescription = listOfNotNull(text, context.getString(R.string.cube_ptr_refreshing)).joinToString(", ")
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
    }

    override fun onUIRefreshComplete(frame: PtrFrameLayout) {
        loadFinish()
    }

    override fun onUIPositionChange(frame: PtrFrameLayout, isUnderTouch: Boolean, status: Byte, ptrIndicator: PtrIndicator) {
        progress = min(1f, ptrIndicator.getCurrentPercent())
        invalidate()
    }

    /**
     * YES while the lines shimmer.
     */
    val isLoading: Boolean
        get() = isInLoading

    private inner class AniController : Runnable {
        private var tick = 0
        private var countPerSeg = 0
        private var segCount = 0
        private var interval = 0
        private var running = true

        fun start() {
            // Nothing to animate before initWithString (issue #150).
            if (mItemList.isEmpty()) return
            running = true
            tick = 0
            interval = max(1, loadingAniDuration / mItemList.size)
            countPerSeg = max(1, loadingAniSegDuration / interval)
            segCount = mItemList.size / countPerSeg + 1
            run()
        }

        override fun run() {
            if (mItemList.isEmpty()) return
            val pos = tick % countPerSeg
            for (i in 0 until segCount) {
                var index = i * countPerSeg + pos
                if (index > tick) continue
                index %= mItemList.size
                val item = mItemList[index]
                item.fillAfter = false
                item.isFillEnabled = true
                item.fillBefore = false
                item.duration = loadingAniItemDuration.toLong()
                item.start(fromAlpha, toAlpha)
            }
            tick++
            if (running) postDelayed(this, interval.toLong())
        }

        fun stop() {
            running = false
            removeCallbacks(this)
        }
    }
}
