package com.cyl.refresh

import android.content.Context
import android.view.HapticFeedbackConstants
import android.view.View
import com.cyl.refresh.merged.R
import com.scwang.smart.refresh.classics.ClassicsAbstract
import com.scwang.smart.refresh.footer.ClassicsFooter
import com.scwang.smart.refresh.header.ClassicsHeader
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import com.scwang.smart.refresh.layout.api.RefreshComponent
import com.scwang.smart.refresh.layout.api.RefreshFooter
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.simple.SimpleMultiListener
import java.util.Date
import java.util.concurrent.CopyOnWriteArrayList
import kotlin.math.max

/**
 * The iOS `CYLRefreshComponent` on Android (docs/Android-API-Map.md): the API both a header and a footer share, with the
 * iOS names, on top of SmartRefreshLayout. On iOS a component is attached to a scroll view; on Android it is attached
 * to the [SmartRefreshLayout] that wraps the content ([attach], or `refreshLayout.cyl_header` / `cyl_footer`), and
 * [view] is the SmartRefreshLayout header or footer it shows.
 */
abstract class CYLRefreshComponent internal constructor(
    /**
     * The SmartRefreshLayout header or footer this component shows.
     */
    val view: RefreshComponent,
) {
    internal abstract val isHeader: Boolean

    /**
     * The layout the component is attached to (the iOS `scrollView`'s counterpart), or null.
     */
    var refreshLayout: SmartRefreshLayout? = null
        private set

    /**
     * The scrolling content of the layout the component is attached to (`scrollView`).
     */
    val scrollView: View?
        get() = refreshLayout?.let { layout -> (0 until layout.childCount).map { layout.getChildAt(it) }.firstOrNull { it !== view.view && it !== layout.refreshHeader?.view && it !== layout.refreshFooter?.view } }

    /**
     * Whether the component is attached to a layout (`attached`).
     */
    val attached: Boolean
        get() = refreshLayout != null

    /**
     * The fast animation's duration, in seconds (`fastAnimationDuration`).
     */
    var fastAnimationDuration: Double = CYLRefreshConst.CYLRefreshFastAnimationDuration

    /**
     * The slow animation's duration, in seconds (`slowAnimationDuration`).
     */
    var slowAnimationDuration: Double = CYLRefreshConst.CYLRefreshSlowAnimationDuration

    /**
     * Sets both animation durations to 0 (`setAnimationDisabled`).
     */
    fun setAnimationDisabled(): CYLRefreshComponent = apply {
        fastAnimationDuration = 0.0
        slowAnimationDuration = 0.0
    }

    /**
     * Called when the component starts refreshing (`refreshingBlock`).
     */
    var refreshingBlock: CYLRefreshComponentRefreshingBlock? = null

    /**
     * Called with the component when it starts refreshing (`refreshingHandler`), after [refreshingBlock].
     */
    var refreshingHandler: CYLRefreshComponentHandler? = null

    /**
     * Called once a refresh has begun (`beginRefreshingCompletionBlock`).
     */
    var beginRefreshingCompletionBlock: CYLRefreshComponentBeginRefreshingCompletionBlock? = null

    /**
     * Called when the closing animation of a refresh starts (`endRefreshingAnimationBeginAction`).
     */
    var endRefreshingAnimationBeginAction: CYLRefreshComponentAction? = null

    /**
     * Called once a refresh has ended and closed (`endRefreshingCompletionBlock`).
     */
    var endRefreshingCompletionBlock: CYLRefreshComponentEndRefreshingCompletionBlock? = null

    /**
     * Calls [refreshingBlock], [refreshingHandler], then [beginRefreshingCompletionBlock], in the iOS order
     * (`executeRefreshingCallback`).
     */
    open fun executeRefreshingCallback() {
        refreshingBlock?.invoke()
        refreshingHandler?.invoke(this)
        beginRefreshingCompletionBlock?.invoke()
    }

    /**
     * Starts refreshing (`beginRefreshing`); before the layout is on screen, the state is [CYLRefreshState.WillRefresh]
     * until it shows.
     */
    abstract fun beginRefreshing()

    /**
     * Starts refreshing and calls [completion] once it has begun (`beginRefreshingWithCompletionBlock:`).
     */
    fun beginRefreshingWithCompletionBlock(completion: CYLRefreshComponentBeginRefreshingCompletionBlock) {
        beginRefreshingCompletionBlock = completion
        beginRefreshing()
    }

    /**
     * Ends refreshing (`endRefreshing`).
     */
    fun endRefreshing() = endRefreshingWithSuccess(true)

    /**
     * Ends refreshing and calls [completion] once it has closed (`endRefreshingWithCompletionBlock:`).
     */
    fun endRefreshingWithCompletionBlock(completion: CYLRefreshComponentEndRefreshingCompletionBlock) {
        endRefreshingCompletionBlock = completion
        endRefreshing()
    }

    /**
     * Ends refreshing, showing success or failure (`endRefreshingWithSuccess:`).
     */
    fun endRefreshingWithSuccess(success: Boolean) {
        lastRefreshSucceeded = success
        finish(success)
    }

    internal abstract fun finish(success: Boolean)

    /**
     * Whether the last refresh succeeded (`lastRefreshSucceeded`).
     */
    var lastRefreshSucceeded: Boolean = true
        private set

    /**
     * Whether the component is refreshing or about to (`refreshing`).
     */
    val isRefreshing: Boolean
        get() = state == CYLRefreshState.Refreshing || state == CYLRefreshState.WillRefresh

    /**
     * The state (`state`).
     */
    open val state: CYLRefreshState
        get() = when (phase) {
            CYLRefreshPhase.Idle, CYLRefreshPhase.PullToRefresh, CYLRefreshPhase.Finishing -> CYLRefreshState.Idle
            CYLRefreshPhase.ReleaseToRefresh, CYLRefreshPhase.SecondaryArmed -> CYLRefreshState.Pulling
            CYLRefreshPhase.WillRefresh -> CYLRefreshState.WillRefresh
            CYLRefreshPhase.NoMoreData -> CYLRefreshState.NoMoreData
            else -> CYLRefreshState.Refreshing
        }

    /**
     * The detailed phase (`phase`).
     */
    var phase: CYLRefreshPhase = CYLRefreshPhase.Idle
        private set

    /**
     * True when [phase] is one of [phases] (`isInAnyPhase:`).
     */
    fun isInAnyPhase(vararg phases: CYLRefreshPhase): Boolean = phase in phases

    /**
     * True when [phase] is one of [phases] (`isInPhases:`).
     */
    fun isInPhases(phases: Collection<CYLRefreshPhase>): Boolean = phase in phases

    private val phaseObservers = CopyOnWriteArrayList<(CYLRefreshComponent, CYLRefreshPhase, CYLRefreshPhase) -> Unit>()

    /**
     * Calls [observer] with the old and new phase on every change (`addPhaseObserver:`).
     */
    fun addPhaseObserver(observer: (CYLRefreshComponent, CYLRefreshPhase, CYLRefreshPhase) -> Unit) {
        phaseObservers += observer
    }

    /**
     * Stops calling [observer] (`removePhaseObserver:`).
     */
    fun removePhaseObserver(observer: (CYLRefreshComponent, CYLRefreshPhase, CYLRefreshPhase) -> Unit) {
        phaseObservers -= observer
    }

    /**
     * How far the component is pulled, as a share of its height (`pullingPercent`).
     */
    var pullingPercent: Float = 0f
        private set

    /**
     * How far the component is pulled, in pixels (`dragOffset`).
     */
    var dragOffset: Int = 0
        private set

    /**
     * The component's alpha follows [pullingPercent] while it is pulled (`automaticallyChangeAlpha`).
     */
    var automaticallyChangeAlpha: Boolean = false
        set(value) {
            field = value
            if (value && state == CYLRefreshState.Idle) view.view.alpha = pullingPercent.coerceIn(0f, 1f)
            if (!value) view.view.alpha = 1f
        }

    /**
     * Whether pulling can refresh at all (`refreshEnabled`).
     */
    var refreshEnabled: Boolean = true
        set(value) {
            field = value
            refreshLayout?.let { applyEnabled(it) }
        }

    /**
     * The share of the component's height to pull before releasing refreshes (`triggerRate`).
     */
    var triggerRate: Float = 1f
        set(value) {
            field = value
            refreshLayout?.let { applyTriggerRate(it) }
        }

    /**
     * How long the finished text stays, in seconds (`finishDuration`); used by the classic header and footer.
     */
    var finishDuration: Double = 0.5
        set(value) {
            field = value
            (view as? ClassicsAbstract<*>)?.setFinishDuration((value * 1000).toInt())
        }

    /**
     * How the component moves with the pull (`scrollMode`); the classic header and footer change their spinner style.
     */
    var scrollMode: CYLRefreshScrollMode
        get() = when (view.spinnerStyle) {
            SpinnerStyle.FixedFront -> CYLRefreshScrollMode.Front
            SpinnerStyle.FixedBehind -> CYLRefreshScrollMode.Behind
            else -> if (view.spinnerStyle.scale) CYLRefreshScrollMode.Stretch else CYLRefreshScrollMode.Move
        }
        set(value) {
            val style = when (value) {
                CYLRefreshScrollMode.Move -> SpinnerStyle.Translate
                CYLRefreshScrollMode.Stretch -> SpinnerStyle.Scale
                CYLRefreshScrollMode.Front -> SpinnerStyle.FixedFront
                CYLRefreshScrollMode.Behind -> SpinnerStyle.FixedBehind
            }
            (view as? ClassicsAbstract<*>)?.setSpinnerStyle(style)
        }

    /**
     * The accent color (text and icons), or 0 for the component's own (`colorAccent`).
     */
    var colorAccent: Int = 0
        set(value) {
            field = value
            applyColors()
        }

    /**
     * The primary color (background), or 0 for the component's own (`colorPrimary`).
     */
    var colorPrimary: Int = 0
        set(value) {
            field = value
            applyColors()
        }

    private fun applyColors() {
        if (colorPrimary == 0 && colorAccent == 0) return
        (view as? ClassicsAbstract<*>)?.let {
            if (colorPrimary != 0) it.setPrimaryColor(colorPrimary)
            if (colorAccent != 0) it.setAccentColor(colorAccent)
            return
        }
        view.setPrimaryColors(colorPrimary, colorAccent)
    }

    /**
     * Vibrates once when the pull passes the trigger (`hapticFeedback`).
     */
    var hapticFeedback: Boolean = false

    /**
     * Whether a refresh and a load exclude each other (`exclusiveWithOtherRefresh`); SmartRefreshLayout always does, so
     * turning it off has no effect.
     */
    var exclusiveWithOtherRefresh: Boolean = true

    /**
     * Called when [beginRefreshing] is refused because the other component is busy (`blockedByOtherRefreshBlock`).
     */
    var blockedByOtherRefreshBlock: CYLRefreshComponentAction? = null

    /**
     * Whether the component holds its refreshing position (`expanded`).
     */
    val expanded: Boolean
        get() = phase == CYLRefreshPhase.Releasing || phase == CYLRefreshPhase.Refreshing || phase == CYLRefreshPhase.WillRefresh

    /**
     * The component's height when open, in pixels (`expandHeight`).
     */
    val expandHeight: Int
        get() = view.view.height

    /**
     * The farthest the component can be pulled open, in dp; 0 for no limit of its own (`maxPullDistance`).
     */
    var maxPullDistance: Float = 0f
        set(value) {
            field = value
            refreshLayout?.let { applyMaxPullDistance(it) }
        }

    /**
     * Whether the component keeps reporting while hidden (`notifiesWhenHidden`); SmartRefreshLayout always reports.
     */
    var notifiesWhenHidden: Boolean = true

    /**
     * Whether reaching the trigger starts at once, without a release (`triggersWhenReached`); a footer loads when
     * reached (SmartRefreshLayout's auto load more), a header keeps waiting for the release.
     */
    var triggersWhenReached: Boolean = false
        set(value) {
            field = value
            if (!isHeader) refreshLayout?.setEnableAutoLoadMore(value)
        }

    /**
     * Where a pull may start (`triggerMode`); SmartRefreshLayout pulls once the content is at its edge.
     */
    var triggerMode: CYLRefreshTriggerMode = CYLRefreshTriggerMode.OnEdge

    /**
     * Whether the component hides while it has nothing to show (`autoHideRefresh`).
     */
    var autoHideRefresh: Boolean = false
        set(value) {
            field = value
            updateAutoHideVisibility()
        }

    /**
     * Whether the component is at rest and not pulled, so auto hide may hide it (`isReadyToAutoHide`).
     */
    fun isReadyToAutoHide(): Boolean = phase == CYLRefreshPhase.Idle && dragOffset == 0

    /**
     * Applies [autoHideRefresh] now (`updateAutoHideVisibility`).
     */
    fun updateAutoHideVisibility() {
        view.view.visibility = if (autoHideRefresh && isReadyToAutoHide()) View.INVISIBLE else View.VISIBLE
    }

    /**
     * Starts refreshing with an opening animation of [duration] seconds that overshoots by [overOffset] pixels; with
     * [force], also when a pull is under way (`beginRefreshingWithDuration:overOffset:force:`).
     */
    fun beginRefreshingWithDuration(duration: Double, overOffset: Float, force: Boolean) {
        val layout = refreshLayout ?: return
        if (force && layout.state != RefreshState.None && !isRefreshing) layout.closeHeaderOrFooter()
        val height = max(1, expandHeight)
        val rate = 1f + overOffset / height
        val started = if (isHeader) layout.autoRefresh(0, (duration * 1000).toInt(), rate, false) else layout.autoLoadMore(0, (duration * 1000).toInt(), rate, false)
        if (!started && !isRefreshing) blockedByOtherRefreshBlock?.invoke()
    }

    internal abstract fun applyMaxPullDistance(layout: SmartRefreshLayout)

    /**
     * Attaches the component to [layout] (`attach:`), replacing its header (or footer).
     */
    fun attach(layout: SmartRefreshLayout): CYLRefreshComponent = apply {
        refreshLayout = layout
        if (isHeader) layout.setRefreshHeader(view as RefreshHeader) else layout.setRefreshFooter(view as RefreshFooter)
        CYLRefreshBridge.of(layout).attach(this)
        applyEnabled(layout)
        applyTriggerRate(layout)
        if (maxPullDistance > 0f) view.view.post { applyMaxPullDistance(layout) }
        if (!isHeader && triggersWhenReached) layout.setEnableAutoLoadMore(true)
        didAttachToScrollView(layout)
    }

    internal fun detach() {
        refreshLayout?.let { willDetachFromScrollView(it) }
        refreshLayout = null
    }

    internal abstract fun applyEnabled(layout: SmartRefreshLayout)

    internal abstract fun applyTriggerRate(layout: SmartRefreshLayout)

    // MARK: - Subclass hooks (the iOS names)

    /**
     * Called once attached to [layout] (`didAttachToScrollView:`).
     */
    protected open fun didAttachToScrollView(layout: SmartRefreshLayout) {}

    /**
     * Called before leaving [layout] (`willDetachFromScrollView:`).
     */
    protected open fun willDetachFromScrollView(layout: SmartRefreshLayout) {}

    /**
     * Called as the pull moves (`didScrollWithOffset:percent:dragging:`).
     */
    protected open fun didScrollWithOffset(offset: Int, percent: Float, dragging: Boolean) {}

    /**
     * Called on every phase change (`phaseDidChangeFrom:to:`).
     */
    protected open fun phaseDidChangeFrom(old: CYLRefreshPhase, new: CYLRefreshPhase) {}

    /**
     * Called when a refresh ends (`refreshDidFinishWithSuccess:`).
     */
    protected open fun refreshDidFinishWithSuccess(success: Boolean) {}

    /**
     * How long the finished state shows, in seconds (`finishingDurationWithSuccess:`).
     */
    open fun finishingDurationWithSuccess(success: Boolean): Double = finishDuration

    // MARK: - Driven by the layout

    internal fun moved(offset: Int, percent: Float, dragging: Boolean) {
        dragOffset = offset
        pullingPercent = percent
        if (autoHideRefresh) updateAutoHideVisibility()
        if (automaticallyChangeAlpha) {
            view.view.alpha = if (state == CYLRefreshState.Refreshing) 1f else percent.coerceIn(0f, 1f)
        }
        didScrollWithOffset(offset, percent, dragging)
    }

    internal fun setPhase(new: CYLRefreshPhase) {
        val old = phase
        if (old == new) return
        phase = new
        if (new == CYLRefreshPhase.ReleaseToRefresh && hapticFeedback) view.view.performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
        if (autoHideRefresh) updateAutoHideVisibility()
        phaseDidChangeFrom(old, new)
        phaseObservers.forEach { it(this, old, new) }
        when {
            new == CYLRefreshPhase.Finishing -> {
                refreshDidFinishWithSuccess(lastRefreshSucceeded)
                endRefreshingAnimationBeginAction?.invoke()
            }
            old == CYLRefreshPhase.Finishing && (new == CYLRefreshPhase.Idle || new == CYLRefreshPhase.NoMoreData) -> {
                didEndRefreshing()
                endRefreshingCompletionBlock?.invoke()
            }
        }
    }

    internal open fun didEndRefreshing() {}

    /**
     * The phase of a layout state, for this side.
     */
    internal open fun phaseOf(state: RefreshState): CYLRefreshPhase? = when (state) {
        RefreshState.None, RefreshState.PullDownCanceled, RefreshState.PullUpCanceled -> CYLRefreshPhase.Idle
        RefreshState.PullDownToRefresh, RefreshState.PullUpToLoad -> CYLRefreshPhase.PullToRefresh
        RefreshState.ReleaseToRefresh, RefreshState.ReleaseToLoad -> CYLRefreshPhase.ReleaseToRefresh
        RefreshState.RefreshReleased, RefreshState.LoadReleased -> CYLRefreshPhase.Releasing
        RefreshState.Refreshing, RefreshState.Loading -> CYLRefreshPhase.Refreshing
        RefreshState.RefreshFinish, RefreshState.LoadFinish -> CYLRefreshPhase.Finishing
        RefreshState.ReleaseToTwoLevel -> CYLRefreshPhase.SecondaryArmed
        RefreshState.TwoLevelReleased, RefreshState.TwoLevel -> CYLRefreshPhase.SecondaryOpen
        RefreshState.TwoLevelFinish -> CYLRefreshPhase.SecondaryClosing
    }

    internal fun layoutStateChanged(state: RefreshState) {
        val mine = state == RefreshState.None || (isHeader && state.isHeader) || (!isHeader && state.isFooter)
        if (!mine) return
        phaseOf(state)?.let { setPhase(it) }
    }

    internal fun markWillRefresh() = setPhase(CYLRefreshPhase.WillRefresh)

    // MARK: - Chaining (`CYLRefreshComponent (ChainingGrammar)`)

    /**
     * Sets [automaticallyChangeAlpha] (`cyl_autoChangeTransparency:`).
     */
    fun cyl_autoChangeTransparency(enabled: Boolean): CYLRefreshComponent = apply { automaticallyChangeAlpha = enabled }

    /**
     * Sets [beginRefreshingCompletionBlock] (`cyl_afterBeginningAction:`).
     */
    fun cyl_afterBeginningAction(action: CYLRefreshComponentAction): CYLRefreshComponent = apply { beginRefreshingCompletionBlock = action }

    /**
     * Sets [endRefreshingAnimationBeginAction] (`cyl_endingAnimationBeginningAction:`).
     */
    fun cyl_endingAnimationBeginningAction(action: CYLRefreshComponentAction): CYLRefreshComponent = apply { endRefreshingAnimationBeginAction = action }

    /**
     * Sets [endRefreshingCompletionBlock] (`cyl_afterEndingAction:`).
     */
    fun cyl_afterEndingAction(action: CYLRefreshComponentAction): CYLRefreshComponent = apply { endRefreshingCompletionBlock = action }

    /**
     * Attaches the component to [layout] (`cyl_linkTo:`).
     */
    fun cyl_linkTo(layout: SmartRefreshLayout): CYLRefreshComponent = attach(layout)
}

