// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Point
import android.util.AttributeSet
import androidx.core.graphics.ColorUtils
import com.scwang.smart.refresh.header.fungame.FunGameView
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.util.SmartUtil
import kotlin.math.tan

/**
 * A breakout game while refreshing, from FunGameRefresh (`FunGameHitBlockHeader`).
 */
open class FunGameHitBlockHeader @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    FunGameView(context, attrs, 0) {

    /**
     * A block's height.
     */
    @JvmField protected var blockHeight = 0f

    /**
     * A block's width.
     */
    @JvmField protected var blockWidth = 0f

    /**
     * The ball's radius.
     */
    @JvmField protected var BALL_RADIUS: Float

    /**
     * The blocks' paint.
     */
    @JvmField protected var blockPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.FILL }

    /**
     * The blocks' left.
     */
    @JvmField protected var blockLeft = 0f

    /**
     * The racket's left.
     */
    @JvmField protected var racketLeft = 0f

    /**
     * The ball's x.
     */
    @JvmField protected var cx = 0f

    /**
     * The ball's y.
     */
    @JvmField protected var cy = 0f

    /**
     * The blocks hit: column and row.
     */
    @JvmField protected var pointList: MutableList<Point> = ArrayList()

    /**
     * True while the ball moves left.
     */
    @JvmField protected var isLeft = false

    /**
     * The ball's angle, in degrees.
     */
    @JvmField protected var angle = 0

    /**
     * The number of block columns.
     */
    @JvmField protected var blockHorizontalNum: Int

    /**
     * The ball's speed, in pixels per frame.
     */
    @JvmField protected var speed: Int

    init {
        val ta = context.obtainStyledAttributes(attrs, R.styleable.FunGameHitBlockHeader)
        speed = ta.getInt(R.styleable.FunGameHitBlockHeader_srlBallSpeed, SmartUtil.dp2px(SPEED.toFloat()))
        blockHorizontalNum = ta.getInt(R.styleable.FunGameHitBlockHeader_srlBlockHorizontalNum, BLOCK_HORIZONTAL_NUM)
        if (ta.hasValue(R.styleable.FunGameHitBlockHeader_fghBallSpeed)) {
            speed = ta.getInt(R.styleable.FunGameHitBlockHeader_fghBallSpeed, SmartUtil.dp2px(SPEED.toFloat()))
        }
        if (ta.hasValue(R.styleable.FunGameHitBlockHeader_fghBlockHorizontalNum)) {
            blockHorizontalNum = ta.getInt(R.styleable.FunGameHitBlockHeader_fghBlockHorizontalNum, BLOCK_HORIZONTAL_NUM)
        }
        ta.recycle()
        BALL_RADIUS = SmartUtil.dp2px(4f).toFloat()
    }

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        blockHeight = 1f * height / BLOCK_VERTICAL_NUM - LINE_SIZE
        blockWidth = measuredWidth * BLOCK_WIDTH_RATIO
        blockLeft = measuredWidth * BLOCK_POSITION_RATIO
        racketLeft = measuredWidth * RACKET_POSITION_RATIO
        controllerSize = (blockHeight * 1.6f).toInt()
        super.onInitialized(kernel, height, maxDragHeight)
    }

    override fun resetConfigParams() {
        cx = racketLeft - 3 * BALL_RADIUS
        cy = (mHeaderHeight * .5f).toInt().toFloat()
        controllerPosition = LINE_SIZE
        angle = DEFAULT_ANGLE
        isLeft = true
        pointList.clear()
    }

    /**
     * True when the ball at [y] is within the racket.
     */
    protected open fun checkTouchRacket(y: Float): Boolean {
        val diffVal = y - controllerPosition
        return diffVal >= 0 && diffVal <= controllerSize
    }

    /**
     * True when the ball at ([x], [y]) hits a block not hit before; records it.
     */
    protected open fun checkTouchBlock(x: Float, y: Float): Boolean {
        var columnX = ((x - blockLeft - BALL_RADIUS - speed) / blockWidth).toInt()
        if (columnX == blockHorizontalNum) columnX--
        var rowY = (y / blockHeight).toInt()
        if (rowY == BLOCK_VERTICAL_NUM) rowY--
        if (pointList.any { it.equals(columnX, rowY) }) return false
        pointList.add(Point(columnX, rowY))
        return true
    }

    override fun drawGame(canvas: Canvas, width: Int, height: Int) {
        drawColorBlock(canvas)
        drawRacket(canvas)
        if (status == STATUS_GAME_PLAY || status == STATUS_GAME_FINISHED || status == STATUS_GAME_FAIL || isInEditMode) {
            drawBallPath(canvas, width)
        }
    }

    /**
     * Draws the racket.
     */
    protected open fun drawRacket(canvas: Canvas) {
        mPaint.color = rModelColor
        canvas.drawRect(racketLeft, controllerPosition, racketLeft + blockWidth, controllerPosition + controllerSize, mPaint)
    }

    /**
     * Moves the ball one frame on, bounces it and draws it.
     */
    protected open fun drawBallPath(canvas: Canvas, width: Int) {
        mPaint.color = mModelColor
        // In the blocks' area: bounce off a block.
        if (cx <= blockLeft + blockHorizontalNum * blockWidth + (blockHorizontalNum - 1) * LINE_SIZE + BALL_RADIUS) {
            if (checkTouchBlock(cx, cy)) isLeft = false
        }
        // Through the blocks.
        if (cx <= blockLeft + BALL_RADIUS) isLeft = false
        if (cx + BALL_RADIUS >= racketLeft && cx - BALL_RADIUS < racketLeft + blockWidth) {
            if (checkTouchRacket(cy)) {
                // Every block hit: the game is over.
                if (pointList.size == blockHorizontalNum * BLOCK_VERTICAL_NUM) {
                    status = STATUS_GAME_OVER
                    return
                }
                isLeft = true
            }
        } else if (cx > width) {
            status = STATUS_GAME_OVER
        }
        if (cy <= BALL_RADIUS + LINE_SIZE) {
            angle = 180 - DEFAULT_ANGLE
        } else if (cy >= mHeaderHeight - BALL_RADIUS - LINE_SIZE) {
            angle = 180 + DEFAULT_ANGLE
        }
        cx += if (isLeft) -speed else speed
        cy -= tan(Math.toRadians(angle.toDouble())).toFloat() * speed
        canvas.drawCircle(cx, cy, BALL_RADIUS, mPaint)
        invalidate()
    }

    /**
     * Draws the blocks not hit yet.
     */
    protected open fun drawColorBlock(canvas: Canvas) {
        for (i in 0 until blockHorizontalNum * BLOCK_VERTICAL_NUM) {
            val row = i / blockHorizontalNum
            val column = i % blockHorizontalNum
            if (pointList.any { it.equals(column, row) }) continue
            blockPaint.color = ColorUtils.setAlphaComponent(lModelColor, 255 / (column + 1))
            val left = blockLeft + column * (blockWidth + LINE_SIZE)
            val top = LINE_SIZE + row * (blockHeight + LINE_SIZE)
            canvas.drawRect(left, top, left + blockWidth, top + blockHeight, blockPaint)
        }
    }

    /**
     * The game's layout constants.
     */
    companion object {
        /**
         * Blocks per column.
         */
        @JvmStatic protected val BLOCK_VERTICAL_NUM = 5

        /**
         * Block columns by default.
         */
        @JvmStatic protected val BLOCK_HORIZONTAL_NUM = 3

        /**
         * A block's width as a share of the view's.
         */
        @JvmStatic protected val BLOCK_WIDTH_RATIO = .01806f

        /**
         * The racket's position as a share of the view's width.
         */
        @JvmStatic protected val RACKET_POSITION_RATIO = .8f

        /**
         * The blocks' position as a share of the view's width.
         */
        @JvmStatic protected val BLOCK_POSITION_RATIO = .08f

        /**
         * The ball's starting angle.
         */
        @JvmStatic protected val DEFAULT_ANGLE = 30

        /**
         * The ball's default speed, in dp per frame.
         */
        @JvmStatic protected val SPEED = 3

        // The game's own 1 px line (the Java version's package-private DIVIDING_LINE_SIZE, which hid FunGameView's).
        private const val LINE_SIZE = 1f
    }
}
