// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header.flyrefresh

import android.content.Context
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.util.AttributeSet
import android.view.View
import androidx.annotation.ColorInt
import androidx.core.graphics.ColorUtils
import androidx.core.view.animation.PathInterpolatorCompat
import com.scwang.smart.refresh.header.R
import kotlin.math.max

/**
 * Hills and trees behind the paper plane, from FlyRefresh (`MountainSceneView`).
 */
open class MountainSceneView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : View(context, attrs) {

    /**
     * The sky's color.
     */
    @JvmField protected var COLOR_BACKGROUND = 0xFF7ECEC9.toInt()

    /**
     * The far hill's color.
     */
    @JvmField protected var COLOR_MOUNTAIN_1 = 0xFF86DAD7.toInt()

    /**
     * The middle hill's color.
     */
    @JvmField protected var COLOR_MOUNTAIN_2 = 0xFF3C929C.toInt()

    /**
     * The near hill's color.
     */
    @JvmField protected var COLOR_MOUNTAIN_3 = 0xFF3E5F73.toInt()

    /**
     * The near trees' branch color.
     */
    @JvmField protected var COLOR_TREE_1_BRANCH = 0xFF1F7177.toInt()

    /**
     * The near trees' trunk color.
     */
    @JvmField protected var COLOR_TREE_1_BRINK = 0xFF0C3E48.toInt()

    /**
     * The middle trees' branch color.
     */
    @JvmField protected var COLOR_TREE_2_BRANCH = 0xFF34888F.toInt()

    /**
     * The middle trees' trunk color.
     */
    @JvmField protected var COLOR_TREE_2_BRINK = 0xFF1B6169.toInt()

    /**
     * The far trees' branch color.
     */
    @JvmField protected var COLOR_TREE_3_BRANCH = 0xFF57B1AE.toInt()

    /**
     * The far trees' trunk color.
     */
    @JvmField protected var COLOR_TREE_3_BRINK = 0xFF62A4AD.toInt()

    /**
     * The hills' paint.
     */
    @JvmField protected var mMountPaint = Paint()

    /**
     * The trunks' paint.
     */
    @JvmField protected var mTrunkPaint = Paint()

    /**
     * The branches' paint.
     */
    @JvmField protected var mBranchPaint = Paint()

    /**
     * The branches' outline paint.
     */
    @JvmField protected var mBoarderPaint = Paint()

    /**
     * The far hill.
     */
    @JvmField protected var mMount1 = Path()

    /**
     * The middle hill.
     */
    @JvmField protected var mMount2 = Path()

    /**
     * The near hill.
     */
    @JvmField protected var mMount3 = Path()

    /**
     * A tree's trunk.
     */
    @JvmField protected var mTrunk = Path()

    /**
     * A tree's branches.
     */
    @JvmField protected var mBranch = Path()

    /**
     * Scales the hills to the view.
     */
    @JvmField protected var mTransMatrix = Matrix()

    /**
     * The horizontal scale.
     */
    @JvmField protected var mScaleX = 5f

    /**
     * The vertical scale.
     */
    @JvmField protected var mScaleY = 5f

    /**
     * How far the hills moved, from the pull.
     */
    @JvmField protected var mMoveFactor = 0f

    /**
     * The latest pull percent.
     */
    @JvmField protected var mBounceMax = 1f

    /**
     * The trees' current bend.
     */
    @JvmField protected var mTreeBendFactor = Float.MAX_VALUE

    /**
     * The height the scene is drawn for, or 0 for the view's height.
     */
    @JvmField protected var mViewportHeight = 0

    init {
        mMountPaint.isAntiAlias = true
        mMountPaint.style = Paint.Style.FILL
        mTrunkPaint.isAntiAlias = true
        mBranchPaint.isAntiAlias = true
        mBoarderPaint.isAntiAlias = true
        mBoarderPaint.style = Paint.Style.STROKE
        mBoarderPaint.strokeWidth = 2f
        mBoarderPaint.strokeJoin = Paint.Join.ROUND
        val ta = context.obtainStyledAttributes(attrs, R.styleable.MountainSceneView)
        if (ta.hasValue(R.styleable.MountainSceneView_msvPrimaryColor)) {
            setPrimaryColor(ta.getColor(R.styleable.MountainSceneView_msvPrimaryColor, 0xff000000.toInt()))
        }
        mViewportHeight = ta.getDimensionPixelOffset(R.styleable.MountainSceneView_msvViewportHeight, 0)
        ta.recycle()
        updateMountainPath(mMoveFactor, HEIGHT)
        updateTreePath(mMoveFactor, true)
        // A decoration: hidden from accessibility services unless the app gives it a description.
        if (contentDescription == null) importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        mScaleX = 1f * measuredWidth / WIDTH
        mScaleY = 1f * (if (mViewportHeight > 0) mViewportHeight else measuredHeight) / HEIGHT
        updateMountainPath(mMoveFactor, measuredHeight)
        updateTreePath(mMoveFactor, true)
    }

