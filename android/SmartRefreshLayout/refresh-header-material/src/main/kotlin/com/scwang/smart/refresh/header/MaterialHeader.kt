// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin, with the pull request #1095 and issue fixes of the Java copy (docs/Android-Port.md); the JVM signatures match
// the Java version.
package com.scwang.smart.refresh.header

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.util.AttributeSet
import android.widget.ImageView
import androidx.annotation.ColorInt
import androidx.annotation.ColorRes
import androidx.core.content.ContextCompat
import com.scwang.smart.refresh.header.material.CircleImageView
import com.scwang.smart.refresh.header.material.MaterialProgressDrawable
import com.scwang.smart.refresh.header.material.R
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.simple.SimpleComponent
import com.scwang.smart.refresh.layout.util.SmartUtil
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow

/**
 * The Material header: SwipeRefreshLayout's spinner in a circle, optionally over a Bezier wave (`MaterialHeader`).
 */
open class MaterialHeader @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    SimpleComponent(context, attrs, 0), RefreshHeader {

    /**
     * True once refreshing finished.
     */
    @JvmField protected var mFinished = false

    /**
     * The circle's diameter in pixels.
     */
    @JvmField protected var mCircleDiameter: Int

    /**
     * The circle.
     */
    @JvmField protected var mCircleView: ImageView

    /**
     * The layout's kernel, once initialized.
     */
    @JvmField protected var mKernel: RefreshKernel? = null

    /**
     * The spinner.
     */
    @JvmField protected var mProgress: MaterialProgressDrawable

    /**
     * The wave's height.
     */
    @JvmField protected var mWaveHeight = 0

    /**
     * The header part's height.
     */
    @JvmField protected var mHeadHeight = 0

    /**
     * The header's height at initialization.
     */
    @JvmField protected var mInitHeight = 0

    /**
     * The wave's path.
     */
    @JvmField protected var mBezierPath = Path()

    /**
     * The wave's paint.
     */
    @JvmField protected var mBezierPaint = Paint().apply {
        isAntiAlias = true
        style = Paint.Style.FILL
    }

    /**
     * The layout's state.
     */
    @JvmField protected var mState: RefreshState? = null

    /**
     * Draws the Bezier wave behind the circle. Default false.
     */
    @JvmField protected var mShowBezierWave = false

    /**
     * Lets the content scroll while refreshing. Default true.
     */
    @JvmField protected var mScrollableWhenRefreshing = true

    init {
        mSpinnerStyle = SpinnerStyle.MatchLayout
        minimumHeight = SmartUtil.dp2px(100f)
        mProgress = MaterialProgressDrawable(this)
        mProgress.setColorSchemeColors(0xff0099cc.toInt(), 0xffff4444.toInt(), 0xff669900.toInt(), 0xffaa66cc.toInt(), 0xffff8800.toInt())
        mCircleView = CircleImageView(context, CIRCLE_BG_LIGHT)
        mCircleView.setImageDrawable(mProgress)
        mCircleView.alpha = 0f
        addView(mCircleView)
        mCircleDiameter = (CIRCLE_DIAMETER * resources.displayMetrics.density).toInt()
        // Accessibility: the circle reads "Refreshing" while it spins, and changes are announced.
        mCircleView.contentDescription = context.getString(R.string.srl_material_refreshing)
        mCircleView.accessibilityLiveRegion = ACCESSIBILITY_LIVE_REGION_POLITE
        mCircleView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO

        val ta = context.obtainStyledAttributes(attrs, R.styleable.MaterialHeader)
        mShowBezierWave = ta.getBoolean(R.styleable.MaterialHeader_srlShowBezierWave, mShowBezierWave)
        mScrollableWhenRefreshing = ta.getBoolean(R.styleable.MaterialHeader_srlScrollableWhenRefreshing, mScrollableWhenRefreshing)
        mBezierPaint.color = ta.getColor(R.styleable.MaterialHeader_srlPrimaryColor, 0xff11bbff.toInt())
        if (ta.hasValue(R.styleable.MaterialHeader_srlShadowRadius)) {
            val radius = ta.getDimensionPixelOffset(R.styleable.MaterialHeader_srlShadowRadius, 0)
            val color = ta.getColor(R.styleable.MaterialHeader_mhShadowColor, 0xff000000.toInt())
            mBezierPaint.setShadowLayer(radius.toFloat(), 0f, 0f, color)
            setLayerType(LAYER_TYPE_SOFTWARE, null)
        }
        mShowBezierWave = ta.getBoolean(R.styleable.MaterialHeader_mhShowBezierWave, mShowBezierWave)
        mScrollableWhenRefreshing = ta.getBoolean(R.styleable.MaterialHeader_mhScrollableWhenRefreshing, mScrollableWhenRefreshing)
        if (ta.hasValue(R.styleable.MaterialHeader_mhPrimaryColor)) {
            mBezierPaint.color = ta.getColor(R.styleable.MaterialHeader_mhPrimaryColor, 0xff11bbff.toInt())
        }
        if (ta.hasValue(R.styleable.MaterialHeader_mhShadowRadius)) {
            val radius = ta.getDimensionPixelOffset(R.styleable.MaterialHeader_mhShadowRadius, 0)
            val color = ta.getColor(R.styleable.MaterialHeader_mhShadowColor, 0xff000000.toInt())
            mBezierPaint.setShadowLayer(radius.toFloat(), 0f, 0f, color)
            setLayerType(LAYER_TYPE_SOFTWARE, null)
        }
        ta.recycle()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.setMeasuredDimension(MeasureSpec.getSize(widthMeasureSpec), MeasureSpec.getSize(heightMeasureSpec))
        mCircleView.measure(
            MeasureSpec.makeMeasureSpec(mCircleDiameter, MeasureSpec.EXACTLY),
            MeasureSpec.makeMeasureSpec(mCircleDiameter, MeasureSpec.EXACTLY),
        )
    }