/**
 * The iOS `CYLRefreshHeader` on Android: pull down to refresh. [view] defaults to the classic header.
 */
open class CYLRefreshHeader(view: RefreshHeader) : CYLRefreshComponent(view) {

    override val isHeader = true

    /**
     * The key the last update time is stored under (`lastUpdatedTimeKey`).
     */
    var lastUpdatedTimeKey: String = CYLRefreshConst.CYLRefreshHeaderLastUpdatedTimeKey

    /**
     * When the header last finished refreshing, or null (`lastUpdatedTime`), kept across launches.
     */
    val lastUpdatedTime: Date?
        get() {
            val context = view.view.context
            val time = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE).getLong(lastUpdatedTimeKey, 0)
            return if (time == 0L) null else Date(time)
        }

    /**
     * The top inset the header ignores, in dp (`ignoredScrollViewContentInsetTop`): the layout's header inset start.
     */
    var ignoredScrollViewContentInsetTop: Float = 0f
        set(value) {
            field = value
            refreshLayout?.setHeaderInsetStart(value)
        }

    /**
     * Whether the content moves down to keep the refreshing header in sight (`addsRefreshingInset`).
     */
    var addsRefreshingInset: Boolean = true
        set(value) {
            field = value
            refreshLayout?.setEnableHeaderTranslationContent(value)
        }

    /**
     * Whether a finished refresh resets the footer's "no more data" (`resetsFooterAfterRefresh`).
     */
    var resetsFooterAfterRefresh: Boolean = false

    override fun beginRefreshing() {
        val layout = refreshLayout ?: return
        if (layout.state.isFooter && layout.state != RefreshState.None) {
            blockedByOtherRefreshBlock?.invoke()
            return
        }
        if (!layout.isAttachedToWindow) markWillRefresh()
        layout.autoRefresh()
    }

    /**
     * The header's height, in dp (`setExpandHeight:`).
     */
    fun setExpandHeight(dp: Float) {
        refreshLayout?.setHeaderHeight(dp)
    }

    override fun applyMaxPullDistance(layout: SmartRefreshLayout) {
        val height = view.view.height
        if (maxPullDistance > 0f && height > 0) layout.setHeaderMaxDragRate(max(1f, maxPullDistance * view.view.resources.displayMetrics.density / height))
    }

    override fun finish(success: Boolean) {
        refreshLayout?.finishRefresh(success)
    }

    override fun applyEnabled(layout: SmartRefreshLayout) {
        layout.setEnableRefresh(refreshEnabled)
    }

    override fun applyTriggerRate(layout: SmartRefreshLayout) {
        layout.setHeaderTriggerRate(triggerRate)
    }

    override fun didEndRefreshing() {
        if (!lastRefreshSucceeded) return
        val now = Date()
        view.view.context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE).edit().putLong(lastUpdatedTimeKey, now.time).apply()
        (view as? ClassicsHeader)?.setLastUpdateTime(now)
        if (resetsFooterAfterRefresh) refreshLayout?.cyl_footer?.resetNoMoreData()
    }

    /**
     * Makes headers with the iOS factory names.
     */
    companion object {
        private const val PREFERENCES = "CYLRefresh"

        /**
         * A classic header calling [block] when it refreshes (`headerWithRefreshingBlock:`).
         */
        @JvmStatic
        fun headerWithRefreshingBlock(context: Context, block: CYLRefreshComponentRefreshingBlock): CYLRefreshHeader =
            CYLRefreshHeader(ClassicsHeader(context)).apply { refreshingBlock = block }
    }
}

