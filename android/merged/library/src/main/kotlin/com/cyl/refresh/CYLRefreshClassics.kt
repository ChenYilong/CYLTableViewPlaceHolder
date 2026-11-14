package com.cyl.refresh

import android.content.Context
import com.scwang.smart.refresh.layout.api.RefreshFooter
import android.graphics.drawable.Drawable
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import com.scwang.smart.refresh.footer.ClassicsFooter
import com.scwang.smart.refresh.header.ClassicsHeader
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import java.text.DateFormat
import java.util.Date

/**
 * The classic header with its texts and views reachable (they are protected in SmartRefreshLayout).
 */
internal class CYLClassicsHeaderView(context: Context) : ClassicsHeader(context) {
    val titleView: TextView? get() = mTitleText
    val arrow: ImageView? get() = mArrowView
    val progress: ImageView? get() = mProgressView
    val update: TextView? get() = mLastUpdateText

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
