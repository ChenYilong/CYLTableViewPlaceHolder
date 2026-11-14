package com.cyl.refresh

import android.content.Context
import com.scwang.smart.refresh.layout.api.RefreshFooter
import android.graphics.drawable.Drawable
import android.view.View
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.footer.ClassicsFooter
import com.scwang.smart.refresh.header.ClassicsHeader
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import java.text.DateFormat
import java.util.Date

/**
 * Puts the arrow and the spinner after the text instead of before it (`iconOnTrailingSide`): the rule "left of the text"
 * becomes "right of the text", and the gap moves to the other side.
 */
internal fun placeIconsOnTrailingSide(views: List<ImageView?>, trailing: Boolean) {
    for (view in views) {
        val lp = view?.layoutParams as? RelativeLayout.LayoutParams ?: continue
        val anchor = lp.getRule(RelativeLayout.LEFT_OF).takeIf { it != 0 } ?: lp.getRule(RelativeLayout.RIGHT_OF)
        if (anchor == 0) continue
        lp.removeRule(RelativeLayout.LEFT_OF)
        lp.removeRule(RelativeLayout.RIGHT_OF)
        lp.removeRule(RelativeLayout.START_OF)
        lp.removeRule(RelativeLayout.END_OF)
        val gap = maxOf(lp.leftMargin, lp.rightMargin)
        lp.addRule(if (trailing) RelativeLayout.RIGHT_OF else RelativeLayout.LEFT_OF, anchor)
        lp.leftMargin = if (trailing) gap else 0
        lp.rightMargin = if (trailing) 0 else gap
        lp.marginStart = lp.leftMargin
        lp.marginEnd = lp.rightMargin
        view.layoutParams = lp
    }
}

/**
 * The classic header with its texts and views reachable (they are protected in SmartRefreshLayout).
 */
internal class CYLClassicsHeaderView(context: Context) : ClassicsHeader(context) {
    val titleView: TextView? get() = mTitleText
    val arrow: ImageView? get() = mArrowView
    val progress: ImageView? get() = mProgressView
    val update: TextView? get() = mLastUpdateText

    /** Shown in place of the spinner while the header holds after a successful refresh. */
    var succeededImage: Drawable? = null

    /** Shown in place of the spinner while the header holds after a failed refresh. */
    var failedImage: Drawable? = null

    private var spinner: Drawable? = null
    private var showingResult = false

    private fun restoreSpinner(hide: Boolean) {
        if (!showingResult) return
        showingResult = false
        mProgressView?.apply {
            setImageDrawable(spinner)
            if (hide) visibility = GONE
        }
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        val hold = super.onFinish(refreshLayout, success)
        val image = if (success) succeededImage else failedImage
        val view = mProgressView
        if (image != null && view != null) {
            if (!showingResult) spinner = view.drawable
            showingResult = true
            view.setImageDrawable(image)
            view.visibility = VISIBLE
        }
        return hold
    }

    override fun onStartAnimator(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        restoreSpinner(false)
        super.onStartAnimator(refreshLayout, height, maxDragHeight)
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        if (newState == RefreshState.None || newState == RefreshState.PullDownToRefresh) restoreSpinner(true)
        super.onStateChanged(refreshLayout, oldState, newState)
    }

    fun setText(state: CYLRefreshState, title: String) {
        when (state) {
            CYLRefreshState.Idle -> mTextPulling = title
            CYLRefreshState.Pulling -> mTextRelease = title
            CYLRefreshState.Refreshing, CYLRefreshState.WillRefresh -> {
                mTextRefreshing = title
                mTextLoading = title
            }
            CYLRefreshState.NoMoreData -> Unit
        }
    }

    fun text(state: CYLRefreshState): String? = when (state) {
        CYLRefreshState.Idle -> mTextPulling
        CYLRefreshState.Pulling -> mTextRelease
        CYLRefreshState.Refreshing, CYLRefreshState.WillRefresh -> mTextRefreshing
        CYLRefreshState.NoMoreData -> null
    }
}

/**
 * The classic footer with its texts and views reachable.
 */
internal class CYLClassicsFooterView(context: Context) : ClassicsFooter(context) {
    val titleView: TextView? get() = mTitleText
    val arrow: ImageView? get() = mArrowView
    val progress: ImageView? get() = mProgressView

    /** Shown beside the text while there is no more data. */
    var noMoreDataImage: Drawable? = null
        set(value) {
            field = value
            if (mNoMoreData) showNoMoreDataImage()
        }

    private var arrowDrawable: Drawable? = null
    private var showingImage = false

