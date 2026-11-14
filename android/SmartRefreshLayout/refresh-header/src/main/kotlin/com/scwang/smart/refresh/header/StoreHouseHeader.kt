// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header

import android.content.Context
import android.content.res.Resources
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Matrix
import android.graphics.PointF
import android.util.AttributeSet
import android.view.animation.AccelerateInterpolator
import android.view.animation.Animation
import android.view.animation.Transformation
import androidx.annotation.ColorInt
import com.scwang.smart.refresh.header.storehouse.StoreHouseBarItem
import com.scwang.smart.refresh.header.storehouse.StoreHousePath
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.simple.SimpleComponent
import com.scwang.smart.refresh.layout.util.SmartUtil
import kotlin.math.ceil
import kotlin.math.max
import kotlin.math.min

/**
 * The header that draws a word from falling bars, from android-Ultra-Pull-To-Refresh (`StoreHouseHeader`).
 */
open class StoreHouseHeader @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    SimpleComponent(context, attrs, 0), RefreshHeader {

    /**
     * The bars.
     */
    @JvmField var mItemList: MutableList<StoreHouseBarItem> = ArrayList()

    /**
     * The word's scale.
     */
    @JvmField protected var mScale = 1f

    /**
     * The bars' width.
     */
    @JvmField protected var mLineWidth: Int

    /**
     * How far the bars fall.
     */
    @JvmField protected var mDropHeight: Int

    /**
     * The bars' largest horizontal offset.
     */
    @JvmField protected var mHorizontalRandomness: Int

    /**
     * The pull progress, 0 to 1.
     */
    @JvmField protected var mProgress = 0f

    /**
     * The word's width.
     */
    @JvmField protected var mDrawZoneWidth = 0

    /**
     * The word's height.
     */
    @JvmField protected var mDrawZoneHeight = 0

    /**
     * The word's left.
     */
    @JvmField protected var mOffsetX = 0

    /**
     * The word's top.
     */
    @JvmField protected var mOffsetY = 0

    /**
     * One loop of the loading animation, in milliseconds.
     */
    @JvmField protected var mLoadingAniDuration = 1000

    /**
     * One segment of the loading animation, in milliseconds.
     */
    @JvmField protected var mLoadingAniSegDuration = 1000

    /**
     * The bars' color.
     */
    @JvmField protected var mTextColor = Color.WHITE

    /**
     * The background color.
     */
    @JvmField protected var mBackgroundColor: Int

    /**
     * True while refreshing.
     */
    @JvmField protected var mIsInLoading = false

    /**
     * Fades the word out after a successful refresh.
     */
    @JvmField protected var mEnableFadeAnimation = false

    /**
     * The matrix for a falling bar.
     */
    @JvmField protected var mMatrix = Matrix()

    /**
     * The layout's kernel, once initialized.
     */
    @JvmField protected var mRefreshKernel: RefreshKernel? = null

    /**
     * Runs the loading animation.
     */
    @JvmField protected var mAniController = AniController()

    /**
     * The bars' transformation.
     */
    @JvmField protected var mTransformation = Transformation()

    init {
        mLineWidth = SmartUtil.dp2px(1f)
        mDropHeight = SmartUtil.dp2px(40f)
        mHorizontalRandomness = Resources.getSystem().displayMetrics.widthPixels / 2
        mBackgroundColor = 0xff333333.toInt()
        setTextColor(0xffcccccc.toInt())
        val ta = context.obtainStyledAttributes(attrs, R.styleable.StoreHouseHeader)
        mLineWidth = ta.getDimensionPixelOffset(R.styleable.StoreHouseHeader_srlLineWidth, mLineWidth)
        mDropHeight = ta.getDimensionPixelOffset(R.styleable.StoreHouseHeader_srlDropHeight, mDropHeight)
        mEnableFadeAnimation = ta.getBoolean(R.styleable.StoreHouseHeader_srlEnableFadeAnimation, mEnableFadeAnimation)
        mLineWidth = ta.getDimensionPixelOffset(R.styleable.StoreHouseHeader_shhLineWidth, mLineWidth)
        mDropHeight = ta.getDimensionPixelOffset(R.styleable.StoreHouseHeader_shhDropHeight, mDropHeight)
        mEnableFadeAnimation = ta.getBoolean(R.styleable.StoreHouseHeader_shhEnableFadeAnimation, mEnableFadeAnimation)
        when {
            ta.hasValue(R.styleable.StoreHouseHeader_shhText) -> initWithString(ta.getString(R.styleable.StoreHouseHeader_shhText) ?: "")
            ta.hasValue(R.styleable.StoreHouseHeader_srlText) -> initWithString(ta.getString(R.styleable.StoreHouseHeader_srlText) ?: "")
            else -> initWithString("StoreHouse")
        }
        ta.recycle()
        minimumHeight = mDrawZoneHeight + SmartUtil.dp2px(40f)
        initRefreshAccessibility()
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.setMeasuredDimension(
            resolveSize(super.getSuggestedMinimumWidth(), widthMeasureSpec),
            resolveSize(super.getSuggestedMinimumHeight(), heightMeasureSpec),
        )
        mOffsetX = (measuredWidth - mDrawZoneWidth) / 2
        mOffsetY = (measuredHeight - mDrawZoneHeight) / 2
        mDropHeight = measuredHeight / 2
    }

