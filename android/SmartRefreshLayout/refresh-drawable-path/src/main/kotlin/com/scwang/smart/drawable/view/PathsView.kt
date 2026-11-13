// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.drawable.view

import android.content.Context
import android.graphics.Canvas
import android.util.AttributeSet
import android.view.View
import com.scwang.smart.drawable.PathsDrawable
import kotlin.math.max

/**
 * A view that draws SVG paths; a string tag is parsed as path data (`PathsView`).
 */
open class PathsView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : View(context, attrs) {

    /**
     * The drawable that draws the paths.
     */
    @JvmField protected var mPathsDrawable = PathsDrawable()

    init {
        // A decoration: hidden from accessibility services unless the app gives it a description.
        if (contentDescription == null) importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    override fun onFinishInflate() {
        super.onFinishInflate()
        (tag as? String)?.let { parserPaths(it) }
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val b = mPathsDrawable.bounds
        super.setMeasuredDimension(
            resolveSize(b.width() + paddingLeft + paddingRight, widthMeasureSpec),
            resolveSize(b.height() + paddingTop + paddingBottom, heightMeasureSpec),
        )
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        super.onLayout(changed, left, top, right, bottom)
        mPathsDrawable.setBounds(
            paddingLeft, paddingTop,
            max(right - left - paddingRight, paddingLeft),
            max(bottom - top - paddingTop, paddingTop),
        )
    }

    override fun onDraw(canvas: Canvas) {
        mPathsDrawable.draw(canvas)
    }

    /**
     * Parses SVG path data; false when the paths are empty.
     */
    open fun parserPaths(vararg paths: String): Boolean = mPathsDrawable.parserPaths(*paths)

    /**
     * The paths' colors, in order.
     */
    open fun parserColors(vararg colors: Int) = mPathsDrawable.parserColors(*colors)
}
