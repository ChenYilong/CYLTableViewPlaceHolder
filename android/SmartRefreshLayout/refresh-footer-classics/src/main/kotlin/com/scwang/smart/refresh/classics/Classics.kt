// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.classics

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Path
import android.graphics.drawable.Animatable
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.annotation.ColorInt
import androidx.annotation.ColorRes
import androidx.annotation.DrawableRes
import androidx.core.content.ContextCompat
import com.scwang.smart.drawable.PaintDrawable
import com.scwang.smart.refresh.footer.classics.R
import com.scwang.smart.refresh.layout.api.RefreshComponent
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.simple.SimpleComponent
import com.scwang.smart.refresh.layout.util.SmartUtil

/**
 * The classic arrow (`ArrowDrawable`).
 */
open class ArrowDrawable : PaintDrawable() {
    private var mWidth = 0
    private var mHeight = 0
    private val mPath = Path()

    override fun draw(canvas: Canvas) {
        val width = bounds.width()
        val height = bounds.height()
        if (mWidth != width || mHeight != height) {
            val lineWidth = width * 30 / 225
            mPath.reset()
            val vector1 = lineWidth * 0.70710678118654752440084436210485f
            val vector2 = lineWidth / 0.70710678118654752440084436210485f
            mPath.moveTo(width / 2f, height.toFloat())
            mPath.lineTo(0f, height / 2f)
            mPath.lineTo(vector1, height / 2f - vector1)
            mPath.lineTo(width / 2f - lineWidth / 2f, height - vector2 - lineWidth / 2f)
            mPath.lineTo(width / 2f - lineWidth / 2f, 0f)
            mPath.lineTo(width / 2f + lineWidth / 2f, 0f)
            mPath.lineTo(width / 2f + lineWidth / 2f, height - vector2 - lineWidth / 2f)
            mPath.lineTo(width - vector1, height / 2f - vector1)
            mPath.lineTo(width.toFloat(), height / 2f)
            mPath.close()
            mWidth = width
            mHeight = height
        }
        canvas.drawPath(mPath, mPaint)
    }
}

/**
 * The base of the classics header and footer: an arrow, a spinner and a title (`ClassicsAbstract`). The setters
 * return [T] for chaining.
 */
