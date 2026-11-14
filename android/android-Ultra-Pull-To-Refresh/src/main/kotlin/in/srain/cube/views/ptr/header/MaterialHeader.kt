// android-Ultra-Pull-To-Refresh (https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh, MIT, Copyright (c) 2015
// liaohuqiu.net) translated to Kotlin, with the open pull requests taken in docs/Android-Port.md.
package `in`.srain.cube.views.ptr.header

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.View
import android.view.animation.Animation
import android.view.animation.Transformation
import androidx.swiperefreshlayout.widget.CircularProgressDrawable
import `in`.srain.cube.views.ptr.PtrFrameLayout
import `in`.srain.cube.views.ptr.PtrUIHandler
import `in`.srain.cube.views.ptr.PtrUIHandlerHook
import `in`.srain.cube.views.ptr.R
import `in`.srain.cube.views.ptr.indicator.PtrIndicator
import kotlin.math.min

/**
 * The Material spinner of the [MaterialHeader]: a 40 dp circle with an arc and an arrow (`MaterialProgressDrawable`).
 * The source carried a copy of the support library's drawable; this one is AndroidX's maintained
 * [CircularProgressDrawable], whose spin has no speed jump after the first turn (issue #192).
 */
class MaterialProgressDrawable(context: Context, @Suppress("UNUSED_PARAMETER") parent: View?) : CircularProgressDrawable(context) {

    private val size = (40 * context.resources.displayMetrics.density).toInt()
    private val circlePaint = Paint(Paint.ANTI_ALIAS_FLAG)
    private var circleAlpha = 255

    init {
        setStyle(DEFAULT)
        circlePaint.color = Color.WHITE
    }

    /**
     * The circle's color behind the arc (pull request #273). Default white.
     */
    override fun setBackgroundColor(color: Int) {
        circlePaint.color = color
        invalidateSelf()
    }

    /**
     * Shows or hides the arrow at the arc's end.
     */
    fun showArrow(show: Boolean) {
        arrowEnabled = show
    }

    override fun setAlpha(alpha: Int) {
        circleAlpha = alpha
        super.setAlpha(alpha)
    }

    override fun draw(canvas: Canvas) {
        circlePaint.alpha = circleAlpha
        val r = bounds
        canvas.drawCircle(r.exactCenterX(), r.exactCenterY(), min(r.width(), r.height()) / 2f, circlePaint)
        super.draw(canvas)
    }

    override fun getIntrinsicWidth(): Int = size

    override fun getIntrinsicHeight(): Int = size
}

/**
 * The Material header: the spinner grows with the pull and spins while refreshing (`MaterialHeader`). Call
 * [setPtrFrameLayout] so it can shrink before the header closes.
 */
class MaterialHeader @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : View(context, attrs, defStyleAttr), PtrUIHandler {

    private val drawable = MaterialProgressDrawable(context, this)
    private var scale = 1f
    private var spinning = false
    private var ptrFrameLayout: PtrFrameLayout? = null
    private val scaleAnimation = object : Animation() {
        override fun applyTransformation(interpolatedTime: Float, t: Transformation) {
            scale = 1f - interpolatedTime
            drawable.alpha = (255 * scale).toInt()
            invalidate()
        }
    }

    init {
        drawable.setBackgroundColor(Color.WHITE)
        drawable.callback = this
        // Accessibility: the spinner reads as "Updating..." while it spins.
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    /**
     * Lets the header shrink its spinner before [layout] closes it.
     */
    fun setPtrFrameLayout(layout: PtrFrameLayout) {
        val hook = object : PtrUIHandlerHook() {
            override fun run() {
                startAnimation(scaleAnimation)
            }
        }
        scaleAnimation.duration = 200
        scaleAnimation.setAnimationListener(object : Animation.AnimationListener {
            override fun onAnimationStart(animation: Animation) {}
            override fun onAnimationEnd(animation: Animation) = hook.resume()
            override fun onAnimationRepeat(animation: Animation) {}
        })
        ptrFrameLayout = layout
        layout.setRefreshCompleteHook(hook)
    }

    override fun invalidateDrawable(dr: Drawable) {
        if (dr === drawable) invalidate() else super.invalidateDrawable(dr)
    }

    /**
     * The arc's colors, in turn.
     */
    fun setColorSchemeColors(colors: IntArray) {
        drawable.setColorSchemeColors(*colors)
        invalidate()
    }

    /**
     * The circle's color behind the arc (pull request #273).
     */
    fun setCustomMaterialHeaderBackground(color: Int) {
        drawable.setBackgroundColor(color)
        invalidate()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val height = drawable.intrinsicHeight + paddingTop + paddingBottom
        super.onMeasure(widthMeasureSpec, MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        val size = drawable.intrinsicHeight
        drawable.setBounds(0, 0, size, size)
    }

    override fun onDraw(canvas: Canvas) {
        val saveCount = canvas.save()
        val rect = drawable.bounds
        val l = paddingLeft + (measuredWidth - drawable.intrinsicWidth) / 2
        canvas.translate(l.toFloat(), paddingTop.toFloat())
        canvas.scale(scale, scale, rect.exactCenterX(), rect.exactCenterY())
        drawable.draw(canvas)
        canvas.restoreToCount(saveCount)
    }

    override fun onUIReset(frame: PtrFrameLayout) {
        scale = 1f
        drawable.stop()
        spinning = false
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    override fun onUIRefreshPrepare(frame: PtrFrameLayout) {
        // A pull right after the last one (enabledNextPtrAtOnce) starts from a full-size spinner, not a blank or
        // shrunken one (issues #129 and #186).
        clearAnimation()
        scale = 1f
        drawable.alpha = 255
    }

    override fun onUIRefreshBegin(frame: PtrFrameLayout) {
        scale = 1f
        drawable.alpha = 255
        drawable.start()
        spinning = true
        contentDescription = context.getString(R.string.cube_ptr_refreshing)
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
    }

    override fun onUIRefreshComplete(frame: PtrFrameLayout) {
        drawable.stop()
        spinning = false
        contentDescription = context.getString(R.string.cube_ptr_refresh_complete)
    }

    override fun onUIPositionChange(frame: PtrFrameLayout, isUnderTouch: Boolean, status: Byte, ptrIndicator: PtrIndicator) {
        val percent = min(1f, ptrIndicator.getCurrentPercent())
        if (status == PtrFrameLayout.PTR_STATUS_PREPARE) {
            drawable.alpha = (255 * percent).toInt()
            drawable.showArrow(true)
            drawable.setStartEndTrim(0f, min(0.8f, percent * .8f))
            drawable.arrowScale = min(1f, percent)
            drawable.progressRotation = (-0.25f + .4f * percent + percent * 2) * .5f
            invalidate()
        }
    }

    /**
     * YES while the spinner spins.
     */
    val isSpinning: Boolean
        get() = spinning

    /**
     * The spinner's current scale (1 = full size).
     */
    val spinnerScale: Float
        get() = scale
}
