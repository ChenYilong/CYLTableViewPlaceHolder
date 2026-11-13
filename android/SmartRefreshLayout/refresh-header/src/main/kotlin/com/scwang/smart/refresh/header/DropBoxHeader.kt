// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.animation.AccelerateInterpolator
import androidx.annotation.ColorInt
import androidx.core.graphics.ColorUtils
import com.scwang.smart.drawable.PathsDrawable
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.simple.SimpleComponent
import com.scwang.smart.refresh.layout.util.SmartUtil
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin

/**
 * A box that opens and drops files in, after "DropBox Refresh" on Dribbble (`DropBoxHeader`).
 */
open class DropBoxHeader @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    SimpleComponent(context, attrs, 0), RefreshHeader {

    /**
     * The path being built.
     */
    @JvmField protected var mPath = Path()

    /**
     * The paint.
     */
    @JvmField protected var mPaint = Paint().apply { isAntiAlias = true }

    /**
     * The box's geometry.
     */
    @JvmField protected var mBoxBody = BoxBody()

    /**
     * The current offset.
     */
    @JvmField protected var mHeight = 0

    /**
     * The box's color.
     */
    @JvmField protected var mAccentColor = 0xff6ea9ff.toInt()

    /**
     * The header's height.
     */
    @JvmField protected var mHeaderHeight = 0

    /**
     * The background color.
     */
    @JvmField protected var mBackgroundColor = 0xff283645.toInt()

    /**
     * True once all three drawings have dropped in.
     */
    @JvmField protected var mDropOutOverFlow = false

    /**
     * The first drawing.
     */
    @JvmField protected var mDrawable1: Drawable

    /**
     * The second drawing.
     */
    @JvmField protected var mDrawable2: Drawable

    /**
     * The third drawing.
     */
    @JvmField protected var mDrawable3: Drawable

    /**
     * The drop's progress, 0 to 3 (one per drawing).
     */
    @JvmField protected var mDropOutPercent = 0f

    /**
     * The lid's bounce, 0 to 1.
     */
    @JvmField protected var mReboundPercent = 0f

    /**
     * The lid's bounce animation.
     */
    @JvmField protected var mReboundAnimator: ValueAnimator? = null

    /**
     * The drop animation.
     */
    @JvmField protected var mDropOutAnimator: ValueAnimator? = null

    /**
     * The layout's state.
     */
    @JvmField protected var mState: RefreshState? = null

    /**
     * The layout's kernel, once initialized.
     */
    @JvmField protected var mKernel: RefreshKernel? = null

