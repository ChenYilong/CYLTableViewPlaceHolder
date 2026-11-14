// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header

import android.content.Context
import android.graphics.Canvas
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import androidx.annotation.ColorInt
import com.scwang.smart.drawable.PathsDrawable
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.simple.SimpleComponent
import com.scwang.smart.refresh.layout.util.SmartUtil
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin

/**
 * A parcel floating down under an umbrella, after "Refresh your delivery" on Dribbble (`DeliveryHeader`).
 */
open class DeliveryHeader @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    SimpleComponent(context, attrs, 0), RefreshHeader {

    /**
     * The first cloud's x.
     */
    @JvmField protected var mCloudX1 = 0

    /**
     * The second cloud's x.
     */
    @JvmField protected var mCloudX2 = 0

    /**
     * The third cloud's x.
     */
    @JvmField protected var mCloudX3 = 0

    /**
     * The current offset.
     */
    @JvmField protected var mHeight = 0

    /**
     * The header's height.
     */
    @JvmField protected var mHeaderHeight = 0

    /**
     * The background color, or 0 for none.
     */
    @JvmField protected var mBackgroundColor = 0

    /**
     * The animation's clock.
     */
    @JvmField protected var mAppreciation = 0f

    /**
     * The layout's state.
     */
    @JvmField protected var mState: RefreshState? = null

    /**
     * The cloud.
     */
    @JvmField protected var mCloudDrawable: Drawable

    /**
     * The umbrella.
     */
    @JvmField protected var mUmbrellaDrawable: Drawable

    /**
     * The parcel.
     */
    @JvmField protected var mBoxDrawable: Drawable

    /**
     * The layout's kernel, once initialized.
     */
    @JvmField protected var mKernel: RefreshKernel? = null

    init {
        mSpinnerStyle = SpinnerStyle.FixedBehind
        minimumHeight = SmartUtil.dp2px(150f)
        mCloudDrawable = PathsDrawable().apply {
            if (!parserPaths(*cloudPaths)) declareOriginal(0, 0, 99, 32)
            parserColors(*cloudColors)
            setGeometricHeight(SmartUtil.dp2px(20f))
        }
        mUmbrellaDrawable = PathsDrawable().apply {
            if (!parserPaths(*umbrellaPaths)) declareOriginal(2, 4, 265, 355)
            parserColors(*umbrellaColors)
            setGeometricWidth(SmartUtil.dp2px(200f))
        }
        mBoxDrawable = PathsDrawable().apply {
            if (!parserPaths(*boxPaths)) declareOriginal(0, 1, 95, 92)
            parserColors(*boxColors)
            setGeometricWidth(SmartUtil.dp2px(50f))
        }
        if (isInEditMode) {
            mState = RefreshState.Refreshing
            mAppreciation = 100f
            mCloudX1 = (mCloudDrawable.bounds.width() * 3.5f).toInt()
            mCloudX2 = (mCloudDrawable.bounds.width() * 0.5f).toInt()
            mCloudX3 = (mCloudDrawable.bounds.width() * 2.0f).toInt()
        }
        initRefreshAccessibility()
    }

    override fun dispatchDraw(canvas: Canvas) {
        val width = width
        val height = mHeight
        val saveCount = canvas.saveCount
        val footer = mKernel?.refreshLayout?.refreshFooter?.let { this == it } == true
        canvas.save()
        if (footer) canvas.translate(0f, (getHeight() - mHeight).toFloat())
        val shake = (mHeaderHeight / 13 * sin(mAppreciation.toDouble())).toInt()
        drawCloud(canvas, width)
        drawBox(canvas, width, height, shake)
        drawUmbrella(canvas, width, height, shake)
        canvas.restoreToCount(saveCount)
        super.dispatchDraw(canvas)
    }

    /**
     * Draws the parcel.
     */
    protected open fun drawBox(canvas: Canvas, width: Int, height: Int, shake: Int) {
        val bounds = mBoxDrawable.bounds
        val centerY = height - mHeaderHeight / 2 + shake
        val centerYBox = centerY + (mHeaderHeight / 2 - bounds.height()) -
            min(mHeaderHeight / 2 - bounds.height(), SmartUtil.dp2px(mAppreciation * 100))
        bounds.offsetTo(width / 2 - bounds.width() / 2, centerYBox - bounds.height() / 4)
        mBoxDrawable.draw(canvas)
    }

    /**
     * Draws the umbrella while refreshing.
     */
    protected open fun drawUmbrella(canvas: Canvas, width: Int, height: Int, shake: Int) {
        if (mState == RefreshState.Refreshing || mState == RefreshState.RefreshFinish) {
            val bounds = mUmbrellaDrawable.bounds
            val centerY = height - mHeaderHeight / 2 + shake
            val centerYUmbrella = centerY - mHeaderHeight + min(mHeaderHeight, SmartUtil.dp2px(mAppreciation * 100))
            bounds.offsetTo(width / 2 - bounds.width() / 2, centerYUmbrella - bounds.height())
            mUmbrellaDrawable.draw(canvas)
        }
    }

