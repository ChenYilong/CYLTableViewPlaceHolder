// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header.fungame

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.text.TextPaint
import android.util.AttributeSet
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.annotation.ColorInt
import androidx.core.graphics.ColorUtils
import com.scwang.smart.refresh.header.R
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.util.SmartUtil
import kotlin.math.max

/**
 * The game headers' curtain and arena, from FunGameRefresh (`FunGameView`).
 */
abstract class FunGameView(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : FunGameBase(context, attrs, defStyleAttr) {

    /**
     * The dividing lines' width.
     */
    @JvmField protected var DIVIDING_LINE_SIZE = 1f

    /**
     * The curtain's shadow.
     */
    @JvmField protected var mShadowView: View

    /**
     * The curtain's upper half.
     */
    @JvmField protected var mMaskViewTop: TextView

    /**
     * The curtain's lower half.
     */
    @JvmField protected var mMaskViewBottom: TextView

    /**
     * The lower curtain's text.
     */
    @JvmField var mMaskTextBottom: String

    /**
     * The upper curtain's text while pulling.
     */
    @JvmField var mMaskTextTopPull: String

    /**
     * The upper curtain's text when releasing refreshes.
     */
    @JvmField var mMaskTextTopRelease: String

    /**
     * Half the header's height.
     */
    @JvmField protected var mHalfHeaderHeight = 0

    /**
     * The "Game Over" text.
     */
    @JvmField var mTextGameOver: String

    /**
     * The text while refreshing.
     */
    @JvmField var mTextLoading: String

    /**
     * The text when refreshed.
     */
    @JvmField var mTextLoadingFinish: String

    /**
     * The text when the refresh failed.
     */
    @JvmField var mTextLoadingFailed: String

    /**
     * The game's paint.
     */
    @JvmField protected var mPaint: Paint

    /**
     * The texts' paint.
     */
    @JvmField protected var mPaintText: Paint

    /**
     * The controller's position.
     */
    @JvmField protected var controllerPosition: Float

    /**
     * The controller's size.
     */
    @JvmField protected var controllerSize = 0

    /**
     * The game's status: one of the STATUS_GAME_ constants.
     */
    @JvmField protected var status = STATUS_GAME_PREPARE

    /**
     * The left model's color.
     */
    @JvmField protected var lModelColor: Int

    /**
     * The right model's color.
     */
    @JvmField protected var rModelColor: Int

    /**
     * The middle model's color.
     */
    @JvmField protected var mModelColor: Int

    /**
     * The arena's background color.
     */
    @JvmField protected var mBackColor: Int

    /**
     * The arena's border color.
     */
    @JvmField protected var mBoundaryColor = 0xff606060.toInt()

    /**
     * The curtain's opening.
     */
    private var mCurtainAnimator: AnimatorSet? = null

    init {
        val ta = context.obtainStyledAttributes(attrs, R.styleable.FunGameView)
        fun string(index: Int, fallback: String): String = if (ta.hasValue(index)) ta.getString(index) ?: fallback else fallback
        mMaskTextBottom = resources.getString(R.string.fgh_mask_bottom)
        mMaskTextTopPull = resources.getString(R.string.fgh_mask_top_pull)
        mMaskTextTopRelease = resources.getString(R.string.fgh_mask_top_release)
        if (ta.hasValue(R.styleable.FunGameView_srlMaskTextTop)) {
            mMaskTextTopPull = string(R.styleable.FunGameView_srlMaskTextTop, mMaskTextTopPull)
            mMaskTextTopRelease = mMaskTextTopPull
        }
        mMaskTextTopPull = string(R.styleable.FunGameView_srlMaskTextTopPull, mMaskTextTopPull)
        mMaskTextTopRelease = string(R.styleable.FunGameView_srlMaskTextTopRelease, mMaskTextTopRelease)
        mMaskTextBottom = string(R.styleable.FunGameView_srlMaskTextBottom, mMaskTextBottom)
        if (ta.hasValue(R.styleable.FunGameView_fghMaskTextTop)) {
            mMaskTextTopPull = string(R.styleable.FunGameView_fghMaskTextTop, mMaskTextTopPull)
            mMaskTextTopRelease = mMaskTextTopPull
        }
        mMaskTextTopPull = string(R.styleable.FunGameView_fghMaskTextTopPull, mMaskTextTopPull)
        mMaskTextTopRelease = string(R.styleable.FunGameView_fghMaskTextTopRelease, mMaskTextTopRelease)
        mMaskTextBottom = string(R.styleable.FunGameView_fghMaskTextBottom, mMaskTextBottom)
        var maskTextSizeTop = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, 16f, resources.displayMetrics).toInt()
        var maskTextSizeBottom = maskTextSizeTop * 14 / 16
        maskTextSizeTop = ta.getDimensionPixelSize(R.styleable.FunGameView_srlMaskTextSizeTop, maskTextSizeTop)
        maskTextSizeBottom = ta.getDimensionPixelSize(R.styleable.FunGameView_srlMaskTextSizeBottom, maskTextSizeBottom)
        maskTextSizeTop = ta.getDimensionPixelSize(R.styleable.FunGameView_fghMaskTextSizeTop, maskTextSizeTop)
        maskTextSizeBottom = ta.getDimensionPixelSize(R.styleable.FunGameView_fghMaskTextSizeBottom, maskTextSizeBottom)
        val curtainLayout: ViewGroup = RelativeLayout(context)
        mShadowView = RelativeLayout(context).apply { setBackgroundColor(0xFF3A3A3A.toInt()) }
        mMaskViewTop = createMaskView(context, mMaskTextTopPull, maskTextSizeTop, Gravity.BOTTOM)
        mMaskViewBottom = createMaskView(context, mMaskTextBottom, maskTextSizeBottom, Gravity.TOP)
        if (!isInEditMode) {
            val height = SmartUtil.dp2px(100f)
            addView(mShadowView, LayoutParams(LayoutParams.MATCH_PARENT, height))
            addView(curtainLayout, LayoutParams(LayoutParams.MATCH_PARENT, height))
            mHalfHeaderHeight = (height * .5f).toInt()
            val lpTop = RelativeLayout.LayoutParams(LayoutParams.MATCH_PARENT, mHalfHeaderHeight)
            val lpBottom = RelativeLayout.LayoutParams(LayoutParams.MATCH_PARENT, mHalfHeaderHeight)
            lpBottom.topMargin = height - mHalfHeaderHeight
            curtainLayout.addView(mMaskViewTop, lpTop)
            curtainLayout.addView(mMaskViewBottom, lpBottom)
        }
        DIVIDING_LINE_SIZE = max(1, SmartUtil.dp2px(0.5f)).toFloat()
        mPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { strokeWidth = DIVIDING_LINE_SIZE }
        controllerPosition = DIVIDING_LINE_SIZE
        mPaintText = TextPaint(Paint.ANTI_ALIAS_FLAG).apply { color = 0xFFC1C2C2.toInt() }
        mTextGameOver = context.getString(R.string.fgh_text_game_over)
        mTextLoading = context.getString(R.string.fgh_text_loading)
        mTextLoadingFinish = context.getString(R.string.fgh_text_loading_finish)
        mTextLoadingFailed = context.getString(R.string.fgh_text_loading_failed)
        mBackColor = ta.getColor(R.styleable.FunGameView_srlBackColor, 0)
        lModelColor = ta.getColor(R.styleable.FunGameView_srlLeftColor, Color.BLACK)
        mModelColor = ta.getColor(R.styleable.FunGameView_srlMiddleColor, Color.BLACK)
        rModelColor = ta.getColor(R.styleable.FunGameView_srlRightColor, 0xFFA5A5A5.toInt())
        if (ta.hasValue(R.styleable.FunGameView_fghBackColor)) mBackColor = ta.getColor(R.styleable.FunGameView_fghBackColor, 0)
        if (ta.hasValue(R.styleable.FunGameView_fghLeftColor)) lModelColor = ta.getColor(R.styleable.FunGameView_fghLeftColor, Color.BLACK)
        if (ta.hasValue(R.styleable.FunGameView_fghMiddleColor)) mModelColor = ta.getColor(R.styleable.FunGameView_fghMiddleColor, Color.BLACK)
        if (ta.hasValue(R.styleable.FunGameView_fghRightColor)) rModelColor = ta.getColor(R.styleable.FunGameView_fghRightColor, 0xFFA5A5A5.toInt())
        mTextGameOver = string(R.styleable.FunGameView_srlTextGameOver, mTextGameOver)
        mTextLoading = string(R.styleable.FunGameView_srlTextLoading, mTextLoading)
        mTextLoadingFinish = string(R.styleable.FunGameView_srlTextLoadingFinished, mTextLoadingFinish)
        mTextLoadingFailed = string(R.styleable.FunGameView_srlTextLoadingFailed, mTextLoadingFailed)
        mTextGameOver = string(R.styleable.FunGameView_fghTextGameOver, mTextGameOver)
        mTextLoading = string(R.styleable.FunGameView_fghTextLoading, mTextLoading)
        mTextLoadingFinish = string(R.styleable.FunGameView_fghTextLoadingFinished, mTextLoadingFinish)
        mTextLoadingFailed = string(R.styleable.FunGameView_fghTextLoadingFailed, mTextLoadingFailed)
        ta.recycle()
    }

    /**
     * One half of the curtain.
     */
    protected open fun createMaskView(context: Context, text: String, textSize: Int, gravity: Int): TextView =
        TextView(context).apply {
            setTextColor(Color.BLACK)
            this.gravity = gravity or Gravity.CENTER_HORIZONTAL
            setTextSize(TypedValue.COMPLEX_UNIT_PX, textSize.toFloat())
            this.text = text
            setBackgroundColor(Color.WHITE)
        }

    /**
     * Draws the game.
     */
    protected abstract fun drawGame(canvas: Canvas, width: Int, height: Int)

    override fun dispatchDraw(canvas: Canvas) {
        val width = width
        val height = mHeaderHeight
        drawBoundary(canvas, width, height)
        drawText(canvas, width, height)
        drawGame(canvas, width, height)
        super.dispatchDraw(canvas)
    }

    /**
     * Draws the arena's background and border.
     */
    protected open fun drawBoundary(canvas: Canvas, width: Int, height: Int) {
        mPaint.color = mBackColor
        canvas.drawRect(0f, 0f, width.toFloat(), height.toFloat(), mPaint)
        mPaint.color = mBoundaryColor
        canvas.drawLine(0f, 0f, width.toFloat(), 0f, mPaint)
        canvas.drawLine(0f, height - DIVIDING_LINE_SIZE, width.toFloat(), height - DIVIDING_LINE_SIZE, mPaint)
    }

    /**
     * Draws the status text.
     */
    protected open fun drawText(canvas: Canvas, width: Int, height: Int) {
        when (status) {
            STATUS_GAME_PREPARE, STATUS_GAME_PLAY -> {
                mPaintText.textSize = SmartUtil.dp2px(25f).toFloat()
                promptText(canvas, mTextLoading, width, height)
            }
            STATUS_GAME_FINISHED -> {
                mPaintText.textSize = SmartUtil.dp2px(20f).toFloat()
                promptText(canvas, mTextLoadingFinish, width, height)
            }
            STATUS_GAME_FAIL -> {
                mPaintText.textSize = SmartUtil.dp2px(20f).toFloat()
                promptText(canvas, mTextLoadingFailed, width, height)
            }
            STATUS_GAME_OVER -> {
                mPaintText.textSize = SmartUtil.dp2px(25f).toFloat()
                promptText(canvas, mTextGameOver, width, height)
            }
        }
    }

    /**
     * Draws [text] in the middle.
     */
    protected open fun promptText(canvas: Canvas, text: String, width: Int, height: Int) {
        val textX = (width - mPaintText.measureText(text)) * .5f
        val textY = height * .5f - (mPaintText.ascent() + mPaintText.descent()) * .5f
        canvas.drawText(text, textX, textY, mPaintText)
    }

    /**
     * Resets the game.
     */
    protected abstract fun resetConfigParams()

    /**
     * Sets the game's [status], one of the STATUS_GAME_ constants.
     */
    open fun postStatus(status: Int) {
        this.status = status
        if (status == STATUS_GAME_PREPARE) resetConfigParams()
        postInvalidate()
    }

    override fun onManualOperationMove(percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        val maxDistance = mHeaderHeight - 2 * DIVIDING_LINE_SIZE - controllerSize
        controllerPosition = minOf(max(offset, 0).toFloat(), maxDistance)
        postInvalidate()
    }

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        if (mHeaderHeight != height && !isInEditMode) {
            mHalfHeaderHeight = (height * .5f).toInt()
            val lpTop = mMaskViewTop.layoutParams as RelativeLayout.LayoutParams
            val lpBottom = mMaskViewBottom.layoutParams as RelativeLayout.LayoutParams
            lpTop.height = mHalfHeaderHeight
            lpBottom.height = mHalfHeaderHeight
            lpBottom.topMargin = height - mHalfHeaderHeight
            mMaskViewTop.layoutParams = lpTop
            mMaskViewBottom.layoutParams = lpBottom
        }
        super.onInitialized(kernel, height, maxDragHeight)
        postStatus(STATUS_GAME_PREPARE)
    }

    @Deprecated("Only called by the layout; use RefreshLayout.setPrimaryColorsId.")
    override fun setPrimaryColors(@ColorInt vararg colors: Int) {
        @Suppress("DEPRECATION")
        super.setPrimaryColors(*colors)
        if (colors.isNotEmpty()) {
            mMaskViewTop.setTextColor(colors[0])
            mMaskViewBottom.setTextColor(colors[0])
            mBackColor = colors[0]
            mBoundaryColor = colors[0]
            if (mBackColor == 0 || mBackColor == 0xffffffff.toInt()) mBoundaryColor = 0xff606060.toInt()
            if (colors.size > 1) {
                mShadowView.setBackgroundColor(colors[1])
                mMaskViewTop.setBackgroundColor(colors[1])
                mMaskViewBottom.setBackgroundColor(colors[1])
                mModelColor = colors[1]
                lModelColor = ColorUtils.setAlphaComponent(colors[1], 225)
                rModelColor = ColorUtils.setAlphaComponent(colors[1], 200)
                mPaintText.color = ColorUtils.setAlphaComponent(colors[1], 150)
            }
        }
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        super.onStateChanged(refreshLayout, oldState, newState)
        when (newState) {
            RefreshState.PullDownToRefresh -> mMaskViewTop.text = mMaskTextTopPull
            RefreshState.ReleaseToRefresh -> mMaskViewTop.text = mMaskTextTopRelease
            else -> Unit
        }
    }

    override fun onStartAnimator(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        super.onStartAnimator(refreshLayout, height, maxDragHeight)
        val topView = mMaskViewTop
        val shadowView = mShadowView
        val bottomView = mMaskViewBottom
        mCurtainAnimator = AnimatorSet().apply {
            play(ObjectAnimator.ofFloat(topView, "translationY", topView.translationY, -mHalfHeaderHeight.toFloat()))
                .with(ObjectAnimator.ofFloat(bottomView, "translationY", bottomView.translationY, mHalfHeaderHeight.toFloat()))
                .with(ObjectAnimator.ofFloat(shadowView, "alpha", shadowView.alpha, 0f))
            addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    topView.visibility = View.GONE
                    bottomView.visibility = View.GONE
                    shadowView.visibility = View.GONE
                    postStatus(STATUS_GAME_PLAY)
                }
            })
            duration = 800
            startDelay = 200
            start()
        }
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        if (mManualOperation) {
            postStatus(if (success) STATUS_GAME_FINISHED else STATUS_GAME_FAIL)
        } else {
            postStatus(STATUS_GAME_PREPARE)
            // Stop the curtain and close it at its start (the Java version shifted it by half the header, which left it
            // open by that much when the refresh finished before the curtain had opened).
            mCurtainAnimator?.let {
                it.removeAllListeners()
                it.cancel()
            }
            mCurtainAnimator = null
            mMaskViewTop.translationY = 0f
            mMaskViewBottom.translationY = 0f
            mShadowView.alpha = 1f
            mMaskViewTop.visibility = View.VISIBLE
            mMaskViewBottom.visibility = View.VISIBLE
            mShadowView.visibility = View.VISIBLE
        }
        return super.onFinish(refreshLayout, success)
    }

    /**
     * The game's status codes and the header's height ratio.
     */
    companion object {
        /**
         * Before the game.
         */
        @JvmStatic protected val STATUS_GAME_PREPARE = 0

        /**
         * Playing.
         */
        @JvmStatic protected val STATUS_GAME_PLAY = 1

        /**
         * Lost.
         */
        @JvmStatic protected val STATUS_GAME_OVER = 2

        /**
         * Refreshed.
         */
        @JvmStatic protected val STATUS_GAME_FINISHED = 3

        /**
         * The refresh failed.
         */
        @JvmStatic protected val STATUS_GAME_FAIL = 4

        /**
         * The header's height as a share of the screen's.
         */
        @JvmStatic protected val VIEW_HEIGHT_RATIO = .161f
    }
}
