// android-Ultra-Pull-To-Refresh (https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh, MIT, Copyright (c) 2015
// liaohuqiu.net) translated to Kotlin.
package `in`.srain.cube.views.ptr

import android.view.View
import android.view.ViewGroup
import `in`.srain.cube.views.ptr.indicator.PtrIndicator

/**
 * Decides whether the content can be pulled down and starts the refresh (`PtrHandler`).
 */
interface PtrHandler {
    /**
     * YES when the content can be pulled down, for example when it is scrolled to its top.
     */
    fun checkCanDoRefresh(frame: PtrFrameLayout, content: View, header: View?): Boolean

    /**
     * Refreshing began; call [PtrFrameLayout.refreshComplete] when it is done.
     */
    fun onRefreshBegin(frame: PtrFrameLayout)
}

/**
 * A [PtrHandler] that also loads more when the content is pulled up (pull request #157, `PtrHandler2`).
 */
interface PtrHandler2 : PtrHandler {
    /**
     * YES when the content can be pulled up, for example when it is scrolled to its end.
     */
    fun checkCanDoLoadMore(frame: PtrFrameLayout, content: View, footer: View?): Boolean

    /**
     * Loading more began; call [PtrFrameLayout.refreshComplete] when it is done.
     */
    fun onLoadMoreBegin(frame: PtrFrameLayout)
}

/**
 * Receives the UI events of a [PtrFrameLayout]: headers and footers implement it (`PtrUIHandler`).
 */
interface PtrUIHandler {
    /**
     * Back at the start, ready for the next pull.
     */
    fun onUIReset(frame: PtrFrameLayout)

    /**
     * A pull started.
     */
    fun onUIRefreshPrepare(frame: PtrFrameLayout)

    /**
     * Refreshing (or loading more) began.
     */
    fun onUIRefreshBegin(frame: PtrFrameLayout)

    /**
     * Refreshing (or loading more) completed.
     */
    fun onUIRefreshComplete(frame: PtrFrameLayout)

    /**
     * The position changed; [status] is one of `PtrFrameLayout.PTR_STATUS_*`.
     */
    fun onUIPositionChange(frame: PtrFrameLayout, isUnderTouch: Boolean, status: Byte, ptrIndicator: PtrIndicator)
}

/**
 * A [PtrHandler] that refreshes when the content cannot scroll up (`PtrDefaultHandler`).
 */
abstract class PtrDefaultHandler : PtrHandler {

    override fun checkCanDoRefresh(frame: PtrFrameLayout, content: View, header: View?): Boolean =
        checkContentCanBePulledDown(frame, content, header)

    /**
     * The checks.
     */
    companion object {
        /**
         * YES when [view] can scroll up. A container that cannot scroll itself (a FrameLayout around a list) asks its
         * scrolling descendants (issue #224); lists use their own scrolling, also when the first item is taller than
         * the view (issues #42 and #206).
         */
        @JvmStatic
        fun canChildScrollUp(view: View): Boolean = canScroll(view, -1)

        /**
         * YES when [content] can be pulled down: it cannot scroll up.
         */
        @JvmStatic
        fun checkContentCanBePulledDown(frame: PtrFrameLayout, content: View, header: View?): Boolean = !canChildScrollUp(content)

        internal fun canScroll(view: View, direction: Int): Boolean {
            if (view.canScrollVertically(direction)) return true
            if (view !is ViewGroup || view.visibility != View.VISIBLE) return false
            for (i in 0 until view.childCount) {
                val child = view.getChildAt(i)
                if (child.visibility == View.VISIBLE && canScroll(child, direction)) return true
            }
            return false
        }
    }
}

/**
 * A [PtrHandler2] that refreshes when the content cannot scroll up and loads more when it cannot scroll down (pull
 * request #157, `PtrDefaultHandler2`).
 */
abstract class PtrDefaultHandler2 : PtrDefaultHandler(), PtrHandler2 {

    override fun checkCanDoLoadMore(frame: PtrFrameLayout, content: View, footer: View?): Boolean =
        checkContentCanBePulledUp(frame, content, footer)

    /**
     * The checks.
     */
    companion object {
        /**
         * YES when [view] (or a scrolling descendant) can scroll down.
         */
        @JvmStatic
        fun canChildScrollDown(view: View): Boolean = PtrDefaultHandler.canScroll(view, 1)

        /**
         * YES when [content] can be pulled up: it cannot scroll down.
         */
        @JvmStatic
        fun checkContentCanBePulledUp(frame: PtrFrameLayout, content: View, footer: View?): Boolean = !canChildScrollDown(content)
    }
}

/**
 * Holds the refresh completion until [resume] is called, for example to finish a header's animation first
 * (`PtrUIHandlerHook`).
 */
abstract class PtrUIHandlerHook : Runnable {
    private var resumeAction: Runnable? = null
    private var status = STATUS_PREPARE

    /**
     * Takes over the completion: runs this hook, or resumes at once when it already ran.
     */
    @JvmOverloads
    fun takeOver(resumeAction: Runnable? = null) {
        if (resumeAction != null) this.resumeAction = resumeAction
        when (status) {
            STATUS_PREPARE -> {
                status = STATUS_IN_HOOK
                run()
            }
            STATUS_RESUMED -> resume()
        }
    }

    /**
     * Ready for the next completion.
     */
    fun reset() {
        status = STATUS_PREPARE
    }

    /**
     * Lets the completion go on.
     */
    fun resume() {
        resumeAction?.run()
        status = STATUS_RESUMED
    }

    /**
     * Sets what [resume] runs.
     */
    fun setResumeAction(runnable: Runnable?) {
        resumeAction = runnable
    }

    private companion object {
        const val STATUS_PREPARE: Byte = 0
        const val STATUS_IN_HOOK: Byte = 1
        const val STATUS_RESUMED: Byte = 2
    }
}

/**
 * Sends the UI events to every added [PtrUIHandler], in the order added, each one once.
 */
internal class PtrUIHandlerHolder : PtrUIHandler {
    private val handlers = mutableListOf<PtrUIHandler>()

    fun hasHandler(): Boolean = handlers.isNotEmpty()

    fun add(handler: PtrUIHandler) {
        if (handlers.none { it === handler }) handlers += handler
    }

    fun remove(handler: PtrUIHandler) {
        handlers.removeAll { it === handler }
    }

    override fun onUIReset(frame: PtrFrameLayout) = handlers.toList().forEach { it.onUIReset(frame) }
    override fun onUIRefreshPrepare(frame: PtrFrameLayout) = handlers.toList().forEach { it.onUIRefreshPrepare(frame) }
    override fun onUIRefreshBegin(frame: PtrFrameLayout) = handlers.toList().forEach { it.onUIRefreshBegin(frame) }
    override fun onUIRefreshComplete(frame: PtrFrameLayout) = handlers.toList().forEach { it.onUIRefreshComplete(frame) }
    override fun onUIPositionChange(frame: PtrFrameLayout, isUnderTouch: Boolean, status: Byte, ptrIndicator: PtrIndicator) =
        handlers.toList().forEach { it.onUIPositionChange(frame, isUnderTouch, status, ptrIndicator) }
}