    private fun showNoMoreDataImage() {
        val view = mArrowView ?: return
        val image = noMoreDataImage
        if (image != null) {
            if (!showingImage) arrowDrawable = view.drawable
            showingImage = true
            view.setImageDrawable(image)
            view.visibility = VISIBLE
        } else if (showingImage) {
            showingImage = false
            view.setImageDrawable(arrowDrawable)
            view.visibility = GONE
        }
    }

    override fun setNoMoreData(noMoreData: Boolean): Boolean {
        val result = super.setNoMoreData(noMoreData)
        if (noMoreData) {
            showNoMoreDataImage()
        } else if (showingImage) {
            showingImage = false
            mArrowView?.setImageDrawable(arrowDrawable)
        }
        return result
    }

    fun setText(state: CYLRefreshState, title: String) {
        when (state) {
            CYLRefreshState.Idle -> mTextPulling = title
            CYLRefreshState.Pulling -> mTextRelease = title
            CYLRefreshState.Refreshing, CYLRefreshState.WillRefresh -> {
                mTextLoading = title
                mTextRefreshing = title
            }
            CYLRefreshState.NoMoreData -> mTextNothing = title
        }
    }

    fun text(state: CYLRefreshState): String? = when (state) {
        CYLRefreshState.Idle -> mTextPulling
        CYLRefreshState.Pulling -> mTextRelease
        CYLRefreshState.Refreshing, CYLRefreshState.WillRefresh -> mTextLoading
        CYLRefreshState.NoMoreData -> mTextNothing
    }
}

/**
 * A header with a state text and a "last updated" line (iOS `CYLRefreshStateHeader`).
 */
open class CYLRefreshStateHeader(context: Context) : CYLRefreshHeader(CYLClassicsHeaderView(context)) {

    internal val classics: CYLClassicsHeaderView get() = view as CYLClassicsHeaderView

    /**
     * The state text (`stateLabel`).
     */
    val stateLabel: TextView? get() = classics.titleView

    /**
     * The "last updated" text (`lastUpdatedTimeLabel`).
     */
    val lastUpdatedTimeLabel: TextView? get() = classics.update

    /**
     * The gap between the icon and the texts, in dp (`labelLeftInset`).
     */
    var labelLeftInset: Float = CYLRefreshConst.CYLRefreshLabelLeftInset
        set(value) {
            field = value
            classics.setDrawableMarginRight(value)
        }

    /**
     * The gap between the state text and the "last updated" line, in dp (`titleTimeSpacing`).
     */
    var titleTimeSpacing: Float = 0f
        set(value) {
            field = value
            classics.setTextTimeMarginTop(value)
        }

    /**
     * The date format of the "last updated" line (`lastUpdatedTimeFormatter`).
     */
    var lastUpdatedTimeFormatter: DateFormat? = null
        set(value) {
            field = value
            value?.let { classics.setTimeFormat(it) }
        }

    /**
     * Makes the "last updated" text from the last time, null for never (`lastUpdatedTimeText`).
     */
    var lastUpdatedTimeText: ((Date?) -> String)? = null
        set(value) {
            field = value
            value?.let { classics.setLastUpdateText(it(lastUpdatedTime)) }
        }

    /**
     * Shown in place of the icon while the header holds after a successful refresh (`succeededImage`); needs a
     * `finishDuration` above 0.
     */
    var succeededImage: Drawable?
        get() = classics.succeededImage
        set(value) { classics.succeededImage = value }

    /**
     * Shown in place of the icon while the header holds after a failed refresh (`failedImage`).
     */
    var failedImage: Drawable?
        get() = classics.failedImage
        set(value) { classics.failedImage = value }

    /**
     * Puts the icon after the text instead of before it (`iconOnTrailingSide`).
     */
    var iconOnTrailingSide: Boolean = false
        set(value) {
            field = value
            placeIconsOnTrailingSide(listOf(classics.arrow, classics.progress), value)
        }

    /**
     * The "last updated" text now shown (`lastUpdatedTimeString`).
     */
    val lastUpdatedTimeString: String
        get() = lastUpdatedTimeLabel?.text?.toString().orEmpty()

    /**
     * The text of [state] (`setTitle:forState:`).
     */
    fun setTitle(title: String, state: CYLRefreshState): CYLRefreshStateHeader = apply {
        classics.setText(state, title)
        if (this.state == state) stateLabel?.text = title
    }

    override fun didEndRefreshing() {
        super.didEndRefreshing()
        lastUpdatedTimeText?.let { classics.setLastUpdateText(it(lastUpdatedTime)) }
    }

