// android-Ultra-Pull-To-Refresh (https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh, MIT, Copyright (c) 2015
// liaohuqiu.net) translated to Kotlin, with the open pull requests taken in docs/Android-Port.md.
package `in`.srain.cube.views.ptr

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.AttributeSet
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.view.ViewGroup
import android.view.accessibility.AccessibilityNodeInfo
import android.widget.AbsListView
import android.widget.Scroller
import android.widget.TextView
import androidx.core.view.ScrollingView
import `in`.srain.cube.views.ptr.indicator.PtrIndicator
import `in`.srain.cube.views.ptr.util.PtrCLog
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min

/**
 * The pull-to-refresh layout: one content view of any kind, a header pulled down to refresh and, with a footer, pulled
 * up to load more (pull request #157). It supports pull to refresh, release to refresh, auto refresh, keeping or hiding
 * the header while refreshing, and UI handlers ([PtrUIHandler]) for custom headers.
 */
open class PtrFrameLayout @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = 0,
) : ViewGroup(context, attrs, defStyle) {

    /**
     * Which directions pull (pull request #157): refresh pulls down, load more pulls up.
     */
    enum class Mode {
        /**
         * Neither.
         */
        NONE,

        /**
         * Pull down to refresh only.
         */
        REFRESH,

        /**
         * Pull up to load more only.
         */
        LOAD_MORE,

        /**
         * Both.
         */
        BOTH,
    }

    /**
     * The log tag of this frame.
     */
    protected val LOG_TAG = "ptr-frame-" + ++ID

    private var status: Byte = PTR_STATUS_INIT
    private var headerId = 0
    private var containerId = 0
    private var footerId = 0
    private var flag = 0
    private var ptrHandler: PtrHandler? = null
    private val uiHandlerHolder = PtrUIHandlerHolder()
    private val scrollChecker = ScrollChecker()
    private val mainHandler = Handler(Looper.getMainLooper())
    private val touchSlop: Int
    private val pagingTouchSlop: Int
    private var disableWhenHorizontal = false
    private var preventForHorizontal = false
    private var isBeingDragged = false
    private var disallowInterceptRequested = false
    private var activePointerId = MotionEvent.INVALID_POINTER_ID
    private var lastMoveEvent: MotionEvent? = null
    private var refreshCompleteHook: PtrUIHandlerHook? = null
    private var loadingStartTime = 0L
    private var hasSendCancelEvent = false
    private var completeNotified = false
    private var pendingAutoRefresh: (() -> Unit)? = null
    private val performRefreshCompleteDelay = Runnable { performRefreshComplete() }
    private val closeAfterCompleted = Runnable {
        tryScrollBackToTopAfterComplete()
        tryToNotifyReset()
    }

    /**
     * The indicator that turns finger moves into the pulled distance; a new one takes the current position.
     */
    var ptrIndicator: PtrIndicator = PtrIndicator()
        set(value) {
            if (field !== value) value.convertFrom(field)
            field = value
        }

    /**
     * The content view.
     */
    protected var mContent: View? = null

    /**
     * The content view (`getContentView`).
     */
    val contentView: View?
        get() = mContent

    private var mHeaderView: View? = null
    private var mFooterView: View? = null

    // Children added before onFinishInflate are sorted there; a frame made in code sorts them as they are added.
    private var childrenSorted = attrs == null

    /**
     * The header view, pulled down; null removes it (pull request #144).
     */
    var headerView: View?
        get() = mHeaderView
        set(header) {
            if (header === mHeaderView) return
            mHeaderView?.let { removeView(it) }
            mHeaderView = header
            if (header != null) {
                if (header.layoutParams == null) header.layoutParams = LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
                (header.parent as? ViewGroup)?.removeView(header)
                addView(header)
            } else {
                headerHeight = 0
                ptrIndicator.setHeaderHeight(0)
            }
        }

    /**
     * The footer view, pulled up to load more (pull request #157); null removes it.
     */
    var footerView: View?
        get() = mFooterView
        set(footer) {
            if (footer === mFooterView) return
            mFooterView?.let { removeView(it) }
            mFooterView = footer
            if (footer != null) {
                if (footer.layoutParams == null) footer.layoutParams = LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
                (footer.parent as? ViewGroup)?.removeView(footer)
                addView(footer)
            } else {
                footerHeight = 0
                ptrIndicator.setFooterHeight(0)
            }
        }

    /**
     * The header's measured height with its margins.
     */
    var headerHeight = 0
        private set

    /**
     * The footer's measured height with its margins (pull request #157).
     */
    var footerHeight = 0
        private set

    /**
     * Which directions pull (pull request #157). Default [Mode.BOTH]; load more also needs a footer and a
     * [PtrHandler2].
     */
    var mode: Mode = Mode.BOTH

    /**
     * The duration, in milliseconds, to go back to the refresh position after a release past it. Default 200.
     */
    var durationToClose = 200

    /**
     * The duration, in milliseconds, to close the header. Default 1000; 0 closes it at once (issues #242 and #245).
     */
    var durationToCloseHeader = 1000

    /**
     * YES keeps the header shown while refreshing. Default YES.
     */
    var isKeepHeaderWhenRefresh = true

    /**
     * YES refreshes as soon as the pull reaches the refresh offset; NO (the default) on release.
     */
    var isPullToRefresh = false

    /**
     * Refreshing lasts at least this many milliseconds. Default 500.
     */
    var loadingMinTime = 500

    /**
     * After refreshing completes, the header shows its completed state this many milliseconds before closing (issues
     * #139 and #302). Default 0.
     */
    var durationToKeepCompleted = 0

    /**
     * The longest distance, in pixels, the frame can be pulled (issues #275 and #308); 0 (the default) has no limit.
     */
    var maxPullDistance = 0

    /**
     * Moves the header down by this many pixels, for example below a toolbar (issues #135 and #165,
     * `setProgressViewOffset`). Default 0.
     */
    var headerOffset = 0
        set(value) {
            field = value
            layoutChildren()
        }

    /**
     * YES scrolls the content to its top when [autoRefresh] starts (issue #249). Default YES.
     */
    var autoRefreshScrollsContentToTop = true

    /**
     * YES ignores touches on the content while refreshing (issue #264). Default NO.
     */
    var isContentTouchBlockedWhileRefreshing = false

    init {
        val arr = context.obtainStyledAttributes(attrs, R.styleable.PtrFrameLayout, 0, 0)
        try {
            headerId = arr.getResourceId(R.styleable.PtrFrameLayout_ptr_header, headerId)
            containerId = arr.getResourceId(R.styleable.PtrFrameLayout_ptr_content, containerId)
            footerId = arr.getResourceId(R.styleable.PtrFrameLayout_ptr_footer, footerId)
            ptrIndicator.resistance = arr.getFloat(R.styleable.PtrFrameLayout_ptr_resistance, ptrIndicator.resistance)
            durationToClose = arr.getInt(R.styleable.PtrFrameLayout_ptr_duration_to_close, durationToClose)
            durationToCloseHeader = arr.getInt(R.styleable.PtrFrameLayout_ptr_duration_to_close_header, durationToCloseHeader)
            ptrIndicator.setRatioOfHeaderHeightToRefresh(
                arr.getFloat(R.styleable.PtrFrameLayout_ptr_ratio_of_header_height_to_refresh, ptrIndicator.ratioOfHeaderToHeightRefresh)
            )
            isKeepHeaderWhenRefresh = arr.getBoolean(R.styleable.PtrFrameLayout_ptr_keep_header_when_refresh, isKeepHeaderWhenRefresh)
            isPullToRefresh = arr.getBoolean(R.styleable.PtrFrameLayout_ptr_pull_to_fresh, isPullToRefresh)
            mode = Mode.entries[arr.getInt(R.styleable.PtrFrameLayout_ptr_mode, Mode.BOTH.ordinal).coerceIn(0, 3)]
            if (arr.getBoolean(R.styleable.PtrFrameLayout_ptr_pin_header, false)) flag = flag or FLAG_PIN_HEADER
            ptrIndicator.deadZone = arr.getDimensionPixelSize(R.styleable.PtrFrameLayout_ptr_dead_zone, 0)
        } finally {
            arr.recycle()
        }
        val conf = ViewConfiguration.get(context)
        touchSlop = conf.scaledTouchSlop
        // The paging slop, as ViewPager uses it (pull request #209).
        pagingTouchSlop = conf.scaledPagingTouchSlop
        ptrIndicator.touchSlop = touchSlop
    }

    override fun onFinishInflate() {
        super.onFinishInflate()
        if (childCount > 3) throw IllegalStateException("PtrFrameLayout can only contains 3 children")
        if (headerId != 0 && mHeaderView == null) mHeaderView = findViewById(headerId)
        if (containerId != 0 && mContent == null) mContent = findViewById(containerId)
        if (footerId != 0 && mFooterView == null) mFooterView = findViewById(footerId)
        val others = (0 until childCount).map { getChildAt(it) }
            .filter { it !== mHeaderView && it !== mContent && it !== mFooterView }.toMutableList()
        when (childCount) {
            0 -> {
                val errorView = TextView(context).apply {
                    isClickable = true
                    setTextColor(0xffff6600.toInt())
                    gravity = Gravity.CENTER
                    textSize = 20f
                    text = "The content view in PtrFrameLayout is empty. Do you forget to specify its id in xml layout file?"
                }
                mContent = errorView
                addView(errorView)
            }
            1 -> if (mContent == null) mContent = others.firstOrNull()
            2 -> {
                // The PtrUIHandler child is the header, else the first child.
                if (mHeaderView == null && mContent == null) {
                    val header = others.firstOrNull { it is PtrUIHandler } ?: others.first()
                    others.remove(header)
                    mHeaderView = header
                }
                if (mHeaderView == null && others.isNotEmpty()) mHeaderView = others.removeAt(0)
                if (mContent == null && others.isNotEmpty()) mContent = others.removeAt(0)
            }
            else -> {
                // Header, content and footer, in that order (pull request #157).
                if (mHeaderView == null && others.isNotEmpty()) mHeaderView = others.removeAt(0)
                if (mContent == null && others.isNotEmpty()) mContent = others.removeAt(0)
                if (mFooterView == null && others.isNotEmpty()) mFooterView = others.removeAt(0)
            }
        }
        mHeaderView?.bringToFront()
        mFooterView?.bringToFront()
        childrenSorted = true
    }

    override fun onViewAdded(child: View) {
        super.onViewAdded(child)
        // A content added in code (issues #234, #272 and #292) becomes the content.
        if (childrenSorted && child !== mHeaderView && child !== mFooterView && (mContent == null || mContent?.parent !== this)) mContent = child
    }

    override fun onViewRemoved(child: View) {
        super.onViewRemoved(child)
        if (child === mContent) mContent = null
        if (child === mHeaderView) mHeaderView = null
        if (child === mFooterView) mFooterView = null
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        scrollChecker.destroy()
        mainHandler.removeCallbacks(performRefreshCompleteDelay)
        mainHandler.removeCallbacks(closeAfterCompleted)
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec)
        if (mContent == null) mContent = (0 until childCount).map { getChildAt(it) }.firstOrNull { it !== headerView && it !== footerView }
        headerView?.let {
            measureChildWithMargins(it, widthMeasureSpec, 0, heightMeasureSpec, 0)
            val lp = it.layoutParams as MarginLayoutParams
            headerHeight = it.measuredHeight + lp.topMargin + lp.bottomMargin
            ptrIndicator.setHeaderHeight(headerHeight)
        }
        footerView?.let {
            measureChildWithMargins(it, widthMeasureSpec, 0, heightMeasureSpec, 0)
            val lp = it.layoutParams as MarginLayoutParams
            footerHeight = it.measuredHeight + lp.topMargin + lp.bottomMargin
            ptrIndicator.setFooterHeight(footerHeight)
        }
        mContent?.let { measureContentView(it, widthMeasureSpec, heightMeasureSpec) }
    }

    private fun measureContentView(child: View, parentWidthMeasureSpec: Int, parentHeightMeasureSpec: Int) {
        val lp = child.layoutParams as MarginLayoutParams
        val childWidthMeasureSpec = getChildMeasureSpec(parentWidthMeasureSpec, paddingLeft + paddingRight + lp.leftMargin + lp.rightMargin, lp.width)
        val childHeightMeasureSpec = getChildMeasureSpec(parentHeightMeasureSpec, paddingTop + paddingBottom + lp.topMargin, lp.height)
        child.measure(childWidthMeasureSpec, childHeightMeasureSpec)
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        layoutChildren()
        // An auto refresh asked for before the first layout starts now (issues #122, #189, #247, #300, #333).
        pendingAutoRefresh?.let { run ->
            if (headerHeight > 0 || footerHeight > 0) {
                pendingAutoRefresh = null
                mainHandler.post(run)
            }
        }
    }

    private fun layoutChildren() {
        val pos = ptrIndicator.getCurrentPosY()
        val headerPos = if (ptrIndicator.isHeader) pos else 0
        val footerPos = if (ptrIndicator.isHeader) 0 else pos
        headerView?.let {
            val lp = it.layoutParams as MarginLayoutParams
            val left = paddingLeft + lp.leftMargin
            // A pinned header stops once fully shown (pull request #236).
            val shown = if (isPinHeader) min(headerPos, headerHeight) else headerPos
            val top = paddingTop + lp.topMargin + headerOffset + shown - headerHeight
            layoutHeader(it, left, top, left + it.measuredWidth, top + it.measuredHeight)
            it.visibility = if (headerOffset != 0 && headerPos == 0) INVISIBLE else VISIBLE
        }
        var contentBottom = 0
        mContent?.let {
            val lp = it.layoutParams as MarginLayoutParams
            val left = paddingLeft + lp.leftMargin
            val move = if (isPinContent) 0 else headerPos - footerPos
            val top = paddingTop + lp.topMargin + move
            layoutContent(it, left, top, left + it.measuredWidth, top + it.measuredHeight)
            contentBottom = top + it.measuredHeight + lp.bottomMargin - move
        }
        footerView?.let {
            val lp = it.layoutParams as MarginLayoutParams
            val left = paddingLeft + lp.leftMargin
            val top = contentBottom + lp.topMargin - footerPos
            layoutFooter(it, left, top, left + it.measuredWidth, top + it.measuredHeight)
        }
    }

    /**
     * Lays out the header; a subclass can place it elsewhere (pull request #162).
     */
    protected open fun layoutHeader(header: View, left: Int, top: Int, right: Int, bottom: Int) {
        header.layout(left, top, right, bottom)
    }

    /**
     * Lays out the content; a subclass can place it elsewhere (pull request #162).
     */
    protected open fun layoutContent(content: View, left: Int, top: Int, right: Int, bottom: Int) {
        content.layout(left, top, right, bottom)
    }

    /**
     * Lays out the footer; a subclass can place it elsewhere.
     */
    protected open fun layoutFooter(footer: View, left: Int, top: Int, right: Int, bottom: Int) {
        footer.layout(left, top, right, bottom)
    }

    // MARK: - Touches

    /**
     * Sends [e] to the children, past this frame's own handling.
     */
    fun dispatchTouchEventSupper(e: MotionEvent): Boolean = super.dispatchTouchEvent(e)

    override fun requestDisallowInterceptTouchEvent(disallowIntercept: Boolean) {
        // A child that handles a sideways gesture itself (a slider, a pager, a draggable badge) keeps it (issues #83,
        // #133, #233), as long as the frame has not started pulling. A vertical drag still pulls: a list at its top asks
        // too when the finger passes its touch slop, and the pull must win then.
        disallowInterceptRequested = disallowIntercept
        super.requestDisallowInterceptTouchEvent(disallowIntercept)
    }

    override fun dispatchTouchEvent(e: MotionEvent): Boolean {
        val content = mContent
        if (!isEnabled || content == null || (headerView == null && footerView == null)) return dispatchTouchEventSupper(e)
        if (isContentTouchBlockedWhileRefreshing && status == PTR_STATUS_LOADING) return true
        when (e.actionMasked) {
            MotionEvent.ACTION_DOWN -> {
                activePointerId = e.getPointerId(0)
                hasSendCancelEvent = false
                isBeingDragged = false
                disallowInterceptRequested = false
                preventForHorizontal = false
                ptrIndicator.onPressDown(e.x, e.y)
                scrollChecker.abortIfWorking()
                // The cancel event is sent once the position moves, so let the event pass to the children (#93, #102).
                dispatchTouchEventSupper(e)
                return true
            }
            MotionEvent.ACTION_POINTER_DOWN -> {
                // The newest finger leads (issue #41).
                val index = e.actionIndex
                activePointerId = e.getPointerId(index)
                ptrIndicator.resetLastMove(e.getX(index), e.getY(index))
                return dispatchTouchEventSupper(e)
            }
            MotionEvent.ACTION_POINTER_UP -> {
                val index = e.actionIndex
                if (e.getPointerId(index) == activePointerId) {
                    val next = if (index == 0) 1 else 0
                    activePointerId = e.getPointerId(next)
                    ptrIndicator.resetLastMove(e.getX(next), e.getY(next))
                }
                return dispatchTouchEventSupper(e)
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                activePointerId = MotionEvent.INVALID_POINTER_ID
                ptrIndicator.onRelease()
                if (ptrIndicator.hasLeftStartPosition()) {
                    onRelease(false)
                    if (ptrIndicator.hasMovedAfterPressedDown()) {
                        sendCancelEvent()
                        return true
                    }
                }
                return dispatchTouchEventSupper(e)
            }
            MotionEvent.ACTION_MOVE -> {
                val index = e.findPointerIndex(activePointerId).takeIf { it >= 0 } ?: 0
                lastMoveEvent = e
                ptrIndicator.onMove(e.getX(index), e.getY(index))
                val offsetX = ptrIndicator.offsetX
                val offsetY = ptrIndicator.offsetY
                val pulled = ptrIndicator.hasLeftStartPosition()
                if (disallowInterceptRequested && !pulled && !isBeingDragged && ptrIndicator.isMovedHorizontal()) return dispatchTouchEventSupper(e)
                // A sideways move from the start goes to the children (pull requests #178, #209, #270).
                if (disableWhenHorizontal && !preventForHorizontal && !pulled && !isBeingDragged &&
                    abs(ptrIndicator.getDistanceX()) > pagingTouchSlop && ptrIndicator.isMovedHorizontal()
                ) {
                    preventForHorizontal = true
                }
                if (preventForHorizontal) return dispatchTouchEventSupper(e)
                if (!pulled && !isBeingDragged) {
                    // Small moves (a tap on an item) go to the children: the touch slop (#178) and the dead zone (#288).
                    if (abs(ptrIndicator.getDistanceY()) <= max(touchSlop, ptrIndicator.deadZone)) return dispatchTouchEventSupper(e)
                    if (disableWhenHorizontal && ptrIndicator.isMovedHorizontal()) return dispatchTouchEventSupper(e)
                }
                val moveDown = offsetY > 0
                val headerShowing = ptrIndicator.isHeader && pulled
                val footerShowing = !ptrIndicator.isHeader && pulled && footerView != null
                if (headerShowing) {
                    moveHeaderPos(offsetY)
                    return true
                }
                if (footerShowing) {
                    if (status != PTR_STATUS_COMPLETE) moveFooterPos(offsetY)
                    return true
                }
                if (moveDown && canHeaderPull(content)) {
                    startDragging()
                    moveHeaderPos(offsetY)
                    return true
                }
                if (offsetY < 0 && canFooterPull(content)) {
                    startDragging()
                    moveFooterPos(offsetY)
                    return true
                }
            }
        }
        return dispatchTouchEventSupper(e)
    }

    private fun startDragging() {
        isBeingDragged = true
        // A scrolling ancestor (a HorizontalScrollView) keeps out while pulling (issue #284).
        parent?.requestDisallowInterceptTouchEvent(true)
    }

    private fun canHeaderPull(content: View): Boolean {
        if (headerView == null || mode == Mode.NONE || mode == Mode.LOAD_MORE) return false
        val handler = ptrHandler ?: return true
        return handler.checkCanDoRefresh(this, content, headerView)
    }

    private fun canFooterPull(content: View): Boolean {
        if (footerView == null || mode == Mode.NONE || mode == Mode.REFRESH) return false
        val handler = ptrHandler as? PtrHandler2 ?: return false
        return handler.checkCanDoLoadMore(this, content, footerView)
    }

    private fun moveHeaderPos(deltaY: Float) {
        if (ptrIndicator.isInStartPosition()) ptrIndicator.isHeader = true
        movePos(deltaY)
    }

    private fun moveFooterPos(deltaY: Float) {
        if (ptrIndicator.isInStartPosition()) ptrIndicator.isHeader = false
        movePos(-deltaY)
    }

    /**
     * Moves [deltaY] pixels away from the start (negative: back toward it).
     */
    private fun movePos(deltaY: Float) {
        if (deltaY < 0 && ptrIndicator.isInStartPosition()) return
        var to = ptrIndicator.getCurrentPosY() + deltaY.toInt()
        if (ptrIndicator.willOverTop(to)) to = PtrIndicator.POS_START
        if (maxPullDistance > 0) to = min(to, maxPullDistance)
        ptrIndicator.setCurrentPos(to)
        updatePos(to - ptrIndicator.getLastPosY())
    }

    private fun updatePos(change: Int) {
        if (change == 0) return
        val isUnderTouch = ptrIndicator.isUnderTouch
        // Once moved, the children get a cancel event.
        if (isUnderTouch && !hasSendCancelEvent && ptrIndicator.hasMovedAfterPressedDown()) {
            hasSendCancelEvent = true
            sendCancelEvent()
        }
        // Left the start, or pulled again right after completing.
        if (ptrIndicator.hasJustLeftStartPosition() && status == PTR_STATUS_INIT ||
            ptrIndicator.goDownCrossFinishPosition() && status == PTR_STATUS_COMPLETE && isEnabledNextPtrAtOnce && isUnderTouch
        ) {
            status = PTR_STATUS_PREPARE
            completeNotified = false
            mainHandler.removeCallbacks(closeAfterCompleted)
            uiHandlerHolder.onUIRefreshPrepare(this)
            if (DEBUG) PtrCLog.i(LOG_TAG, "PtrUIHandler: onUIRefreshPrepare, flag $flag")
        }
        // Back at the start.
        if (ptrIndicator.hasJustBackToStartPosition()) {
            tryToNotifyReset()
            if (isUnderTouch) sendDownEvent()
        }
        if (status == PTR_STATUS_PREPARE) {
            if (isUnderTouch && !isAutoRefresh && isPullToRefresh && ptrIndicator.crossRefreshLineFromTopToBottom()) tryToPerformRefresh()
            if (performAutoRefreshButLater() && ptrIndicator.hasJustReachedHeaderHeightFromTopToBottom()) tryToPerformRefresh()
        }
        layoutChildren()
        invalidate()
        if (uiHandlerHolder.hasHandler()) uiHandlerHolder.onUIPositionChange(this, isUnderTouch, status, ptrIndicator)
        onPositionChange(isUnderTouch, status, ptrIndicator)
    }

    /**
     * Called after every position change; a subclass can follow the pull.
     */
    protected open fun onPositionChange(isInTouching: Boolean, status: Byte, ptrIndicator: PtrIndicator) {}

    private fun onRelease(stayForLoading: Boolean) {
        tryToPerformRefresh()
        if (status == PTR_STATUS_LOADING) {
            if (isKeepHeaderWhenRefresh) {
                if (ptrIndicator.isOverOffsetToKeepHeaderWhileLoading() && !stayForLoading) {
                    scrollChecker.tryToScrollTo(ptrIndicator.getOffsetToKeepHeaderWhileLoading(), durationToClose)
                }
            } else {
                tryScrollBackToTop()
            }
        } else if (status == PTR_STATUS_COMPLETE) {
            notifyUIRefreshComplete(false)
        } else {
            tryScrollBackToTop()
        }
    }

    /**
     * Holds the completion until the hook resumes (please do remember to resume it).
     */
    fun setRefreshCompleteHook(hook: PtrUIHandlerHook) {
        refreshCompleteHook = hook
        hook.setResumeAction { notifyUIRefreshComplete(true) }
    }

    private fun tryScrollBackToTop() {
        if (!ptrIndicator.isUnderTouch) scrollChecker.tryToScrollTo(PtrIndicator.POS_START, durationToCloseHeader)
    }

    private fun tryScrollBackToTopAfterComplete() = tryScrollBackToTop()

    private fun tryToPerformRefresh(): Boolean {
        if (status != PTR_STATUS_PREPARE) return false
        if (ptrIndicator.isOverOffsetToKeepHeaderWhileLoading() && isAutoRefresh || ptrIndicator.isOverOffsetToRefresh()) {
            status = PTR_STATUS_LOADING
            performRefresh()
        }
        return false
    }

    private fun performRefresh() {
        loadingStartTime = System.currentTimeMillis()
        if (uiHandlerHolder.hasHandler()) uiHandlerHolder.onUIRefreshBegin(this)
        announceForAccessibility(context.getString(if (ptrIndicator.isHeader) R.string.cube_ptr_refreshing else R.string.cube_ptr_loading_more))
        if (ptrIndicator.isHeader) ptrHandler?.onRefreshBegin(this) else (ptrHandler as? PtrHandler2)?.onLoadMoreBegin(this)
    }

    private fun tryToNotifyReset(): Boolean {
        if ((status == PTR_STATUS_COMPLETE || status == PTR_STATUS_PREPARE) && ptrIndicator.isInStartPosition()) {
            if (uiHandlerHolder.hasHandler()) uiHandlerHolder.onUIReset(this)
            status = PTR_STATUS_INIT
            completeNotified = false
            clearFlag()
            return true
        }
        return false
    }

    /**
     * The scroll back was stopped by a touch.
     */
    protected open fun onPtrScrollAbort() {
        if (ptrIndicator.hasLeftStartPosition() && isAutoRefresh) onRelease(true)
    }

    /**
     * The scroll back finished.
     */
    protected open fun onPtrScrollFinish() {
        if (ptrIndicator.hasLeftStartPosition() && isAutoRefresh) onRelease(true)
    }

    /**
     * YES while refreshing or loading more.
     */
    val isRefreshing: Boolean
        get() = status == PTR_STATUS_LOADING

    /**
     * YES while loading more, pulled up (pull request #157).
     */
    val isLoadingMore: Boolean
        get() = status == PTR_STATUS_LOADING && !ptrIndicator.isHeader

    /**
     * The status, one of the `PTR_STATUS_*` constants.
     */
    val ptrStatus: Byte
        get() = status

    /**
     * Call this when the data is loaded (refreshing or loading more). The UI completes at once or after
     * [loadingMinTime].
     */
    fun refreshComplete() {
        refreshCompleteHook?.reset()
        // A long, so a loading that never started cannot overflow into a huge delay (pull request #319, issue #246,
        // #339).
        val delay = loadingMinTime - (System.currentTimeMillis() - loadingStartTime)
        mainHandler.removeCallbacks(performRefreshCompleteDelay)
        if (delay <= 0 || loadingStartTime == 0L) performRefreshComplete() else mainHandler.postDelayed(performRefreshCompleteDelay, delay)
    }

    private fun performRefreshComplete() {
        if (status != PTR_STATUS_LOADING && status != PTR_STATUS_PREPARE) return
        status = PTR_STATUS_COMPLETE
        loadingStartTime = 0L
        // An auto refresh waits for its scroll to stop.
        if (scrollChecker.isRunning && isAutoRefresh) return
        notifyUIRefreshComplete(false)
    }

    private fun notifyUIRefreshComplete(ignoreHook: Boolean) {
        if (ptrIndicator.hasLeftStartPosition() && !ignoreHook && refreshCompleteHook != null) {
            refreshCompleteHook?.takeOver()
            return
        }
        // The UI hears about the completion once, even when a touch releases again before the header closed (#77).
        if (!completeNotified) {
            completeNotified = true
            if (uiHandlerHolder.hasHandler()) uiHandlerHolder.onUIRefreshComplete(this)
            ptrIndicator.onUIRefreshComplete()
            if (durationToKeepCompleted > 0 && ptrIndicator.hasLeftStartPosition()) {
                mainHandler.postDelayed(closeAfterCompleted, durationToKeepCompleted.toLong())
                return
            }
        }
        tryScrollBackToTopAfterComplete()
        tryToNotifyReset()
    }

    /**
     * Refreshes as if pulled, showing the header.
     */
    fun autoRefresh() = autoRefresh(true, durationToCloseHeader)

    /**
     * Refreshes as if pulled; [atOnce] NO refreshes once the header is fully shown.
     */
    fun autoRefresh(atOnce: Boolean) = autoRefresh(atOnce, durationToCloseHeader)

    /**
     * Refreshes as if pulled, scrolling the header in over [duration] milliseconds.
     */
    fun autoRefresh(atOnce: Boolean, duration: Int) = autoRefresh(atOnce, duration, true)

    /**
     * Loads more as if pulled up, showing the footer (pull request #157).
     */
    @JvmOverloads
    fun autoLoadMore(atOnce: Boolean = true) = autoRefresh(atOnce, durationToCloseHeader, false)

    /**
     * Refreshes ([isHeader]) or loads more as if pulled. Before the first layout it waits for it (issues #122, #189,
     * #247, #300, #333); with `enabledNextPtrAtOnce` it also works while the last refresh is closing (#123, pull
     * request #176).
     */
    fun autoRefresh(atOnce: Boolean, duration: Int, isHeader: Boolean) {
        val nextAtOnce = status == PTR_STATUS_COMPLETE && isEnabledNextPtrAtOnce
        if (status != PTR_STATUS_INIT && !nextAtOnce) return
        if ((if (isHeader) headerHeight else footerHeight) == 0) {
            pendingAutoRefresh = { autoRefresh(atOnce, duration, isHeader) }
            requestLayout()
            return
        }
        if (nextAtOnce) {
            mainHandler.removeCallbacks(closeAfterCompleted)
            completeNotified = false
        }
        flag = flag or if (atOnce) FLAG_AUTO_REFRESH_AT_ONCE else FLAG_AUTO_REFRESH_BUT_LATER
        if (ptrIndicator.isInStartPosition()) ptrIndicator.isHeader = isHeader
        if (isHeader && autoRefreshScrollsContentToTop) scrollContentToTop()
        status = PTR_STATUS_PREPARE
        if (uiHandlerHolder.hasHandler()) uiHandlerHolder.onUIRefreshPrepare(this)
        scrollChecker.tryToScrollTo(ptrIndicator.getOffsetToTrigger(), duration)
        if (atOnce) {
            status = PTR_STATUS_LOADING
            performRefresh()
        }
    }

    private fun scrollContentToTop() {
        val content = mContent ?: return
        when (content) {
            is AbsListView -> content.setSelection(0)
            is ScrollingView -> content.scrollBy(0, -content.computeVerticalScrollOffset())
            else -> content.scrollTo(content.scrollX, 0)
        }
    }

    private fun clearFlag() {
        flag = flag and MASK_AUTO_REFRESH.inv()
    }

    /**
     * YES during an auto refresh.
     */
    val isAutoRefresh: Boolean
        get() = flag and MASK_AUTO_REFRESH > 0

    private fun performAutoRefreshButLater(): Boolean = flag and MASK_AUTO_REFRESH == FLAG_AUTO_REFRESH_BUT_LATER

    /**
     * YES lets the user pull again at once, while the last refresh is closing.
     */
    var isEnabledNextPtrAtOnce: Boolean
        get() = flag and FLAG_ENABLE_NEXT_PTR_AT_ONCE > 0
        set(enable) {
            flag = if (enable) flag or FLAG_ENABLE_NEXT_PTR_AT_ONCE else flag and FLAG_ENABLE_NEXT_PTR_AT_ONCE.inv()
        }

    /**
     * YES keeps the content in place while the header moves.
     */
    var isPinContent: Boolean
        get() = flag and FLAG_PIN_CONTENT > 0
        set(pin) {
            flag = if (pin) flag or FLAG_PIN_CONTENT else flag and FLAG_PIN_CONTENT.inv()
        }

    /**
     * YES keeps the header in place once fully shown while the content goes on moving (pull request #236).
     */
    var isPinHeader: Boolean
        get() = flag and FLAG_PIN_HEADER > 0
        set(pin) {
            flag = if (pin) flag or FLAG_PIN_HEADER else flag and FLAG_PIN_HEADER.inv()
        }

    /**
     * YES lets sideways moves go to the children, for a ViewPager inside.
     */
    fun disableWhenHorizontalMove(disable: Boolean) {
        disableWhenHorizontal = disable
    }

    /**
     * Not needed any longer: once moved, the children get a cancel event.
     */
    @Deprecated("Once moved, the children get a cancel event.")
    fun setInterceptEventWhileWorking(yes: Boolean) {}

    /**
     * Sets the handler that decides when to pull and starts the refresh.
     */
    fun setPtrHandler(ptrHandler: PtrHandler?) {
        this.ptrHandler = ptrHandler
    }

    /**
     * Adds a UI handler (a header or a footer); each one once.
     */
    fun addPtrUIHandler(ptrUIHandler: PtrUIHandler) {
        uiHandlerHolder.add(ptrUIHandler)
    }

    /**
     * Removes a UI handler.
     */
    fun removePtrUIHandler(ptrUIHandler: PtrUIHandler) {
        uiHandlerHolder.remove(ptrUIHandler)
    }

    /**
     * How hard the frame is to pull. Default 1.7.
     */
    var resistance: Float
        get() = ptrIndicator.resistance
        set(value) {
            ptrIndicator.resistance = value
        }

    /**
     * Pixels the finger moves before a pull starts (pull request #288). Default 0.
     */
    var deadZone: Int
        get() = ptrIndicator.deadZone
        set(value) {
            ptrIndicator.deadZone = value
        }

    /**
     * Sets the refresh offset to [ratio] times the header's height.
     */
    fun setRatioOfHeaderHeightToRefresh(ratio: Float) = ptrIndicator.setRatioOfHeaderHeightToRefresh(ratio)

    /**
     * The refresh offset as a ratio of the header's height.
     */
    val ratioOfHeaderToHeightRefresh: Float
        get() = ptrIndicator.ratioOfHeaderToHeightRefresh

    /**
     * The pulled distance at which a release refreshes.
     */
    var offsetToRefresh: Int
        get() = ptrIndicator.getOffsetToRefresh()
        set(value) = ptrIndicator.setOffsetToRefresh(value)

    /**
     * The offset kept while refreshing.
     */
    var offsetToKeepHeaderWhileLoading: Int
        get() = ptrIndicator.getOffsetToKeepHeaderWhileLoading()
        set(value) = ptrIndicator.setOffsetToKeepHeaderWhileLoading(value)

    override fun checkLayoutParams(p: ViewGroup.LayoutParams?): Boolean = p is LayoutParams

    override fun generateDefaultLayoutParams(): ViewGroup.LayoutParams = LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)

    override fun generateLayoutParams(p: ViewGroup.LayoutParams): ViewGroup.LayoutParams = LayoutParams(p)

    override fun generateLayoutParams(attrs: AttributeSet): ViewGroup.LayoutParams = LayoutParams(context, attrs)

    override fun getAccessibilityClassName(): CharSequence = PtrFrameLayout::class.java.name

    override fun onInitializeAccessibilityNodeInfo(info: AccessibilityNodeInfo) {
        super.onInitializeAccessibilityNodeInfo(info)
        // Accessibility: refreshing is an action, as a pull cannot be done with TalkBack or Switch Access.
        if (isEnabled && headerView != null && status == PTR_STATUS_INIT) {
            info.addAction(AccessibilityNodeInfo.AccessibilityAction(R.id.cube_ptr_action_refresh, context.getString(R.string.cube_ptr_pull_down_to_refresh)))
        }
    }

    override fun performAccessibilityAction(action: Int, arguments: android.os.Bundle?): Boolean {
        if (action == R.id.cube_ptr_action_refresh) {
            autoRefresh()
            return true
        }
        return super.performAccessibilityAction(action, arguments)
    }

    private fun sendCancelEvent() {
        // The ScrollChecker moves without a move event; there is nothing to cancel then (#104, #80, #92).
        val last = lastMoveEvent ?: return
        val e = MotionEvent.obtain(last.downTime, last.eventTime + ViewConfiguration.getLongPressTimeout(), MotionEvent.ACTION_CANCEL, last.x, last.y, last.metaState)
        dispatchTouchEventSupper(e)
        e.recycle()
    }

    private fun sendDownEvent() {
        val last = lastMoveEvent ?: return
        val e = MotionEvent.obtain(last.downTime, last.eventTime, MotionEvent.ACTION_DOWN, last.x, last.y, last.metaState)
        dispatchTouchEventSupper(e)
        e.recycle()
    }

    /**
     * The layout parameters: margins.
     */
    open class LayoutParams : MarginLayoutParams {
        /**
         * From XML attributes.
         */
        constructor(c: Context, attrs: AttributeSet?) : super(c, attrs)

        /**
         * With a width and a height.
         */
        constructor(width: Int, height: Int) : super(width, height)

        /**
         * A copy of margin parameters.
         */
        constructor(source: MarginLayoutParams) : super(source)

        /**
         * A copy of other parameters.
         */
        constructor(source: ViewGroup.LayoutParams) : super(source)
    }

    /**
     * Scrolls the frame to a position over a duration, one step every frame.
     */
    internal inner class ScrollChecker : Runnable {
        private var lastFlingY = 0
        private val scroller = Scroller(context)
        var isRunning = false
            private set
        private var to = 0

        override fun run() {
            val finish = !scroller.computeScrollOffset() || scroller.isFinished
            val curY = scroller.currY
            val deltaY = curY - lastFlingY
            if (!finish) {
                lastFlingY = curY
                movePos(deltaY.toFloat())
                mainHandler.postDelayed(this, FRAME_MILLIS)
            } else {
                finish()
            }
        }

        private fun finish() {
            // Finish once (issue #48), exactly at the target, also with a duration of 0 (pull request #240; issues
            // #239, #242, #245, #276).
            if (!isRunning) return
            if (ptrIndicator.getCurrentPosY() != to) movePos((to - ptrIndicator.getCurrentPosY()).toFloat())
            reset()
            onPtrScrollFinish()
        }

        private fun reset() {
            isRunning = false
            lastFlingY = 0
            mainHandler.removeCallbacks(this)
        }

        fun destroy() {
            // Detached mid-scroll (a fragment switched away): jump to the target, so the header does not stay open
            // (pull request #268, issue #200).
            if (isRunning && ptrIndicator.getCurrentPosY() != to) movePos((to - ptrIndicator.getCurrentPosY()).toFloat())
            reset()
            if (!scroller.isFinished) scroller.forceFinished(true)
        }

        fun abortIfWorking() {
            if (isRunning) {
                if (!scroller.isFinished) scroller.forceFinished(true)
                onPtrScrollAbort()
                reset()
            }
        }

        fun tryToScrollTo(to: Int, duration: Int) {
            if (ptrIndicator.isAlreadyHere(to)) return
            val start = ptrIndicator.getCurrentPosY()
            this.to = to
            mainHandler.removeCallbacks(this)
            lastFlingY = 0
            // The scroller is reused (#47).
            if (!scroller.isFinished) scroller.forceFinished(true)
            isRunning = true
            if (duration <= 0) {
                finish()
                return
            }
            scroller.startScroll(0, 0, 0, to - start, duration)
            mainHandler.post(this)
        }
    }

    /**
     * Status constants and the debug switch.
     */
    companion object {
        /**
         * At the start, nothing pulled.
         */
        const val PTR_STATUS_INIT: Byte = 1

        /**
         * Pulled, not refreshing yet.
         */
        const val PTR_STATUS_PREPARE: Byte = 2

        /**
         * Refreshing or loading more.
         */
        const val PTR_STATUS_LOADING: Byte = 3

        /**
         * Refreshing completed; the header is closing.
         */
        const val PTR_STATUS_COMPLETE: Byte = 4

        /**
         * YES logs the frame's steps.
         */
        @JvmField
        var DEBUG = false

        private var ID = 1
        private const val FRAME_MILLIS = 10L
        private const val FLAG_AUTO_REFRESH_AT_ONCE = 0x01
        private const val FLAG_AUTO_REFRESH_BUT_LATER = 0x01 shl 1
        private const val FLAG_ENABLE_NEXT_PTR_AT_ONCE = 0x01 shl 2
        private const val FLAG_PIN_CONTENT = 0x01 shl 3
        private const val FLAG_PIN_HEADER = 0x01 shl 4
        private const val MASK_AUTO_REFRESH = 0x03
    }
}
