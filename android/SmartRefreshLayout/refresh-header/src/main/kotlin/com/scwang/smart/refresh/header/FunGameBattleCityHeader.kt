// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header

import android.content.Context
import android.graphics.Canvas
import android.graphics.Point
import android.graphics.RectF
import android.util.AttributeSet
import android.util.SparseArray
import com.scwang.smart.refresh.header.fungame.FunGameView
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.util.SmartUtil
import java.util.LinkedList
import java.util.Queue
import java.util.Random
import kotlin.math.floor
import kotlin.math.max

/**
 * A tank game while refreshing, from FunGameRefresh (`FunGameBattleCityHeader`).
 */
open class FunGameBattleCityHeader @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    FunGameView(context, attrs, 0) {

    /**
     * The enemy tanks on each track.
     */
    @JvmField protected var eTankSparseArray = SparseArray<Queue<RectF>>()

    /**
     * The bullets on screen.
     */
    @JvmField protected var mBulletList: Queue<Point> = LinkedList()

    /**
     * The bullet that hit a tank this frame.
     */
    @JvmField protected var usedBullet: Point? = null

    /**
     * Picks a track.
     */
    @JvmField protected var random = Random()

    /**
     * A bullet's radius.
     */
    @JvmField protected var bulletRadius = 0f

    /**
     * The space between enemy tanks.
     */
    @JvmField protected var enemyTankSpace = 0

    /**
     * The space between bullets.
     */
    @JvmField protected var bulletSpace = 0

    /**
     * The barrel's size.
     */
    @JvmField protected var barrelSize = 0

    /**
     * The enemy tanks' speed.
     */
    @JvmField protected var enemySpeed = 1

    /**
     * The bullets' speed.
     */
    @JvmField protected var bulletSpeed = 4

    /**
     * The distance since the last enemy tank.
     */
    @JvmField protected var offsetETankX = 0

    /**
     * The distance since the last bullet.
     */
    @JvmField protected var offsetMBulletX = 0

    /**
     * The enemy tanks that got through.
     */
    @JvmField protected var overstepNum = 0

    /**
     * The tanks to destroy for the next level.
     */
    @JvmField protected var levelNum = 0

    /**
     * The tanks destroyed in this level.
     */
    @JvmField protected var wipeOutNum = 0

    /**
     * True until the first enemy tank is sent.
     */
    @JvmField protected var once = true