/**
 * The iOS `CYLRefreshFooter` on Android: pull up to load more. [view] defaults to the classic footer.
 */
open class CYLRefreshFooter(view: RefreshFooter) : CYLRefreshComponent(view) {

    override val isHeader = false

    /**
     * Whether there is no more data (`noMoreData`).
     */
    var noMoreData: Boolean = false
        private set

    /**
     * The bottom inset the footer ignores, in dp (`ignoredScrollViewContentInsetBottom`): the layout's footer inset
     * start.
     */
    var ignoredScrollViewContentInsetBottom: Float = 0f
        set(value) {
            field = value
            refreshLayout?.setFooterInsetStart(value)
        }

    override val state: CYLRefreshState
        get() = if (noMoreData && phase != CYLRefreshPhase.Refreshing) CYLRefreshState.NoMoreData else super.state

    override fun beginRefreshing() {
        val layout = refreshLayout ?: return
        if (layout.state.isHeader && layout.state != RefreshState.None) {
            blockedByOtherRefreshBlock?.invoke()
            return
        }
        if (!layout.isAttachedToWindow) markWillRefresh()
        layout.autoLoadMore()
    }

    /**
     * Whether a pull still loads after "no more data" (`loadsAfterNoMoreData`); when on, a pull clears "no more data"
     * first.
     */
    var loadsAfterNoMoreData: Boolean = false

