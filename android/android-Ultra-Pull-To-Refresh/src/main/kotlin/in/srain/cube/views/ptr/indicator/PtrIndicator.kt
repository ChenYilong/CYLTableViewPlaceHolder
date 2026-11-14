// android-Ultra-Pull-To-Refresh (https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh, MIT, Copyright (c) 2015
// liaohuqiu.net) translated to Kotlin.
package `in`.srain.cube.views.ptr.indicator

import android.graphics.PointF
import kotlin.math.abs

/**
 * Tracks the finger and the pulled distance of a [in.srain.cube.views.ptr.PtrFrameLayout]: the current and last
 * positions, the trigger offsets and the resistance. Positions count pixels pulled away from the start, for the header
 * (pulled down) and, with [isHeader] false, for the footer (pulled up, pull request #157).
 */
open class PtrIndicator {

    /**
     * The pulled distance at which a release refreshes.
     */
    protected var mOffsetToRefresh = 0

    /**
     * The pulled distance at which a release loads more (pull request #157).
     */
    protected var mOffsetToLoadMore = 0

    private val ptLastMove = PointF()
    private val ptPressDown = PointF()
    private var currentPos = 0
    private var lastPos = 0
    private var pressedPos = 0
    private var offsetToKeepHeaderWhileLoadingValue = -1
    private var refreshCompleteY = 0

    /**
     * The horizontal move of the last finger move.
     */
    var offsetX = 0f
        private set

    /**
     * The vertical move of the last finger move, after the resistance.
     */
    var offsetY = 0f
        private set

    /**
     * The header's height in pixels.
     */
    var headerHeight = 0
        private set

    /**
     * The footer's height in pixels (pull request #157).
     */
    var footerHeight = 0
        private set

    /**
     * YES while a finger is down.
     */
    var isUnderTouch = false
        private set

    /**
     * YES when the positions are the header's (pulled down), NO for the footer's (pulled up; pull request #157).
     */
    var isHeader = true

    /**
     * How hard the frame is to pull: the finger moves this many pixels per pixel pulled. Default 1.7.
     */
    var resistance = 1.7f

    /**
     * Pixels the finger moves before a pull starts (pull request #288). Default 0.
     */
    var deadZone = 0

    /**
     * The system's touch slop, set by the frame.
     */
    var touchSlop = 0

    /**
     * The refresh offset as a ratio of the header's height (`ratioOfHeaderHeightToRefresh`). Default 1.2.
     */
    var ratioOfHeaderToHeightRefresh = 1.2f
        private set

    /**
     * Sets the refresh offset to [ratio] times the header's (and the load-more offset to the footer's) height.
     */
    fun setRatioOfHeaderHeightToRefresh(ratio: Float) {
        ratioOfHeaderToHeightRefresh = ratio
        mOffsetToRefresh = (headerHeight * ratio).toInt()
        mOffsetToLoadMore = (footerHeight * ratio).toInt()
    }

    /**
     * The pulled distance at which a release refreshes.
     */
    open fun getOffsetToRefresh(): Int = mOffsetToRefresh

    /**
     * Sets the pulled distance at which a release refreshes.
     */
    fun setOffsetToRefresh(offset: Int) {
        if (offset > 0) ratioOfHeaderToHeightRefresh = headerHeight * 1f / offset
        mOffsetToRefresh = offset
        mOffsetToLoadMore = offset
    }

    /**
     * The pulled distance at which a release loads more (pull request #157).
     */
    fun getOffsetToLoadMore(): Int = mOffsetToLoadMore

    /**
     * The trigger offset of the side being pulled.
     */
    fun getOffsetToTrigger(): Int = if (isHeader) getOffsetToRefresh() else getOffsetToLoadMore()

    /**
     * The finger is up.
     */
    open fun onRelease() {
        isUnderTouch = false
    }

    /**
     * Remembers where refreshing completed, for `enabledNextPtrAtOnce`.
     */
    open fun onUIRefreshComplete() {
        refreshCompleteY = currentPos
    }

    /**
     * YES once pulled down past where the last refresh completed.
     */
    fun goDownCrossFinishPosition(): Boolean = currentPos >= refreshCompleteY

    /**
     * Turns a finger move into [offsetX] and [offsetY]. Far past the trigger the pull gets progressively harder
     * (pull request #209).
     */
    protected open fun processOnMove(currentX: Float, currentY: Float, offsetX: Float, offsetY: Float) {
        val height = if (isHeader) headerHeight else footerHeight
        if (isOverOffsetToRefresh() && offsetY > 0 && height > 0 && currentPos > 1.2f * height) {
            setOffset(offsetX, offsetY / resistance / (currentPos / (height / 8f)).coerceAtLeast(1f))
        } else {
            setOffset(offsetX, offsetY / resistance)
        }
    }

    /**
     * A finger went down at ([x], [y]).
     */
    open fun onPressDown(x: Float, y: Float) {
        isUnderTouch = true
        pressedPos = currentPos
        ptLastMove.set(x, y)
        ptPressDown.set(x, y)
    }

    /**
     * Restarts the move from ([x], [y]) without a move, for example when another finger takes over (issue #41).
     */
    fun resetLastMove(x: Float, y: Float) {
        ptLastMove.set(x, y)
    }

    /**
     * The finger moved to ([x], [y]).
     */
    fun onMove(x: Float, y: Float) {
        val dx = x - ptLastMove.x
        val dy = y - ptLastMove.y
        processOnMove(x, y, dx, dy)
        ptLastMove.set(x, y)
    }

    /**
     * Sets the last move's offsets.
     */
    protected fun setOffset(x: Float, y: Float) {
        offsetX = x
        offsetY = y
    }