    override fun dispatchDraw(canvas: Canvas) {
        val c1 = canvas.save()
        val len = mItemList.size
        val progress = if (isInEditMode) 1f else mProgress
        for (i in 0 until len) {
            canvas.save()
            val item = mItemList[i]
            var offsetX = mOffsetX + item.midPoint.x
            var offsetY = mOffsetY + item.midPoint.y
            if (mIsInLoading) {
                item.getTransformation(drawingTime, mTransformation)
                canvas.translate(offsetX, offsetY)
            } else {
                if (progress == 0f) {
                    item.resetPosition(mHorizontalRandomness)
                    // Restore the save above (the Java version skipped it, leaving one save per bar on the canvas).
                    canvas.restore()
                    continue
                }
                val startPadding = (1 - mInternalAnimationFactor) * i / len
                val endPadding = 1 - mInternalAnimationFactor - startPadding
                if (progress == 1f || progress >= 1 - endPadding) {
                    canvas.translate(offsetX, offsetY)
                    item.setAlpha(mBarDarkAlpha)
                } else {
                    val realProgress = if (progress <= startPadding) 0f else min(1f, (progress - startPadding) / mInternalAnimationFactor)
                    offsetX += item.translationX * (1 - realProgress)
                    offsetY += -mDropHeight * (1 - realProgress)
                    mMatrix.reset()
                    mMatrix.postRotate(360 * realProgress)
                    mMatrix.postScale(realProgress, realProgress)
                    mMatrix.postTranslate(offsetX, offsetY)
                    item.setAlpha(mBarDarkAlpha * realProgress)
                    canvas.concat(mMatrix)
                }
            }
            item.draw(canvas)
            canvas.restore()
        }
        if (mIsInLoading) invalidate()
        canvas.restoreToCount(c1)
        super.dispatchDraw(canvas)
    }

    /**
     * One loop of the loading animation, in milliseconds.
     */
    open fun setLoadingAniDuration(duration: Int): StoreHouseHeader = apply {
        mLoadingAniDuration = duration
        mLoadingAniSegDuration = duration
    }

    /**
     * The bars' width.
     */
    open fun setLineWidth(width: Int): StoreHouseHeader = apply {
        mLineWidth = width
        mItemList.forEach { it.setLineWidth(width) }
    }

    /**
     * The bars' color.
     */
    open fun setTextColor(@ColorInt color: Int): StoreHouseHeader = apply {
        mTextColor = color
        mItemList.forEach { it.setColor(color) }
    }

    /**
     * How far the bars fall.
     */
    open fun setDropHeight(height: Int): StoreHouseHeader = apply { mDropHeight = height }

    /**
     * Draws [str] (letters, digits, space, - and .) at the default size.
     */
    open fun initWithString(str: String): StoreHouseHeader = initWithString(str, 25)

    /**
     * Draws [str] (letters, digits, space, - and .) at [fontSize].
     */
    open fun initWithString(str: String, fontSize: Int): StoreHouseHeader =
        initWithPointList(StoreHousePath.getPath(str, fontSize * 0.01f, 14))

    /**
     * Draws the segments in the string array [id], each "x1,y1,x2,y2".
     */
    open fun initWithStringArray(id: Int): StoreHouseHeader =
        initWithPointList(resources.getStringArray(id).map { point ->
            val x = point.split(",")
            FloatArray(4) { x[it].trim().toFloat() }
        })

    /**
     * The word's scale.
     */
    open fun setScale(scale: Float): StoreHouseHeader = apply { mScale = scale }