    override fun applyMaxPullDistance(layout: SmartRefreshLayout) {
        val height = view.view.height
        if (maxPullDistance > 0f && height > 0) layout.setFooterMaxDragRate(max(1f, maxPullDistance * view.view.resources.displayMetrics.density / height))
    }

    override fun finish(success: Boolean) {
        refreshLayout?.finishLoadMore(success)
    }

    /**
     * Ends loading and shows "no more data" (`endRefreshingWithNoMoreData`).
     */
    fun endRefreshingWithNoMoreData() {
        noMoreData = true
        refreshLayout?.finishLoadMoreWithNoMoreData()
        if (loadsAfterNoMoreData) refreshLayout?.let { layout -> layout.postDelayed({ if (noMoreData) { noMoreData = false; layout.setNoMoreData(false) } }, 1500) }
    }

    /**
     * Shows "no more data" (`noticeNoMoreData`).
     */
    fun noticeNoMoreData() {
        noMoreData = true
        refreshLayout?.setNoMoreData(true)
    }

    /**
     * Clears "no more data" (`resetNoMoreData`).
     */
    fun resetNoMoreData() {
        noMoreData = false
        refreshLayout?.setNoMoreData(false)
    }

    override fun applyEnabled(layout: SmartRefreshLayout) {
        layout.setEnableLoadMore(refreshEnabled)
    }