    /**
     * Rebuilds the hills for the pull [factor] and the view's [height].
     */
    protected open fun updateMountainPath(factor: Float, height: Int) {
        mTransMatrix.reset()
        mTransMatrix.setScale(mScaleX, mScaleY)
        val w = WIDTH.toFloat()
        val h = HEIGHT.toFloat()
        val offset1 = 10 * factor
        mMount1.reset()
        mMount1.moveTo(0f, 95 + offset1)
        mMount1.lineTo(55f, 74 + offset1)
        mMount1.lineTo(146f, 104 + offset1)
        mMount1.lineTo(227f, 72 + offset1)
        mMount1.lineTo(w, 80 + offset1)
        mMount1.lineTo(w, h)
        mMount1.lineTo(0f, h)
        mMount1.close()
        mMount1.transform(mTransMatrix)
        val offset2 = 20 * factor
        mMount2.reset()
        mMount2.moveTo(0f, 103 + offset2)
        mMount2.lineTo(67f, 90 + offset2)
        mMount2.lineTo(165f, 115 + offset2)
        mMount2.lineTo(221f, 87 + offset2)
        mMount2.lineTo(w, 100 + offset2)
        mMount2.lineTo(w, h)
        mMount2.lineTo(0f, h)
        mMount2.close()
        mMount2.transform(mTransMatrix)
        val offset3 = 30 * factor
        mMount3.reset()
        mMount3.moveTo(0f, 114 + offset3)
        mMount3.cubicTo(30f, 106 + offset3, 196f, 97 + offset3, w, 104 + offset3)
        mMount3.lineTo(w, height / mScaleY)
        mMount3.lineTo(0f, height / mScaleY)
        mMount3.close()
        mMount3.transform(mTransMatrix)
    }

    /**
     * Rebuilds the tree bent by [factor]; [force] rebuilds it even when the bend did not change.
     */
    protected open fun updateTreePath(factor: Float, force: Boolean) {
        if (factor == mTreeBendFactor && !force) return
        // Remember the bend, so an unchanged one is skipped (the Java version never stored it).
        mTreeBendFactor = factor
        val interpolator = PathInterpolatorCompat.create(0.8f, -0.5f * factor)
        val width = TREE_WIDTH.toFloat()
        val height = TREE_HEIGHT.toFloat()
        val maxMove = width * 0.3f * factor
        val trunkSize = width * 0.05f
        val branchSize = width * 0.2f
        val x0 = width / 2
        val y0 = height
        val n = 25
        val dp = 1f / n
        val dy = -dp * height
        var y = y0
        var p = 0f
        val xx = FloatArray(n + 1)
        val yy = FloatArray(n + 1)
        for (i in 0..n) {
            xx[i] = interpolator.getInterpolation(p) * maxMove + x0
            yy[i] = y
            y += dy
            p += dp
        }
        mTrunk.reset()
        mTrunk.moveTo(x0 - trunkSize, y0)
        val max = (n * 0.7f).toInt()
        val max1 = (max * 0.5f).toInt()
        var diff = (max - max1).toFloat()
        for (i in 0 until max) {
            mTrunk.lineTo(if (i < max1) xx[i] - trunkSize else xx[i] - trunkSize * (max - i) / diff, yy[i])
        }
        for (i in max - 1 downTo 0) {
            mTrunk.lineTo(if (i < max1) xx[i] + trunkSize else xx[i] + trunkSize * (max - i) / diff, yy[i])
        }
        mTrunk.close()
        mBranch.reset()
        val min = (n * 0.4f).toInt()
        diff = (n - min).toFloat()
        mBranch.moveTo(xx[min] - branchSize, yy[min])
        mBranch.addArc(RectF(xx[min] - branchSize, yy[min] - branchSize, xx[min] + branchSize, yy[min] + branchSize), 0f, 180f)
        for (i in min..n) {
            val f = (i - min) / diff
            mBranch.lineTo(xx[i] - branchSize + f * f * branchSize, yy[i])
        }
        for (i in n downTo min) {
            val f = (i - min) / diff
            mBranch.lineTo(xx[i] + branchSize - f * f * branchSize, yy[i])
        }
    }