    /**
     * The finger's horizontal distance from where it went down (pull requests #178, #209, #270).
     */
    fun getDistanceX(): Float = ptLastMove.x - ptPressDown.x

    /**
     * The finger's vertical distance from where it went down (pull requests #178, #209, #270).
     */
    fun getDistanceY(): Float = ptLastMove.y - ptPressDown.y

    /**
     * YES when the finger moved more sideways than up or down since it went down (pull request #270).
     */
    fun isMovedHorizontal(): Boolean = abs(getDistanceX()) > abs(getDistanceY())

    /**
     * YES while the finger is still within the touch slop of where it went down (pull request #157).
     */
    fun moveLesserThanTouchSlop(): Boolean = abs(getDistanceY()) < touchSlop

    /**
     * YES while the finger is still within [deadZone] of where it went down (pull request #288).
     */
    fun isInDeadZone(): Boolean = abs(getDistanceY()) < deadZone

    /**
     * The position before the last change.
     */
    fun getLastPosY(): Int = lastPos

    /**
     * The pulled distance.
     */
    fun getCurrentPosY(): Int = currentPos

    /**
     * Moves to [current].
     */
    fun setCurrentPos(current: Int) {
        lastPos = currentPos
        currentPos = current
        onUpdatePos(current, lastPos)
    }

    /**
     * Called after every position change.
     */
    protected open fun onUpdatePos(current: Int, last: Int) {}

    /**
     * Sets the header's height and updates the refresh offset.
     */
    open fun setHeaderHeight(height: Int) {
        headerHeight = height
        updateHeight()
    }

    /**
     * Sets the footer's height and updates the load-more offset (pull request #157).
     */
    fun setFooterHeight(height: Int) {
        footerHeight = height
        updateHeight()
    }

    /**
     * Recomputes the offsets from the heights.
     */
    protected open fun updateHeight() {
        mOffsetToRefresh = (ratioOfHeaderToHeightRefresh * headerHeight).toInt()
        mOffsetToLoadMore = (ratioOfHeaderToHeightRefresh * footerHeight).toInt()
    }

    /**
     * Takes the positions and heights of [ptrSlider], when the frame switches indicators.
     */
    open fun convertFrom(ptrSlider: PtrIndicator) {
        currentPos = ptrSlider.currentPos
        lastPos = ptrSlider.lastPos
        headerHeight = ptrSlider.headerHeight
        footerHeight = ptrSlider.footerHeight
        isHeader = ptrSlider.isHeader
        resistance = ptrSlider.resistance
        deadZone = ptrSlider.deadZone
        touchSlop = ptrSlider.touchSlop
        updateHeight()
    }

    /**
     * YES while pulled.
     */
    fun hasLeftStartPosition(): Boolean = currentPos > POS_START

    /**
     * YES on the change that left the start.
     */
    fun hasJustLeftStartPosition(): Boolean = lastPos == POS_START && hasLeftStartPosition()

    /**
     * YES on the change that came back to the start.
     */
    fun hasJustBackToStartPosition(): Boolean = lastPos != POS_START && isInStartPosition()

    /**
     * YES at or past the trigger offset of the side being pulled.
     */
    fun isOverOffsetToRefresh(): Boolean = currentPos >= getOffsetToTrigger()

    /**
     * YES once the position changed since the finger went down.
     */
    fun hasMovedAfterPressedDown(): Boolean = currentPos != pressedPos

    /**
     * YES at the start.
     */
    fun isInStartPosition(): Boolean = currentPos == POS_START

    /**
     * YES on the change that crossed the trigger offset going away from the start.
     */
    fun crossRefreshLineFromTopToBottom(): Boolean = lastPos < getOffsetToTrigger() && currentPos >= getOffsetToTrigger()

    /**
     * YES on the change that reached the header's (or footer's) height going away from the start.
     */
    fun hasJustReachedHeaderHeightFromTopToBottom(): Boolean {
        val height = if (isHeader) headerHeight else footerHeight
        return lastPos < height && currentPos >= height
    }

    /**
     * YES past the offset kept while loading.
     */
    fun isOverOffsetToKeepHeaderWhileLoading(): Boolean = currentPos > getOffsetToKeepHeaderWhileLoading()

    /**
     * Sets the offset kept while loading; a negative value keeps the header's (footer's) height.
     */
    fun setOffsetToKeepHeaderWhileLoading(offset: Int) {
        offsetToKeepHeaderWhileLoadingValue = offset
    }

    /**
     * The offset kept while loading: the set value, or the header's (footer's) height.
     */
    open fun getOffsetToKeepHeaderWhileLoading(): Int = when {
        offsetToKeepHeaderWhileLoadingValue >= 0 -> offsetToKeepHeaderWhileLoadingValue
        isHeader -> headerHeight
        else -> footerHeight
    }

    /**
     * YES when already at [to].
     */
    fun isAlreadyHere(to: Int): Boolean = currentPos == to

    /**
     * The last position over the header's (footer's) height.
     */
    fun getLastPercent(): Float {
        val height = if (isHeader) headerHeight else footerHeight
        return if (height == 0) 0f else lastPos * 1f / height
    }

    /**
     * The position over the header's (footer's) height.
     */
    fun getCurrentPercent(): Float {
        val height = if (isHeader) headerHeight else footerHeight
        return if (height == 0) 0f else currentPos * 1f / height
    }

    /**
     * YES when [to] is before the start.
     */
    fun willOverTop(to: Int): Boolean = to < POS_START

    /**
     * Constants.
     */
    companion object {
        /**
         * The start position: nothing pulled.
         */
        const val POS_START = 0
    }
}