    /**
     * Sets [lastUpdatedTimeText] (`cyl_modifyLastUpdatedTimeText:`).
     */
    fun cyl_modifyLastUpdatedTimeText(block: (Date?) -> String): CYLRefreshStateHeader = apply { lastUpdatedTimeText = block }
}

/**
 * The state header with an arrow and a spinner (iOS `CYLRefreshNormalHeader`).
 */
open class CYLRefreshNormalHeader(context: Context) : CYLRefreshStateHeader(context) {
    /**
     * The arrow (`arrowView`).
     */
    val arrowView: ImageView? get() = classics.arrow

    /**
     * The spinner (`loadingView`).
     */
    val loadingView: ImageView? get() = classics.progress

    /**
     * The arrow's and spinner's side, in dp (`iconSize`).
     */
    var iconSize: Float = 20f
        set(value) {
            field = value
            classics.setDrawableSize(value)
        }
}

/**
 * The state header with image frames per state (iOS `CYLRefreshGifHeader`).
 */
open class CYLRefreshGifHeader(context: Context) : CYLRefreshStateHeader(context) {
    /**
     * The view that shows the frames (`gifView`).
     */
    val gifView: ImageView get() = cyl_iconView.placeholderView.imageView

    /**
     * The frames of [state], [duration] seconds in all (`setImages:duration:forState:`).
     */
    fun setImages(images: List<Drawable>, duration: Double, state: CYLRefreshState) {
        cyl_setIconImages(images, duration, state)
        cyl_updateIconViewVisible(true, listOfNotNull<View>(classics.arrow, classics.progress))
    }

    /**
     * The frames of [state], 0.1 seconds each (`setImages:forState:`).
     */
    fun setImages(images: List<Drawable>, state: CYLRefreshState) = setImages(images, images.size * 0.1, state)
}

/**
 * The state header with an animation per state (iOS `CYLRefreshAnimationHeader`).
 */
open class CYLRefreshAnimationHeader(context: Context) : CYLRefreshGifHeader(context) {
    /**
     * The view that shows the animation (`animationView`).
     */
    val animationView: ImageView get() = gifView

    /**
     * The frames of [state], [duration] seconds in all (`setAnimationImages:duration:forState:`).
     */
    fun setAnimationImages(images: List<Drawable>, duration: Double, state: CYLRefreshState) = setImages(images, duration, state)

    /**
     * The frames of [state], 0.1 seconds each (`setAnimationImages:forState:`).
     */
    fun setAnimationImages(images: List<Drawable>, state: CYLRefreshState) = setImages(images, state)
}

/**
 * A footer that loads by itself when it comes into view (iOS `CYLRefreshAutoFooter`).
 */
open class CYLRefreshAutoFooter internal constructor(view: RefreshFooter) : CYLRefreshFooter(view) {

    constructor(context: Context) : this(CYLClassicsFooterView(context))

    internal val classics: CYLClassicsFooterView get() = view as CYLClassicsFooterView

    /**
     * Whether reaching the end loads by itself (`automaticallyRefresh`).
     */
    var automaticallyRefresh: Boolean = true
        set(value) {
            field = value
            refreshLayout?.setEnableAutoLoadMore(value)
        }

    /**
     * How much of the footer must show before it loads, 0 to 1 (`triggerAutomaticallyRefreshPercent`).
     */
    var triggerAutomaticallyRefreshPercent: Float = 1f
        set(value) {
            field = value
            triggerRate = value
        }

    /**
     * How many times one drag may load, -1 for no limit (`autoTriggerTimes`); SmartRefreshLayout loads once per drag.
     */
    var autoTriggerTimes: Int = 1

    override fun didAttachToScrollView(layout: SmartRefreshLayout) {
        layout.setEnableAutoLoadMore(automaticallyRefresh)
    }
}

/**
 * The automatic footer with a state text (iOS `CYLRefreshAutoStateFooter`).
 */
open class CYLRefreshAutoStateFooter(context: Context) : CYLRefreshAutoFooter(context) {
    /**
     * The state text (`stateLabel`).
     */
    val stateLabel: TextView? get() = classics.titleView

    /**
     * The gap between the icon and the text, in dp (`labelLeftInset`).
     */
    var labelLeftInset: Float = CYLRefreshConst.CYLRefreshLabelLeftInset
        set(value) {
            field = value
            classics.setDrawableMarginRight(value)
        }

    /**
     * Whether the text hides while loading (`refreshingTitleHidden`).
     */
    var refreshingTitleHidden: Boolean = false