    /**
     * Draws the segments {x1, y1, x2, y2} in [pointList], in dp.
     */
    open fun initWithPointList(pointList: List<FloatArray>): StoreHouseHeader {
        var drawWidth = 0f
        var drawHeight = 0f
        val shouldLayout = mItemList.isNotEmpty()
        mItemList.clear()
        pointList.forEachIndexed { i, line ->
            val startPoint = PointF(SmartUtil.dp2px(line[0]) * mScale, SmartUtil.dp2px(line[1]) * mScale)
            val endPoint = PointF(SmartUtil.dp2px(line[2]) * mScale, SmartUtil.dp2px(line[3]) * mScale)
            drawWidth = max(drawWidth, max(startPoint.x, endPoint.x))
            drawHeight = max(drawHeight, max(startPoint.y, endPoint.y))
            val item = StoreHouseBarItem(i, startPoint, endPoint, mTextColor, mLineWidth)
            item.resetPosition(mHorizontalRandomness)
            mItemList.add(item)
        }
        mDrawZoneWidth = ceil(drawWidth).toInt()
        mDrawZoneHeight = ceil(drawHeight).toInt()
        if (shouldLayout) requestLayout()
        return this
    }

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        mRefreshKernel = kernel
        kernel.requestDrawBackgroundFor(this, mBackgroundColor)
    }

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        mProgress = percent * .8f
        invalidate()
    }

    override fun onReleased(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        mIsInLoading = true
        mAniController.start()
        invalidate()
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        updateRefreshAccessibility(newState)
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        mIsInLoading = false
        mAniController.stop()
        if (success && mEnableFadeAnimation) {
            startAnimation(object : Animation() {
                init {
                    duration = 250
                    interpolator = AccelerateInterpolator()
                }

                override fun applyTransformation(interpolatedTime: Float, t: Transformation) {
                    mProgress = 1 - interpolatedTime
                    invalidate()
                    if (interpolatedTime == 1f) mItemList.forEach { it.resetPosition(mHorizontalRandomness) }
                }
            })
            return 250
        }
        mItemList.forEach { it.resetPosition(mHorizontalRandomness) }
        return 0
    }

    @Deprecated("Only called by the layout; use RefreshLayout.setPrimaryColorsId.")
    override fun setPrimaryColors(@ColorInt vararg colors: Int) {
        if (colors.isNotEmpty()) {
            mBackgroundColor = colors[0]
            mRefreshKernel?.requestDrawBackgroundFor(this, mBackgroundColor)
            if (colors.size > 1) setTextColor(colors[1])
        }
    }

    /**
     * Fades the bars one after another while refreshing (`AniController`).
     */
    protected open inner class AniController : Runnable {

        /**
         * The current tick.
         */
        @JvmField var mTick = 0

        /**
         * Bars per segment.
         */
        @JvmField var mCountPerSeg = 0

        /**
         * The number of segments.
         */
        @JvmField var mSegCount = 0

        /**
         * The time between ticks, in milliseconds.
         */
        @JvmField var mInterval = 0

        /**
         * True while running.
         */
        @JvmField var mRunning = true

        /**
         * Starts the animation.
         */
        open fun start() {
            mRunning = true
            mTick = 0
            // At least one bar and a 1 ms tick: an empty word or a short duration divided by zero in the Java version.
            mInterval = max(1, mLoadingAniDuration / max(1, mItemList.size))
            mCountPerSeg = max(1, mLoadingAniSegDuration / mInterval)
            mSegCount = mItemList.size / mCountPerSeg + 1
            run()
        }

        override fun run() {
            if (mItemList.isEmpty()) return
            val pos = mTick % mCountPerSeg
            for (i in 0 until mSegCount) {
                var index = i * mCountPerSeg + pos
                if (index > mTick) continue
                index %= mItemList.size
                val item = mItemList[index]
                item.fillAfter = false
                item.isFillEnabled = true
                item.fillBefore = false
                item.duration = mLoadingAniItemDuration.toLong()
                item.start(mFromAlpha, mToAlpha)
            }
            mTick++
            if (mRunning) mRefreshKernel?.refreshLayout?.layout?.postDelayed(this, mInterval.toLong())
        }

        /**
         * Stops the animation.
         */
        open fun stop() {
            mRunning = false
            // Posted on the layout, so removed there (the Java version removed it from the header, so it kept running).
            mRefreshKernel?.refreshLayout?.layout?.removeCallbacks(this)
            removeCallbacks(this)
        }
    }

    /**
     * The animation constants, under the Java version's names.
     */
    companion object {
        /**
         * The share of the pull each bar spends falling.
         */
        @JvmStatic protected val mInternalAnimationFactor = 0.7f

        /**
         * The bars' alpha once in place.
         */
        @JvmStatic protected val mBarDarkAlpha = 0.4f

        /**
         * The loading fade's start alpha.
         */
        @JvmStatic protected val mFromAlpha = 1.0f

        /**
         * The loading fade's end alpha.
         */
        @JvmStatic protected val mToAlpha = 0.4f

        /**
         * One bar's loading fade, in milliseconds.
         */
        @JvmStatic protected val mLoadingAniItemDuration = 400
    }
}