    /**
     * Draws a tree at [scale] standing on ([baseX], [baseY]).
     */
    protected open fun drawTree(canvas: Canvas, scale: Float, baseX: Float, baseY: Float, colorTrunk: Int, colorBranch: Int) {
        canvas.save()
        canvas.translate(baseX - TREE_WIDTH * scale / 2, baseY - TREE_HEIGHT * scale)
        canvas.scale(scale, scale)
        mBranchPaint.color = colorBranch
        canvas.drawPath(mBranch, mBranchPaint)
        mTrunkPaint.color = colorTrunk
        canvas.drawPath(mTrunk, mTrunkPaint)
        mBoarderPaint.color = colorTrunk
        canvas.drawPath(mBranch, mBoarderPaint)
        canvas.restore()
    }

    override fun onDraw(canvas: Canvas) {
        super.onDraw(canvas)
        canvas.drawColor(COLOR_BACKGROUND)
        mMountPaint.color = COLOR_MOUNTAIN_1
        canvas.drawPath(mMount1, mMountPaint)
        canvas.save()
        canvas.scale(-1f, 1f, width / 2f, 0f)
        drawTree(canvas, 0.12f * mScaleX, 180 * mScaleX, (93 + 20 * mMoveFactor) * mScaleY, COLOR_TREE_3_BRINK, COLOR_TREE_3_BRANCH)
        drawTree(canvas, 0.1f * mScaleX, 200 * mScaleX, (96 + 20 * mMoveFactor) * mScaleY, COLOR_TREE_3_BRINK, COLOR_TREE_3_BRANCH)
        canvas.restore()
        mMountPaint.color = COLOR_MOUNTAIN_2
        canvas.drawPath(mMount2, mMountPaint)
        drawTree(canvas, 0.2f * mScaleX, 160 * mScaleX, (105 + 30 * mMoveFactor) * mScaleY, COLOR_TREE_1_BRINK, COLOR_TREE_1_BRANCH)
        drawTree(canvas, 0.14f * mScaleX, 180 * mScaleX, (105 + 30 * mMoveFactor) * mScaleY, COLOR_TREE_2_BRINK, COLOR_TREE_2_BRANCH)
        drawTree(canvas, 0.16f * mScaleX, 140 * mScaleX, (105 + 30 * mMoveFactor) * mScaleY, COLOR_TREE_2_BRINK, COLOR_TREE_2_BRANCH)
        mMountPaint.color = COLOR_MOUNTAIN_3
        canvas.drawPath(mMount3, mMountPaint)
    }

    /**
     * Tints the whole scene from [color], the sky's color.
     */
    open fun setPrimaryColor(@ColorInt color: Int) {
        COLOR_BACKGROUND = color
        COLOR_MOUNTAIN_1 = ColorUtils.compositeColors(0x99ffffff.toInt(), color)
        COLOR_MOUNTAIN_2 = ColorUtils.compositeColors(0x993C929C.toInt(), color)
        COLOR_MOUNTAIN_3 = ColorUtils.compositeColors(0xCC3E5F73.toInt(), color)
        COLOR_TREE_1_BRANCH = ColorUtils.compositeColors(0x551F7177, color)
        COLOR_TREE_1_BRINK = ColorUtils.compositeColors(0xCC0C3E48.toInt(), color)
        COLOR_TREE_2_BRANCH = ColorUtils.compositeColors(0x5534888F, color)
        COLOR_TREE_2_BRINK = ColorUtils.compositeColors(0xCC1B6169.toInt(), color)
        COLOR_TREE_3_BRANCH = ColorUtils.compositeColors(0x5557B1AE, color)
        COLOR_TREE_3_BRINK = ColorUtils.compositeColors(0xCC62A4AD.toInt(), color)
    }

    /**
     * Moves the hills and bends the trees for the pull [percent].
     */
    open fun updatePercent(percent: Float) {
        mBounceMax = percent
        val bendFactor = max(0f, percent)
        mMoveFactor = max(0f, mBounceMax)
        updateMountainPath(mMoveFactor, if (measuredHeight > 0) measuredHeight else HEIGHT)
        updateTreePath(bendFactor, false)
    }

    /**
     * The scene's design size.
     */
    companion object {
        /**
         * The design width.
         */
        @JvmStatic protected val WIDTH = 240

        /**
         * The design height.
         */
        @JvmStatic protected val HEIGHT = 180

        /**
         * A tree's design width.
         */
        @JvmStatic protected val TREE_WIDTH = 100

        /**
         * A tree's design height.
         */
        @JvmStatic protected val TREE_HEIGHT = 200
    }
}
