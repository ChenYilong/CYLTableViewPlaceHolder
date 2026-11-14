// SVPullToRefresh (https://github.com/samvermette/SVPullToRefresh, MIT, Copyright (C) 2012 Sam Vermette) in Kotlin.
package com.cyl.svpulltorefresh

import android.animation.ValueAnimator
import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.view.ViewGroup
import android.view.animation.DecelerateInterpolator
import androidx.core.view.NestedScrollingParent3
import androidx.core.view.NestedScrollingParentHelper
import androidx.core.view.ViewCompat
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min

/**
 * The Android counterpart of SVPullToRefresh's `UIScrollView (SVPullToRefresh)` and `UIScrollView (SVInfiniteScrolling)`
 * categories. Android has no scroll view to extend, so this container holds one scrolling view (a RecyclerView,
 * ScrollView, ListView, …) and adds the pull-to-refresh views at the top and the bottom and the infinite-scrolling
 * view after it. Touches of views that support nested scrolling (RecyclerView, NestedScrollView) arrive through nested
 * scrolling; other views are dragged through touch interception.
 */
class SVPullToRefreshLayout @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
) : ViewGroup(context, attrs), NestedScrollingParent3 {

    private val density = resources.displayMetrics.density
    private val touchSlop = ViewConfiguration.get(context).scaledTouchSlop
    private val parentHelper = NestedScrollingParentHelper(this)

    /**
     * Height of a pull-to-refresh view and of the infinite-scrolling view, in pixels (SVPullToRefreshViewHeight /
     * SVInfiniteScrollingViewHeight: 60).
     */
    var viewHeight: Int = (60 * density).toInt()

    /**
     * The trigger distance is [viewHeight] times this factor (pull request #269, `pullThresholdFactor`). Default 1.
     */
    var pullThresholdFactor: Float = 1f

    /**
     * How far the finger moves for one pixel of pull; 2 halves the pull, like a scroll view's rubber band. Default 2.
     */
    var dragResistance: Float = 2f

    /**
     * Pixels before the end of the content at which infinite scrolling starts (pull request #154, sensitivity). Default
     * 0: at the end.
     */
    var infiniteScrollingThreshold: Int = 0

    /**
     * Extra space kept before the content, counted in the trigger distance (pull requests #173 and #177, a modified
     * content inset).
     */
    var contentInsetTop: Int = 0

    /**
     * Extra space kept after the content, counted for infinite scrolling (pull requests #297 and #300).
     */
    var contentInsetBottom: Int = 0

    private val refreshViews = mutableMapOf<SVPullToRefreshPosition, SVPullToRefreshView>()
    private val handlers = mutableMapOf<SVPullToRefreshPosition, () -> Unit>()
    private var infiniteView: SVInfiniteScrollingView? = null
    private var infiniteHandler: (() -> Unit)? = null
    private var infiniteDirection = SVInfiniteScrollingDirection.VERTICAL

    /** The pull being shown: positive pulls the content down (top view), negative up (bottom view). */
    private var pull = 0f
    private var animator: ValueAnimator? = null
    private var dragging = false
    private var downX = 0f
    private var downY = 0f
    private var lastY = 0f
    private var activePosition: SVPullToRefreshPosition? = null
    private var originalPaddingBottom = -1
    private var originalPaddingRight = -1

    /**
     * The scrolling view: this layout's first child that is not one of its own views.
     */
    val target: View?
        get() = (0 until childCount).map { getChildAt(it) }
            .firstOrNull { it !is SVPullToRefreshView && it !is SVInfiniteScrollingView }

    // MARK: - Pull to refresh

    /**
     * Adds pull to refresh at [position] calling [actionHandler] when it starts loading
     * (`addPullToRefreshWithActionHandler:position:`). Top and bottom can both be added (pull request #158).
     * [viewFactory] makes the view, for example a subclass of [SVPullToRefreshView] (issue #195).
     */
    @JvmOverloads
    fun addPullToRefresh(
        position: SVPullToRefreshPosition = SVPullToRefreshPosition.TOP,
        viewFactory: (Context, SVPullToRefreshPosition) -> SVPullToRefreshView = ::SVPullToRefreshView,
        actionHandler: () -> Unit,
    ) {
        refreshViews[position]?.let { removeView(it) }
        val view = viewFactory(context, position)
        view.layout = this
        refreshViews[position] = view
        handlers[position] = actionHandler
        addView(view)
        observeTarget()
        layoutChildrenForPull()
    }

    /**
     * Removes pull to refresh at [position] (issue #261); [addPullToRefresh] adds it again.
     */
    @JvmOverloads
    fun removePullToRefresh(position: SVPullToRefreshPosition = SVPullToRefreshPosition.TOP) {
        val view = refreshViews.remove(position) ?: return
        handlers.remove(position)
        if (activePosition == position) activePosition = null
        completedHiders.remove(position)?.let { mainHandler.removeCallbacks(it) }
        removeView(view)
        if (refreshViews.values.none { it.state == SVPullToRefreshState.LOADING }) animatePull(0f)
    }

    /**
     * The pull-to-refresh view at the top (`pullToRefreshView`); null before [addPullToRefresh].
     */
    val pullToRefreshView: SVPullToRefreshView?
        get() = refreshViews[SVPullToRefreshPosition.TOP]

    /**
     * The pull-to-refresh view at [position]; null when none was added there.
     */
    fun pullToRefreshView(position: SVPullToRefreshPosition): SVPullToRefreshView? = refreshViews[position]

    /**
     * NO hides pull to refresh and stops it from triggering (`showsPullToRefresh`). Default YES.
     */
    var showsPullToRefresh: Boolean = true
        set(value) {
            field = value
            if (!value) refreshViews.values.forEach { stopLoading(it) }
            layoutChildrenForPull()
        }

    /**
     * Starts loading at [position] as if pulled and released, and shows the view (`triggerPullToRefresh`).
     */
    @JvmOverloads
    fun triggerPullToRefresh(position: SVPullToRefreshPosition = SVPullToRefreshPosition.TOP) {
        refreshViews[position]?.let { startLoading(it, byUser = false) }
    }

    internal fun startLoading(view: SVPullToRefreshView, byUser: Boolean) {
        if (!showsPullToRefresh || view.state == SVPullToRefreshState.LOADING) return
        // One loading at a time: refresh and load more never run together (pull requests #163, #254, #260).
        if (infiniteView?.state == SVInfiniteScrollingState.LOADING) return
        completedHiders.remove(view.position)?.let { mainHandler.removeCallbacks(it) }
        view.isShowingCompleted = false
        // Set the state after the view is in place, so stopAnimating can never come first (pull request #201).
        val height = viewHeight.toFloat()
        animatePull(if (view.position == SVPullToRefreshPosition.TOP) height else -height)
        view.state = SVPullToRefreshState.LOADING
        handlers[view.position]?.invoke()
        if (!byUser && view.position == SVPullToRefreshPosition.TOP) scrollTargetToStart()
    }

    internal fun stopLoading(view: SVPullToRefreshView) {
        if (view.state == SVPullToRefreshState.STOPPED) return
        view.state = SVPullToRefreshState.STOPPED
        if (view.completedTitle != null && showsPullToRefresh && refreshViews[view.position] === view) {
            // Keep the view open with the completed text for a moment (issue #231).
            view.isShowingCompleted = true
            val hide = Runnable {
                completedHiders.remove(view.position)
                view.isShowingCompleted = false
                if (activePosition == null || activePosition == view.position) animatePull(0f)
            }
            completedHiders[view.position] = hide
            mainHandler.postDelayed(hide, view.completedDisplayMillis)
            return
        }
        if (activePosition == null || activePosition == view.position) animatePull(0f)
    }

    private val completedHiders = mutableMapOf<SVPullToRefreshPosition, Runnable>()

    // A handler, not View.postDelayed, which waits until the view is attached.
    private val mainHandler = android.os.Handler(android.os.Looper.getMainLooper())

    // MARK: - Infinite scrolling

    /**
     * Adds infinite scrolling calling [actionHandler] when the content's end is reached
     * (`addInfiniteScrollingWithActionHandler:`); [direction] HORIZONTAL loads to the right (pull requests #146, #180,
     * #203). [viewFactory] makes the view, for example a subclass of [SVInfiniteScrollingView] (issue #195).
     */
    @JvmOverloads
    fun addInfiniteScrolling(
        direction: SVInfiniteScrollingDirection = SVInfiniteScrollingDirection.VERTICAL,
        viewFactory: (Context) -> SVInfiniteScrollingView = ::SVInfiniteScrollingView,
        actionHandler: () -> Unit,
    ) {
        removeInfiniteScrolling()
        val view = viewFactory(context)
        view.layout = this
        view.visibility = GONE
        infiniteView = view
        infiniteHandler = actionHandler
        infiniteDirection = direction
        addView(view)
        view.refresh()
        updateInfiniteScrollingRoom()
        observeTarget()
    }

    /**
     * Removes infinite scrolling and the room it took after the content (issue #261); [addInfiniteScrolling] adds it
     * again.
     */
    fun removeInfiniteScrolling() {
        val view = infiniteView ?: return
        view.state = SVInfiniteScrollingState.STOPPED
        infiniteView = null
        infiniteHandler = null
        updateInfiniteScrollingRoom()
        view.layout = null
        removeView(view)
    }

    /**
     * NO stops infinite scrolling from starting when the content's end is reached: the view stays after the content
     * as a "Load more" button (or the STOPPED custom view) and loads on a tap or [triggerInfiniteScrolling] (issues #217
     * and #246). Default YES.
     */
    var automaticallyTriggersInfiniteScrolling: Boolean = true
        set(value) {
            field = value
            infiniteView?.refresh()
            updateInfiniteScrollingRoom()
        }

    /**
     * The infinite-scrolling view (`infiniteScrollingView`); null before [addInfiniteScrolling].
     */
    val infiniteScrollingView: SVInfiniteScrollingView?
        get() = infiniteView

    /**
     * NO hides infinite scrolling and stops it from triggering (`showsInfiniteScrolling`). Default YES.
     */
    var showsInfiniteScrolling: Boolean = true
        set(value) {
            field = value
            if (!value) stopInfiniteScrolling()
            updateInfiniteScrollingRoom()
        }

    /**
     * Starts loading more and shows the view (`triggerInfiniteScrolling`).
     */
    fun triggerInfiniteScrolling() {
        startInfiniteScrolling(byUser = false)
    }

    internal fun startInfiniteScrolling(byUser: Boolean) {
        val view = infiniteView ?: return
        if (!showsInfiniteScrolling || !view.isInfiniteScrollingEnabled || view.showsNoMoreData) return
        if (view.state == SVInfiniteScrollingState.LOADING) return
        if (refreshViews.values.any { it.state != SVPullToRefreshState.STOPPED } || pull != 0f) return
        val hadRoom = originalPaddingBottom >= 0 || originalPaddingRight >= 0
        view.state = SVInfiniteScrollingState.LOADING
        updateInfiniteScrollingRoom()
        if (byUser && !hadRoom) {
            // Show the view that just got its room.
            if (infiniteDirection == SVInfiniteScrollingDirection.VERTICAL) target?.scrollBy(0, viewHeight)
            else target?.scrollBy(viewHeight, 0)
        }
        infiniteHandler?.invoke()
    }

    internal fun stopInfiniteScrolling() {
        val view = infiniteView ?: return
        if (view.state == SVInfiniteScrollingState.STOPPED) return
        view.state = SVInfiniteScrollingState.STOPPED
        updateInfiniteScrollingRoom()
    }

    /**
     * Gives the infinite-scrolling view room after the content while it needs it (loading, "No more data", "Load more"),
     * and gives the original padding back otherwise (pull request #237). Only the padding changes, never the scroll
     * position, so hiding it does not jump (issue #250).
     */
    internal fun updateInfiniteScrollingRoom() {
        val view = infiniteView
        val needsRoom = view != null && showsInfiniteScrolling && view.needsRoom
        view?.visibility = if (needsRoom) VISIBLE else GONE
        val t = target
        if (t != null) {
            if (needsRoom) {
                // Room for the view after the content, so the content can scroll above it.
                if (t is ViewGroup) t.clipToPadding = false
                if (infiniteDirection == SVInfiniteScrollingDirection.VERTICAL) {
                    if (originalPaddingBottom < 0) originalPaddingBottom = t.paddingBottom
                    t.setPadding(t.paddingLeft, t.paddingTop, t.paddingRight, originalPaddingBottom + viewHeight)
                } else {
                    if (originalPaddingRight < 0) originalPaddingRight = t.paddingRight
                    t.setPadding(t.paddingLeft, t.paddingTop, originalPaddingRight + viewHeight, t.paddingBottom)
                }
            } else {
                if (originalPaddingBottom >= 0) t.setPadding(t.paddingLeft, t.paddingTop, t.paddingRight, originalPaddingBottom)
                if (originalPaddingRight >= 0) t.setPadding(t.paddingLeft, t.paddingTop, originalPaddingRight, t.paddingBottom)
            }
        }
        if (!needsRoom) {
            originalPaddingBottom = -1
            originalPaddingRight = -1
        }
        layoutChildrenForPull()
    }

    override fun onViewAdded(child: View) {
        super.onViewAdded(child)
        if (child !is SVPullToRefreshView && child !is SVInfiniteScrollingView) observeTarget()
    }

    override fun generateDefaultLayoutParams(): LayoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT)

    /**
     * Checks the content's end after every scroll of the target. It uses the target's OnScrollChangeListener, so an
     * app that needs its own scroll callback calls [checkInfiniteScrolling] from it.
     */
    private var observedTarget: View? = null

    private fun observeTarget() {
        val t = target ?: return
        if (observedTarget === t) return
        observedTarget = t
        t.setOnScrollChangeListener { _, x, y, oldX, oldY ->
            layoutChildrenForPull()
            // Only scrolling toward the end loads more, never scrolling back (issue #288).
            val forward = if (infiniteDirection == SVInfiniteScrollingDirection.VERTICAL) y > oldY else x > oldX
            if (forward) checkInfiniteScrolling()
        }
    }

    /**
     * Starts infinite scrolling when the target is scrolled to its end, never on content shorter than the view (pull
     * requests #157, #277, #283; issues #101, #141) and never while pulling to refresh (#163, #254, #260).
     */
    fun checkInfiniteScrolling() {
        val t = target ?: return
        val view = infiniteView ?: return
        if (!showsInfiniteScrolling || !view.isInfiniteScrollingEnabled || view.state != SVInfiniteScrollingState.STOPPED) return
        if (!automaticallyTriggersInfiniteScrolling || view.showsNoMoreData) return
        if (pull != 0f || dragging && activePosition != null) return
        val vertical = infiniteDirection == SVInfiniteScrollingDirection.VERTICAL
        val canScrollBack = if (vertical) t.canScrollVertically(-1) else t.canScrollHorizontally(-1)
        val canScrollOn = if (vertical) t.canScrollVertically(1) else t.canScrollHorizontally(1)
        // Content shorter than the view can scroll neither way: nothing to load more after.
        if (!canScrollBack && !canScrollOn) return
        val remaining = remainingDistance(t, vertical)
        if (!canScrollOn || remaining <= infiniteScrollingThreshold + contentInsetBottom) startInfiniteScrolling(byUser = true)
    }

    private fun remainingDistance(t: View, vertical: Boolean): Int {
        // ScrollView and HorizontalScrollView: the content's far edge minus the visible far edge.
        if (t is android.widget.ScrollView || t is android.widget.HorizontalScrollView) {
            val content = (t as ViewGroup).getChildAt(0) ?: return 0
            return if (vertical) content.bottom + t.paddingBottom - (t.scrollY + t.height)
            else content.right + t.paddingRight - (t.scrollX + t.width)
        }
        val rv = t as? androidx.core.view.ScrollingView ?: return if ((vertical && t.canScrollVertically(1)) || (!vertical && t.canScrollHorizontally(1))) Int.MAX_VALUE else 0
        return if (vertical) {
            rv.computeVerticalScrollRange() - rv.computeVerticalScrollOffset() - rv.computeVerticalScrollExtent()
        } else {
            rv.computeHorizontalScrollRange() - rv.computeHorizontalScrollOffset() - rv.computeHorizontalScrollExtent()
        }
    }

    // MARK: - Pull

    private val triggerDistance: Float
        get() = viewHeight * pullThresholdFactor + contentInsetTop

    private fun canPullDown(): Boolean {
        val view = refreshViews[SVPullToRefreshPosition.TOP] ?: return false
        return showsPullToRefresh && view.state != SVPullToRefreshState.LOADING && target?.canScrollVertically(-1) == false
    }

    private fun canPullUp(): Boolean {
        val view = refreshViews[SVPullToRefreshPosition.BOTTOM] ?: return false
        val t = target ?: return false
        // A bottom pull needs the content's end; on short content it is also its start (pull request #264).
        return showsPullToRefresh && view.state != SVPullToRefreshState.LOADING && !t.canScrollVertically(1) &&
            infiniteView?.state != SVInfiniteScrollingState.LOADING
    }

    /** Applies a drag of [delta] finger pixels; returns the pixels it used. */
    private fun dragBy(delta: Float): Float {
        val old = pull
        val position = activePosition ?: return 0f
        val next = pull + delta / dragResistance
        pull = if (position == SVPullToRefreshPosition.TOP) max(0f, next) else min(0f, next)
        updatePull(byUser = true)
        return (pull - old) * dragResistance
    }

    private fun updatePull(byUser: Boolean) {
        layoutChildrenForPull()
        val position = if (pull > 0) SVPullToRefreshPosition.TOP else if (pull < 0) SVPullToRefreshPosition.BOTTOM else activePosition
        val view = position?.let { refreshViews[it] } ?: return
        val distance = abs(pull)
        if (byUser && view.state != SVPullToRefreshState.LOADING) {
            view.state = if (distance >= triggerDistance) SVPullToRefreshState.TRIGGERED else SVPullToRefreshState.STOPPED
        }
        view.reportPull(distance, distance / triggerDistance)
    }

    private fun release() {
        val position = activePosition
        dragging = false
        activePosition = null
        val view = position?.let { refreshViews[it] }
        if (view != null && view.state == SVPullToRefreshState.TRIGGERED) {
            view.state = SVPullToRefreshState.STOPPED
            startLoading(view, byUser = true)
        } else if (refreshViews.values.none { it.state == SVPullToRefreshState.LOADING }) {
            animatePull(0f)
        }
    }

    private fun animatePull(to: Float) {
        animator?.cancel()
        val from = pull
        if (from == to) {
            layoutChildrenForPull()
            return
        }
        animator = ValueAnimator.ofFloat(from, to).apply {
            duration = 250
            interpolator = DecelerateInterpolator()
            addUpdateListener {
                pull = it.animatedValue as Float
                updatePull(byUser = false)
            }
            start()
        }
    }

    private fun scrollTargetToStart() {
        val t = target ?: return
        if (t.canScrollVertically(-1)) t.scrollTo(t.scrollX, 0)
    }

    // MARK: - Touches (views without nested scrolling)

    override fun onInterceptTouchEvent(ev: MotionEvent): Boolean {
        if (!isEnabled || refreshViews.isEmpty()) return false
        val t = target ?: return false
        if (ViewCompat.isNestedScrollingEnabled(t)) return false
        when (ev.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                downX = ev.x
                downY = ev.y
                lastY = ev.y
                dragging = false
            }
            MotionEvent.ACTION_MOVE -> startDragIfPulled(ev)
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> dragging = false
        }
        return dragging
    }

    private fun startDragIfPulled(ev: MotionEvent) {
        val dy = ev.y - downY
        if (abs(dy) > touchSlop && abs(dy) > abs(ev.x - downX)) {
            if (dy > 0 && canPullDown()) startDrag(SVPullToRefreshPosition.TOP, ev.y)
            else if (dy < 0 && canPullUp()) startDrag(SVPullToRefreshPosition.BOTTOM, ev.y)
        }
    }

    private fun startDrag(position: SVPullToRefreshPosition, y: Float) {
        animator?.cancel()
        dragging = true
        activePosition = position
        lastY = y
    }

    override fun onTouchEvent(ev: MotionEvent): Boolean {
        if (!dragging) {
            // A touch no child took (an empty or not yet laid out target, issue #302) still pulls.
            val t = target
            if (!isEnabled || refreshViews.isEmpty() || t == null || ViewCompat.isNestedScrollingEnabled(t)) return super.onTouchEvent(ev)
            when (ev.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    downX = ev.x
                    downY = ev.y
                    lastY = ev.y
                }
                MotionEvent.ACTION_MOVE -> startDragIfPulled(ev)
            }
            return true
        }
        when (ev.actionMasked) {
            MotionEvent.ACTION_MOVE -> {
                dragBy(ev.y - lastY)
                lastY = ev.y
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> release()
        }
        return true
    }

    override fun requestDisallowInterceptTouchEvent(disallowIntercept: Boolean) {
        // A target without nested scrolling (a ScrollView, a WebView, issue #302) asks on every touch down; ignoring it
        // keeps the pull working, like SwipeRefreshLayout. Views with nested scrolling report through it instead.
        val t = target
        if (t != null && !ViewCompat.isNestedScrollingEnabled(t)) return
        super.requestDisallowInterceptTouchEvent(disallowIntercept)
    }

    // MARK: - Nested scrolling (RecyclerView, NestedScrollView)

    override fun onStartNestedScroll(child: View, target: View, axes: Int, type: Int): Boolean =
        isEnabled && type == ViewCompat.TYPE_TOUCH && axes and ViewCompat.SCROLL_AXIS_VERTICAL != 0 && refreshViews.isNotEmpty()

    override fun onNestedScrollAccepted(child: View, target: View, axes: Int, type: Int) {
        parentHelper.onNestedScrollAccepted(child, target, axes, type)
        animator?.cancel()
        dragging = true
        activePosition = null
    }

    override fun onNestedPreScroll(target: View, dx: Int, dy: Int, consumed: IntArray, type: Int) {
        // While pulled, scrolling back first reduces the pull.
        val position = activePosition ?: return
        if (position == SVPullToRefreshPosition.TOP && pull > 0 && dy > 0 || position == SVPullToRefreshPosition.BOTTOM && pull < 0 && dy < 0) {
            consumed[1] = (-dragBy(-dy.toFloat())).toInt()
        }
    }

    override fun onNestedScroll(target: View, dxConsumed: Int, dyConsumed: Int, dxUnconsumed: Int, dyUnconsumed: Int, type: Int, consumed: IntArray) {
        if (type != ViewCompat.TYPE_TOUCH) return
        if (activePosition == null) {
            if (dyUnconsumed < 0 && canPullDown()) activePosition = SVPullToRefreshPosition.TOP
            else if (dyUnconsumed > 0 && canPullUp()) activePosition = SVPullToRefreshPosition.BOTTOM
        }
        if (activePosition != null && dyUnconsumed != 0) consumed[1] += (-dragBy(-dyUnconsumed.toFloat())).toInt()
    }

    override fun onNestedScroll(target: View, dxConsumed: Int, dyConsumed: Int, dxUnconsumed: Int, dyUnconsumed: Int, type: Int) {
        onNestedScroll(target, dxConsumed, dyConsumed, dxUnconsumed, dyUnconsumed, type, IntArray(2))
    }

    override fun onStopNestedScroll(target: View, type: Int) {
        parentHelper.onStopNestedScroll(target, type)
        if (type == ViewCompat.TYPE_TOUCH && dragging) release()
    }

    override fun getNestedScrollAxes(): Int = parentHelper.nestedScrollAxes

    // MARK: - Layout

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        val width = MeasureSpec.getSize(widthMeasureSpec)
        val height = MeasureSpec.getSize(heightMeasureSpec)
        setMeasuredDimension(width, height)
        val exactWidth = MeasureSpec.makeMeasureSpec(width, MeasureSpec.EXACTLY)
        target?.measure(exactWidth, MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
        refreshViews.values.forEach { it.measure(exactWidth, MeasureSpec.makeMeasureSpec(viewHeight, MeasureSpec.EXACTLY)) }
        infiniteView?.let {
            if (infiniteDirection == SVInfiniteScrollingDirection.VERTICAL) {
                it.measure(exactWidth, MeasureSpec.makeMeasureSpec(viewHeight, MeasureSpec.EXACTLY))
            } else {
                it.measure(MeasureSpec.makeMeasureSpec(viewHeight, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(height, MeasureSpec.EXACTLY))
            }
        }
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        layoutChildrenForPull(inLayoutPass = true)
    }

    /**
     * The target moves with the pull; the views sit just outside its moved edges. Outside a layout pass (the pull and
     * its animation), a target waiting for a layout (rows added while loading) is measured again first: laying it out
     * directly cleared its layout request without a measure, so the window's next pass skipped measuring it and the
     * new rows stayed 0 x 0, a blank list (found by the merged example, docs/Android-Port.md).
     */
    private fun layoutChildrenForPull(inLayoutPass: Boolean = false) {
        val w = width
        val h = height
        val offset = pull.toInt()
        target?.let {
            if (!inLayoutPass && it.isLayoutRequested) {
                it.measure(MeasureSpec.makeMeasureSpec(w, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(h, MeasureSpec.EXACTLY))
            }
            it.layout(0, offset, w, h + offset)
        }
        refreshViews[SVPullToRefreshPosition.TOP]?.layout(0, offset - viewHeight, w, offset)
        refreshViews[SVPullToRefreshPosition.BOTTOM]?.layout(0, h + offset, w, h + offset + viewHeight)
        // A view shows only while it is pulled into sight or loading, never before the first pull (issues #210 and
        // #232), and accessibility services skip it then.
        refreshViews.forEach { (position, view) ->
            val inSight = if (position == SVPullToRefreshPosition.TOP) offset > 0 else offset < 0
            view.visibility = when {
                !showsPullToRefresh -> GONE
                inSight || view.state == SVPullToRefreshState.LOADING || view.isShowingCompleted -> VISIBLE
                else -> INVISIBLE
            }
        }
        // The infinite-scrolling view follows the content's end, so a "Load more" or "No more data" view stays after
        // the content instead of over it.
        infiniteView?.takeIf { it.visibility == VISIBLE }?.let { view ->
            val t = target
            val vertical = infiniteDirection == SVInfiniteScrollingDirection.VERTICAL
            val remaining = if (t == null) 0 else remainingDistance(t, vertical).coerceIn(0, if (vertical) h else w)
            if (vertical) view.layout(0, h - viewHeight + remaining, w, h + remaining)
            else view.layout(w - viewHeight + remaining, 0, w + remaining, h)
        }
    }
}
