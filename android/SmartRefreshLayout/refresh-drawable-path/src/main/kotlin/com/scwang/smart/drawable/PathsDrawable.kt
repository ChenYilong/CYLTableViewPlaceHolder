// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.drawable

import android.graphics.Canvas
import android.graphics.Path
import android.graphics.Rect
import android.graphics.RectF
import android.graphics.Region
import com.scwang.smart.drawable.path.PathParser

/**
 * A drawable of SVG paths, one color per path, that scales to its bounds (`PathsDrawable`).
 */
open class PathsDrawable : PaintDrawable() {

    /**
     * The paths' width.
     */
    @JvmField protected var mWidth = 1

    /**
     * The paths' height.
     */
    @JvmField protected var mHeight = 1

    /**
     * The paths' left.
     */
    @JvmField protected var mStartX = 0

    /**
     * The paths' top.
     */
    @JvmField protected var mStartY = 0

    /**
     * The width the paths were parsed at.
     */
    @JvmField protected var mOriginWidth = 0

    /**
     * The height the paths were parsed at.
     */
    @JvmField protected var mOriginHeight = 0

    /**
     * The paths at the current size.
     */
    @JvmField protected var mPaths: List<Path>? = null

    /**
     * The paths' colors.
     */
    @JvmField protected var mColors: MutableList<Int>? = null

    /**
     * The paths as parsed.
     */
    @JvmField protected var mltOriginPath: MutableList<Path>? = null

    /**
     * The SVG path data.
     */
    @JvmField protected var mltOriginSvg: MutableList<String>? = null

    /**
     * Measures the paths' bounds; false when they are empty.
     */
    protected open fun onMeasure(): Boolean {
        var top: Int? = null
        var left: Int? = null
        var right: Int? = null
        var bottom: Int? = null
        mPaths?.forEach { path ->
            // Path bounds instead of a Region clipped to MAX_CLIP: Skia rejects a clip of ±Int.MAX_VALUE and returns an
            // empty region (seen on API 34 native graphics), so every path measured empty.
            val b = Rect().also { r -> RectF().also { path.computeBounds(it, true) }.roundOut(r) }
            top = minOf(top ?: b.top, b.top)
            left = minOf(left ?: b.left, b.left)
            right = maxOf(right ?: b.right, b.right)
            bottom = maxOf(bottom ?: b.bottom, b.bottom)
        }
        mStartX = left ?: 0
        mStartY = top ?: 0
        mWidth = right?.let { it - mStartX } ?: 0
        mHeight = bottom?.let { it - mStartY } ?: 0
        if (mOriginWidth == 0) mOriginWidth = mWidth
        if (mOriginHeight == 0) mOriginHeight = mHeight
        val bounds = bounds
        if (mWidth == 0 || mHeight == 0) {
            if (mOriginWidth == 0) mOriginWidth = 1
            if (mOriginHeight == 0) mOriginHeight = 1
            mWidth = 1
            mHeight = 1
            return false
        }
        super.setBounds(bounds.left, bounds.top, bounds.left + mWidth, bounds.top + mHeight)
        return true
    }

    override fun setBounds(left: Int, top: Int, right: Int, bottom: Int) {
        val width = right - left
        val height = bottom - top
        val origin = mltOriginPath
        if (origin != null && origin.isNotEmpty() && (width != mWidth || height != mHeight)) {
            val ox = mStartX
            val oy = mStartY
            mPaths = PathParser.transformScale(1f * width / mOriginWidth, 1f * height / mOriginHeight, origin, mltOriginSvg)
            if (!onMeasure()) {
                mWidth = width
                mHeight = height
                mStartX = (1f * ox * width / mOriginWidth).toInt()
                mStartY = (1f * oy * height / mOriginHeight).toInt()
                super.setBounds(left, top, right, bottom)
            }
        } else {
            super.setBounds(left, top, right, bottom)
        }
    }

    override fun setBounds(bounds: Rect) = setBounds(bounds.left, bounds.top, bounds.right, bounds.bottom)

    /**
     * Parses SVG path data; false when the paths are empty.
     */
    open fun parserPaths(vararg paths: String): Boolean {
        mOriginWidth = 0
        mOriginHeight = 0
        val svgs = ArrayList<String>()
        val parsed = ArrayList<Path>()
        for (path in paths) {
            svgs.add(path)
            PathParser.createPathFromPathData(path)?.let { parsed.add(it) }
        }
        mltOriginSvg = svgs
        mltOriginPath = parsed
        mPaths = parsed
        return onMeasure()
    }

    /**
     * Declares the paths' original box.
     */
    open fun declareOriginal(startX: Int, startY: Int, width: Int, height: Int) {
        mStartX = startX
        mStartY = startY
        mOriginWidth = width
        mWidth = width
        mOriginHeight = height
        mHeight = height
        val bounds = bounds
        super.setBounds(bounds.left, bounds.top, bounds.left + width, bounds.top + height)
    }

    /**
     * The paths' colors, in order.
     */
    open fun parserColors(vararg colors: Int) {
        mColors = colors.toMutableList()
    }

    override fun draw(canvas: Canvas) {
        val bounds = bounds
        if (mPaint.alpha == 0xFF) {
            canvas.save()
            canvas.translate((bounds.left - mStartX).toFloat(), (bounds.top - mStartY).toFloat())
            mPaths?.let { paths ->
                drawPaths(canvas, paths)
                mPaint.alpha = 0xFF
            }
            canvas.restore()
        } else {
            // Issues #1405, #1533, #1535: a translucent drawable draws through a layer of its alpha instead of a
            // cached bitmap the size of its bounds. Large bounds no longer allocate a bitmap too large to draw (or run
            // out of memory), and a changed path or color is no longer drawn from a stale cache.
            val alpha = mPaint.alpha
            canvas.saveLayerAlpha(bounds.left.toFloat(), bounds.top.toFloat(), bounds.right.toFloat(), bounds.bottom.toFloat(), alpha)
            canvas.translate((bounds.left - mStartX).toFloat(), (bounds.top - mStartY).toFloat())
            mPaths?.let { paths ->
                mPaint.alpha = 0xFF
                drawPaths(canvas, paths)
            }
            mPaint.alpha = alpha
            canvas.restore()
        }
    }

    private fun drawPaths(canvas: Canvas, paths: List<Path>) {
        val colors = mColors
        for (i in paths.indices) {
            if (colors != null && i < colors.size) mPaint.color = colors[i]
            canvas.drawPath(paths[i], mPaint)
        }
    }

    /**
     * Scales the bounds to [width], keeping the aspect ratio.
     */
    open fun setGeometricWidth(width: Int) = scaleBounds(1f * width / bounds.width())

    /**
     * Scales the bounds to [height], keeping the aspect ratio.
     */
    open fun setGeometricHeight(height: Int) = scaleBounds(1f * height / bounds.height())

    private fun scaleBounds(rate: Float) {
        // Empty bounds give an infinite rate, which made the bounds (and the drawing) huge.
        if (rate.isNaN() || rate.isInfinite()) return
        val b = bounds
        setBounds((b.left * rate).toInt(), (b.top * rate).toInt(), (b.right * rate).toInt(), (b.bottom * rate).toInt())
    }

    /**
     * Kept from the Java version for subclasses.
     */
    companion object {
        /**
         * The region the Java version measured paths with; kept for subclasses.
         */
        @JvmStatic protected val REGION = Region()

        /**
         * The clip for measuring paths: everything.
         */
        @JvmStatic protected val MAX_CLIP = Region(Int.MIN_VALUE, Int.MIN_VALUE, Int.MAX_VALUE, Int.MAX_VALUE)
    }
}
