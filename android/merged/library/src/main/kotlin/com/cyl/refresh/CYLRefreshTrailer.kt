package com.cyl.refresh

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.cyl.refresh.merged.R
import kotlin.math.abs
import kotlin.math.max

/*
 * MJRefreshTrailer, MJRefreshStateTrailer and MJRefreshNormalTrailer (MIT; created by kinarobin, Copyright (c) 2020
 * 小码哥), translated from the iOS port (`CYLRefreshTrailer`, `CYLRefreshStateTrailer`, `CYLRefreshNormalTrailer`) to
 * Kotlin. CYLRefreshLayout only pulls vertically, so the trailer drives a horizontal RecyclerView itself.
 */

/**
 * A control at the end of a horizontal list, pulled from the right (`CYLRefreshTrailer`). Attach it with
 * `RecyclerView.cyl_trailer`.
 */
open class CYLRefreshTrailer(context: Context) : FrameLayout(context) {

    /**
     * Called when a pull past the trigger is released (`refreshingBlock`).
     */
    var refreshingBlock: CYLRefreshComponentRefreshingBlock? = null

    /**
     * Called once refreshing has ended and the trailer has slid away (`endRefreshingCompletionBlock`).
     */
    var endRefreshingCompletionBlock: CYLRefreshComponentEndRefreshingCompletionBlock? = null

    /**
     * The share of the trailer's width to pull before release refreshes (`triggerRate`).
     */
    var triggerRate: Float = 1f

    /**
     * How far the trailer is pulled, as a share of the trigger distance (`pullingPercent`).
     */
    var pullingPercent: Float = 0f
        private set

    /**
     * The current state (`state`).
     */
    var state: CYLRefreshState = CYLRefreshState.Idle
        set(value) {
            if (field == value) return
            val old = field
            field = value
            // An automatic refresh started by a drag uses one of the drag's [autoTriggerTimes] once it ends.
            if (value != CYLRefreshState.Refreshing && value != CYLRefreshState.Pulling && triggerByDrag) {
                if (leftTriggerTimes != -1) leftTriggerTimes -= 1
                triggerByDrag = false
            }
            stateDidChange(old, value)
        }

    /**
     * Whether pulling the trailer into view refreshes without a release (`automaticallyRefresh`); false, the default,
     * keeps the pull-and-release behavior. Only applies when the content is wider than the list. A fling that reaches
     * the end (no drag) also refreshes.
     */
    var automaticallyRefresh: Boolean = false

    /**
     * How much of the trailer must be in view before it refreshes automatically, 1 for fully
     * (`triggerAutomaticallyRefreshPercent`).
     */
    var triggerAutomaticallyRefreshPercent: Float = 1f

    /**
     * Automatic refreshes allowed per drag, 1 by default; -1 for no limit (`autoTriggerTimes`). A fling without a drag
     * is not limited.
     */
    var autoTriggerTimes: Int = 1
        set(value) {
            field = value
            leftTriggerTimes = value
        }

    private var leftTriggerTimes = 1
    private var triggerByDrag = false

    /**
     * True while refreshing (`isRefreshing`).
     */
    val isRefreshing: Boolean get() = state == CYLRefreshState.Refreshing

    /**
     * The list the trailer is attached to, or null (`scrollView`).
     */
    var scrollView: RecyclerView? = null
        private set

    /**
     * The trailer's width, in pixels (`CYLRefreshTrailWidth`).
     */
    val trailerWidth: Int get() = (CYLRefreshConst.CYLRefreshTrailWidth * resources.displayMetrics.density).toInt()

    private var pull = 0f
    private var animator: ValueAnimator? = null

    /**
     * Starts refreshing: the trailer stays shown and [refreshingBlock] runs (`beginRefreshing`).
     */
    fun beginRefreshing() {
        if (isRefreshing) return
        state = CYLRefreshState.Refreshing
        animatePull(trailerWidth.toFloat()) { refreshingBlock?.invoke() }
    }

    /**
     * Ends refreshing and slides the trailer away (`endRefreshing`).
     */
    fun endRefreshing() {
        if (!isRefreshing) return
        state = CYLRefreshState.Idle
        animatePull(0f) { endRefreshingCompletionBlock?.invoke() }
    }

    /**
     * Called when the state changes; subclasses update their views (`setState:`).
     */
    protected open fun stateDidChange(old: CYLRefreshState, new: CYLRefreshState) {}

    internal fun attach(list: RecyclerView) {
        scrollView = list
        list.addOnItemTouchListener(touches)
        list.addOnScrollListener(flings)
    }

    internal fun detach() {
        scrollView?.removeOnItemTouchListener(touches)
        scrollView?.removeOnScrollListener(flings)
        animator?.cancel()
        setPull(0f)
        scrollView = null
    }