    /**
     * Draws the clouds while refreshing and advances the animation.
     */
    protected open fun drawCloud(canvas: Canvas, width: Int) {
        if (mState == RefreshState.Refreshing || mState == RefreshState.RefreshFinish) {
            val bounds = mCloudDrawable.bounds
            bounds.offsetTo(mCloudX1, mHeaderHeight / 3)
            mCloudDrawable.draw(canvas)
            bounds.offsetTo(mCloudX2, mHeaderHeight / 2)
            mCloudDrawable.draw(canvas)
            bounds.offsetTo(mCloudX3, mHeaderHeight * 2 / 3)
            mCloudDrawable.draw(canvas)
            canvas.rotate(5 * sin(mAppreciation / 2.0).toFloat(), width / 2f, mHeaderHeight / 2f - mUmbrellaDrawable.bounds.height())
            calculateFrame(width)
        }
    }

    /**
     * Moves the clouds and the clock one frame on.
     */
    protected open fun calculateFrame(width: Int) {
        mCloudX1 += SmartUtil.dp2px(9f)
        mCloudX2 += SmartUtil.dp2px(5f)
        mCloudX3 += SmartUtil.dp2px(12f)
        val cloudWidth = mCloudDrawable.bounds.width()
        if (mCloudX1 > width + cloudWidth) mCloudX1 = -cloudWidth
        if (mCloudX2 > width + cloudWidth) mCloudX2 = -cloudWidth
        if (mCloudX3 > width + cloudWidth) mCloudX3 = -cloudWidth
        mAppreciation += 0.1f
        invalidate()
    }

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        mKernel = kernel
        mHeaderHeight = height
        if (mBackgroundColor != 0) kernel.requestDrawBackgroundFor(this, mBackgroundColor)
    }

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        mHeight = offset
        if (mState != RefreshState.Refreshing) mBoxDrawable.alpha = (255 * (1f - max(0f, percent - 1))).toInt()
        invalidate()
    }

    override fun onReleased(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        onStartAnimator(refreshLayout, height, maxDragHeight)
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        mState = newState
        if (newState == RefreshState.None) {
            mAppreciation = 0f
            mCloudX1 = -mCloudDrawable.bounds.width()
            mCloudX2 = mCloudX1
            mCloudX3 = mCloudX1
        }
        updateRefreshAccessibility(newState)
    }

    @Deprecated("Only called by the layout; use RefreshLayout.setPrimaryColorsId.")
    override fun setPrimaryColors(@ColorInt vararg colors: Int) {
        if (colors.isNotEmpty()) {
            mBackgroundColor = colors[0]
            mKernel?.requestDrawBackgroundFor(this, mBackgroundColor)
            if (colors.size > 1) (mCloudDrawable as? PathsDrawable)?.parserColors(colors[1])
        }
    }

    override fun onStartAnimator(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        mState = RefreshState.Refreshing
        mBoxDrawable.alpha = 255
        invalidate()
    }

    /**
     * The drawings' SVG paths and colors.
     */
    companion object {
        /**
         * The umbrellaPaths (from the Java version).
         */
        @JvmStatic protected var umbrellaPaths = arrayOf(
        "m114,329 5,2 16,28h-1zM2,144.5c-4,-77 50,-122 96,-135 6,0 7.1,.2 13,3.5v4.5C63,55.1 56,97.1 43,154.5 37.6,195 16,191 2,144.5Z",
        "m134,359 -1,-27h2.6l-1,26zm-24,-34.6c0,-1 -2,-3.6 -4.5,-6C88,300 7,218.5 2,144.5c18,43.6 33,45 41,10 0,-71 34,-125.5 68,-137 2,3 4,4.5 8,7.5C97,91 96.5,109.4 95.5,175.4 86.5,205 58,208.5 43,154.5c14,64 32,101.6 60.6,147 6,8 15.4,18.5 15.4,29.5 -3.8,-1.3 -8.27988,-2.8 -9,-6.6zM98.5,9.5c4.6,-1.5 18,-4.6 34,-5 1,1 1,2 1,3 -9,1 -16,3 -22,6 -2.5,-1 -8,-3 -13,-4z",
        "m119,331c-1,-7.6 -4,-12 -6.5,-16 -37,-55 -64,-98.9 -69.5,-160.5 20,46 41.5,48.5 52.5,20.9C93.5,122.9 87,84 119,25l31,-.1c40,60.5 25.2,136.5 22.2,150.1 -14,53 -66.7,33.4 -76.7,.4 11.5,50.5 19.7,89.1 29.7,136.1 4,10 4.2,10.1 5,21.5 -3,0 -8,-1 -11,-2z",
        "m172,174.5c5,-51.6 -2,-106 -22,-149.6 2.5,-3 3,-4 6.6,-6 48,22.5 77.5,63 69,140 -24.8,55.8 -48.1,39.2703 -53.6,15.6zM154.6,14C148,11 142.4,9 133,7c0,-1 -.5,-1.5 -.5,-2.5 16,0 31.5,3.5 40.9,6.5C167.9,11 158.6,12 154.6,14Z",
        "m134,359 15,-28 2,-1 -16,29zm7,-26c0,-12 2,-14.4 4,-21.9 12,-47 16,-77.5 27,-137 12,38.5 37.1,22.9 53.6,-15.2 -4,54 -44.6,120.2 -69.6,154.2 -6,9.5 -7.4,16.9 -5,16.9 -2.4,1.4 -6.5,2.4 -10,3z",
        "m225.6,159c1.6,-52 -22,-117 -69,-140 -1.5,-2 -1.6,-2 -2,-5 4,-3 9,-5 15,-4 48.6,10 103,67 96.6,132 -10,46 -35.5,52 -40.6,17z",
        "m156,313.1c33,-59 54.6,-86.2 69.6,-154.2 12,38 28.9,22.1 40.5,-16.9 -2,50.6 -43,113 -99.6,171 -4.6,5 -8,9 -8,10 0,2 -3.5,5 -7,7 -4.6,1 1.5,-13.9 4.5,-16.9z",
        "m130,333c-.5,-11.5 -1.4,-12 -5,-22 -11,-30 -23.5,-89.1 -29.5,-135.6 16.5,39 59.5,33.1 76.5,-.9 -6,59 -11,88.5 -27,139 -2,7 -3,11.6 -4,19.5 -3,.5 -6.5,.5 -11,0zM119,25c-3.5,-1 -7,-3.5 -8,-7.5V13c2.5,-4.5 14.5,-6 22,-6 5,0 15,1 21,6 2,1.6 3.2,3.9 2.6,5.9 -1,3 -4,5 -6.6,6 -14.8,4.2 -31.0,.1 -31,.1z"
        )

        /**
         * The umbrellaColors (from the Java version).
         */
        @JvmStatic protected var umbrellaColors = intArrayOf(
            0xff92dfeb.toInt(),
            0xff6dd0e9.toInt(),
            0xff4fc3e7.toInt(),
            0xff2fb6e6.toInt(),
            0xff25a9de.toInt(),
            0xff11abe4.toInt(),
            0xff0e9bd8.toInt(),
            0xff40b7e1.toInt()
        )

        /**
         * The cloudPaths (from the Java version).
         */
        @JvmStatic protected var cloudPaths = arrayOf(
            "M63,0A22.6,22 0,0 0,42 14,17 17,0 0,0 30.9,10 17,17 0,0 0,13.7 26,9 9,0 0,0 9,24 9,9 0,0 0,0 32h99a8,8 0,0 0,0 -.6,8 8,0 0,0 -8,-8 8,8 0,0 0,-6 2.6,22.6 22,0 0,0 0,-3.6A22.6,22 0,0 0,63 0Z"
        )

        /**
         * The cloudColors (from the Java version).
         */
        @JvmStatic protected var cloudColors = intArrayOf(
            0xffffffff.toInt()
        )

        /**
         * The boxPaths (from the Java version).
         */
        @JvmStatic protected var boxPaths = arrayOf(
            "M0,17.5 L3,30 2.9,76 47.5,93 92.8,76V30L95,18 47,.5Z",
            "M3,30 L48,46 47.5,93 2.9,76ZM0,17.5 L48,35 48,46 0,29Z",
            "m56.5,18c0,2 -3.8,3.8 -8.5,3.8 -4.7,0 -8.5,-1.7 -8.5,-3.8 0,-2 3.8,-3.8 8.5,-3.8 4.7,0 8.5,1.7 8.5,3.8zM3,30 L3,34.7l44.7,17 0,-5z",
            "M48,35 L47.5,93 92.8,76V30l2,-.8 0,-10.9z",
            "M82.6,80 L92.8,62 92.8,76ZM47.6,80 L60,88 47.5,93ZM48,46 L92.8,30 92.8,34 48,51.6Z"
        )

        /**
         * The boxColors (from the Java version).
         */
        @JvmStatic protected var boxColors = intArrayOf(
            0xfff8b147.toInt(),
            0xfff2973c.toInt(),
            0xffed8030.toInt(),
            0xfffec051.toInt(),
            0xfff7ad49.toInt()
        )
    }
}