    override fun applyTriggerRate(layout: SmartRefreshLayout) {
        layout.setFooterTriggerRate(triggerRate)
    }

    /**
     * Makes footers with the iOS factory names.
     */
    companion object {
        /**
         * A classic footer calling [block] when it loads (`footerWithRefreshingBlock:`).
         */
        @JvmStatic
        fun footerWithRefreshingBlock(context: Context, block: CYLRefreshComponentRefreshingBlock): CYLRefreshFooter =
            CYLRefreshFooter(ClassicsFooter(context)).apply { refreshingBlock = block }
    }
}

/**
 * Forwards a layout's events to its header and footer components (one per layout, kept in a tag).
 */
internal class CYLRefreshBridge private constructor(private val layout: SmartRefreshLayout) : SimpleMultiListener() {
    var header: CYLRefreshHeader? = null
    var footer: CYLRefreshFooter? = null

    fun attach(component: CYLRefreshComponent) {
        if (component is CYLRefreshHeader) {
            header?.takeIf { it !== component }?.detach()
            header = component
        } else if (component is CYLRefreshFooter) {
            footer?.takeIf { it !== component }?.detach()
            footer = component
        }
    }

    override fun onRefresh(refreshLayout: RefreshLayout) {
        header?.executeRefreshingCallback()
    }