    /**
     * The text of [state] (`setTitle:forState:`).
     */
    fun setTitle(title: String, state: CYLRefreshState): CYLRefreshAutoStateFooter = apply {
        classics.setText(state, title)
        if (this.state == state) stateLabel?.text = title
    }

    /**
     * The text of [state] (`titleForState:`).
     */
    fun titleForState(state: CYLRefreshState): String? = classics.text(state)

    override fun phaseDidChangeFrom(old: CYLRefreshPhase, new: CYLRefreshPhase) {
        if (refreshingTitleHidden) stateLabel?.visibility = if (new == CYLRefreshPhase.Refreshing) View.INVISIBLE else View.VISIBLE
    }
}

/**
 * The automatic state footer with a spinner (iOS `CYLRefreshAutoNormalFooter`).
 */
open class CYLRefreshAutoNormalFooter(context: Context) : CYLRefreshAutoStateFooter(context) {
    /**
     * Shown beside the text while there is no more data (`noMoreDataImage`).
     */
    var noMoreDataImage: Drawable?
        get() = classics.noMoreDataImage
        set(value) { classics.noMoreDataImage = value }

    /**
     * The spinner (`loadingView`).
     */
    val loadingView: ImageView? get() = classics.progress
}

/**
 * The automatic state footer with image frames per state (iOS `CYLRefreshAutoGifFooter`).
 */
open class CYLRefreshAutoGifFooter(context: Context) : CYLRefreshAutoStateFooter(context) {
    /**
     * The view that shows the frames (`gifView`).
     */
    val gifView: ImageView get() = cyl_iconView.placeholderView.imageView

    /**
     * The frames of [state], [duration] seconds in all (`setImages:duration:forState:`).
     */
    fun setImages(images: List<Drawable>, duration: Double, state: CYLRefreshState) {
        cyl_setIconImages(images, duration, state)
        cyl_updateIconViewVisible(true, listOfNotNull<View>(classics.arrow, classics.progress))
    }

    /**
     * The frames of [state], 0.1 seconds each (`setImages:forState:`).
     */
    fun setImages(images: List<Drawable>, state: CYLRefreshState) = setImages(images, images.size * 0.1, state)
}

/**
 * The automatic state footer with an animation per state (iOS `CYLRefreshAutoAnimationFooter`).
 */
open class CYLRefreshAutoAnimationFooter(context: Context) : CYLRefreshAutoGifFooter(context) {
    /**
     * The view that shows the animation (`animationView`).
     */
    val animationView: ImageView get() = gifView

    /**
     * The frames of [state], [duration] seconds in all (`setAnimationImages:duration:forState:`).
     */
    fun setAnimationImages(images: List<Drawable>, duration: Double, state: CYLRefreshState) = setImages(images, duration, state)

    /**
     * The frames of [state], 0.1 seconds each (`setAnimationImages:forState:`).
     */
    fun setAnimationImages(images: List<Drawable>, state: CYLRefreshState) = setImages(images, state)
}

/**
 * A footer that loads when pulled up and released (iOS `CYLRefreshBackFooter`).
 */
open class CYLRefreshBackFooter internal constructor(view: RefreshFooter) : CYLRefreshFooter(view) {

    constructor(context: Context) : this(CYLClassicsFooterView(context))

    internal val classics: CYLClassicsFooterView get() = view as CYLClassicsFooterView

    override fun didAttachToScrollView(layout: SmartRefreshLayout) {
        layout.setEnableAutoLoadMore(false)
    }

    /**
     * Seconds "no more data" stays visible, with the footer held open, after a load ends with
     * [endRefreshingWithNoMoreData] (`noMoreDataDisplayDuration`); 0 rebounds at once.
     */
    var noMoreDataDisplayDuration: Double = 0.0

    override val noMoreDataHoldMillis: Int get() = (noMoreDataDisplayDuration * 1000).toInt().coerceAtLeast(0)

    internal val floor = CYLRefreshSecondaryFloor(this)

    /**
     * Pulling up this far and releasing opens the second floor below the list, in dp; 0 for never
     * (`secondaryTriggerOffset`).
     */
    var secondaryTriggerOffset: Float by floor::triggerOffset

    /**
     * The open second floor's height, in dp; 0 for the layout's height (`secondaryDimension`).
     */
    var secondaryDimension: Float by floor::dimension

    /**
     * Pulling the open second floor down this far and releasing closes it, in dp (`secondaryCloseTriggerOffset`).
     */
    var secondaryCloseTriggerOffset: Float by floor::closeTriggerOffset

    /**
     * A release this fast opens the second floor (`secondaryVelocity`); kept, a release's speed is not measured on
     * Android.
     */
    var secondaryVelocity: Float by floor::velocity