    init {
        minimumHeight = SmartUtil.dp2px(150f)
        mSpinnerStyle = SpinnerStyle.FixedBehind
        val ta = context.obtainStyledAttributes(attrs, R.styleable.DropBoxHeader)
        fun drawable(dh: Int, srl: Int, paths: Array<String>, colors: IntArray, x: Int, y: Int, w: Int, h: Int): Drawable =
            (if (ta.hasValue(dh)) ta.getDrawable(dh) else if (ta.hasValue(srl)) ta.getDrawable(srl) else null)
                ?: PathsDrawable().apply {
                    parserColors(*colors)
                    if (!parserPaths(*paths)) declareOriginal(x, y, w, h)
                }
        mDrawable1 = drawable(R.styleable.DropBoxHeader_dhDrawable1, R.styleable.DropBoxHeader_srlDrawable1, drawable1Paths, drawable1Colors, 2, 1, 20, 22)
        mDrawable2 = drawable(R.styleable.DropBoxHeader_dhDrawable2, R.styleable.DropBoxHeader_srlDrawable2, drawable2Paths, drawable2Colors, 8, 3, 41, 53)
        mDrawable3 = drawable(R.styleable.DropBoxHeader_dhDrawable3, R.styleable.DropBoxHeader_srlDrawable3, drawable3Paths, drawable3Colors, 2, 0, 15, 16)
        ta.recycle()
        initRefreshAccessibility()
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        val interpolator = AccelerateInterpolator()
        mReboundAnimator = ValueAnimator.ofFloat(0f, 1f, 0f).apply {
            this.interpolator = interpolator
            duration = 300
            addUpdateListener {
                mReboundPercent = it.animatedValue as Float
                invalidate()
            }
            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    if (mState == RefreshState.Refreshing) mDropOutAnimator?.start() else mDropOutPercent = 0f
                }
            })
        }
        mDropOutAnimator = ValueAnimator.ofFloat(0f, 1f).apply {
            this.interpolator = interpolator
            duration = 300
            addUpdateListener {
                val value = it.animatedValue as Float
                if (mDropOutPercent < 1 || mDropOutPercent >= 3) {
                    mDropOutPercent = value
                } else if (mDropOutPercent < 2) {
                    mDropOutPercent = 1 + value
                } else if (mDropOutPercent < 3) {
                    mDropOutPercent = 2 + value
                    if (mDropOutPercent == 3f) mDropOutOverFlow = true
                }
                invalidate()
            }
            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    mReboundAnimator?.start()
                }
            })
        }
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        mReboundAnimator?.let {
            it.removeAllUpdateListeners()
            it.removeAllListeners()
            it.cancel()
        }
        mReboundAnimator = null
        mDropOutAnimator?.let {
            it.removeAllUpdateListeners()
            it.removeAllListeners()
            it.cancel()
        }
        mDropOutAnimator = null
    }

    override fun dispatchDraw(canvas: Canvas) {
        val width = width
        val height = mHeight
        val sideLength = generateSideLength()
        val footer = mKernel?.refreshLayout?.refreshFooter?.let { this == it } == true
        // Saved in every case: the clip below must not reach the children (the Java version only saved for a footer).
        val saveCount = canvas.save()
        if (footer) canvas.translate(0f, (getHeight() - mHeight).toFloat())
        val body = generateBoxBody(width, height, sideLength)
        mPaint.color = ColorUtils.setAlphaComponent(mAccentColor, 150)
        canvas.drawPath(generateBoxBodyPath(body), mPaint)
        mPaint.color = mAccentColor
        canvas.drawPath(generateBoxCoverPath(body), mPaint)
        if (isInEditMode) mDropOutPercent = 2.5f
        if (mDropOutPercent > 0) {
            canvas.clipPath(generateClipPath(body, width))
            val drawables = arrayOf(mDrawable1, mDrawable2, mDrawable3)
            drawables.forEachIndexed { i, drawable ->
                val percent = min(max(mDropOutPercent - i, 0f), 1f)
                val bounds = drawable.bounds
                bounds.offsetTo(width / 2 - bounds.width() / 2, ((body.boxCenterY - bounds.height() / 2 + bounds.height()) * percent).toInt() - bounds.height())
                drawable.draw(canvas)
            }
            if (mDropOutOverFlow) {
                drawables.forEach { drawable ->
                    val bounds = drawable.bounds
                    bounds.offsetTo(width / 2 - bounds.width() / 2, body.boxCenterY - bounds.height() / 2)
                    drawable.draw(canvas)
                }
            }
        }
        canvas.restoreToCount(saveCount)
        super.dispatchDraw(canvas)
    }

    /**
     * The box's side, a fifth of the header's height.
     */
    protected open fun generateSideLength(): Int = mHeaderHeight / 5

    /**
     * The area above the box's opening, where the drawings show.
     */
    protected open fun generateClipPath(body: BoxBody, width: Int): Path {
        mPath.reset()
        mPath.lineTo(0f, body.boxCenterTop.toFloat())
        mPath.lineTo(body.boxLeft.toFloat(), body.boxCenterTop.toFloat())
        mPath.lineTo(body.boxCenterX.toFloat(), body.boxCenterY.toFloat())
        mPath.lineTo(body.boxRight.toFloat(), body.boxCenterTop.toFloat())
        mPath.lineTo(width.toFloat(), body.boxCenterTop.toFloat())
        mPath.lineTo(width.toFloat(), 0f)
        mPath.close()
        return mPath
    }

    /**
     * The box's geometry for the size.
     */
    protected open fun generateBoxBody(width: Int, height: Int, sideLength: Int): BoxBody =
        mBoxBody.measure(width, height, sideLength, sideLength / 2)

    /**
     * The four lid flaps, opened by the bounce.
     */
    protected open fun generateBoxCoverPath(body: BoxBody): Path {
        mPath.reset()
        val sideLength = (body.boxCenterX - body.boxLeft) * 4 / 5
        val offsetAngle = mReboundPercent * (PI * 2 / 5)
        val middleY = (body.boxBottom + body.boxTop) / 2f
        val topX = sideLength * sin(PI / 3 - offsetAngle / 2).toFloat()
        val topY = sideLength * cos(PI / 3 - offsetAngle / 2).toFloat()
        val bottomX = sideLength * sin(PI / 3 + offsetAngle).toFloat()
        val bottomY = sideLength * cos(PI / 3 + offsetAngle).toFloat()
        for (side in intArrayOf(-1, 1)) {
            val edge = (if (side < 0) body.boxLeft else body.boxRight).toFloat()
            // The upper flap.
            mPath.moveTo(edge, body.boxCenterTop.toFloat())
            mPath.lineTo(body.boxCenterX.toFloat(), body.boxTop.toFloat())
            mPath.lineTo(body.boxCenterX + side * topX, body.boxTop - topY)
            mPath.lineTo(edge + side * topX, body.boxCenterTop - topY)
            mPath.close()
            // The lower flap.
            mPath.moveTo(edge, body.boxCenterTop.toFloat())
            mPath.lineTo(body.boxCenterX.toFloat(), middleY)
            mPath.lineTo(body.boxCenterX + side * bottomX, middleY + bottomY)
            mPath.lineTo(edge + side * bottomX, body.boxCenterTop + bottomY)
            mPath.close()
        }
        return mPath
    }

    /**
     * The box's body, bulging with the bounce.
     */
    protected open fun generateBoxBodyPath(body: BoxBody): Path {
        mPath.reset()
        mPath.moveTo(body.boxLeft.toFloat(), body.boxCenterBottom.toFloat())
        mPath.lineTo(body.boxCenterX.toFloat(), body.boxBottom.toFloat())
        mPath.lineTo(body.boxRight.toFloat(), body.boxCenterBottom.toFloat())
        mPath.quadTo(body.boxRight + body.boxSideLength / 2f * mReboundPercent, body.boxCenterY.toFloat(), body.boxRight.toFloat(), body.boxCenterTop.toFloat())
        mPath.lineTo(body.boxCenterX.toFloat(), body.boxTop.toFloat())
        mPath.lineTo(body.boxLeft.toFloat(), body.boxCenterTop.toFloat())
        mPath.quadTo(body.boxLeft - body.boxSideLength / 2f * mReboundPercent, body.boxCenterY.toFloat(), body.boxLeft.toFloat(), body.boxCenterBottom.toFloat())
        mPath.close()
        return mPath
    }

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        mKernel = kernel
        mHeaderHeight = height
        kernel.requestDrawBackgroundFor(this, mBackgroundColor)
        val sideLength = generateSideLength()
        mDrawable1.setBounds(0, 0, sideLength, sideLength)
        mDrawable2.setBounds(0, 0, sideLength, sideLength)
        mDrawable3.setBounds(0, 0, sideLength, sideLength)
    }

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        mHeight = offset
        if (!isDragging || mState != RefreshState.Refreshing) {
            // max(1, …): a zero max drag height divided by zero in the Java version.
            mReboundPercent = 1f * max(0, offset - height) / max(1, maxDragHeight)
        }
        invalidate()
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        mState = newState
        if (newState == RefreshState.None) mDropOutOverFlow = false
        updateRefreshAccessibility(newState)
    }

    @Deprecated("Only called by the layout; use RefreshLayout.setPrimaryColorsId.")
    override fun setPrimaryColors(@ColorInt vararg colors: Int) {
        if (colors.isNotEmpty()) {
            mBackgroundColor = colors[0]
            mKernel?.requestDrawBackgroundFor(this, mBackgroundColor)
            if (colors.size > 1) mAccentColor = colors[1]
        }
    }

    override fun onStartAnimator(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        mDropOutAnimator?.start()
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        mDropOutPercent = 0f
        return 0
    }

    /**
     * The box's geometry (`BoxBody`).
     */
    protected open class BoxBody {
        /**
         * The box's center x.
         */
        @JvmField var boxCenterX = 0

        /**
         * The box's center y.
         */
        @JvmField var boxCenterY = 0

        /**
         * The box's bottom.
         */
        @JvmField var boxBottom = 0

        /**
         * The box's top.
         */
        @JvmField var boxTop = 0

        /**
         * The box's left.
         */
        @JvmField var boxLeft = 0

        /**
         * The top of the box's sides.
         */
        @JvmField var boxCenterTop = 0

        /**
         * The bottom of the box's sides.
         */
        @JvmField var boxCenterBottom = 0

        /**
         * The box's right.
         */
        @JvmField var boxRight = 0

        /**
         * The box's side.
         */
        @JvmField var boxSideLength = 0

        /**
         * Measures the box for the size.
         */
        open fun measure(width: Int, height: Int, sideLength: Int, margin: Int): BoxBody {
            boxSideLength = sideLength
            boxCenterX = width / 2
            boxBottom = height - margin
            boxTop = boxBottom - 2 * sideLength
            boxLeft = boxCenterX - (sideLength * sin(PI / 3)).toInt()
            boxCenterTop = boxTop + sideLength / 2
            boxCenterBottom = boxBottom - sideLength / 2
            boxRight = width - boxLeft
            boxCenterY = boxBottom - sideLength
            return this
        }
    }

    /**
     * The drawings' SVG paths and colors.
     */
    companion object {
        /**
         * The drawable1Paths (from the Java version).
         */
        @JvmStatic protected var drawable1Paths = arrayOf(
            "M3 2h18v20h-18z",
            "m4 1c-1 0 -2 1 -2 2v18c0 1 1 2 2 2h16c1 0 2 -1 2 -2v-18c0 -1 -1 -2 -2 -2h-16zM3.5 3h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 3h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 6h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 6h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 9h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 9h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 12h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 12h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 15h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 15h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM3.5 18h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5zM19.5 18h1c0 0 .5 0 .5 .5v1c0 0 0 .5 -.5 .5h-1c-0 0 -.5 0 -.5 -.5v-1c0 0 0 -.5 .5 -.5z"
        )

        /**
         * The drawable1Colors (from the Java version).
         */
        @JvmStatic protected var drawable1Colors = intArrayOf(
            0xffecf0f1.toInt(),
            0xfffc4108.toInt()
        )

        /**
         * The drawable2Paths (from the Java version).
         */
        @JvmStatic protected var drawable2Paths = arrayOf(
            "M49,16.5l-14,-14l-27,0l0,53l41,0z",
            "m16,23.5h25c0.55,0 1,-.45 1,-1 0,-.55 -.45,-1 -1,-1L16,21.5c-.55,0 -1,.45 -1,1 0,.55 .45,1 1,1z",
            "m16,15.5h10c0.55,0 1,-.45 1,-1 0,-.55 -.45,-1 -1,-1L16,13.5c-.55,0 -1,.45 -1,1 0,.55 .45,1 1,1z",
            "M41,29.5L16,29.5c-.55,0 -1,.45 -1,1 0,.55 .45,1 1,1h25c0.55,0 1,-.45 1,-1 0,-.55 -.45,-1 -1,-1z",
            "M41,37.5L16,37.5c-.55,0 -1,.45 -1,1 0,.55 .45,1 1,1h25c0.55,0 1,-.45 1,-1 0,-.55 -.45,-1 -1,-1z",
            "M41,45.5L16,45.5c-.55,0 -1,.45 -1,1 0,.55 .45,1 1,1h25c0.55,0 1,-.45 1,-1 0,-.55 -.45,-1 -1,-1z",
            "M49,16.5l-14,-14l0,14z"
        )

        /**
         * The drawable2Colors (from the Java version).
         */
        @JvmStatic protected var drawable2Colors = intArrayOf(
            0xfffed469.toInt(),
            0xffd5ae57.toInt()
        )

        /**
         * The drawable3Paths (from the Java version).
         */
        @JvmStatic protected var drawable3Paths = arrayOf(
            "M6,2.1L6,11.3C5.4,11.3 4.8,11.4 4.2,11.6C2.6,12.3 1.6,13.7 2.1,14.8C2.6,15.9 4.2,16.2 5.8,15.6C7.1,15.1 7.8,14.1 7.9,13.2L7.9,4.3L15,3L15,9.4C14.4,9.3 13.7,9.4 13,9.7C11.4,10.3 10.5,11.7 11,12.8C11.4,13.9 13.1,14.3 14.7,13.6C15.9,13.1 16.8,12.2 16.9,11.3L16.9,0L6,2.1L6,2.1Z"
        )

        /**
         * The drawable3Colors (from the Java version).
         */
        @JvmStatic protected var drawable3Colors = intArrayOf(
            0xff98d761.toInt()
        )
    }
}
