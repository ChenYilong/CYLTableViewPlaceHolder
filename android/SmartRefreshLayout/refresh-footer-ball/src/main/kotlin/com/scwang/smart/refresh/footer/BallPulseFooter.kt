// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.footer

import android.animation.TimeInterpolator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.AttributeSet
import android.view.animation.AccelerateDecelerateInterpolator
import androidx.annotation.ColorInt
import androidx.core.graphics.ColorUtils
import com.scwang.smart.refresh.footer.ball.R
import com.scwang.smart.refresh.layout.api.RefreshFooter
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.simple.SimpleComponent
import com.scwang.smart.refresh.layout.util.SmartUtil
import kotlin.math.min

/**
 * The footer with three pulsing balls (`BallPulseFooter`).
 */
open class BallPulseFooter @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    SimpleComponent(context, attrs, 0), RefreshFooter {

    /**
     * True once the app set the normal color.
     */
    @JvmField protected var mManualNormalColor = false

    /**
     * True once the app set the animating color.
     */
    @JvmField protected var mManualAnimationColor = false

    /**
     * The balls' paint.
     */
    @JvmField protected var mPaint = Paint().apply {
        color = Color.WHITE
        style = Paint.Style.FILL
        isAntiAlias = true
    }

    /**
     * The balls' color at rest.
     */
    @JvmField protected var mNormalColor = 0xffeeeeee.toInt()

    /**
     * The balls' color while loading.
     */
    @JvmField protected var mAnimatingColor = 0xffe75946.toInt()

    /**
     * The space between the balls.
     */
    @JvmField protected var mCircleSpacing: Float

    /**
     * When the animation started, in ms.
     */
    @JvmField protected var mStartTime = 0L

    /**
     * True while animating.
     */
    @JvmField protected var mIsStarted = false

    /**
     * The pulse's interpolator.
     */
    @JvmField protected var mInterpolator: TimeInterpolator = AccelerateDecelerateInterpolator()

    init {
        minimumHeight = SmartUtil.dp2px(60f)
        val ta = context.obtainStyledAttributes(attrs, R.styleable.BallPulseFooter)
        mSpinnerStyle = SpinnerStyle.values[ta.getInt(R.styleable.BallPulseFooter_srlClassicsSpinnerStyle, SpinnerStyle.Translate.ordinal)]
        if (ta.hasValue(R.styleable.BallPulseFooter_srlNormalColor)) setNormalColor(ta.getColor(R.styleable.BallPulseFooter_srlNormalColor, 0))
        if (ta.hasValue(R.styleable.BallPulseFooter_srlAnimatingColor)) setAnimatingColor(ta.getColor(R.styleable.BallPulseFooter_srlAnimatingColor, 0))
        ta.recycle()
        mCircleSpacing = SmartUtil.dp2px(4f).toFloat()
        // Accessibility: the footer is a polite live region that reads "Loading" / "Loaded"; hidden while idle.
        accessibilityLiveRegion = ACCESSIBILITY_LIVE_REGION_POLITE
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    override fun dispatchDraw(canvas: Canvas) {
        val radius = (min(width, height) - mCircleSpacing * 2) / 6
        val x = width / 2f - (radius * 2 + mCircleSpacing)
        val y = height / 2f
        val now = System.currentTimeMillis()
        for (i in 0 until 3) {
            val time = now - mStartTime - 120 * (i + 1)
            val percent = mInterpolator.getInterpolation(if (time > 0) (time % 750) / 750f else 0f)
            canvas.save()
            canvas.translate(x + radius * 2 * i + mCircleSpacing * i, y)
            val scale = if (percent < 0.5) 1 - percent * 2 * 0.7f else percent * 2 * 0.7f - 0.4f
            canvas.scale(scale, scale)
            canvas.drawCircle(0f, 0f, radius, mPaint)
            canvas.restore()
        }
        super.dispatchDraw(canvas)
        if (mIsStarted) invalidate()
    }

    override fun onStartAnimator(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        if (mIsStarted) return
        invalidate()
        mIsStarted = true
        mStartTime = System.currentTimeMillis()
        mPaint.color = mAnimatingColor
        contentDescription = context.getString(R.string.srl_ball_loading)
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        mIsStarted = false
        mStartTime = 0
        mPaint.color = mNormalColor
        contentDescription = context.getString(R.string.srl_ball_loaded)
        return 0
    }

    @Deprecated("Only called by the layout; use setNormalColor and setAnimatingColor.")
    override fun setPrimaryColors(@ColorInt vararg colors: Int) {
        if (!mManualAnimationColor && colors.size > 1) {
            setAnimatingColor(colors[0])
            mManualAnimationColor = false
        }
        if (!mManualNormalColor) {
            if (colors.size > 1) {
                setNormalColor(colors[1])
            } else if (colors.isNotEmpty()) {
                setNormalColor(ColorUtils.compositeColors(0x99ffffff.toInt(), colors[0]))
            }
            mManualNormalColor = false
        }
    }

    /**
     * How the footer moves.
     */
    open fun setSpinnerStyle(mSpinnerStyle: SpinnerStyle?): BallPulseFooter {
        this.mSpinnerStyle = mSpinnerStyle
        return this
    }

    /**
     * The balls' color at rest.
     */
    open fun setNormalColor(@ColorInt color: Int): BallPulseFooter {
        mNormalColor = color
        mManualNormalColor = true
        if (!mIsStarted) mPaint.color = color
        return this
    }

    /**
     * The balls' color while loading.
     */
    open fun setAnimatingColor(@ColorInt color: Int): BallPulseFooter {
        mAnimatingColor = color
        mManualAnimationColor = true
        if (mIsStarted) mPaint.color = color
        return this
    }
}