    /**
     * The second floor's content, placed over the layout's lower part and slid in by the pull (`secondaryView`).
     */
    var secondaryView: View? by floor::view

    /**
     * Whether the second floor is open (`secondaryOpen`).
     */
    val secondaryOpen: Boolean get() = floor.isOpen

    /**
     * Called after the second floor has opened (`secondaryOpenedBlock`).
     */
    var secondaryOpenedBlock: CYLRefreshComponentAction? by floor::openedBlock

    /**
     * Called after the second floor has closed (`secondaryClosedBlock`).
     */
    var secondaryClosedBlock: CYLRefreshComponentAction? by floor::closedBlock

    /**
     * Opens the second floor (`openSecondary`).
     */
    fun openSecondary() = floor.open()

    /**
     * Closes the second floor (`closeSecondary`).
     */
    fun closeSecondary() = floor.close()

    internal fun released() {
        if (floor.openOnReleaseIfPulledFar()) refreshLayout?.finishLoadMore(0, true, false)
    }
}

/**
 * The back footer with a state text (iOS `CYLRefreshBackStateFooter`).
 */
open class CYLRefreshBackStateFooter(context: Context) : CYLRefreshBackFooter(context) {
    /**
     * The state text (`stateLabel`).
     */
    val stateLabel: TextView? get() = classics.titleView

    /**
     * The gap between the icon and the text, in dp (`labelLeftInset`).
     */
    var labelLeftInset: Float = CYLRefreshConst.CYLRefreshLabelLeftInset
        set(value) {
            field = value
            classics.setDrawableMarginRight(value)
        }

    /**
     * The text of [state] (`setTitle:forState:`).
     */
    fun setTitle(title: String, state: CYLRefreshState): CYLRefreshBackStateFooter = apply {
        classics.setText(state, title)
        if (this.state == state) stateLabel?.text = title
    }

    /**
     * The text of [state] (`titleForState:`).
     */
    fun titleForState(state: CYLRefreshState): String? = classics.text(state)
}

/**
 * The back state footer with an arrow and a spinner (iOS `CYLRefreshBackNormalFooter`).
 */
open class CYLRefreshBackNormalFooter(context: Context) : CYLRefreshBackStateFooter(context) {
    /**
     * Shown beside the text while there is no more data (`noMoreDataImage`).
     */
    var noMoreDataImage: Drawable?
        get() = classics.noMoreDataImage
        set(value) { classics.noMoreDataImage = value }

    /**
     * The arrow (`arrowView`).
     */
    val arrowView: ImageView? get() = classics.arrow

    /**
     * The spinner (`loadingView`).
     */
    val loadingView: ImageView? get() = classics.progress

    /**
     * The arrow's and spinner's side, in dp (`iconSize`).
     */
    var iconSize: Float = 20f
        set(value) {
            field = value
            classics.setDrawableSize(value)
        }
}

/**
 * The back state footer with image frames per state (iOS `CYLRefreshBackGifFooter`).
 */
open class CYLRefreshBackGifFooter(context: Context) : CYLRefreshBackStateFooter(context) {
    /**
     * The view that shows the frames (`gifView`).
     */
    val gifView: ImageView get() = cyl_iconView.placeholderView.imageView

    /**
     * The frames of [state], [duration] seconds in all (`setImages:duration:forState:`).
     */
    fun setImages(images: List<Drawable>, duration: Double, state: CYLRefreshState) {
        cyl_setIconImages(images, duration, state)
        cyl_updateIconViewVisible(true, listOfNotNull<View>(classics.arrow, classics.progress))
    }

    /**
     * The frames of [state], 0.1 seconds each (`setImages:forState:`).
     */
    fun setImages(images: List<Drawable>, state: CYLRefreshState) = setImages(images, images.size * 0.1, state)
}

/**
 * The back state footer with an animation per state (iOS `CYLRefreshBackAnimationFooter`).
 */
open class CYLRefreshBackAnimationFooter(context: Context) : CYLRefreshBackGifFooter(context) {
    /**
     * The view that shows the animation (`animationView`).
     */
    val animationView: ImageView get() = gifView

    /**
     * The frames of [state], [duration] seconds in all (`setAnimationImages:duration:forState:`).
     */
    fun setAnimationImages(images: List<Drawable>, duration: Double, state: CYLRefreshState) = setImages(images, duration, state)

    /**
     * The frames of [state], 0.1 seconds each (`setAnimationImages:forState:`).
     */
    fun setAnimationImages(images: List<Drawable>, state: CYLRefreshState) = setImages(images, state)
}
