// android-Ultra-Pull-To-Refresh (https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh, MIT, Copyright (c) 2015
// liaohuqiu.net) translated to Kotlin.
package `in`.srain.cube.views.ptr.indicator

import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow

/**
 * An indicator with the tension of the Material pull: the pull slows down past four fifths of the header's height.
 */
class PtrTensionIndicator : PtrIndicator() {

    private val dragRate = 0.5f
    private var downY = 0f
    private var downPos = 0f
    private var oneHeight = 0f
    private var currentDragPercent = 0f
    private var releasePos = 0
    private var releasePercent = -1f

    override fun onPressDown(x: Float, y: Float) {
        super.onPressDown(x, y)
        downY = y
        downPos = getCurrentPosY().toFloat()
    }

    override fun onRelease() {
        super.onRelease()
        releasePos = getCurrentPosY()
        releasePercent = currentDragPercent
    }

    override fun onUIRefreshComplete() {
        releasePos = getCurrentPosY()
        releasePercent = getOverDragPercent()
    }

    override fun setHeaderHeight(height: Int) {
        super.setHeaderHeight(height)
        oneHeight = height * 4f / 5
    }

    override fun processOnMove(currentX: Float, currentY: Float, offsetX: Float, offsetY: Float) {
        if (currentY < downY || oneHeight == 0f) {
            super.processOnMove(currentX, currentY, offsetX, offsetY)
            return
        }
        val scrollTop = (currentY - downY) * dragRate + downPos
        val dragPercent = scrollTop / oneHeight
        if (dragPercent < 0) {
            setOffset(offsetX, 0f)
            return
        }
        currentDragPercent = dragPercent
        val boundedDragPercent = min(1f, abs(dragPercent))
        val extraOS = scrollTop - oneHeight
        val tensionSlingshotPercent = max(0f, min(extraOS, oneHeight * 2) / oneHeight)
        val tensionPercent = ((tensionSlingshotPercent / 4) - (tensionSlingshotPercent / 4).pow(2)) * 2f
        val extraMove = oneHeight * tensionPercent / 2
        val targetY = (oneHeight * boundedDragPercent + extraMove).toInt()
        setOffset(currentX, (targetY - getCurrentPosY()).toFloat())
    }

    override fun getOffsetToKeepHeaderWhileLoading(): Int = getOffsetToRefresh()

    override fun getOffsetToRefresh(): Int = oneHeight.toInt()

    /**
     * How far past the refresh offset the pull is, as a ratio.
     */
    fun getOverDragPercent(): Float = when {
        isUnderTouch -> currentDragPercent
        releasePercent <= 0 -> if (getOffsetToKeepHeaderWhileLoading() == 0) 0f else 1f * getCurrentPosY() / getOffsetToKeepHeaderWhileLoading()
        releasePos == 0 -> 0f
        else -> releasePercent * getCurrentPosY() / releasePos
    }
}
