// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header.falsify

import android.content.Context
import android.graphics.Canvas
import android.graphics.DashPathEffect
import android.graphics.Paint
import android.util.AttributeSet
import android.view.Gravity
import android.view.View.MeasureSpec.EXACTLY
import android.view.View.MeasureSpec.makeMeasureSpec
import android.widget.TextView
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.simple.SimpleComponent
import com.scwang.smart.refresh.layout.util.SmartUtil

/**
 * The empty header and footer's base: draws nothing at run time and a dashed outline in the layout editor
 * (`FalsifyAbstract`).
 */
abstract class FalsifyAbstract protected constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) :
    SimpleComponent(context, attrs, defStyleAttr), RefreshHeader {

    /**
     * The layout's kernel, once initialized.
     */
    @JvmField protected var mRefreshKernel: RefreshKernel? = null

    init {
        // Draws nothing: hidden from accessibility services.
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO_HIDE_DESCENDANTS
    }

    override fun dispatchDraw(canvas: Canvas) {
        super.dispatchDraw(canvas)
        // Only in the layout editor's preview, so its cost does not matter.
        if (!isInEditMode) return
        val d = SmartUtil.dp2px(5f)
        val paint = Paint().apply {
            style = Paint.Style.STROKE
            color = 0xcccccccc.toInt()
            strokeWidth = SmartUtil.dp2px(1f).toFloat()
            pathEffect = DashPathEffect(floatArrayOf(d.toFloat(), d.toFloat(), d.toFloat(), d.toFloat()), 1f)
        }
        canvas.drawRect(d.toFloat(), d.toFloat(), (width - d).toFloat(), (bottom - d).toFloat(), paint)
        val textView = TextView(context)
        textView.text = context.getString(R.string.srl_component_falsify, javaClass.simpleName, SmartUtil.px2dp(height))
        textView.setTextColor(0xcccccccc.toInt())
        textView.gravity = Gravity.CENTER
        textView.measure(makeMeasureSpec(width, EXACTLY), makeMeasureSpec(height, EXACTLY))
        textView.layout(0, 0, width, height)
        textView.draw(canvas)
    }

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        mRefreshKernel = kernel
    }

    override fun onReleased(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        mRefreshKernel?.let {
            it.setState(RefreshState.None)
            it.setState(RefreshState.RefreshFinish)
        }
    }
}
