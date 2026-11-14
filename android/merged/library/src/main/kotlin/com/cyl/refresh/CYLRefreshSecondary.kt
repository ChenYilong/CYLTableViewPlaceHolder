package com.cyl.refresh

import android.content.Context
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.scwang.smart.refresh.layout.SmartRefreshLayout

/**
 * Holds a second floor's content over the list and follows the finger on it (iOS "second floor": a pull past
 * `secondaryTriggerOffset` opens a page above the header, or below the footer).
 */
private class CYLSecondaryHost(context: Context, private val onSwipe: (Float) -> Unit) : FrameLayout(context) {
    private var downY = 0f

    override fun dispatchTouchEvent(event: MotionEvent): Boolean {
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN -> downY = event.y
            MotionEvent.ACTION_UP -> onSwipe(event.y - downY)
        }
        return super.dispatchTouchEvent(event)
    }
}

/**
 * The second floor of a header or a footer (iOS `secondary…` properties of `CYLRefreshHeader` and
 * `CYLRefreshBackFooter`): a view placed over the layout that slides in from the header's (or the footer's) side.
 */
internal class CYLRefreshSecondaryFloor(private val component: CYLRefreshComponent) {
    var triggerOffset = 0f
    var dimension = 0f
    var closeTriggerOffset = 80f
    var velocity = 0f
    var openedBlock: CYLRefreshComponentAction? = null
    var closedBlock: CYLRefreshComponentAction? = null

    var view: View? = null
        set(value) {
            val wasOpen = isOpen
            if (wasOpen) removeHost()
            field = value
            if (wasOpen && value != null) show(animated = false)
        }

    var isOpen = false
        private set

    /** The pull's distance in pixels at the last drag, read when the finger lets go. */
    var lastDragOffset = 0

    private var host: CYLSecondaryHost? = null
    private var closing = false

    private val header get() = component.isHeader

    private fun density() = component.view.view.resources.displayMetrics.density

    /**
     * Called as the layout is released: opens the second floor and returns true when the pull went far enough.
     */
    fun openOnReleaseIfPulledFar(): Boolean {
        if (view == null || triggerOffset <= 0f || isOpen) return false
        if (kotlin.math.abs(lastDragOffset) < triggerOffset * density()) return false
        open()
        return true
    }

    fun open() {
        if (isOpen || view == null || component.refreshLayout == null) return
        show(animated = true)
    }

    private fun parentOf(layout: SmartRefreshLayout): ViewGroup? =
        (layout.parent as? FrameLayout) ?: layout.rootView.findViewById(android.R.id.content)

    private fun show(animated: Boolean) {
        val layout = component.refreshLayout ?: return
        val content = view ?: return
        val parent = parentOf(layout) ?: return
        val height = if (dimension > 0f) (dimension * density()).toInt() else layout.height
        (content.parent as? ViewGroup)?.removeView(content)
        val floor = CYLSecondaryHost(layout.context) { dy ->
            val swipe = if (header) -dy else dy
            if (swipe >= closeTriggerOffset * density()) close()
        }
        floor.addView(content, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        val gravity = if (header) android.view.Gravity.TOP else android.view.Gravity.BOTTOM
        parent.addView(floor, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, height, gravity))
        host = floor
        isOpen = true
        closing = false
        component.setPhase(CYLRefreshPhase.SecondaryOpen)
        val from = if (header) -height.toFloat() else height.toFloat()
        floor.translationY = if (animated) from else 0f
        if (!animated) {
            return
        }
        floor.animate().translationY(0f).setDuration((component.slowAnimationDuration * 1000).toLong()).withEndAction {
            openedBlock?.invoke()
        }.start()
    }

    fun close() {
        val floor = host ?: return
        if (!isOpen || closing) return
        closing = true
        component.setPhase(CYLRefreshPhase.SecondaryClosing)
        val away = if (header) -floor.height.toFloat() else floor.height.toFloat()
        floor.animate().translationY(away).setDuration((component.slowAnimationDuration * 1000).toLong()).withEndAction {
            removeHost()
            isOpen = false
            closing = false
            component.setPhase(CYLRefreshPhase.Idle)
            closedBlock?.invoke()
        }.start()
    }

    private fun removeHost() {
        host?.let { (it.parent as? ViewGroup)?.removeView(it); it.removeAllViews() }
        host = null
    }
}