    init {
        resetTracks()
    }

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        controllerSize = height / TANK_ROW_NUM
        barrelSize = floor(controllerSize * TANK_BARREL_RATIO + .5f).toInt()
        bulletRadius = (barrelSize - 2 * DIVIDING_LINE_SIZE) * .5f
        super.onInitialized(kernel, height, maxDragHeight)
    }

    // Empty tracks and no bullets; also set up at construction, so drawing before onInitialized does not throw (the
    // Java version left them null until then).
    private fun resetTracks() {
        eTankSparseArray = SparseArray<Queue<RectF>>().apply { for (i in 0 until TANK_ROW_NUM) put(i, LinkedList()) }
        mBulletList = LinkedList()
    }

    override fun resetConfigParams() {
        status = STATUS_GAME_PREPARE
        controllerPosition = DIVIDING_LINE_SIZE
        enemySpeed = SmartUtil.dp2px(1f)
        bulletSpeed = SmartUtil.dp2px(4f)
        levelNum = DEFAULT_TANK_MAGIC_TOTAL_NUM
        wipeOutNum = 0
        once = true
        enemyTankSpace = controllerSize + barrelSize + DEFAULT_ENEMY_TANK_NUM_SPACING
        bulletSpace = DEFAULT_BULLET_NUM_SPACING
        resetTracks()
    }

    /**
     * A new enemy tank at the left of track [index].
     */
    protected open fun generateEnemyTank(index: Int): RectF {
        val left = -(controllerSize + barrelSize).toFloat()
        val top = index * controllerSize + DIVIDING_LINE_SIZE
        return RectF(left, top, left + barrelSize * 2.5f, top + controllerSize)
    }

    /**
     * The track at [y].
     */
    protected open fun getTrackIndex(y: Int): Int {
        // max(1, …): a header shorter than the tracks divided by zero in the Java version.
        val index = y / max(1, mHeaderHeight / TANK_ROW_NUM)
        return max(if (index >= TANK_ROW_NUM) TANK_ROW_NUM - 1 else index, 0)
    }

    /**
     * True when the bullet at [point] destroys a tank.
     */
    protected open fun checkWipeOutETank(point: Point): Boolean {
        val track = eTankSparseArray.get(getTrackIndex(point.y)) ?: return false
        val rectF = track.peek()
        if (rectF != null && rectF.contains(point.x.toFloat(), point.y.toFloat())) {
            if (++wipeOutNum == levelNum) upLevel()
            track.poll()
            return true
        }
        return false
    }

    /**
     * Makes the game harder.
     */
    protected open fun upLevel() {
        levelNum += DEFAULT_TANK_MAGIC_TOTAL_NUM
        enemySpeed += SmartUtil.dp2px(1f)
        bulletSpeed += SmartUtil.dp2px(1f)
        wipeOutNum = 0
        if (enemyTankSpace > 12) enemyTankSpace -= 12
        if (bulletSpace > 30) bulletSpace -= 30
    }

    /**
     * True when the player's tank at ([selfX], [selfY]) hits the first tank on track [index].
     */
    protected open fun checkTankCrash(index: Int, selfX: Float, selfY: Float): Boolean =
        eTankSparseArray.get(index)?.peek()?.contains(selfX, selfY) == true

    /**
     * A random track.
     */
    protected open fun appearanceOption(): Int = random.nextInt(TANK_ROW_NUM)

    override fun drawGame(canvas: Canvas, width: Int, height: Int) {
        drawSelfTank(canvas, width)
        if (status == STATUS_GAME_PLAY || status == STATUS_GAME_FINISHED || status == STATUS_GAME_FAIL) {
            drawEnemyTank(canvas, width)
            drawBulletPath(canvas, width)
        }
        if (isInEditMode) {
            val s = controllerSize.toFloat()
            drawTank(canvas, RectF(s, 0f, s * 2, s))
            drawTank(canvas, RectF(0f, s, s, s * 2))
            drawTank(canvas, RectF(s * 3, s * 2, s * 4, s * 3))
        }
    }

    /**
     * Fires and moves the bullets.
     */
    protected open fun drawBulletPath(canvas: Canvas, width: Int) {
        mPaint.color = mModelColor
        offsetMBulletX += bulletSpeed
        if (offsetMBulletX / bulletSpace == 1) offsetMBulletX = 0
        if (offsetMBulletX == 0) {
            mBulletList.offer(Point(width - controllerSize - barrelSize, (controllerPosition + controllerSize * .5f).toInt()))
        }
        var isOverStep = false
        for (point in mBulletList) {
            if (checkWipeOutETank(point)) {
                usedBullet = point
                continue
            }
            if (point.x + bulletRadius <= 0) isOverStep = true
            drawBullet(canvas, point)
        }
        if (isOverStep) mBulletList.poll()
        mBulletList.remove(usedBullet)
        usedBullet = null
    }

    /**
     * Moves and draws one bullet.
     */
    protected open fun drawBullet(canvas: Canvas, point: Point) {
        point.x -= bulletSpeed
        canvas.drawCircle(point.x.toFloat(), point.y.toFloat(), bulletRadius, mPaint)
    }

    /**
     * Draws the player's tank; a crash ends the game.
     */
    protected open fun drawSelfTank(canvas: Canvas, width: Int) {
        mPaint.color = rModelColor
        val selfX = (width - controllerSize).toFloat()
        val isAboveCrash = checkTankCrash(getTrackIndex(controllerPosition.toInt()), selfX, controllerPosition)
        val isBelowCrash = checkTankCrash(getTrackIndex((controllerPosition + controllerSize).toInt()), selfX, controllerPosition + controllerSize)
        if (isAboveCrash || isBelowCrash) status = STATUS_GAME_OVER
        canvas.drawRect(selfX, controllerPosition + DIVIDING_LINE_SIZE, width.toFloat(), controllerPosition + controllerSize + DIVIDING_LINE_SIZE, mPaint)
        val barrelTop = controllerPosition + (controllerSize - barrelSize) * .5f
        canvas.drawRect(selfX - barrelSize, barrelTop, selfX, barrelTop + barrelSize, mPaint)
    }

    /**
     * Sends and moves the enemy tanks.
     */
    protected open fun drawEnemyTank(canvas: Canvas, width: Int) {
        mPaint.color = lModelColor
        offsetETankX += enemySpeed
        if (offsetETankX / enemyTankSpace == 1 || once) {
            offsetETankX = 0
            once = false
        }
        var isOverstep = false
        val option = appearanceOption()
        for (i in 0 until TANK_ROW_NUM) {
            val rectFQueue = eTankSparseArray.get(i) ?: continue
            if (offsetETankX == 0 && i == option) rectFQueue.offer(generateEnemyTank(i))
            for (rectF in rectFQueue) {
                if (rectF.left >= width) {
                    isOverstep = true
                    if (++overstepNum >= DEFAULT_TANK_MAGIC_TOTAL_NUM) {
                        status = STATUS_GAME_OVER
                        break
                    }
                    continue
                }
                drawTank(canvas, rectF)
            }
            if (status == STATUS_GAME_OVER) break
            if (isOverstep) {
                rectFQueue.poll()
                isOverstep = false
            }
        }
        invalidate()
    }

    /**
     * Moves and draws one enemy tank.
     */
    protected open fun drawTank(canvas: Canvas, rectF: RectF) {
        rectF.set(rectF.left + enemySpeed, rectF.top, rectF.right + enemySpeed, rectF.bottom)
        canvas.drawRect(rectF, mPaint)
        val barrelTop = rectF.top + (controllerSize - barrelSize) * .5f
        canvas.drawRect(rectF.right, barrelTop, rectF.right + barrelSize, barrelTop + barrelSize, mPaint)
    }

    /**
     * The game's constants.
     */
    companion object {
        /**
         * The number of tracks.
         */
        @JvmStatic protected var TANK_ROW_NUM = 3

        /**
         * The barrel's size as a share of a tank's.
         */
        @JvmStatic protected val TANK_BARREL_RATIO = 1 / 3f

        /**
         * The space between bullets by default.
         */
        @JvmStatic protected val DEFAULT_BULLET_NUM_SPACING = 360

        /**
         * The space between enemy tanks by default.
         */
        @JvmStatic protected val DEFAULT_ENEMY_TANK_NUM_SPACING = 60

        /**
         * The tanks that may get through, and the tanks to destroy per level.
         */
        @JvmStatic protected val DEFAULT_TANK_MAGIC_TOTAL_NUM = 8
    }
}