@Suppress("UNCHECKED_CAST")
abstract class ClassicsAbstract<T : ClassicsAbstract<T>>(context: Context, attrs: AttributeSet?, defStyleAttr: Int) :
    SimpleComponent(context, attrs, defStyleAttr), RefreshComponent {

    /**
     * The title.
     */
    @JvmField protected var mTitleText: TextView? = null

    /**
     * The arrow.
     */
    @JvmField protected var mArrowView: ImageView? = null

    /**
     * The spinner.
     */
    @JvmField protected var mProgressView: ImageView? = null

    /**
     * The layout's kernel, once initialized.
     */
    @JvmField protected var mRefreshKernel: RefreshKernel? = null

    /**
     * The drawn arrow, or null for an app's image.
     */
    @JvmField protected var mArrowDrawable: PaintDrawable? = null

    /**
     * The drawn spinner, or null for an app's image.
     */
    @JvmField protected var mProgressDrawable: PaintDrawable? = null

    /**
     * True once the app set the accent color.
     */
    @JvmField protected var mSetAccentColor = false

    /**
     * True once the app set the primary color.
     */
    @JvmField protected var mSetPrimaryColor = false

    /**
     * The background color drawn behind the component.
     */
    @JvmField protected var mBackgroundColor = 0

    /**
     * Milliseconds the finished state stays before closing. Default 500.
     */
    @JvmField protected var mFinishDuration = 500

    /**
     * The top padding.
     */
    @JvmField protected var mPaddingTop = 20

    /**
     * The bottom padding.
     */
    @JvmField protected var mPaddingBottom = 20

    /**
     * The height of the tallest child.
     */
    @JvmField protected var mMinHeightOfContent = 0

    init {
        mSpinnerStyle = SpinnerStyle.Translate
    }

    /**
     * Makes the parts reachable by accessibility services the right way: the title is read and announced when it
     * changes; the arrow and the spinner are decoration.
     */
    protected fun setUpAccessibility() {
        mTitleText?.accessibilityLiveRegion = ACCESSIBILITY_LIVE_REGION_POLITE
        mArrowView?.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        mProgressView?.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        if (mMinHeightOfContent == 0) {
            mPaddingTop = paddingTop
            mPaddingBottom = paddingBottom
            if (mPaddingTop == 0 || mPaddingBottom == 0) {
                mPaddingTop = if (mPaddingTop == 0) SmartUtil.dp2px(20f) else mPaddingTop
                mPaddingBottom = if (mPaddingBottom == 0) SmartUtil.dp2px(20f) else mPaddingBottom
                setPadding(paddingLeft, mPaddingTop, paddingRight, mPaddingBottom)
            }
            clipToPadding = false
        }
        if (MeasureSpec.getMode(heightMeasureSpec) == MeasureSpec.EXACTLY) {
            val parentHeight = MeasureSpec.getSize(heightMeasureSpec)
            if (parentHeight < mMinHeightOfContent) {
                val padding = (parentHeight - mMinHeightOfContent) / 2
                setPadding(paddingLeft, padding, paddingRight, padding)
            } else {
                setPadding(paddingLeft, 0, paddingRight, 0)
            }
        } else {
            setPadding(paddingLeft, mPaddingTop, paddingRight, mPaddingBottom)
        }
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        if (mMinHeightOfContent == 0) {
            for (i in 0 until childCount) {
                val height = getChildAt(i).measuredHeight
                if (mMinHeightOfContent < height) mMinHeightOfContent = height
            }
        }
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        mArrowView?.animate()?.cancel()
        mProgressView?.animate()?.cancel()
        (mProgressView?.drawable as? Animatable)?.let { if (it.isRunning) it.stop() }
    }

    /**
     * This component as [T].
     */
    protected fun self(): T = this as T

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        mRefreshKernel = kernel
        kernel.requestDrawBackgroundFor(this, mBackgroundColor)
    }

    override fun onStartAnimator(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        val progressView = mProgressView ?: return
        if (progressView.visibility != VISIBLE) {
            progressView.visibility = VISIBLE
            val drawable = progressView.drawable
            if (drawable is Animatable) drawable.start() else progressView.animate().rotation(36000f).setDuration(100000)
        }
    }

    override fun onReleased(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        onStartAnimator(refreshLayout, height, maxDragHeight)
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        val progressView = mProgressView ?: return mFinishDuration
        val drawable = progressView.drawable
        if (drawable is Animatable) {
            if (drawable.isRunning) drawable.stop()
        } else {
            progressView.animate().rotation(0f).setDuration(0)
        }
        progressView.visibility = GONE
        // The finished state stays mFinishDuration milliseconds before closing.
        return mFinishDuration
    }

    override fun setPrimaryColors(@ColorInt vararg colors: Int) {
        if (colors.isEmpty()) return
        if (background !is BitmapDrawable && !mSetPrimaryColor) {
            setPrimaryColor(colors[0])
            mSetPrimaryColor = false
        }
        if (!mSetAccentColor) {
            if (colors.size > 1) setAccentColor(colors[1])
            mSetAccentColor = false
        }
    }

    /**
     * The spinner image.
     */
    open fun setProgressBitmap(bitmap: Bitmap?): T {
        mProgressDrawable = null
        mProgressView?.setImageBitmap(bitmap)
        return self()
    }

    /**
     * The spinner drawable.
     */
    open fun setProgressDrawable(drawable: Drawable?): T {
        mProgressDrawable = null
        mProgressView?.setImageDrawable(drawable)
        return self()
    }

    /**
     * The spinner resource.
     */
    open fun setProgressResource(@DrawableRes resId: Int): T {
        mProgressDrawable = null
        mProgressView?.setImageResource(resId)
        return self()
    }

    /**
     * The arrow image.
     */
    open fun setArrowBitmap(bitmap: Bitmap?): T {
        mArrowDrawable = null
        mArrowView?.setImageBitmap(bitmap)
        return self()
    }

    /**
     * The arrow drawable.
     */
    open fun setArrowDrawable(drawable: Drawable?): T {
        mArrowDrawable = null
        mArrowView?.setImageDrawable(drawable)
        return self()
    }

    /**
     * The arrow resource.
     */
    open fun setArrowResource(@DrawableRes resId: Int): T {
        mArrowDrawable = null
        mArrowView?.setImageResource(resId)
        return self()
    }

    /**
     * How the component moves with the pull.
     */
    open fun setSpinnerStyle(style: SpinnerStyle?): T {
        mSpinnerStyle = style
        return self()
    }

    /**
     * The background color.
     */
    open fun setPrimaryColor(@ColorInt primaryColor: Int): T {
        mSetPrimaryColor = true
        mBackgroundColor = primaryColor
        mRefreshKernel?.requestDrawBackgroundFor(this, primaryColor)
        return self()
    }

    /**
     * The color of the title, the arrow and the spinner.
     */
    open fun setAccentColor(@ColorInt accentColor: Int): T {
        mSetAccentColor = true
        mTitleText?.setTextColor(accentColor)
        mArrowDrawable?.let {
            it.setColor(accentColor)
            mArrowView?.invalidateDrawable(it)
        }
        mProgressDrawable?.let {
            it.setColor(accentColor)
            mProgressView?.invalidateDrawable(it)
        }
        return self()
    }

    /**
     * The background color, as a resource.
     */
    open fun setPrimaryColorId(@ColorRes colorId: Int): T {
        setPrimaryColor(ContextCompat.getColor(context, colorId))
        return self()
    }

    /**
     * The accent color, as a resource.
     */
    open fun setAccentColorId(@ColorRes colorId: Int): T {
        setAccentColor(ContextCompat.getColor(context, colorId))
        return self()
    }

    /**
     * Milliseconds the finished state stays.
     */
    open fun setFinishDuration(delay: Int): T {
        mFinishDuration = delay
        return self()
    }

    /**
     * The title's text size in sp.
     */
    open fun setTextSizeTitle(size: Float): T {
        mTitleText?.textSize = size
        mRefreshKernel?.requestRemeasureHeightFor(this)
        return self()
    }

    /**
     * The title's text size in [unit].
     */
    open fun setTextSizeTitle(unit: Int, size: Float): T {
        mTitleText?.setTextSize(unit, size)
        mRefreshKernel?.requestRemeasureHeightFor(this)
        return self()
    }

    /**
     * The space after the arrow and the spinner, in dp.
     */
    open fun setDrawableMarginRight(dp: Float): T = setDrawableMarginRightPx(SmartUtil.dp2px(dp))

    /**
     * The space after the arrow and the spinner, in pixels.
     */
    open fun setDrawableMarginRightPx(px: Int): T {
        val arrowView = mArrowView ?: return self()
        val progressView = mProgressView ?: return self()
        val lpArrow = arrowView.layoutParams as ViewGroup.MarginLayoutParams
        val lpProgress = progressView.layoutParams as ViewGroup.MarginLayoutParams
        lpArrow.rightMargin = px
        lpProgress.rightMargin = px
        arrowView.layoutParams = lpArrow
        progressView.layoutParams = lpProgress
        return self()
    }

    /**
     * The size of the arrow and the spinner, in dp.
     */
    open fun setDrawableSize(dp: Float): T = setDrawableSizePx(SmartUtil.dp2px(dp))

    /**
     * The size of the arrow and the spinner, in pixels.
     */
    open fun setDrawableSizePx(px: Int): T {
        resize(mArrowView, px)
        resize(mProgressView, px)
        return self()
    }

    /**
     * The arrow's size in dp.
     */
    open fun setDrawableArrowSize(dp: Float): T = setDrawableArrowSizePx(SmartUtil.dp2px(dp))

    /**
     * The arrow's size in pixels.
     */
    open fun setDrawableArrowSizePx(px: Int): T {
        resize(mArrowView, px)
        return self()
    }

    /**
     * The spinner's size in dp.
     */
    open fun setDrawableProgressSize(dp: Float): T = setDrawableProgressSizePx(SmartUtil.dp2px(dp))

    /**
     * The spinner's size in pixels.
     */
    open fun setDrawableProgressSizePx(px: Int): T {
        resize(mProgressView, px)
        return self()
    }

    private fun resize(view: View?, px: Int) {
        view ?: return
        val lp = view.layoutParams
        lp.width = px
        lp.height = px
        view.layoutParams = lp
    }

    /**
     * The ids of the parts.
     */
    companion object {
        /**
         * The title's id.
         */
        @JvmField val ID_TEXT_TITLE = R.id.srl_classics_title

        /**
         * The arrow's id.
         */
        @JvmField val ID_IMAGE_ARROW = R.id.srl_classics_arrow

        /**
         * The spinner's id.
         */
        @JvmField val ID_IMAGE_PROGRESS = R.id.srl_classics_progress
    }
}