    /**
     * Moves the list left by [distance] pixels and the trailer in from the right with it.
     */
    internal fun setPull(distance: Float) {
        pull = max(0f, distance)
        scrollView?.translationX = -pull
        translationX = trailerWidth - pull
        pullingPercent = pull / (trailerWidth * triggerRate)
        if (!isRefreshing) state = if (pullingPercent >= 1f) CYLRefreshState.Pulling else CYLRefreshState.Idle
    }

    // The iOS shouldAutomaticallyRefreshWithChange:pullingPercent: (moving toward the end, content wider than the list,
    // enough of the trailer in view, and a drag's automatic refreshes not used up).
    private fun shouldAutomaticallyRefresh(movingLeft: Boolean, dragging: Boolean): Boolean {
        val list = scrollView ?: return false
        if (!automaticallyRefresh || !movingLeft) return false
        if (state != CYLRefreshState.Idle && state != CYLRefreshState.Pulling) return false
        if (list.computeHorizontalScrollRange() <= list.width) return false
        if (pull / trailerWidth < triggerAutomaticallyRefreshPercent) return false
        return !(dragging && leftTriggerTimes != -1 && leftTriggerTimes <= 0)
    }

    /**
     * A fling that reaches the end refreshes when [automaticallyRefresh] is on (scrolling without a drag).
     */
    private val flings = object : RecyclerView.OnScrollListener() {
        override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
            if (!automaticallyRefresh || dx <= 0 || recyclerView.scrollState != RecyclerView.SCROLL_STATE_SETTLING) return
            if (recyclerView.canScrollHorizontally(1) || recyclerView.computeHorizontalScrollRange() <= recyclerView.width) return
            if (state == CYLRefreshState.Idle) beginRefreshing()
        }
    }

    private fun animatePull(to: Float, end: () -> Unit) {
        animator?.cancel()
        animator = ValueAnimator.ofFloat(pull, to).apply {
            duration = (CYLRefreshConst.CYLRefreshFastAnimationDuration * 1000).toLong()
            addUpdateListener {
                pull = it.animatedValue as Float
                scrollView?.translationX = -pull
                translationX = trailerWidth - pull
            }
            addListener(object : android.animation.AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: android.animation.Animator) = end()
            })
            start()
        }
    }

    /**
     * Takes over a drag that keeps going left once the list is at its end.
     */
    private val touches = object : RecyclerView.OnItemTouchListener {
        private var lastX = 0f
        private var startX = 0f
        private val slop = ViewConfiguration.get(context).scaledTouchSlop

        override fun onInterceptTouchEvent(rv: RecyclerView, e: MotionEvent): Boolean {
            when (e.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    lastX = e.x
                    startX = e.x
                    leftTriggerTimes = autoTriggerTimes
                }
                MotionEvent.ACTION_MOVE -> {
                    val movingLeft = e.x < lastX
                    lastX = e.x
                    if (!isRefreshing && movingLeft && !rv.canScrollHorizontally(1) && abs(e.x - startX) > slop) {
                        startX = e.x + pull / DAMPING
                        rv.stopScroll()
                        return true
                    }
                }
            }
            return false
        }

        override fun onTouchEvent(rv: RecyclerView, e: MotionEvent) {
            when (e.actionMasked) {
                MotionEvent.ACTION_MOVE -> {
                    val movingLeft = e.x < lastX
                    lastX = e.x
                    if (isRefreshing) return
                    setPull((startX - e.x) * DAMPING)
                    if (shouldAutomaticallyRefresh(movingLeft, dragging = true)) {
                        triggerByDrag = true
                        beginRefreshing()
                    }
                }
                MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> when {
                    isRefreshing -> Unit
                    state == CYLRefreshState.Pulling -> beginRefreshing()
                    else -> animatePull(0f) {}
                }
            }
        }

        override fun onRequestDisallowInterceptTouchEvent(disallowIntercept: Boolean) = Unit
    }

    private companion object {
        /**
         * The trailer moves half as far as the finger, like a scroll view's rubber band.
         */
        const val DAMPING = 0.5f
    }
}

/**
 * A trailer with a vertical state text (`CYLRefreshStateTrailer`).
 */
open class CYLRefreshStateTrailer(context: Context) : CYLRefreshTrailer(context) {

    /**
     * The state text (`stateLabel`).
     */
    val stateLabel = TextView(context).apply {
        textSize = 11f
        setTextColor(Color.DKGRAY)
        gravity = Gravity.CENTER
        // A narrow column that wraps between words, never inside one.
        breakStrategy = android.text.Layout.BREAK_STRATEGY_SIMPLE
        hyphenationFrequency = android.text.Layout.HYPHENATION_FREQUENCY_NONE
        maxWidth = (42 * resources.displayMetrics.density).toInt()
    }