    override fun onLayout(changed: Boolean, left: Int, top: Int, right: Int, bottom: Int) {
        if (childCount == 0) return
        val width = measuredWidth
        val circleWidth = mCircleView.measuredWidth
        val circleHeight = mCircleView.measuredHeight
        if (isInEditMode && mHeadHeight > 0) {
            val circleTop = mHeadHeight - circleHeight / 2
            mCircleView.layout(width / 2 - circleWidth / 2, circleTop, width / 2 + circleWidth / 2, circleTop + circleHeight)
            mProgress.showArrow(true)
            mProgress.setStartEndTrim(0f, MAX_PROGRESS_ANGLE)
            mProgress.setArrowScale(1f)
            mCircleView.alpha = 1f
            mCircleView.visibility = VISIBLE
        } else {
            mCircleView.layout(width / 2 - circleWidth / 2, -circleHeight, width / 2 + circleWidth / 2, 0)
        }
    }

    override fun dispatchDraw(canvas: Canvas) {
        if (mShowBezierWave) {
            mBezierPath.reset()
            mBezierPath.lineTo(0f, mHeadHeight.toFloat())
            mBezierPath.quadTo(measuredWidth / 2f, mHeadHeight + mWaveHeight * 1.9f, measuredWidth.toFloat(), mHeadHeight.toFloat())
            mBezierPath.lineTo(measuredWidth.toFloat(), 0f)
            canvas.drawPath(mBezierPath, mBezierPaint)
        }
        super.dispatchDraw(canvas)
    }

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        // Without the wave the content stays in place; pull request #1095: only while this header is the header.
        if (!mShowBezierWave) kernel.requestDefaultTranslationContentFor(this, false)
        if (isInEditMode) {
            mHeadHeight = height / 2
            mWaveHeight = mHeadHeight
        }
        mKernel = kernel
        mInitHeight = height
    }

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        if (mState == RefreshState.Refreshing) return
        if (mShowBezierWave) {
            mHeadHeight = min(offset, height)
            mWaveHeight = max(0, offset - height)
            postInvalidate()
        }
        if (isDragging || (!mProgress.isRunning && !mFinished)) {
            if (mState != RefreshState.Refreshing) {
                val originalDragPercent = 1f * offset / height
                val dragPercent = min(1f, abs(originalDragPercent))
                val adjustedPercent = max(dragPercent - .4f, 0f) * 5 / 3
                val extraOS = abs(offset).toFloat() - height
                val tensionSlingshotPercent = max(0f, min(extraOS, height.toFloat() * 2) / height.toFloat())
                val tensionPercent = ((tensionSlingshotPercent / 4) - (tensionSlingshotPercent / 4).pow(2)) * 2f
                val strokeStart = adjustedPercent * .8f
                mProgress.showArrow(true)
                mProgress.setStartEndTrim(0f, min(MAX_PROGRESS_ANGLE, strokeStart))
                mProgress.setArrowScale(min(1f, adjustedPercent))
                mProgress.setProgressRotation((-0.25f + .4f * adjustedPercent + tensionPercent * 2) * .5f)
            }
            val targetY = offset / 2f + mCircleDiameter / 2f
            mCircleView.translationY = min(offset.toFloat(), targetY)
            mCircleView.alpha = min(1f, 4f * offset / mCircleDiameter)
        }
    }

    override fun onStartAnimator(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        // Back in the window while still refreshing (issue #1429), the circle shrunk by onFinish shows again.
        if (mFinished) {
            mCircleView.animate().cancel()
            mCircleView.scaleX = 1f
            mCircleView.scaleY = 1f
            mFinished = false
        }
        mProgress.start()
        mCircleView.contentDescription = context.getString(R.string.srl_material_refreshing)
        mCircleView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        mState = newState
        if (newState == RefreshState.PullDownToRefresh) {
            mFinished = false
            mCircleView.visibility = VISIBLE
            mCircleView.translationY = 0f
            mCircleView.scaleX = 1f
            mCircleView.scaleY = 1f
        } else if (newState == RefreshState.None) {
            mCircleView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        }
    }

    /**
     * Issue #1600: back from the background while refreshing, the spinner runs again; the system may have dropped its
     * view animation, which froze the arc (often as a full circle).
     */
    override fun onWindowVisibilityChanged(visibility: Int) {
        super.onWindowVisibilityChanged(visibility)
        if (visibility == VISIBLE && mState == RefreshState.Refreshing && !mFinished && !mProgress.isRunning) mProgress.start()
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        mProgress.stop()
        mCircleView.animate().scaleX(0f).scaleY(0f)
        mFinished = true
        mCircleView.contentDescription = context.getString(R.string.srl_material_refreshed)
        return 0
    }

    @Deprecated("Only called by the layout; use the wave's color setters.")
    override fun setPrimaryColors(@ColorInt vararg colors: Int) {
        if (colors.isNotEmpty()) mBezierPaint.color = colors[0]
    }

    /**
     * Pull request #1095: the alpha (0 to 255) of the progress arc.
     */
    open fun setProgressAlpha(alpha: Int): MaterialHeader {
        mProgress.alpha = alpha
        return this
    }

    /**
     * The circle's color, as a resource.
     */
    open fun setProgressBackgroundColorSchemeResource(@ColorRes colorRes: Int): MaterialHeader =
        setProgressBackgroundColorSchemeColor(ContextCompat.getColor(context, colorRes))

    /**
     * The circle's color.
     */
    open fun setProgressBackgroundColorSchemeColor(@ColorInt color: Int): MaterialHeader {
        mCircleView.setBackgroundColor(color)
        return this
    }

    /**
     * The arc's colors, in turn.
     */
    open fun setColorSchemeColors(@ColorInt vararg colors: Int): MaterialHeader {
        mProgress.setColorSchemeColors(*colors)
        return this
    }

    /**
     * The arc's colors, as resources.
     */
    open fun setColorSchemeResources(@ColorRes vararg colorIds: Int): MaterialHeader =
        setColorSchemeColors(*IntArray(colorIds.size) { ContextCompat.getColor(context, colorIds[it]) })

    /**
     * The circle's size: [SIZE_LARGE] or [SIZE_DEFAULT].
     */
    open fun setSize(size: Int): MaterialHeader {
        if (size != SIZE_LARGE && size != SIZE_DEFAULT) return this
        val density = resources.displayMetrics.density
        mCircleDiameter = ((if (size == SIZE_LARGE) CIRCLE_DIAMETER_LARGE else CIRCLE_DIAMETER) * density).toInt()
        mCircleView.setImageDrawable(null)
        mProgress.updateSizes(size)
        mCircleView.setImageDrawable(mProgress)
        return this
    }

    /**
     * Draws the Bezier wave behind the circle.
     */
    open fun setShowBezierWave(show: Boolean): MaterialHeader {
        mShowBezierWave = show
        return this
    }

    /**
     * Lets the content scroll while refreshing.
     */
    open fun setScrollableWhenRefreshing(scrollable: Boolean): MaterialHeader {
        mScrollableWhenRefreshing = scrollable
        return this
    }

    override fun autoOpen(duration: Int, dragRate: Float, animationOnly: Boolean): Boolean {
        // With the wave, the layout's own auto refresh animation; also without a kernel yet.
        if (mShowBezierWave) return false
        // The kernel of this open, kept for the end of the animation (issues #1547, #1584, #1589: a null kernel there
        // crashed when animations end at once, for example with animations turned off).
        val kernel = mKernel ?: return false
        val circleView = mCircleView
        circleView.alpha = 1f
        circleView.scaleX = 0f
        circleView.scaleY = 0f
        circleView.translationY = mInitHeight / 2f + mCircleDiameter / 2f
        circleView.animate().scaleX(1f).scaleY(1f).setDuration(duration.toLong()).setListener(object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                circleView.animate().setListener(null)
                mProgress.start()
                kernel.onAutoRefreshAnimationEnd(animation, animationOnly)
            }
        })
        return true
    }

    /**
     * The sizes and the circle's defaults.
     */
    companion object {
        /**
         * The large circle.
         */
        const val SIZE_LARGE = 0

        /**
         * The default circle.
         */
        const val SIZE_DEFAULT = 1

        /**
         * The circle's light background.
         */
        @JvmStatic protected val CIRCLE_BG_LIGHT = 0xFFFAFAFA.toInt()

        /**
         * The longest arc while pulling.
         */
        @JvmStatic protected val MAX_PROGRESS_ANGLE = .8f

        /**
         * The default circle's diameter in dp.
         */
        @JvmStatic protected val CIRCLE_DIAMETER = 40

        /**
         * The large circle's diameter in dp.
         */
        @JvmStatic protected val CIRCLE_DIAMETER_LARGE = 56
    }
}