    override fun onLoadMore(refreshLayout: RefreshLayout) {
        footer?.executeRefreshingCallback()
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        header?.layoutStateChanged(newState)
        footer?.layoutStateChanged(newState)
    }

    override fun onHeaderMoving(header: RefreshHeader?, isDragging: Boolean, percent: Float, offset: Int, headerHeight: Int, maxDragHeight: Int) {
        this.header?.moved(offset, percent, isDragging)
    }

    override fun onFooterMoving(footer: RefreshFooter?, isDragging: Boolean, percent: Float, offset: Int, footerHeight: Int, maxDragHeight: Int) {
        this.footer?.moved(offset, percent, isDragging)
    }

    companion object {
        fun of(layout: SmartRefreshLayout): CYLRefreshBridge {
            (layout.getTag(R.id.cyl_refresh_bridge) as? CYLRefreshBridge)?.let { return it }
            val bridge = CYLRefreshBridge(layout)
            layout.setTag(R.id.cyl_refresh_bridge, bridge)
            layout.setOnMultiListener(bridge)
            return bridge
        }

        fun existing(layout: SmartRefreshLayout): CYLRefreshBridge? = layout.getTag(R.id.cyl_refresh_bridge) as? CYLRefreshBridge
    }
}

/**
 * The layout's header component (the iOS `UIScrollView.cyl_header`); setting it attaches it.
 */