    private val titles = HashMap<CYLRefreshState, String>()

    /**
     * The row holding the optional arrow and the state text.
     */
    protected val row = LinearLayout(context).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.CENTER
        addView(stateLabel)
    }

    init {
        addView(row, LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        setTitle(context.getString(R.string.cyl_refresh_trailer_idle), CYLRefreshState.Idle)
        setTitle(context.getString(R.string.cyl_refresh_trailer_pulling), CYLRefreshState.Pulling)
        setTitle(context.getString(R.string.cyl_refresh_trailer_pulling), CYLRefreshState.Refreshing)
    }

    /**
     * Sets the text shown in [state] (`setTitle:forState:`).
     */
    fun setTitle(title: String, state: CYLRefreshState): CYLRefreshStateTrailer = apply {
        titles[state] = title
        stateLabel.text = titles[this.state]
    }

    /**
     * The text shown in [state] (`titleForState:`), as on the state footers.
     */
    fun titleForState(state: CYLRefreshState): String? = titles[state]

    override fun stateDidChange(old: CYLRefreshState, new: CYLRefreshState) {
        stateLabel.text = titles[new]
    }
}

/**
 * A trailer with an arrow that turns around past the trigger (`CYLRefreshNormalTrailer`).
 */
open class CYLRefreshNormalTrailer(context: Context) : CYLRefreshStateTrailer(context) {

    /**
     * The arrow, pointing left until the pull passes the trigger (`arrowView`).
     */
    val arrowView: View = object : View(context) {
        private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = 2 * resources.displayMetrics.density
            strokeCap = Paint.Cap.ROUND
            strokeJoin = Paint.Join.ROUND
        }
        private val path = Path()

        override fun onDraw(canvas: Canvas) {
            val w = width.toFloat()
            val h = height.toFloat()
            paint.color = stateLabel.currentTextColor
            path.reset()
            path.moveTo(w * 0.9f, h / 2)
            path.lineTo(w * 0.1f, h / 2)
            path.moveTo(w * 0.45f, h * 0.15f)
            path.lineTo(w * 0.1f, h / 2)
            path.lineTo(w * 0.45f, h * 0.85f)
            canvas.drawPath(path, paint)
        }
    }

    init {
        val side = (16 * resources.displayMetrics.density).toInt()
        row.addView(arrowView, 0, LinearLayout.LayoutParams(side * 3 / 4, side).apply { marginEnd = side / 8 })
    }

    override fun stateDidChange(old: CYLRefreshState, new: CYLRefreshState) {
        super.stateDidChange(old, new)
        arrowView.animate().rotation(if (new == CYLRefreshState.Idle) 0f else 180f)
            .setDuration((CYLRefreshConst.CYLRefreshFastAnimationDuration * 1000).toLong()).start()
    }

    companion object {
        /**
         * A trailer that runs [refreshingBlock] when released past the trigger (`trailerWithRefreshingBlock:`).
         */
        @JvmStatic
        fun trailerWithRefreshingBlock(context: Context, refreshingBlock: CYLRefreshComponentRefreshingBlock) =
            CYLRefreshNormalTrailer(context).apply { this.refreshingBlock = refreshingBlock }
    }
}

/**
 * The list's trailer (the iOS `UIScrollView.cyl_trailer`). Setting it wraps the list in a frame with the trailer at its
 * right edge (set it once the list is in its parent); null removes it and puts the list back.
 */
var RecyclerView.cyl_trailer: CYLRefreshTrailer?
    get() = getTag(R.id.cyl_refresh_trailer) as? CYLRefreshTrailer
    set(value) {
        cyl_trailer?.let { old ->
            old.detach()
            val frame = parent as? FrameLayout
            val host = frame?.parent as? ViewGroup
            if (frame != null && host != null && frame.getTag(R.id.cyl_refresh_trailer) === old) {
                val index = host.indexOfChild(frame)
                val params = frame.layoutParams
                frame.removeAllViews()
                host.removeView(frame)
                host.addView(this, index, params)
            }
        }
        setTag(R.id.cyl_refresh_trailer, value)
        val trailer = value ?: return
        val host = parent as? ViewGroup
        val frame = FrameLayout(context).apply { clipChildren = true; setTag(R.id.cyl_refresh_trailer, trailer) }
        if (host != null) {
            val index = host.indexOfChild(this)
            val params = layoutParams
            host.removeView(this)
            host.addView(frame, index, params)
        }
        frame.addView(this, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        frame.addView(trailer, FrameLayout.LayoutParams(trailer.trailerWidth, ViewGroup.LayoutParams.MATCH_PARENT, Gravity.END))
        trailer.translationX = trailer.trailerWidth.toFloat()
        trailer.attach(this)
    }