var SmartRefreshLayout.cyl_header: CYLRefreshHeader?
    get() = CYLRefreshBridge.existing(this)?.header
    set(value) {
        if (value != null) value.attach(this) else CYLRefreshBridge.existing(this)?.let { it.header?.detach(); it.header = null }
    }

/**
 * The layout's footer component (the iOS `UIScrollView.cyl_footer`); setting it attaches it.
 */
var SmartRefreshLayout.cyl_footer: CYLRefreshFooter?
    get() = CYLRefreshBridge.existing(this)?.footer
    set(value) {
        if (value != null) value.attach(this) else CYLRefreshBridge.existing(this)?.let { it.footer?.detach(); it.footer = null }
    }

/**
 * Hides both components while they have nothing to show (the iOS `UIScrollView.cyl_autoHideRefresh`).
 */
var SmartRefreshLayout.cyl_autoHideRefresh: Boolean
    get() = cyl_autoHideRefreshHeader && cyl_autoHideRefreshFooter
    set(value) {
        cyl_autoHideRefreshHeader = value
        cyl_autoHideRefreshFooter = value
    }

/**
 * Hides the header while it has nothing to show (`cyl_autoHideRefreshHeader`).
 */
var SmartRefreshLayout.cyl_autoHideRefreshHeader: Boolean
    get() = cyl_header?.autoHideRefresh == true
    set(value) { cyl_header?.autoHideRefresh = value }

/**
 * Hides the footer while it has nothing to show (`cyl_autoHideRefreshFooter`).
 */
var SmartRefreshLayout.cyl_autoHideRefreshFooter: Boolean
    get() = cyl_footer?.autoHideRefresh == true
    set(value) { cyl_footer?.autoHideRefresh = value }

/**
 * Attaches [startHeader] and starts refreshing with it (`cyl_beginRefreshingWithStartHeader:`).
 */
fun SmartRefreshLayout.cyl_beginRefreshingWithStartHeader(startHeader: CYLRefreshHeader) {
    cyl_header = startHeader
    startHeader.beginRefreshing()
}

/**
 * The number of rows of the list inside the layout, 0 when it holds no RecyclerView with an adapter
 * (`cyl_totalDataCount`).
 */
fun SmartRefreshLayout.cyl_totalDataCount(): Int {
    fun count(view: View): Int? {
        if (view is androidx.recyclerview.widget.RecyclerView) return view.adapter?.itemCount ?: 0
        if (view is android.view.ViewGroup) for (i in 0 until view.childCount) count(view.getChildAt(i))?.let { return it }
        return null
    }
    return runCatching { count(this) }.getOrNull() ?: 0
}
