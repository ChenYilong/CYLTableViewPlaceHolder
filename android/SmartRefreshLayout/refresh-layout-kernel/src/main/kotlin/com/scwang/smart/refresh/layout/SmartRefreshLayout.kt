// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin, with the pull requests and issue fixes of the Java copy (docs/Android-Port.md). Field and method names and
// the JVM signatures match the Java version.
@file:Suppress("MemberVisibilityCanBePrivate", "unused")

package com.scwang.smart.refresh.layout

import android.animation.Animator
import android.animation.AnimatorListenerAdapter
import android.animation.ValueAnimator
import android.animation.ValueAnimator.AnimatorUpdateListener
import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.os.Handler
import android.os.Looper
import android.util.AttributeSet
import android.util.Log
import android.view.Gravity
import android.view.MotionEvent
import android.view.VelocityTracker
import android.view.View
import android.view.ViewConfiguration
import android.view.ViewGroup
import android.view.ViewTreeObserver
import android.view.animation.AnimationUtils
import android.view.animation.Interpolator
import android.widget.Scroller
import android.widget.TextView
import androidx.annotation.ColorInt
import androidx.annotation.ColorRes
import androidx.core.content.ContextCompat
import androidx.core.view.NestedScrollingChildHelper
import androidx.core.view.NestedScrollingParent
import androidx.core.view.NestedScrollingParentHelper
import androidx.core.view.ViewCompat
import com.scwang.smart.refresh.layout.api.RefreshComponent
import com.scwang.smart.refresh.layout.api.RefreshContent
import com.scwang.smart.refresh.layout.api.RefreshFooter
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.DimensionStatus
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.kernel.R
import com.scwang.smart.refresh.layout.listener.DefaultRefreshFooterCreator
import com.scwang.smart.refresh.layout.listener.DefaultRefreshHeaderCreator
import com.scwang.smart.refresh.layout.listener.DefaultRefreshInitializer
import com.scwang.smart.refresh.layout.listener.OnLoadMoreListener
import com.scwang.smart.refresh.layout.listener.OnMultiListener
import com.scwang.smart.refresh.layout.listener.OnRefreshListener
import com.scwang.smart.refresh.layout.listener.OnRefreshLoadMoreListener
import com.scwang.smart.refresh.layout.listener.ScrollBoundaryDecider
import com.scwang.smart.refresh.layout.util.SmartUtil
import com.scwang.smart.refresh.layout.util.SmartUtil.Companion.dp2px
import com.scwang.smart.refresh.layout.util.SmartUtil.Companion.fling
import com.scwang.smart.refresh.layout.wrapper.RefreshContentWrapper
import com.scwang.smart.refresh.layout.wrapper.RefreshFooterWrapper
import com.scwang.smart.refresh.layout.wrapper.RefreshHeaderWrapper
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min
import kotlin.math.pow

/**
 * The smart refresh layout: a content of any kind with a header pulled down to refresh and a footer pulled up to load
 * more (`SmartRefreshLayout`). Headers and footers are [RefreshHeader] / [RefreshFooter] components (or any view,
 * wrapped); the layout drives them through [RefreshKernel].
 */
@SuppressLint("RestrictedApi")
open class SmartRefreshLayout @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
) : ViewGroup(context, attrs), RefreshLayout, NestedScrollingParent {

    // MARK: - Fields (the Java version's names, so subclasses and tools keep working)

    @JvmField protected var mTouchSlop: Int
    @JvmField protected var mSpinner = 0
    @JvmField protected var mLastSpinner = 0
    @JvmField protected var mTouchSpinner = 0
    @JvmField protected var mFloorDuration = 300
    @JvmField protected var mReboundDuration = 300
    @JvmField protected var mScreenHeightPixels: Int
    @JvmField protected var mTouchX = 0f
    @JvmField protected var mTouchY = 0f
    @JvmField protected var mLastTouchX = 0f
    @JvmField protected var mLastTouchY = 0f
    @JvmField protected var mDragRate = .5f
    @JvmField protected var mDragDirection = 'n'
    @JvmField protected var mIsBeingDragged = false
    @JvmField protected var mSuperDispatchTouchEvent = false
    @JvmField protected var mEnableDisallowIntercept = false
    @JvmField protected var mFixedHeaderViewId = View.NO_ID
    @JvmField protected var mFixedFooterViewId = View.NO_ID
    @JvmField protected var mHeaderTranslationViewId = View.NO_ID
    @JvmField protected var mFooterTranslationViewId = View.NO_ID
    @JvmField protected var mMinimumVelocity: Int
    @JvmField protected var mMaximumVelocity: Int
    @JvmField protected var mCurrentVelocity = 0
    @JvmField protected var mScroller: Scroller
    @JvmField protected var mVelocityTracker: VelocityTracker
    @JvmField protected var mReboundInterpolator: Interpolator
    @JvmField protected var mPrimaryColors: IntArray? = null
    @JvmField protected var mEnableRefresh = true
    @JvmField protected var mEnableLoadMore = false
    @JvmField protected var mEnableClipHeaderWhenFixedBehind = true
    @JvmField protected var mEnableClipFooterWhenFixedBehind = true
    @JvmField protected var mEnableHeaderTranslationContent = true
    @JvmField protected var mEnableFooterTranslationContent = true
    @JvmField protected var mEnableFooterFollowWhenNoMoreData = false
    @JvmField protected var mEnablePreviewInEditMode = true
    @JvmField protected var mEnableOverScrollBounce = true
    @JvmField protected var mEnableOverScrollDrag = false
    @JvmField protected var mEnableAutoLoadMore = true
    @JvmField protected var mEnablePureScrollMode = false

    // Issues #1109, #1199: pure scroll mode (not the app) enabled load more.
    @JvmField protected var mLoadMoreByPureScrollMode = false
    @JvmField protected var mEnableScrollContentWhenLoaded = true
    @JvmField protected var mEnableScrollContentWhenRefreshed = true
    @JvmField protected var mEnableLoadMoreWhenContentNotFull = true
    @JvmField protected var mEnableNestedScrolling = true
    @JvmField protected var mDisableContentWhenRefresh = false
    @JvmField protected var mDisableContentWhenLoading = false
    @JvmField protected var mFooterNoMoreData = false
    @JvmField protected var mFooterNoMoreDataEffective = false
    @JvmField protected var mManualLoadMore = false
    @JvmField protected var mManualHeaderTranslationContent = false
    @JvmField protected var mManualFooterTranslationContent = false

    // Pull request #1095: the header (not the app) set the translation default.
    @JvmField protected var mComponentHeaderTranslationContent = false
    @JvmField protected var mRefreshListener: OnRefreshListener? = null
    @JvmField protected var mLoadMoreListener: OnLoadMoreListener? = null
    @JvmField protected var mOnMultiListener: OnMultiListener? = null
    @JvmField protected var mScrollBoundaryDecider: ScrollBoundaryDecider? = null
    @JvmField protected var mTotalUnconsumed = 0
    @JvmField protected var mNestedInProgress = false
    @JvmField protected var mParentOffsetInWindow = IntArray(2)
    @JvmField protected var mNestedChild = NestedScrollingChildHelper(this)
    @JvmField protected var mNestedParent = NestedScrollingParentHelper(this)
    @JvmField protected var mHeaderHeight: Int
    @JvmField protected var mHeaderHeightStatus = DimensionStatus.DefaultUnNotify
    @JvmField protected var mFooterHeight: Int
    @JvmField protected var mFooterHeightStatus = DimensionStatus.DefaultUnNotify
    @JvmField protected var mHeaderInsetStart = 0
    @JvmField protected var mFooterInsetStart = 0
    @JvmField protected var mHeaderMaxDragRate = 2.5f
    @JvmField protected var mFooterMaxDragRate = 2.5f
    @JvmField protected var mHeaderTriggerRate = 1.0f
    @JvmField protected var mFooterTriggerRate = 1.0f
    @JvmField protected var mTwoLevelBottomPullUpToCloseRate = 1 / 6f
    @JvmField protected var mRefreshHeader: RefreshComponent? = null
    @JvmField protected var mRefreshFooter: RefreshComponent? = null
    @JvmField protected var mRefreshContent: RefreshContent? = null
    @JvmField protected var mPaint: Paint? = null
    @JvmField protected var mHandler: Handler
    @JvmField protected var mKernel: RefreshKernel = RefreshKernelImpl()
    @JvmField protected var mState = RefreshState.None
    @JvmField protected var mViceState = RefreshState.None
    @JvmField protected var mLastOpenTime = 0L
    @JvmField protected var mHeaderBackgroundColor = 0
    @JvmField protected var mFooterBackgroundColor = 0
    @JvmField protected var mHeaderNeedTouchEventWhenRefreshing = false
    @JvmField protected var mFooterNeedTouchEventWhenLoading = false
    @JvmField protected var mAttachedToWindow = false
    @JvmField protected var mFooterLocked = false
    @JvmField protected var mLastTimeOnActionDown = 0L
    @JvmField protected var mLastTouchXOnActionDown = 0f
    @JvmField protected var mLastTouchYOnActionDown = 0f
    @JvmField protected var mVerticalPermit = false
    @JvmField protected var mFalsifyEvent: MotionEvent? = null
    @JvmField protected var animationRunnable: Runnable? = null
    @JvmField protected var reboundAnimator: ValueAnimator? = null

    /**
     * The opening animation of an auto refresh or auto load; a touch does not stop it (issues #1326, #1401, #1595).
     */
    private var mAutoOpenAnimator: ValueAnimator? = null

    init {
        val configuration = ViewConfiguration.get(context)
        mHandler = Handler(Looper.getMainLooper())
        mScroller = Scroller(context)
        mVelocityTracker = VelocityTracker.obtain()
        mScreenHeightPixels = context.resources.displayMetrics.heightPixels
        mReboundInterpolator = SmartUtil(SmartUtil.INTERPOLATOR_VISCOUS_FLUID)
        mTouchSlop = configuration.scaledTouchSlop
        mMinimumVelocity = configuration.scaledMinimumFlingVelocity
        mMaximumVelocity = configuration.scaledMaximumFlingVelocity
        mFooterHeight = dp2px(60f)
        mHeaderHeight = dp2px(100f)

        val ta = context.obtainStyledAttributes(attrs, R.styleable.SmartRefreshLayout)
        if (!ta.hasValue(R.styleable.SmartRefreshLayout_android_clipToPadding)) super.setClipToPadding(false)
        if (!ta.hasValue(R.styleable.SmartRefreshLayout_android_clipChildren)) super.setClipChildren(false)
        sRefreshInitializer?.initialize(context, this)
        mDragRate = ta.getFloat(R.styleable.SmartRefreshLayout_srlDragRate, mDragRate)
        mHeaderMaxDragRate = ta.getFloat(R.styleable.SmartRefreshLayout_srlHeaderMaxDragRate, mHeaderMaxDragRate)
        mFooterMaxDragRate = ta.getFloat(R.styleable.SmartRefreshLayout_srlFooterMaxDragRate, mFooterMaxDragRate)
        mHeaderTriggerRate = ta.getFloat(R.styleable.SmartRefreshLayout_srlHeaderTriggerRate, mHeaderTriggerRate)
        mFooterTriggerRate = ta.getFloat(R.styleable.SmartRefreshLayout_srlFooterTriggerRate, mFooterTriggerRate)
        mEnableRefresh = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnableRefresh, mEnableRefresh)
        mReboundDuration = ta.getInt(R.styleable.SmartRefreshLayout_srlReboundDuration, mReboundDuration)
        mEnableLoadMore = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnableLoadMore, mEnableLoadMore)
        mHeaderHeight = ta.getDimensionPixelOffset(R.styleable.SmartRefreshLayout_srlHeaderHeight, mHeaderHeight)
        mFooterHeight = ta.getDimensionPixelOffset(R.styleable.SmartRefreshLayout_srlFooterHeight, mFooterHeight)
        mHeaderInsetStart = ta.getDimensionPixelOffset(R.styleable.SmartRefreshLayout_srlHeaderInsetStart, mHeaderInsetStart)
        mFooterInsetStart = ta.getDimensionPixelOffset(R.styleable.SmartRefreshLayout_srlFooterInsetStart, mFooterInsetStart)
        mDisableContentWhenRefresh = ta.getBoolean(R.styleable.SmartRefreshLayout_srlDisableContentWhenRefresh, mDisableContentWhenRefresh)
        mDisableContentWhenLoading = ta.getBoolean(R.styleable.SmartRefreshLayout_srlDisableContentWhenLoading, mDisableContentWhenLoading)
        mEnableHeaderTranslationContent = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnableHeaderTranslationContent, mEnableHeaderTranslationContent)
        mEnableFooterTranslationContent = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnableFooterTranslationContent, mEnableFooterTranslationContent)
        mEnablePreviewInEditMode = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnablePreviewInEditMode, mEnablePreviewInEditMode)
        mEnableAutoLoadMore = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnableAutoLoadMore, mEnableAutoLoadMore)
        mEnableOverScrollBounce = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnableOverScrollBounce, mEnableOverScrollBounce)
        mEnablePureScrollMode = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnablePureScrollMode, mEnablePureScrollMode)
        mEnableScrollContentWhenLoaded = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnableScrollContentWhenLoaded, mEnableScrollContentWhenLoaded)
        mEnableScrollContentWhenRefreshed = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnableScrollContentWhenRefreshed, mEnableScrollContentWhenRefreshed)
        mEnableLoadMoreWhenContentNotFull = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnableLoadMoreWhenContentNotFull, mEnableLoadMoreWhenContentNotFull)
        mEnableFooterFollowWhenNoMoreData = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnableFooterFollowWhenLoadFinished, mEnableFooterFollowWhenNoMoreData)
        mEnableFooterFollowWhenNoMoreData = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnableFooterFollowWhenNoMoreData, mEnableFooterFollowWhenNoMoreData)
        mEnableClipHeaderWhenFixedBehind = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnableClipHeaderWhenFixedBehind, mEnableClipHeaderWhenFixedBehind)
        mEnableClipFooterWhenFixedBehind = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnableClipFooterWhenFixedBehind, mEnableClipFooterWhenFixedBehind)
        mEnableOverScrollDrag = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnableOverScrollDrag, mEnableOverScrollDrag)
        mFixedHeaderViewId = ta.getResourceId(R.styleable.SmartRefreshLayout_srlFixedHeaderViewId, mFixedHeaderViewId)
        mFixedFooterViewId = ta.getResourceId(R.styleable.SmartRefreshLayout_srlFixedFooterViewId, mFixedFooterViewId)
        mHeaderTranslationViewId = ta.getResourceId(R.styleable.SmartRefreshLayout_srlHeaderTranslationViewId, mHeaderTranslationViewId)
        mFooterTranslationViewId = ta.getResourceId(R.styleable.SmartRefreshLayout_srlFooterTranslationViewId, mFooterTranslationViewId)
        mEnableNestedScrolling = ta.getBoolean(R.styleable.SmartRefreshLayout_srlEnableNestedScrolling, mEnableNestedScrolling)
        mNestedChild.isNestedScrollingEnabled = mEnableNestedScrolling
        mManualLoadMore = mManualLoadMore || ta.hasValue(R.styleable.SmartRefreshLayout_srlEnableLoadMore)
        mManualHeaderTranslationContent = mManualHeaderTranslationContent || ta.hasValue(R.styleable.SmartRefreshLayout_srlEnableHeaderTranslationContent)
        mManualFooterTranslationContent = mManualFooterTranslationContent || ta.hasValue(R.styleable.SmartRefreshLayout_srlEnableFooterTranslationContent)
        mHeaderHeightStatus = if (ta.hasValue(R.styleable.SmartRefreshLayout_srlHeaderHeight)) DimensionStatus.XmlLayoutUnNotify else mHeaderHeightStatus
        mFooterHeightStatus = if (ta.hasValue(R.styleable.SmartRefreshLayout_srlFooterHeight)) DimensionStatus.XmlLayoutUnNotify else mFooterHeightStatus
        val accentColor = ta.getColor(R.styleable.SmartRefreshLayout_srlAccentColor, 0)
        val primaryColor = ta.getColor(R.styleable.SmartRefreshLayout_srlPrimaryColor, 0)
        if (primaryColor != 0) {
            mPrimaryColors = if (accentColor != 0) intArrayOf(primaryColor, accentColor) else intArrayOf(primaryColor)
        } else if (accentColor != 0) {
            mPrimaryColors = intArrayOf(0, accentColor)
        }
        if (mEnablePureScrollMode && !mManualLoadMore && !mEnableLoadMore) {
            mEnableLoadMore = true
            mLoadMoreByPureScrollMode = true
        }
        ta.recycle()
    }

    private fun maxDragHeight(rate: Float, height: Int): Int = (if (rate < 10) height * rate else rate).toInt()

    private fun triggerHeight(rate: Float, height: Int): Float = if (rate < 10) height * rate else rate

    private fun marginsOf(view: View): MarginLayoutParams = view.layoutParams as? MarginLayoutParams ?: sDefaultMarginLP

    // MARK: - Life cycle

    override fun onFinishInflate() {
        super.onFinishInflate()
        val count = super.getChildCount()
        if (count > 3) throw RuntimeException("最多只支持3个子View，Most only support three sub view")
        var contentLevel = 0
        var indexContent = -1
        for (i in 0 until count) {
            val view = super.getChildAt(i)
            if (SmartUtil.isContentView(view) && (contentLevel < 2 || i == 1)) {
                indexContent = i
                contentLevel = 2
            } else if (view !is RefreshComponent && contentLevel < 1) {
                indexContent = i
                contentLevel = if (i > 0) 1 else 0
            }
        }
        var indexHeader = -1
        var indexFooter = -1
        if (indexContent >= 0) {
            mRefreshContent = RefreshContentWrapper(super.getChildAt(indexContent))
            if (indexContent == 1) {
                indexHeader = 0
                if (count == 3) indexFooter = 2
            } else if (count == 2) {
                indexFooter = 1
            }
        }
        for (i in 0 until count) {
            val view = super.getChildAt(i)
            if (i == indexHeader || (i != indexFooter && indexHeader == -1 && mRefreshHeader == null && view is RefreshHeader)) {
                mRefreshHeader = view as? RefreshHeader ?: RefreshHeaderWrapper(view)
            } else if (i == indexFooter || (indexFooter == -1 && view is RefreshFooter)) {
                mEnableLoadMore = mEnableLoadMore || !mManualLoadMore
                mRefreshFooter = view as? RefreshFooter ?: RefreshFooterWrapper(view)
            }
        }
    }

    /**
     * Issues #1352, #1615: the "no more data" footer held open below the list stays after the list grows (items
     * added or expanded); the list then scrolls on, so the footer is let go and the list scrolled by its height,
     * leaving the items where they were and the footer after the last one.
     */
    private val mFollowingFooterCheck = ViewTreeObserver.OnGlobalLayoutListener { releaseFollowingFooterIfContentGrew() }

    /**
     * Lets go of the "no more data" footer held below the content once the content scrolls further (issue #1352).
     */
    protected open fun releaseFollowingFooterIfContentGrew() {
        val content = mRefreshContent ?: return
        val spinner = mSpinner
        if (spinner >= 0 || mState != RefreshState.None || reboundAnimator != null || mIsBeingDragged || mNestedInProgress) return
        if (!(mEnableFooterFollowWhenNoMoreData && mFooterNoMoreData && mFooterNoMoreDataEffective)) return
        val scrollable = content.scrollableView
        if (!scrollable.canScrollVertically(1)) return
        mKernel.moveSpinner(0, false)
        scrollable.scrollBy(0, -spinner)
    }

    override fun onAttachedToWindow() {
        super.onAttachedToWindow()
        mAttachedToWindow = true
        viewTreeObserver.addOnGlobalLayoutListener(mFollowingFooterCheck)
        if (!isInEditMode) {
            if (mRefreshHeader == null) sHeaderCreator?.let { setRefreshHeader(it.createRefreshHeader(context, this)) }
            if (mRefreshFooter == null) {
                sFooterCreator?.let { setRefreshFooter(it.createRefreshFooter(context, this)) }
            } else {
                mEnableLoadMore = mEnableLoadMore || !mManualLoadMore
            }
            if (mRefreshContent == null) {
                for (i in 0 until childCount) {
                    val view = getChildAt(i)
                    if ((mRefreshHeader == null || view !== mRefreshHeader!!.view) && (mRefreshFooter == null || view !== mRefreshFooter!!.view)) {
                        mRefreshContent = RefreshContentWrapper(view)
                    }
                }
            }
            if (mRefreshContent == null) {
                val padding = dp2px(20f)
                val errorView = TextView(context)
                errorView.setTextColor(0xffff6600.toInt())
                errorView.gravity = Gravity.CENTER
                errorView.textSize = 20f
                errorView.setText(R.string.srl_content_empty)
                super.addView(errorView, 0, LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
                mRefreshContent = RefreshContentWrapper(errorView)
                errorView.setPadding(padding, padding, padding, padding)
            }
            val content = mRefreshContent!!
            val fixedHeaderView = findViewById<View>(mFixedHeaderViewId)
            val fixedFooterView = findViewById<View>(mFixedFooterViewId)
            content.setScrollBoundaryDecider(mScrollBoundaryDecider)
            content.setEnableLoadMoreWhenContentNotFull(isLoadMoreWhenContentNotFull())
            content.setUpComponent(mKernel, fixedHeaderView, fixedFooterView)
            if (mState == RefreshState.Refreshing || mState == RefreshState.Loading) {
                resumeAfterReattach()
            } else if (mSpinner != 0) {
                notifyStateChanged(RefreshState.None)
                mSpinner = 0
                content.moveSpinner(0, mHeaderTranslationViewId, mFooterTranslationViewId)
            }
        }
        mPrimaryColors?.let { colors ->
            mRefreshHeader?.setPrimaryColors(*colors)
            mRefreshFooter?.setPrimaryColors(*colors)
        }
        mRefreshContent?.let { super.bringChildToFront(it.view) }
        mRefreshHeader?.takeIf { it.spinnerStyle.front }?.let { super.bringChildToFront(it.view) }
        mRefreshFooter?.takeIf { it.spinnerStyle.front }?.let { super.bringChildToFront(it.view) }
    }

    override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
        var minimumWidth = 0
        var minimumHeight = 0
        val needPreview = isInEditMode && mEnablePreviewInEditMode
        for (i in 0 until super.getChildCount()) {
            // Issue #1544: a child removed while its sibling measures (or lays out) leaves no view at its index.
            val child: View = super.getChildAt(i) ?: continue
            if (child.visibility == GONE || "GONE" == child.getTag(R.id.srl_tag)) continue
            val header = mRefreshHeader
            if (header != null && header.view === child) {
                val headerView = header.view
                val lp = headerView.layoutParams
                val mlp = marginsOf(headerView)
                val widthSpec = getChildMeasureSpec(widthMeasureSpec, mlp.leftMargin + mlp.rightMargin, lp.width)
                var height = mHeaderHeight
                if (mHeaderHeightStatus.ordinal < DimensionStatus.XmlLayoutUnNotify.ordinal) {
                    if (lp.height > 0) {
                        height = lp.height + mlp.bottomMargin + mlp.topMargin
                        if (mHeaderHeightStatus.canReplaceWith(DimensionStatus.XmlExactUnNotify)) {
                            mHeaderHeight = lp.height + mlp.bottomMargin + mlp.topMargin
                            mHeaderHeightStatus = DimensionStatus.XmlExactUnNotify
                        }
                    } else if (lp.height == ViewGroup.LayoutParams.WRAP_CONTENT && (header.spinnerStyle != SpinnerStyle.MatchLayout || !mHeaderHeightStatus.notified)) {
                        val maxHeight = max(MeasureSpec.getSize(heightMeasureSpec) - mlp.bottomMargin - mlp.topMargin, 0)
                        headerView.measure(widthSpec, MeasureSpec.makeMeasureSpec(maxHeight, MeasureSpec.AT_MOST))
                        val measuredHeight = headerView.measuredHeight
                        if (measuredHeight > 0) {
                            height = -1
                            if (measuredHeight != maxHeight && mHeaderHeightStatus.canReplaceWith(DimensionStatus.XmlWrapUnNotify)) {
                                mHeaderHeight = measuredHeight + mlp.bottomMargin + mlp.topMargin
                                mHeaderHeightStatus = DimensionStatus.XmlWrapUnNotify
                            }
                        }
                    }
                }
                if (header.spinnerStyle == SpinnerStyle.MatchLayout) {
                    height = MeasureSpec.getSize(heightMeasureSpec)
                } else if (header.spinnerStyle.scale && !needPreview) {
                    height = max(0, if (isEnableRefreshOrLoadMore(mEnableRefresh)) mSpinner else 0)
                }
                if (height != -1) {
                    headerView.measure(widthSpec, MeasureSpec.makeMeasureSpec(max(height - mlp.bottomMargin - mlp.topMargin, 0), MeasureSpec.EXACTLY))
                }
                if (!mHeaderHeightStatus.notified) {
                    mHeaderHeightStatus = mHeaderHeightStatus.notified()
                    header.onInitialized(mKernel, mHeaderHeight, maxDragHeight(mHeaderMaxDragRate, mHeaderHeight))
                }
                if (needPreview && isEnableRefreshOrLoadMore(mEnableRefresh)) {
                    minimumWidth += headerView.measuredWidth
                    minimumHeight += headerView.measuredHeight
                }
            }
            val footer = mRefreshFooter
            if (footer != null && footer.view === child) {
                val footerView = footer.view
                val lp = footerView.layoutParams
                val mlp = marginsOf(footerView)
                val widthSpec = getChildMeasureSpec(widthMeasureSpec, mlp.leftMargin + mlp.rightMargin, lp.width)
                var height = mFooterHeight
                if (mFooterHeightStatus.ordinal < DimensionStatus.XmlLayoutUnNotify.ordinal) {
                    if (lp.height > 0) {
                        height = lp.height + mlp.topMargin + mlp.bottomMargin
                        if (mFooterHeightStatus.canReplaceWith(DimensionStatus.XmlExactUnNotify)) {
                            mFooterHeight = lp.height + mlp.topMargin + mlp.bottomMargin
                            mFooterHeightStatus = DimensionStatus.XmlExactUnNotify
                        }
                    } else if (lp.height == ViewGroup.LayoutParams.WRAP_CONTENT && (footer.spinnerStyle != SpinnerStyle.MatchLayout || !mFooterHeightStatus.notified)) {
                        val maxHeight = max(MeasureSpec.getSize(heightMeasureSpec) - mlp.bottomMargin - mlp.topMargin, 0)
                        footerView.measure(widthSpec, MeasureSpec.makeMeasureSpec(maxHeight, MeasureSpec.AT_MOST))
                        val measuredHeight = footerView.measuredHeight
                        if (measuredHeight > 0) {
                            height = -1
                            if (measuredHeight != maxHeight && mFooterHeightStatus.canReplaceWith(DimensionStatus.XmlWrapUnNotify)) {
                                mFooterHeight = measuredHeight + mlp.topMargin + mlp.bottomMargin
                                mFooterHeightStatus = DimensionStatus.XmlWrapUnNotify
                            }
                        }
                    }
                }
                if (footer.spinnerStyle == SpinnerStyle.MatchLayout) {
                    height = MeasureSpec.getSize(heightMeasureSpec)
                } else if (footer.spinnerStyle.scale && !needPreview) {
                    height = max(0, if (isEnableRefreshOrLoadMore(mEnableLoadMore)) -mSpinner else 0)
                }
                if (height != -1) {
                    footerView.measure(widthSpec, MeasureSpec.makeMeasureSpec(max(height - mlp.bottomMargin - mlp.topMargin, 0), MeasureSpec.EXACTLY))
                }
                if (!mFooterHeightStatus.notified) {
                    mFooterHeightStatus = mFooterHeightStatus.notified()
                    footer.onInitialized(mKernel, mFooterHeight, maxDragHeight(mFooterMaxDragRate, mFooterHeight))
                }
                if (needPreview && isEnableRefreshOrLoadMore(mEnableLoadMore)) {
                    minimumWidth += footerView.measuredWidth
                    minimumHeight += footerView.measuredHeight
                }
            }
            val content = mRefreshContent
            if (content != null && content.view === child) {
                val contentView = content.view
                val lp = contentView.layoutParams
                val mlp = marginsOf(contentView)
                val showHeader = header != null && isEnableRefreshOrLoadMore(mEnableRefresh) && isEnableTranslationContent(mEnableHeaderTranslationContent, header)
                val showFooter = footer != null && isEnableRefreshOrLoadMore(mEnableLoadMore) && isEnableTranslationContent(mEnableFooterTranslationContent, footer)
                val widthSpec = getChildMeasureSpec(widthMeasureSpec, paddingLeft + paddingRight + mlp.leftMargin + mlp.rightMargin, lp.width)
                val heightSpec = getChildMeasureSpec(
                    heightMeasureSpec,
                    paddingTop + paddingBottom + mlp.topMargin + mlp.bottomMargin +
                        (if (needPreview && showHeader) mHeaderHeight else 0) + (if (needPreview && showFooter) mFooterHeight else 0),
                    lp.height,
                )
                contentView.measure(widthSpec, heightSpec)
                minimumWidth += contentView.measuredWidth + mlp.leftMargin + mlp.rightMargin
                minimumHeight += contentView.measuredHeight + mlp.topMargin + mlp.bottomMargin
            }
        }
        minimumWidth += paddingLeft + paddingRight
        minimumHeight += paddingTop + paddingBottom
        super.setMeasuredDimension(
            resolveSize(max(minimumWidth, super.getSuggestedMinimumWidth()), widthMeasureSpec),
            resolveSize(max(minimumHeight, super.getSuggestedMinimumHeight()), heightMeasureSpec),
        )
        mLastTouchX = measuredWidth / 2f
    }

    override fun onLayout(changed: Boolean, l: Int, t: Int, r: Int, b: Int) {
        for (i in 0 until super.getChildCount()) {
            val child: View = super.getChildAt(i) ?: continue
            if (child.visibility == GONE || "GONE" == child.getTag(R.id.srl_tag)) continue
            val content = mRefreshContent
            val header = mRefreshHeader
            val footer = mRefreshFooter
            if (content != null && content.view === child) {
                val isPreviewMode = isInEditMode && mEnablePreviewInEditMode && isEnableRefreshOrLoadMore(mEnableRefresh) && header != null
                val contentView = content.view
                val mlp = marginsOf(contentView)
                val left = paddingLeft + mlp.leftMargin
                var top = paddingTop + mlp.topMargin
                if (isPreviewMode && isEnableTranslationContent(mEnableHeaderTranslationContent, header)) top += mHeaderHeight
                contentView.layout(left, top, left + contentView.measuredWidth, top + contentView.measuredHeight)
            }
            if (header != null && header.view === child) {
                val isPreviewMode = isInEditMode && mEnablePreviewInEditMode && isEnableRefreshOrLoadMore(mEnableRefresh)
                val headerView = header.view
                val mlp = marginsOf(headerView)
                val left = mlp.leftMargin
                var top = mlp.topMargin + mHeaderInsetStart
                if (!isPreviewMode && header.spinnerStyle == SpinnerStyle.Translate) top -= mHeaderHeight
                headerView.layout(left, top, left + headerView.measuredWidth, top + headerView.measuredHeight)
            }
            if (footer != null && footer.view === child) {
                val isPreviewMode = isInEditMode && mEnablePreviewInEditMode && isEnableRefreshOrLoadMore(mEnableLoadMore)
                val footerView = footer.view
                val mlp = marginsOf(footerView)
                val style = footer.spinnerStyle
                val left = mlp.leftMargin
                var top = mlp.topMargin + measuredHeight - mFooterInsetStart
                if (mFooterNoMoreData && mFooterNoMoreDataEffective && mEnableFooterFollowWhenNoMoreData && content != null &&
                    style == SpinnerStyle.Translate && isEnableRefreshOrLoadMore(mEnableLoadMore)
                ) {
                    val contentView = content.view
                    val topMargin = (contentView.layoutParams as? MarginLayoutParams)?.topMargin ?: 0
                    // Issue #1475: the top padding once (the source added it twice, so the footer sat lower by it).
                    top = paddingTop + topMargin + contentView.measuredHeight
                }
                if (style == SpinnerStyle.MatchLayout) {
                    top = mlp.topMargin - mFooterInsetStart
                } else if (isPreviewMode || style == SpinnerStyle.FixedFront || style == SpinnerStyle.FixedBehind) {
                    top -= mFooterHeight
                } else if (style.scale && mSpinner < 0) {
                    top -= max(if (isEnableRefreshOrLoadMore(mEnableLoadMore)) -mSpinner else 0, 0)
                }
                footerView.layout(left, top, left + footerView.measuredWidth, top + footerView.measuredHeight)
            }
        }
    }

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        mAttachedToWindow = false
        viewTreeObserver.removeOnGlobalLayoutListener(mFollowingFooterCheck)
        mManualLoadMore = true
        animationRunnable = null
        reboundAnimator?.let {
            // Issue #1228: no removeAllUpdateListeners: a layout removed from inside an animation frame (a listener
            // of the moving header) emptied the list ValueAnimator was walking, a NullPointerException. A duration of
            // 0 tells this layout's listeners the animation was canceled.
            reboundAnimator = null
            it.duration = 0
            it.cancel()
        }
        // Issues #1137, #1168, #1198, #1400, #1414, #1429: a layout that leaves the window while refreshing or loading
        // (a fragment switched away in a ViewPager2) keeps refreshing: a release whose opening animation was cut off
        // still starts the refresh, the components' animations stop until it comes back (#1166: no frozen spinner,
        // no animation running unseen), and a finish already asked for still runs.
        when (mState) {
            RefreshState.RefreshReleased -> setStateDirectRefreshing(true)
            RefreshState.LoadReleased -> setStateDirectLoading(true)
            else -> Unit
        }
        if (mState == RefreshState.Refreshing) {
            mRefreshHeader?.onFinish(this, true)
        } else if (mState == RefreshState.Loading) {
            mRefreshFooter?.onFinish(this, true)
        } else {
            if (mSpinner != 0) mKernel.moveSpinner(0, true)
            if (mState != RefreshState.None) notifyStateChanged(RefreshState.None)
            mHandler.removeCallbacksAndMessages(null)
            // Issue #716: a finishLoadMore that never ran must not leave the footer locked.
            mFooterLocked = false
        }
    }

    /**
     * Back in the window while still refreshing or loading: shows the header (or the footer) open again and restarts
     * its animation (issues #1137, #1168, #1198, #1429).
     */
    protected open fun resumeAfterReattach() {
        if (mState == RefreshState.Refreshing) {
            val header = mRefreshHeader ?: return
            if (mSpinner != mHeaderHeight) mKernel.moveSpinner(mHeaderHeight, false)
            header.onStateChanged(this, RefreshState.RefreshReleased, RefreshState.Refreshing)
            header.onStartAnimator(this, mHeaderHeight, maxDragHeight(mHeaderMaxDragRate, mHeaderHeight))
        } else if (mState == RefreshState.Loading) {
            val footer = mRefreshFooter ?: return
            if (mSpinner < 0 && mSpinner != -mFooterHeight) mKernel.moveSpinner(-mFooterHeight, false)
            footer.onStateChanged(this, RefreshState.LoadReleased, RefreshState.Loading)
            footer.onStartAnimator(this, mFooterHeight, maxDragHeight(mFooterMaxDragRate, mFooterHeight))
        }
    }

    override fun drawChild(canvas: Canvas, child: View, drawingTime: Long): Boolean {
        val contentView = mRefreshContent?.view
        val header = mRefreshHeader
        if (header != null && header.view === child) {
            if (!isEnableRefreshOrLoadMore(mEnableRefresh) || (!mEnablePreviewInEditMode && isInEditMode)) return true
            if (contentView != null) {
                var bottom = max(contentView.top + contentView.paddingTop + mSpinner, child.top)
                val paint = mPaint
                if (mHeaderBackgroundColor != 0 && paint != null) {
                    paint.color = mHeaderBackgroundColor
                    if (header.spinnerStyle.scale) bottom = child.bottom
                    else if (header.spinnerStyle == SpinnerStyle.Translate) bottom = child.bottom + mSpinner
                    canvas.drawRect(0f, child.top.toFloat(), width.toFloat(), bottom.toFloat(), paint)
                }
                if ((mEnableClipHeaderWhenFixedBehind && header.spinnerStyle == SpinnerStyle.FixedBehind) || header.spinnerStyle.scale) {
                    canvas.save()
                    canvas.clipRect(child.left, child.top, child.right, bottom)
                    val ret = super.drawChild(canvas, child, drawingTime)
                    canvas.restore()
                    return ret
                }
            }
        }
        val footer = mRefreshFooter
        if (footer != null && footer.view === child) {
            if (!isEnableRefreshOrLoadMore(mEnableLoadMore) || (!mEnablePreviewInEditMode && isInEditMode)) return true
            if (contentView != null) {
                var top = min(contentView.bottom - contentView.paddingBottom + mSpinner, child.bottom)
                val paint = mPaint
                if (mFooterBackgroundColor != 0 && paint != null) {
                    paint.color = mFooterBackgroundColor
                    if (footer.spinnerStyle.scale) top = child.top
                    else if (footer.spinnerStyle == SpinnerStyle.Translate) top = child.top + mSpinner
                    canvas.drawRect(0f, top.toFloat(), width.toFloat(), child.bottom.toFloat(), paint)
                }
                if ((mEnableClipFooterWhenFixedBehind && footer.spinnerStyle == SpinnerStyle.FixedBehind) || footer.spinnerStyle.scale) {
                    canvas.save()
                    canvas.clipRect(child.left, top, child.right, child.bottom)
                    val ret = super.drawChild(canvas, child, drawingTime)
                    canvas.restore()
                    return ret
                }
            }
        }
        return super.drawChild(canvas, child, drawingTime)
    }

    override fun computeScroll() {
        // Issue #1546: some devices' Scroller throws ArrayIndexOutOfBoundsException from its spline table for an
        // elapsed time below 0; the fling then stops instead of crashing the app.
        val scrolling = try {
            mScroller.computeScrollOffset()
        } catch (e: ArrayIndexOutOfBoundsException) {
            mScroller.forceFinished(true)
            false
        }
        if (scrolling) {
            val finalY = mScroller.finalY
            val content = mRefreshContent
            if (content != null && ((finalY < 0 && (mEnableRefresh || mEnableOverScrollDrag) && content.canRefresh()) ||
                    (finalY > 0 && (mEnableLoadMore || mEnableOverScrollDrag) && content.canLoadMore()))
            ) {
                if (mVerticalPermit) {
                    val velocity = if (finalY > 0) -mScroller.currVelocity else mScroller.currVelocity
                    animSpinnerBounce(velocity)
                }
                mScroller.forceFinished(true)
            } else {
                mVerticalPermit = true
                invalidate()
            }
        }
    }

    // MARK: - Touches

    override fun dispatchTouchEvent(e: MotionEvent): Boolean {
        // The focal point of every finger.
        val action = e.actionMasked
        val pointerUp = action == MotionEvent.ACTION_POINTER_UP
        val skipIndex = if (pointerUp) e.actionIndex else -1
        var sumX = 0f
        var sumY = 0f
        val count = e.pointerCount
        for (i in 0 until count) {
            if (skipIndex == i) continue
            sumX += e.getX(i)
            sumY += e.getY(i)
        }
        val div = if (pointerUp) count - 1 else count
        val touchX = sumX / div
        val touchY = sumY / div
        if ((action == MotionEvent.ACTION_POINTER_UP || action == MotionEvent.ACTION_POINTER_DOWN) && mIsBeingDragged) {
            mTouchY += touchY - mLastTouchY
        }
        mLastTouchX = touchX
        mLastTouchY = touchY
        if (action == MotionEvent.ACTION_DOWN) {
            // Issue #1540: kept to tell a tap while the close animation runs.
            mLastTouchXOnActionDown = touchX
            mLastTouchYOnActionDown = touchY
            mLastTimeOnActionDown = System.currentTimeMillis()
        }

        if (mNestedInProgress) {
            // Nested scrolling: a sideways move that scrolled nothing goes to the components' horizontal drag.
            val totalUnconsumed = mTotalUnconsumed
            val ret = super.dispatchTouchEvent(e)
            if (action == MotionEvent.ACTION_MOVE && totalUnconsumed == mTotalUnconsumed) {
                val offsetX = mLastTouchX.toInt()
                val offsetMax = width
                val percentX = mLastTouchX / (if (offsetMax == 0) 1 else offsetMax)
                val header = mRefreshHeader
                val footer = mRefreshFooter
                if (isEnableRefreshOrLoadMore(mEnableRefresh) && mSpinner > 0 && header != null && header.isSupportHorizontalDrag) {
                    header.onHorizontalDrag(percentX, offsetX, offsetMax)
                } else if (isEnableRefreshOrLoadMore(mEnableLoadMore) && mSpinner < 0 && footer != null && footer.isSupportHorizontalDrag) {
                    footer.onHorizontalDrag(percentX, offsetX, offsetMax)
                }
            }
            return ret
        } else if (!isEnabled ||
            (!mEnableRefresh && !mEnableLoadMore && !mEnableOverScrollDrag) ||
            (mHeaderNeedTouchEventWhenRefreshing && ((mState.isOpening || mState.isFinishing) && mState.isHeader)) ||
            (mFooterNeedTouchEventWhenLoading && ((mState.isOpening || mState.isFinishing) && mState.isFooter))
        ) {
            return super.dispatchTouchEvent(e)
        } else if (mState == RefreshState.LoadFinish) {
            // Issue #1169: after loading more, the list scrolls at once instead of after the footer's close
            // animation. The gesture stays the content's to the end, so it never turns into a pull.
            if (action == MotionEvent.ACTION_DOWN) mDragDirection = 'h'
            return super.dispatchTouchEvent(e)
        } else if (mState.isFinishing) {
            // Issue #1540: while the close animation runs the content does not scroll, but a tap still clicks.
            if (action == MotionEvent.ACTION_UP && System.currentTimeMillis() - mLastTimeOnActionDown < 500) {
                val dx = touchX - mLastTouchXOnActionDown
                val dy = touchY - mLastTouchYOnActionDown
                if (abs(dx) < mTouchSlop && abs(dy) < mTouchSlop) {
                    e.action = MotionEvent.ACTION_DOWN
                    super.dispatchTouchEvent(e)
                    e.action = MotionEvent.ACTION_UP
                    return super.dispatchTouchEvent(e)
                }
            }
            return true
        }

        if (interceptAnimatorByAction(action) ||
            (mState == RefreshState.Loading && mDisableContentWhenLoading) ||
            (mState == RefreshState.Refreshing && mDisableContentWhenRefresh)
        ) {
            return false
        }

        when (action) {
            MotionEvent.ACTION_DOWN -> {
                mCurrentVelocity = 0
                mVelocityTracker.addMovement(e)
                mScroller.forceFinished(true)
                mTouchX = touchX
                mTouchY = touchY
                mLastSpinner = 0
                mTouchSpinner = mSpinner
                mIsBeingDragged = false
                mEnableDisallowIntercept = false
                mSuperDispatchTouchEvent = super.dispatchTouchEvent(e)
                // Issues #1258, #1260, #1305, #1432, #1534: while the header or the footer shows (a refresh or a load
                // still running), a finger on the layout belongs to it, so a ViewPager or ViewPager2 around it does
                // not switch pages.
                if (mSpinner != 0) parent?.requestDisallowInterceptTouchEvent(true)
                if (mState == RefreshState.TwoLevel && mTouchY < measuredHeight * (1 - mTwoLevelBottomPullUpToCloseRate)) {
                    mDragDirection = 'h'
                    return mSuperDispatchTouchEvent
                }
                mRefreshContent?.onActionDown(e)
                return true
            }
            MotionEvent.ACTION_MOVE -> {
                val dx = touchX - mTouchX
                var dy = touchY - mTouchY
                mVelocityTracker.addMovement(e)
                val content = mRefreshContent
                if (!mIsBeingDragged && !mEnableDisallowIntercept && mDragDirection != 'h' && content != null) {
                    if (mDragDirection == 'v' || (abs(dy) >= mTouchSlop && abs(dx) < abs(dy))) {
                        mDragDirection = 'v'
                        if (dy > 0 && (mSpinner < 0 || ((mEnableOverScrollDrag || mEnableRefresh) && content.canRefresh()))) {
                            mIsBeingDragged = true
                            mTouchY = touchY - mTouchSlop
                        } else if (dy < 0 && (mSpinner > 0 || ((mEnableOverScrollDrag || mEnableLoadMore) &&
                                ((mState == RefreshState.Loading && mFooterLocked) || content.canLoadMore())))
                        ) {
                            mIsBeingDragged = true
                            mTouchY = touchY + mTouchSlop
                        }
                        if (mIsBeingDragged) {
                            dy = touchY - mTouchY
                            if (mSuperDispatchTouchEvent) {
                                e.action = MotionEvent.ACTION_CANCEL
                                super.dispatchTouchEvent(e)
                            }
                            mKernel.setState(if (mSpinner > 0 || (mSpinner == 0 && dy > 0)) RefreshState.PullDownToRefresh else RefreshState.PullUpToLoad)
                            // Issue #580: the parent stops intercepting while pulling.
                            (parent as? ViewGroup)?.requestDisallowInterceptTouchEvent(true)
                        }
                    } else if (abs(dx) >= mTouchSlop && abs(dx) > abs(dy) && mDragDirection != 'v') {
                        mDragDirection = 'h'
                    }
                }
                if (mIsBeingDragged) {
                    var spinner = dy.toInt() + mTouchSpinner
                    if ((mViceState.isHeader && (spinner < 0 || mLastSpinner < 0)) || (mViceState.isFooter && (spinner > 0 || mLastSpinner > 0))) {
                        // The pull went back past the start: the content scrolls again, with events sent to it.
                        mLastSpinner = spinner
                        if (mFalsifyEvent == null) {
                            val falsify = obtainLike(e, MotionEvent.ACTION_DOWN, mTouchX + dx, mTouchY)
                            mFalsifyEvent = falsify
                            super.dispatchTouchEvent(falsify)
                            // A parent hands a child only the first finger on ACTION_DOWN; the other fingers follow as
                            // ACTION_POINTER_DOWN, so the child keeps every pointer (#532, #1227, #1319, #1496).
                            for (i in 1 until e.pointerCount) {
                                val pointerDown = obtainLike(e, MotionEvent.ACTION_POINTER_DOWN or (i shl MotionEvent.ACTION_POINTER_INDEX_SHIFT), mTouchX + dx, mTouchY)
                                super.dispatchTouchEvent(pointerDown)
                                pointerDown.recycle()
                            }
                        }
                        val em = obtainLike(e, MotionEvent.ACTION_MOVE, mTouchX + dx, mTouchY + spinner)
                        super.dispatchTouchEvent(em)
                        if (mFooterLocked && dy > mTouchSlop && mSpinner < 0) mFooterLocked = false
                        if (spinner > 0 && ((mEnableOverScrollDrag || mEnableRefresh) && content!!.canRefresh())) {
                            mLastTouchY = touchY
                            mTouchY = touchY
                            spinner = 0
                            mTouchSpinner = 0
                            mKernel.setState(RefreshState.PullDownToRefresh)
                        } else if (spinner < 0 && ((mEnableOverScrollDrag || mEnableLoadMore) && content!!.canLoadMore())) {
                            mLastTouchY = touchY
                            mTouchY = touchY
                            spinner = 0
                            mTouchSpinner = 0
                            mKernel.setState(RefreshState.PullUpToLoad)
                        }
                        if ((mViceState.isHeader && spinner < 0) || (mViceState.isFooter && spinner > 0)) {
                            if (mSpinner != 0) moveSpinnerInfinitely(0f)
                            return true
                        } else if (mFalsifyEvent != null) {
                            mFalsifyEvent = null
                            em.action = MotionEvent.ACTION_CANCEL
                            super.dispatchTouchEvent(em)
                        }
                        em.recycle()
                    }
                    moveSpinnerInfinitely(spinner.toFloat())
                    return true
                } else if (mFooterLocked && dy > mTouchSlop && mSpinner < 0) {
                    mFooterLocked = false
                }
            }
            MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                if (action == MotionEvent.ACTION_UP) {
                    mVelocityTracker.addMovement(e)
                    mVelocityTracker.computeCurrentVelocity(1000, mMaximumVelocity.toFloat())
                    mCurrentVelocity = mVelocityTracker.yVelocity.toInt()
                    startFlingIfNeed(0f)
                }
                mVelocityTracker.clear()
                mDragDirection = 'n'
                mFalsifyEvent?.let {
                    it.recycle()
                    mFalsifyEvent = null
                    val ec = obtainLike(e, action, mTouchX, touchY)
                    super.dispatchTouchEvent(ec)
                    ec.recycle()
                }
                overSpinner()
                if (mIsBeingDragged) {
                    mIsBeingDragged = false
                    return true
                }
            }
        }
        return super.dispatchTouchEvent(e)
    }

    /**
     * The height the drag damping is measured against: this layout's height, between [minimum] and [maximum]. A layout
     * taller than the screen (inside a ScrollView or a NestedScrollView, or one that grows as pages load) no longer
     * makes the pull ever harder, until it cannot reach the refresh height (issues #1197, #1200, #1236).
     */
    protected open fun dampingHeight(minimum: Double, maximum: Double): Double = max(minimum, min(height.toDouble(), maximum))

    /**
     * The content was removed (for example to wrap it in another view, issue #1235): the next child added becomes the
     * content.
     */
    override fun onViewRemoved(child: View) {
        super.onViewRemoved(child)
        if (mRefreshContent != null && child === mRefreshContent!!.view) mRefreshContent = null
    }

    /**
     * A child added while there is no content becomes the content (issue #1235).
     */
    override fun onViewAdded(child: View) {
        super.onViewAdded(child)
        if (mRefreshContent == null && mAttachedToWindow &&
            (mRefreshHeader == null || child !== mRefreshHeader!!.view) &&
            (mRefreshFooter == null || child !== mRefreshFooter!!.view)
        ) {
            val content = RefreshContentWrapper(child)
            mRefreshContent = content
            content.setScrollBoundaryDecider(mScrollBoundaryDecider)
            content.setEnableLoadMoreWhenContentNotFull(isLoadMoreWhenContentNotFull())
            content.setUpComponent(mKernel, null, null)
        }
    }

    override fun requestDisallowInterceptTouchEvent(disallowIntercept: Boolean) {
        // From SwipeRefreshLayout: a list before Lollipop, or another view without nested scrolling, cannot steal the
        // vertical scroll.
        // Issue #1241: the request still reaches the parents (a ViewPager around a WebView with a sideways scrolling
        // area), so only this layout ignores it.
        val target = mRefreshContent?.scrollableView
        if (target != null && ViewCompat.isNestedScrollingEnabled(target)) {
            mEnableDisallowIntercept = disallowIntercept
            super.requestDisallowInterceptTouchEvent(disallowIntercept)
        } else {
            parent?.requestDisallowInterceptTouchEvent(disallowIntercept)
        }
    }

    /**
     * Starts a fling or a bounce for [flingVelocity] (0: the last touch's velocity); true when it was used up.
     */
    protected open fun startFlingIfNeed(flingVelocity: Float): Boolean {
        val velocity = if (flingVelocity == 0f) mCurrentVelocity.toFloat() else flingVelocity
        if (abs(velocity) > mMinimumVelocity) {
            if (velocity * mSpinner < 0) {
                if (mState == RefreshState.Refreshing || mState == RefreshState.Loading || (mSpinner < 0 && mFooterNoMoreData)) {
                    animationRunnable = FlingRunnable(velocity).start()
                    return true
                } else if (mState.isReleaseToOpening) {
                    return true
                }
            }
            if ((velocity < 0 && ((mEnableOverScrollBounce && (mEnableLoadMore || mEnableOverScrollDrag)) ||
                    (mState == RefreshState.Loading && mSpinner >= 0) || (mEnableAutoLoadMore && isEnableRefreshOrLoadMore(mEnableLoadMore)))) ||
                (velocity > 0 && ((mEnableOverScrollBounce && mEnableRefresh || mEnableOverScrollDrag) || (mState == RefreshState.Refreshing && mSpinner <= 0)))
            ) {
                mVerticalPermit = false
                mScroller.fling(0, 0, 0, (-velocity).toInt(), 0, 0, -Int.MAX_VALUE, Int.MAX_VALUE)
                mScroller.computeScrollOffset()
                invalidate()
            }
        }
        return false
    }

    /**
     * A touch down stops a running bounce; true while an animation keeps the touch.
     */
    protected open fun interceptAnimatorByAction(action: Int): Boolean {
        if (action == MotionEvent.ACTION_DOWN) {
            reboundAnimator?.let { animator ->
                // Issues #1326, #1401, #1595: a finger on the layout while an auto refresh (or auto load) opens no
                // longer stops it halfway, which made the header jump back and lost the refresh.
                if (animator === mAutoOpenAnimator && animator.isRunning) return true
                if (mState.isFinishing || mState == RefreshState.TwoLevelReleased || mState == RefreshState.RefreshReleased || mState == RefreshState.LoadReleased) {
                    return true
                }
                if (mState == RefreshState.PullDownCanceled) {
                    mKernel.setState(RefreshState.PullDownToRefresh)
                } else if (mState == RefreshState.PullUpCanceled) {
                    mKernel.setState(RefreshState.PullUpToLoad)
                }
                animator.duration = 0
                animator.cancel()
                reboundAnimator = null
            }
            animationRunnable = null
        }
        return reboundAnimator != null
    }

    // MARK: - States

    /**
     * Moves to [state] and tells the header, the footer and the listener.
     */
    protected open fun notifyStateChanged(state: RefreshState) {
        val oldState = mState
        if (oldState != state) {
            mState = state
            mViceState = state
            mRefreshHeader?.let {
                it.onStateChanged(this, oldState, state)
                // Pull request #1095: the auto refresh mark ends with the refresh.
                if (state == RefreshState.None && oldState == RefreshState.RefreshFinish) it.onAutoRefresh(false)
            }
            mRefreshFooter?.let {
                it.onStateChanged(this, oldState, state)
                if (state == RefreshState.None && oldState == RefreshState.LoadFinish) it.onAutoRefresh(false)
            }
            mOnMultiListener?.onStateChanged(this, oldState, state)
            if (state == RefreshState.LoadFinish) mFooterLocked = false
        } else if (mViceState != mState) {
            mViceState = mState
        }
    }

    /**
     * Starts loading more at once, calling the listener when [triggerLoadMoreEvent].
     */
    protected open fun setStateDirectLoading(triggerLoadMoreEvent: Boolean) {
        if (mState == RefreshState.Loading) return
        mLastOpenTime = System.currentTimeMillis()
        mFooterLocked = true
        notifyStateChanged(RefreshState.Loading)
        val loadMore = mLoadMoreListener
        if (loadMore != null) {
            if (triggerLoadMoreEvent) loadMore.onLoadMore(this)
        } else if (mOnMultiListener == null) {
            finishLoadMore(2000)
        }
        val maxDragHeight = maxDragHeight(mFooterMaxDragRate, mFooterHeight)
        mRefreshFooter?.onStartAnimator(this, mFooterHeight, maxDragHeight)
        val multi = mOnMultiListener
        val footer = mRefreshFooter
        if (multi != null && footer is RefreshFooter) {
            if (triggerLoadMoreEvent) multi.onLoadMore(this)
            multi.onFooterStartAnimator(footer, mFooterHeight, maxDragHeight)
        }
    }

    /**
     * Opens the footer and starts loading more.
     */
    protected open fun setStateLoading(notify: Boolean) {
        val listener = object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                if (animation.duration == 0L) return
                setStateDirectLoading(notify)
            }
        }
        notifyStateChanged(RefreshState.LoadReleased)
        val animator = mKernel.animSpinner(-mFooterHeight)
        animator?.addListener(listener)
        val before = reboundAnimator
        val maxDragHeight = maxDragHeight(mFooterMaxDragRate, mFooterHeight)
        mRefreshFooter?.onReleased(this, mFooterHeight, maxDragHeight)
        val footer = mRefreshFooter
        if (footer is RefreshFooter) mOnMultiListener?.onFooterReleased(footer, mFooterHeight, maxDragHeight)
        followReplacedAnimator(animator, before, listener) { setStateDirectLoading(notify) }
    }

    /**
     * Issue #1455: a header (or footer) whose onReleased runs its own animation through the kernel's animSpinner
     * replaced the opening animation, and the refresh (or load) waiting for its end never started. [listener] now
     * follows the replacement; with no animation left, [start] runs at once. [before] is the animation before the
     * component's onReleased.
     */
    private fun followReplacedAnimator(animator: ValueAnimator?, before: ValueAnimator?, listener: Animator.AnimatorListener, start: () -> Unit) {
        val current = reboundAnimator
        when {
            current === before -> if (animator == null) start()
            // A component that ended the release itself (FalsifyHeader moves to None) keeps it ended.
            mState != RefreshState.RefreshReleased && mState != RefreshState.LoadReleased -> Unit
            current != null -> current.addListener(listener)
            else -> start()
        }
    }

    /**
     * Starts refreshing at once, calling the listener when [notify].
     */
    protected open fun setStateDirectRefreshing(notify: Boolean) {
        if (mState == RefreshState.Refreshing) return
        mLastOpenTime = System.currentTimeMillis()
        notifyStateChanged(RefreshState.Refreshing)
        val refresh = mRefreshListener
        if (refresh != null) {
            if (notify) refresh.onRefresh(this)
        } else if (mOnMultiListener == null) {
            finishRefresh(3000)
        }
        val maxDragHeight = maxDragHeight(mHeaderMaxDragRate, mHeaderHeight)
        mRefreshHeader?.onStartAnimator(this, mHeaderHeight, maxDragHeight)
        val multi = mOnMultiListener
        val header = mRefreshHeader
        if (multi != null && header is RefreshHeader) {
            if (notify) multi.onRefresh(this)
            multi.onHeaderStartAnimator(header, mHeaderHeight, maxDragHeight)
        }
    }

    /**
     * Opens the header and starts refreshing.
     */
    protected open fun setStateRefreshing(notify: Boolean) {
        val start = { setStateDirectRefreshing(notify) }
        val listener = object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                if (animation.duration == 0L) return
                start()
            }
        }
        notifyStateChanged(RefreshState.RefreshReleased)
        val animator = mKernel.animSpinner(mHeaderHeight)
        animator?.addListener(listener)
        val before = reboundAnimator
        val maxDragHeight = maxDragHeight(mHeaderMaxDragRate, mHeaderHeight)
        mRefreshHeader?.onReleased(this, mHeaderHeight, maxDragHeight)
        val header = mRefreshHeader
        if (header is RefreshHeader) mOnMultiListener?.onHeaderReleased(header, mHeaderHeight, maxDragHeight)
        followReplacedAnimator(animator, before, listener, start)
    }

    /**
     * Sets the state the layout is heading to.
     */
    protected open fun setViceState(state: RefreshState) {
        if (mState.isDragging && mState.isHeader != state.isHeader) notifyStateChanged(RefreshState.None)
        if (mViceState != state) mViceState = state
    }

    /**
     * True when the content moves with [internal].
     */
    protected open fun isEnableTranslationContent(enable: Boolean, internal: RefreshComponent?): Boolean =
        enable || mEnablePureScrollMode || internal == null || internal.spinnerStyle == SpinnerStyle.FixedBehind

    /**
     * True when refreshing (or loading) can really happen, not only a pure-scroll bounce.
     */
    protected open fun isEnableRefreshOrLoadMore(enable: Boolean): Boolean = enable && !mEnablePureScrollMode

    // MARK: - Animations

    /**
     * Carries a fling past the open header or footer.
     */
    protected open inner class FlingRunnable(velocity: Float) : Runnable {
        @JvmField internal var mOffset: Int = mSpinner
        @JvmField internal var mFrame = 0
        @JvmField internal var mFrameDelay = 10
        @JvmField internal var mVelocity = velocity
        @JvmField internal var mDamping = 0.98f
        @JvmField internal var mStartTime = 0L
        @JvmField internal var mLastTime = AnimationUtils.currentAnimationTimeMillis()

        /**
         * Starts the fling; null when it would end at once.
         */
        fun start(): Runnable? {
            if (mState.isFinishing) return null
            val followNoMoreData = mFooterNoMoreData && mEnableFooterFollowWhenNoMoreData && mFooterNoMoreDataEffective && isEnableRefreshOrLoadMore(mEnableLoadMore)
            if (mSpinner != 0 && (!(mState.isOpening || followNoMoreData) ||
                    ((mState == RefreshState.Loading || followNoMoreData) && mSpinner < -mFooterHeight) ||
                    (mState == RefreshState.Refreshing && mSpinner > mHeaderHeight))
            ) {
                var frame = 0
                var offset = mSpinner
                val spinner = mSpinner
                var velocity = mVelocity
                while (spinner * offset > 0) {
                    velocity *= mDamping.toDouble().pow(((++frame) * mFrameDelay / 10f).toDouble()).toFloat()
                    val velocityFrame = velocity * (1f * mFrameDelay / 1000)
                    if (abs(velocityFrame) < 1) {
                        if (!mState.isOpening || (mState == RefreshState.Refreshing && offset > mHeaderHeight) ||
                            (mState != RefreshState.Refreshing && offset < -mFooterHeight)
                        ) {
                            return null
                        }
                        break
                    }
                    offset += velocityFrame.toInt()
                }
            }
            mStartTime = AnimationUtils.currentAnimationTimeMillis()
            mHandler.postDelayed(this, mFrameDelay.toLong())
            return this
        }

        override fun run() {
            if (animationRunnable !== this || mState.isFinishing) return
            val now = AnimationUtils.currentAnimationTimeMillis()
            // Pull request #1621: a clock that goes back (dropped frames, #1463) never runs the fling backwards.
            val span = max(0L, now - mLastTime)
            mVelocity *= mDamping.toDouble().pow(((now - mStartTime) / (1000f / mFrameDelay)).toDouble()).toFloat()
            val velocity = mVelocity * (1f * span / 1000)
            if (abs(velocity) > 1) {
                mLastTime = now
                mOffset += velocity.toInt()
                if (mSpinner * mOffset > 0) {
                    mKernel.moveSpinner(mOffset, true)
                    mHandler.postDelayed(this, mFrameDelay.toLong())
                } else {
                    animationRunnable = null
                    mKernel.moveSpinner(0, true)
                    mRefreshContent?.let { fling(it.scrollableView, (-mVelocity).toInt()) }
                    if (mFooterLocked && velocity > 0) mFooterLocked = false
                }
            } else {
                animationRunnable = null
            }
        }
    }

    /**
     * Bounces past the edge after a fling.
     */
    protected open inner class BounceRunnable(velocity: Float, smoothDistance: Int) : Runnable {
        @JvmField internal var mFrame = 0
        @JvmField internal var mFrameDelay = 10
        @JvmField internal var mSmoothDistance = smoothDistance
        @JvmField internal var mLastTime = AnimationUtils.currentAnimationTimeMillis()
        @JvmField internal var mOffset = 0f
        @JvmField internal var mVelocity = velocity

        init {
            mHandler.postDelayed(this, mFrameDelay.toLong())
            mKernel.setState(if (velocity > 0) RefreshState.PullDownToRefresh else RefreshState.PullUpToLoad)
        }

        override fun run() {
            if (animationRunnable !== this || mState.isFinishing) return
            mVelocity *= if (abs(mSpinner) >= abs(mSmoothDistance)) {
                (if (mSmoothDistance != 0) 0.45 else 0.85).pow((++mFrame * 2).toDouble()).toFloat()
            } else {
                0.95.pow((++mFrame * 2).toDouble()).toFloat()
            }
            val now = AnimationUtils.currentAnimationTimeMillis()
            // Pull request #1621.
            val t = max(0f, 1f * (now - mLastTime) / 1000)
            val velocity = mVelocity * t
            if (abs(velocity) >= 1) {
                mLastTime = now
                mOffset += velocity
                moveSpinnerInfinitely(mOffset)
                mHandler.postDelayed(this, mFrameDelay.toLong())
            } else {
                if (mViceState.isDragging && mViceState.isHeader) {
                    mKernel.setState(RefreshState.PullDownCanceled)
                } else if (mViceState.isDragging && mViceState.isFooter) {
                    mKernel.setState(RefreshState.PullUpCanceled)
                }
                animationRunnable = null
                if (abs(mSpinner) >= abs(mSmoothDistance)) {
                    val duration = 10 * min(max(SmartUtil.px2dp(abs(mSpinner - mSmoothDistance)).toInt(), 30), 100)
                    animSpinner(mSmoothDistance, 0, mReboundInterpolator, duration)
                }
            }
        }
    }

    /**
     * Animates the pull to [endSpinner]; null when it is already there.
     */
    protected open fun animSpinner(endSpinner: Int, startDelay: Int, interpolator: Interpolator, duration: Int): ValueAnimator? {
        if (mSpinner == endSpinner) return null
        reboundAnimator?.let {
            it.duration = 0
            it.cancel()
            reboundAnimator = null
        }
        animationRunnable = null
        val animator = ValueAnimator.ofInt(mSpinner, endSpinner)
        reboundAnimator = animator
        animator.duration = duration.toLong()
        animator.interpolator = interpolator
        animator.addListener(object : AnimatorListenerAdapter() {
            override fun onAnimationEnd(animation: Animator) {
                // A duration of 0 means it was canceled.
                if (animation.duration == 0L) return
                reboundAnimator = null
                if (mSpinner == 0 && mState != RefreshState.None && !mState.isOpening && !mState.isDragging) {
                    notifyStateChanged(RefreshState.None)
                } else if (mState != mViceState) {
                    setViceState(mState)
                }
            }
        })
        animator.addUpdateListener { mKernel.moveSpinner(it.animatedValue as Int, false) }
        animator.startDelay = startDelay.toLong()
        animator.start()
        return animator
    }

    /**
     * Bounces after a fling of [velocity] reached the edge.
     */
    protected open fun animSpinnerBounce(velocity: Float) {
        if (reboundAnimator != null) return
        if (velocity > 0 && (mState == RefreshState.Refreshing || mState == RefreshState.TwoLevel)) {
            animationRunnable = BounceRunnable(velocity, mHeaderHeight)
        } else if (velocity < 0 && (mState == RefreshState.Loading ||
                (mEnableFooterFollowWhenNoMoreData && mFooterNoMoreData && mFooterNoMoreDataEffective && isEnableRefreshOrLoadMore(mEnableLoadMore)) ||
                (mEnableAutoLoadMore && !mFooterNoMoreData && isEnableRefreshOrLoadMore(mEnableLoadMore) && mState != RefreshState.Refreshing))
        ) {
            animationRunnable = BounceRunnable(velocity, -mFooterHeight)
        } else if (mSpinner == 0 && mEnableOverScrollBounce) {
            animationRunnable = BounceRunnable(velocity, 0)
        }
    }

    /**
     * The finger lifted: open, close or keep the header or footer.
     */
    protected open fun overSpinner() {
        when {
            mState == RefreshState.TwoLevel -> {
                if (mCurrentVelocity > -1000 && mSpinner > height / 2) {
                    mKernel.animSpinner(height)?.duration = mFloorDuration.toLong()
                } else if (mIsBeingDragged) {
                    mKernel.finishTwoLevel()
                }
            }
            mState == RefreshState.Loading ||
                (mEnableFooterFollowWhenNoMoreData && mFooterNoMoreData && mFooterNoMoreDataEffective && mSpinner < 0 && isEnableRefreshOrLoadMore(mEnableLoadMore)) -> {
                if (mSpinner < -mFooterHeight) mKernel.animSpinner(-mFooterHeight)
                else if (mSpinner > 0) mKernel.animSpinner(0)
            }
            mState == RefreshState.Refreshing -> {
                if (mSpinner > mHeaderHeight) mKernel.animSpinner(mHeaderHeight)
                else if (mSpinner < 0) mKernel.animSpinner(0)
            }
            mState == RefreshState.PullDownToRefresh -> mKernel.setState(RefreshState.PullDownCanceled)
            mState == RefreshState.PullUpToLoad -> mKernel.setState(RefreshState.PullUpCanceled)
            mState == RefreshState.ReleaseToRefresh -> mKernel.setState(RefreshState.Refreshing)
            mState == RefreshState.ReleaseToLoad -> mKernel.setState(RefreshState.Loading)
            mState == RefreshState.ReleaseToTwoLevel -> mKernel.setState(RefreshState.TwoLevelReleased)
            mState == RefreshState.RefreshReleased -> if (reboundAnimator == null) mKernel.animSpinner(mHeaderHeight)
            mState == RefreshState.LoadReleased -> if (reboundAnimator == null) mKernel.animSpinner(-mFooterHeight)
            mState == RefreshState.LoadFinish -> Log.d("SmartRefreshLayout", "overSpinner: nothing to do in LoadFinish")
            mSpinner != 0 -> mKernel.animSpinner(0)
        }
    }

    /**
     * Moves the pull to [spinner] finger pixels, with the damping past the header's (footer's) height.
     */
    protected open fun moveSpinnerInfinitely(spinner: Float) {
        var value = spinner
        if (mNestedInProgress && !isLoadMoreWhenContentNotFull() && value < 0 && mRefreshContent?.canLoadMore() == false) {
            // 2019-1-22: mEnableLoadMoreWhenContentNotFull = false in nested scrolling mode.
            value = 0f
        }
        // The easter egg toast of the source is removed: a library shows no surprise messages (issues #1105, #1110).
        val followNoMoreData = mEnableFooterFollowWhenNoMoreData && mFooterNoMoreData && mFooterNoMoreDataEffective && isEnableRefreshOrLoadMore(mEnableLoadMore)
        if (mState == RefreshState.TwoLevel && value > 0) {
            mKernel.moveSpinner(min(value.toInt(), measuredHeight), true)
        } else if (mState == RefreshState.Refreshing && value >= 0) {
            if (value < mHeaderHeight) {
                mKernel.moveSpinner(value.toInt(), true)
            } else {
                val m = triggerHeight(mHeaderMaxDragRate, mHeaderHeight).toDouble() - mHeaderHeight
                val h = dampingHeight(mScreenHeightPixels * 4 / 3.0, mScreenHeightPixels * 4 / 3.0) - mHeaderHeight
                val x = max(0.0, ((value - mHeaderHeight) * mDragRate).toDouble())
                val y = min(m * (1 - 100.0.pow(-x / (if (h == 0.0) 1.0 else h))), x)
                mKernel.moveSpinner(y.toInt() + mHeaderHeight, true)
            }
        } else if (value < 0 && (mState == RefreshState.Loading || followNoMoreData ||
                (mEnableAutoLoadMore && !mFooterNoMoreData && isEnableRefreshOrLoadMore(mEnableLoadMore)))
        ) {
            if (value > -mFooterHeight) {
                mKernel.moveSpinner(value.toInt(), true)
            } else {
                val m = triggerHeight(mFooterMaxDragRate, mFooterHeight).toDouble() - mFooterHeight
                val h = dampingHeight(mScreenHeightPixels * 4 / 3.0, mScreenHeightPixels * 4 / 3.0) - mFooterHeight
                val x = -min(0.0, ((value + mFooterHeight) * mDragRate).toDouble())
                val y = -min(m * (1 - 100.0.pow(-x / (if (h == 0.0) 1.0 else h))), x)
                mKernel.moveSpinner(y.toInt() - mFooterHeight, true)
            }
        } else if (value >= 0) {
            val m = triggerHeight(mHeaderMaxDragRate, mHeaderHeight).toDouble()
            val h = dampingHeight(mScreenHeightPixels / 2.0, mScreenHeightPixels.toDouble())
            val x = max(0.0, (value * mDragRate).toDouble())
            val y = min(m * (1 - 100.0.pow(-x / (if (h == 0.0) 1.0 else h))), x)
            mKernel.moveSpinner(y.toInt(), true)
        } else {
            val m = triggerHeight(mFooterMaxDragRate, mFooterHeight).toDouble()
            val h = dampingHeight(mScreenHeightPixels / 2.0, mScreenHeightPixels.toDouble())
            val x = -min(0.0, (value * mDragRate).toDouble())
            val y = -min(m * (1 - 100.0.pow(-x / (if (h == 0.0) 1.0 else h))), x)
            mKernel.moveSpinner(y.toInt(), true)
        }
        if (mEnableAutoLoadMore && !mFooterNoMoreData && isEnableRefreshOrLoadMore(mEnableLoadMore) && value < 0 &&
            mState != RefreshState.Refreshing && mState != RefreshState.Loading && mState != RefreshState.LoadFinish
        ) {
            if (mDisableContentWhenLoading) {
                animationRunnable = null
                mKernel.animSpinner(-mFooterHeight)
            }
            setStateDirectLoading(false)
            // Auto load more calls the listener after the rebound duration, so the animation runs smoothly.
            mHandler.postDelayed({
                val loadMore = mLoadMoreListener
                if (loadMore != null) loadMore.onLoadMore(this) else if (mOnMultiListener == null) finishLoadMore(2000)
                mOnMultiListener?.onLoadMore(this)
            }, mReboundDuration.toLong())
        }
    }

    // MARK: - Layout parameters

    override fun generateLayoutParams(attrs: AttributeSet): ViewGroup.LayoutParams = LayoutParams(context, attrs)

    /**
     * The layout parameters of the layout's children: a background color and a spinner style for a header or footer.
     */
    open class LayoutParams : MarginLayoutParams {
        /**
         * The background color drawn behind the component.
         */
        @JvmField var backgroundColor = 0

        /**
         * The component's spinner style, or null for its own.
         */
        @JvmField var spinnerStyle: SpinnerStyle? = null

        /**
         * From XML attributes.
         */
        constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
            val ta = context.obtainStyledAttributes(attrs, R.styleable.SmartRefreshLayout_Layout)
            backgroundColor = ta.getColor(R.styleable.SmartRefreshLayout_Layout_layout_srlBackgroundColor, backgroundColor)
            if (ta.hasValue(R.styleable.SmartRefreshLayout_Layout_layout_srlSpinnerStyle)) {
                spinnerStyle = SpinnerStyle.values[ta.getInt(R.styleable.SmartRefreshLayout_Layout_layout_srlSpinnerStyle, SpinnerStyle.Translate.ordinal)]
            }
            ta.recycle()
        }

        /**
         * With a width and a height.
         */
        constructor(width: Int, height: Int) : super(width, height)
    }

    // MARK: - Nested scrolling

    override fun getNestedScrollAxes(): Int = mNestedParent.nestedScrollAxes

    override fun onStartNestedScroll(child: View, target: View, nestedScrollAxes: Int): Boolean =
        isEnabled && isNestedScrollingEnabled && (nestedScrollAxes and ViewCompat.SCROLL_AXIS_VERTICAL) != 0 &&
            (mEnableOverScrollDrag || mEnableRefresh || mEnableLoadMore)

    override fun onNestedScrollAccepted(child: View, target: View, axes: Int) {
        mNestedParent.onNestedScrollAccepted(child, target, axes)
        mNestedChild.startNestedScroll(axes and ViewCompat.SCROLL_AXIS_VERTICAL)
        mTotalUnconsumed = mSpinner
        mNestedInProgress = true
        interceptAnimatorByAction(MotionEvent.ACTION_DOWN)
    }

    override fun onNestedPreScroll(target: View, dx: Int, dy: Int, consumed: IntArray) {
        var consumedY = 0
        if (dy * mTotalUnconsumed > 0) {
            if (abs(dy) > abs(mTotalUnconsumed)) {
                consumedY = mTotalUnconsumed
                mTotalUnconsumed = 0
            } else {
                consumedY = dy
                mTotalUnconsumed -= dy
            }
            moveSpinnerInfinitely(mTotalUnconsumed.toFloat())
        } else if (dy > 0 && mFooterLocked) {
            consumedY = dy
            mTotalUnconsumed -= dy
            moveSpinnerInfinitely(mTotalUnconsumed.toFloat())
        }
        mNestedChild.dispatchNestedPreScroll(dx, dy - consumedY, consumed, null)
        consumed[1] += consumedY
    }

    override fun onNestedScroll(target: View, dxConsumed: Int, dyConsumed: Int, dxUnconsumed: Int, dyUnconsumed: Int) {
        val scrolled = mNestedChild.dispatchNestedScroll(dxConsumed, dyConsumed, dxUnconsumed, dyUnconsumed, mParentOffsetInWindow)
        val dy = dyUnconsumed + mParentOffsetInWindow[1]
        val decider = mScrollBoundaryDecider
        val contentView = mRefreshContent?.view
        if ((dy < 0 && (mEnableRefresh || mEnableOverScrollDrag) && (mTotalUnconsumed != 0 || decider == null || (contentView != null && decider.canRefresh(contentView)))) ||
            (dy > 0 && (mEnableLoadMore || mEnableOverScrollDrag) && (mTotalUnconsumed != 0 || decider == null || (contentView != null && decider.canLoadMore(contentView))))
        ) {
            if (mViceState == RefreshState.None || mViceState.isOpening) {
                mKernel.setState(if (dy > 0) RefreshState.PullUpToLoad else RefreshState.PullDownToRefresh)
                if (!scrolled) parent?.requestDisallowInterceptTouchEvent(true)
            }
            mTotalUnconsumed -= dy
            moveSpinnerInfinitely(mTotalUnconsumed.toFloat())
        }
        if (mFooterLocked && dyConsumed < 0) mFooterLocked = false
    }

    override fun onNestedPreFling(target: View, velocityX: Float, velocityY: Float): Boolean =
        (mFooterLocked && velocityY > 0) || startFlingIfNeed(-velocityY) || mNestedChild.dispatchNestedPreFling(velocityX, velocityY)

    override fun onNestedFling(target: View, velocityX: Float, velocityY: Float, consumed: Boolean): Boolean =
        mNestedChild.dispatchNestedFling(velocityX, velocityY, consumed)

    override fun onStopNestedScroll(target: View) {
        mNestedParent.onStopNestedScroll(target)
        mNestedInProgress = false
        mTotalUnconsumed = 0
        overSpinner()
        mNestedChild.stopNestedScroll()
    }

    // View's constructor may call these before the fields exist.
    @Suppress("UNNECESSARY_SAFE_CALL", "USELESS_CAST")
    override fun setNestedScrollingEnabled(enabled: Boolean) {
        mEnableNestedScrolling = enabled
        (mNestedChild as NestedScrollingChildHelper?)?.isNestedScrollingEnabled = enabled
    }

    override fun isNestedScrollingEnabled(): Boolean = mEnableNestedScrolling && (mEnableOverScrollDrag || mEnableRefresh || mEnableLoadMore)

    // MARK: - RefreshLayout: sizes and options

    override fun setHeaderHeight(dp: Float): RefreshLayout = setHeaderHeightPx(dp2px(dp))

    override fun setHeaderHeightPx(px: Int): RefreshLayout {
        if (px == mHeaderHeight) return this
        if (mHeaderHeightStatus.canReplaceWith(DimensionStatus.CodeExact)) {
            mHeaderHeight = px
            val header = mRefreshHeader
            if (header != null && mAttachedToWindow && mHeaderHeightStatus.notified) {
                val style = header.spinnerStyle
                if (style != SpinnerStyle.MatchLayout && !style.scale) {
                    val headerView = header.view
                    val mlp = marginsOf(headerView)
                    val widthSpec = MeasureSpec.makeMeasureSpec(headerView.measuredWidth, MeasureSpec.EXACTLY)
                    headerView.measure(widthSpec, MeasureSpec.makeMeasureSpec(max(mHeaderHeight - mlp.bottomMargin - mlp.topMargin, 0), MeasureSpec.EXACTLY))
                    val left = mlp.leftMargin
                    val top = mlp.topMargin + mHeaderInsetStart - (if (style == SpinnerStyle.Translate) mHeaderHeight else 0)
                    headerView.layout(left, top, left + headerView.measuredWidth, top + headerView.measuredHeight)
                }
                mHeaderHeightStatus = DimensionStatus.CodeExact
                header.onInitialized(mKernel, mHeaderHeight, maxDragHeight(mHeaderMaxDragRate, mHeaderHeight))
            } else {
                mHeaderHeightStatus = DimensionStatus.CodeExactUnNotify
            }
        }
        return this
    }

    override fun setFooterHeight(dp: Float): RefreshLayout = setFooterHeightPx(dp2px(dp))

    override fun setFooterHeightPx(px: Int): RefreshLayout {
        if (px == mFooterHeight) return this
        if (mFooterHeightStatus.canReplaceWith(DimensionStatus.CodeExact)) {
            mFooterHeight = px
            val footer = mRefreshFooter
            if (footer != null && mAttachedToWindow && mFooterHeightStatus.notified) {
                val style = footer.spinnerStyle
                if (style != SpinnerStyle.MatchLayout && !style.scale) {
                    val footerView = footer.view
                    val mlp = marginsOf(footerView)
                    val widthSpec = MeasureSpec.makeMeasureSpec(footerView.measuredWidth, MeasureSpec.EXACTLY)
                    footerView.measure(widthSpec, MeasureSpec.makeMeasureSpec(max(mFooterHeight - mlp.bottomMargin - mlp.topMargin, 0), MeasureSpec.EXACTLY))
                    val left = mlp.leftMargin
                    val top = mlp.topMargin + measuredHeight - mFooterInsetStart - (if (style != SpinnerStyle.Translate) mFooterHeight else 0)
                    footerView.layout(left, top, left + footerView.measuredWidth, top + footerView.measuredHeight)
                }
                mFooterHeightStatus = DimensionStatus.CodeExact
                footer.onInitialized(mKernel, mFooterHeight, maxDragHeight(mFooterMaxDragRate, mFooterHeight))
            } else {
                mFooterHeightStatus = DimensionStatus.CodeExactUnNotify
            }
        }
        return this
    }

    override fun setHeaderInsetStart(dp: Float): RefreshLayout = apply { mHeaderInsetStart = dp2px(dp) }

    override fun setHeaderInsetStartPx(px: Int): RefreshLayout = apply { mHeaderInsetStart = px }

    override fun setFooterInsetStart(dp: Float): RefreshLayout = apply { mFooterInsetStart = dp2px(dp) }

    override fun setFooterInsetStartPx(px: Int): RefreshLayout = apply { mFooterInsetStart = px }

    override fun setDragRate(rate: Float): RefreshLayout = apply { mDragRate = rate }

    override fun setHeaderMaxDragRate(rate: Float): RefreshLayout {
        mHeaderMaxDragRate = rate
        val header = mRefreshHeader
        if (header != null && mAttachedToWindow) {
            header.onInitialized(mKernel, mHeaderHeight, maxDragHeight(mHeaderMaxDragRate, mHeaderHeight))
        } else {
            mHeaderHeightStatus = mHeaderHeightStatus.unNotify()
        }
        return this
    }

    override fun setFooterMaxDragRate(rate: Float): RefreshLayout {
        mFooterMaxDragRate = rate
        val footer = mRefreshFooter
        if (footer != null && mAttachedToWindow) {
            footer.onInitialized(mKernel, mFooterHeight, maxDragHeight(mFooterMaxDragRate, mFooterHeight))
        } else {
            mFooterHeightStatus = mFooterHeightStatus.unNotify()
        }
        return this
    }

    override fun setHeaderTriggerRate(rate: Float): RefreshLayout = apply { mHeaderTriggerRate = rate }

    override fun setFooterTriggerRate(rate: Float): RefreshLayout = apply { mFooterTriggerRate = rate }

    override fun setReboundInterpolator(interpolator: Interpolator): RefreshLayout = apply { mReboundInterpolator = interpolator }

    override fun setReboundDuration(duration: Int): RefreshLayout = apply { mReboundDuration = duration }

    override fun setEnableLoadMore(enabled: Boolean): RefreshLayout = apply {
        mManualLoadMore = true
        mEnableLoadMore = enabled
    }

    override fun setEnableRefresh(enabled: Boolean): RefreshLayout = apply { mEnableRefresh = enabled }

    override fun setEnableHeaderTranslationContent(enabled: Boolean): RefreshLayout = apply {
        mEnableHeaderTranslationContent = enabled
        mManualHeaderTranslationContent = true
    }

    override fun setEnableFooterTranslationContent(enabled: Boolean): RefreshLayout = apply {
        mEnableFooterTranslationContent = enabled
        mManualFooterTranslationContent = true
    }

    override fun setEnableAutoLoadMore(enabled: Boolean): RefreshLayout = apply { mEnableAutoLoadMore = enabled }

    override fun setEnableOverScrollBounce(enabled: Boolean): RefreshLayout = apply { mEnableOverScrollBounce = enabled }

    override fun setEnablePureScrollMode(enabled: Boolean): RefreshLayout {
        mEnablePureScrollMode = enabled
        // Pure scroll mode pulls both ways: on, it allows the pull up as the XML attribute does (issue #1109); off, it
        // takes back only what it allowed itself (issue #1199).
        if (enabled && !mManualLoadMore && !mEnableLoadMore) {
            mEnableLoadMore = true
            mLoadMoreByPureScrollMode = true
        } else if (!enabled && mLoadMoreByPureScrollMode) {
            mEnableLoadMore = false
            mLoadMoreByPureScrollMode = false
        }
        return this
    }

    override fun setEnableScrollContentWhenLoaded(enabled: Boolean): RefreshLayout = apply { mEnableScrollContentWhenLoaded = enabled }

    override fun setEnableScrollContentWhenRefreshed(enabled: Boolean): RefreshLayout = apply { mEnableScrollContentWhenRefreshed = enabled }

    override fun setEnableLoadMoreWhenContentNotFull(enabled: Boolean): RefreshLayout = apply {
        mEnableLoadMoreWhenContentNotFull = enabled
        mRefreshContent?.setEnableLoadMoreWhenContentNotFull(isLoadMoreWhenContentNotFull())
    }

    /**
     * Whether a content shorter than the layout can pull up the footer: also when the "no more data" footer follows
     * the content, so a footer just below the screen can still be seen (issue #1427).
     */
    protected open fun isLoadMoreWhenContentNotFull(): Boolean =
        mEnableLoadMoreWhenContentNotFull || (mFooterNoMoreData && mEnableFooterFollowWhenNoMoreData)

    override fun setEnableOverScrollDrag(enabled: Boolean): RefreshLayout = apply { mEnableOverScrollDrag = enabled }

    override fun setEnableFooterFollowWhenNoMoreData(enabled: Boolean): RefreshLayout = apply {
        mEnableFooterFollowWhenNoMoreData = enabled
        mRefreshContent?.setEnableLoadMoreWhenContentNotFull(isLoadMoreWhenContentNotFull())
    }

    override fun setEnableClipHeaderWhenFixedBehind(enabled: Boolean): RefreshLayout = apply { mEnableClipHeaderWhenFixedBehind = enabled }

    override fun setEnableClipFooterWhenFixedBehind(enabled: Boolean): RefreshLayout = apply { mEnableClipFooterWhenFixedBehind = enabled }

    override fun setEnableNestedScroll(enabled: Boolean): RefreshLayout = apply { isNestedScrollingEnabled = enabled }

    override fun setFixedHeaderViewId(id: Int): RefreshLayout = apply { mFixedHeaderViewId = id }

    override fun setFixedFooterViewId(id: Int): RefreshLayout = apply { mFixedFooterViewId = id }

    override fun setHeaderTranslationViewId(id: Int): RefreshLayout = apply { mHeaderTranslationViewId = id }

    override fun setFooterTranslationViewId(id: Int): RefreshLayout = apply { mFooterTranslationViewId = id }

    override fun setDisableContentWhenRefresh(disable: Boolean): RefreshLayout = apply { mDisableContentWhenRefresh = disable }

    override fun setDisableContentWhenLoading(disable: Boolean): RefreshLayout = apply { mDisableContentWhenLoading = disable }

    // MARK: - RefreshLayout: components

    override fun setRefreshHeader(header: RefreshHeader): RefreshLayout = setRefreshHeader(header, 0, 0)

    override fun setRefreshHeader(header: RefreshHeader, width: Int, height: Int): RefreshLayout {
        mRefreshHeader?.let { super.removeView(it.view) }
        mRefreshHeader = header
        mHeaderBackgroundColor = 0
        // Pull request #1095 (#1075, #1396): a default a previous header asked for does not stay for the next header.
        if (mComponentHeaderTranslationContent) {
            mComponentHeaderTranslationContent = false
            mManualHeaderTranslationContent = false
            mEnableHeaderTranslationContent = true
        }
        mHeaderNeedTouchEventWhenRefreshing = false
        // 2020-5-23: a header switched in measures its new height.
        mHeaderHeightStatus = DimensionStatus.DefaultUnNotify
        val lp = header.view.layoutParams as? LayoutParams
            ?: LayoutParams(if (width == 0) ViewGroup.LayoutParams.MATCH_PARENT else width, if (height == 0) ViewGroup.LayoutParams.WRAP_CONTENT else height)
        if (header.spinnerStyle.front) super.addView(header.view, childCount, lp) else super.addView(header.view, 0, lp)
        mPrimaryColors?.let { header.setPrimaryColors(*it) }
        return this
    }

    override fun setRefreshFooter(footer: RefreshFooter): RefreshLayout = setRefreshFooter(footer, 0, 0)

    override fun setRefreshFooter(footer: RefreshFooter, width: Int, height: Int): RefreshLayout {
        mRefreshFooter?.let { super.removeView(it.view) }
        mRefreshFooter = footer
        mFooterLocked = false
        mFooterBackgroundColor = 0
        mFooterNoMoreDataEffective = false
        mFooterNeedTouchEventWhenLoading = false
        mFooterHeightStatus = DimensionStatus.DefaultUnNotify
        mEnableLoadMore = !mManualLoadMore || mEnableLoadMore
        val lp = footer.view.layoutParams as? LayoutParams
            ?: LayoutParams(if (width == 0) ViewGroup.LayoutParams.MATCH_PARENT else width, if (height == 0) ViewGroup.LayoutParams.WRAP_CONTENT else height)
        if (footer.spinnerStyle.front) super.addView(footer.view, childCount, lp) else super.addView(footer.view, 0, lp)
        mPrimaryColors?.let { footer.setPrimaryColors(*it) }
        return this
    }

    override fun setRefreshContent(content: View): RefreshLayout = setRefreshContent(content, 0, 0)

    override fun setRefreshContent(content: View, width: Int, height: Int): RefreshLayout {
        mRefreshContent?.let { super.removeView(it.view) }
        val lp = content.layoutParams as? LayoutParams
            ?: LayoutParams(if (width == 0) ViewGroup.LayoutParams.MATCH_PARENT else width, if (height == 0) ViewGroup.LayoutParams.MATCH_PARENT else height)
        super.addView(content, childCount, lp)
        val wrapper = RefreshContentWrapper(content)
        mRefreshContent = wrapper
        if (mAttachedToWindow) {
            val fixedHeaderView = findViewById<View>(mFixedHeaderViewId)
            val fixedFooterView = findViewById<View>(mFixedFooterViewId)
            wrapper.setScrollBoundaryDecider(mScrollBoundaryDecider)
            wrapper.setEnableLoadMoreWhenContentNotFull(isLoadMoreWhenContentNotFull())
            wrapper.setUpComponent(mKernel, fixedHeaderView, fixedFooterView)
        }
        mRefreshHeader?.takeIf { it.spinnerStyle.front }?.let { super.bringChildToFront(it.view) }
        mRefreshFooter?.takeIf { it.spinnerStyle.front }?.let { super.bringChildToFront(it.view) }
        return this
    }

    override val refreshFooter: RefreshFooter?
        get() = mRefreshFooter as? RefreshFooter

    override val refreshHeader: RefreshHeader?
        get() = mRefreshHeader as? RefreshHeader

    override val state: RefreshState
        get() = mState

    override val layout: ViewGroup
        get() = this

    override fun setOnRefreshListener(listener: OnRefreshListener?): RefreshLayout = apply { mRefreshListener = listener }

    override fun setOnLoadMoreListener(listener: OnLoadMoreListener?): RefreshLayout = apply {
        mLoadMoreListener = listener
        mEnableLoadMore = mEnableLoadMore || (!mManualLoadMore && listener != null)
    }

    override fun setOnRefreshLoadMoreListener(listener: OnRefreshLoadMoreListener?): RefreshLayout = apply {
        mRefreshListener = listener
        mLoadMoreListener = listener
        mEnableLoadMore = mEnableLoadMore || (!mManualLoadMore && listener != null)
    }

    override fun setOnMultiListener(listener: OnMultiListener?): RefreshLayout = apply { mOnMultiListener = listener }

    override fun setPrimaryColors(@ColorInt vararg primaryColors: Int): RefreshLayout {
        mRefreshHeader?.setPrimaryColors(*primaryColors)
        mRefreshFooter?.setPrimaryColors(*primaryColors)
        mPrimaryColors = primaryColors
        return this
    }

    override fun setPrimaryColorsId(@ColorRes vararg primaryColorId: Int): RefreshLayout =
        setPrimaryColors(*IntArray(primaryColorId.size) { ContextCompat.getColor(context, primaryColorId[it]) })

    override fun setScrollBoundaryDecider(boundary: ScrollBoundaryDecider?): RefreshLayout = apply {
        mScrollBoundaryDecider = boundary
        mRefreshContent?.setScrollBoundaryDecider(boundary)
    }

    override fun setNoMoreData(noMoreData: Boolean): RefreshLayout {
        if (mState == RefreshState.Refreshing && noMoreData) {
            finishRefreshWithNoMoreData()
        } else if (mState == RefreshState.Loading && noMoreData) {
            finishLoadMoreWithNoMoreData()
        } else if (mFooterNoMoreData != noMoreData) {
            mFooterNoMoreData = noMoreData
            mRefreshContent?.setEnableLoadMoreWhenContentNotFull(isLoadMoreWhenContentNotFull())
            val footer = mRefreshFooter
            if (footer is RefreshFooter) {
                if (footer.setNoMoreData(noMoreData)) {
                    mFooterNoMoreDataEffective = true
                    if (mFooterNoMoreData && mEnableFooterFollowWhenNoMoreData && mSpinner > 0 &&
                        footer.spinnerStyle == SpinnerStyle.Translate && isEnableRefreshOrLoadMore(mEnableLoadMore) &&
                        isEnableTranslationContent(mEnableRefresh, mRefreshHeader)
                    ) {
                        footer.view.translationY = mSpinner.toFloat()
                    }
                } else {
                    mFooterNoMoreDataEffective = false
                    RuntimeException("Footer:$footer NoMoreData is not supported.(不支持NoMoreData，请使用[ClassicsFooter]或者[自定义Footer并实现setNoMoreData方法且返回true])").printStackTrace()
                }
            }
        }
        return this
    }

    override fun resetNoMoreData(): RefreshLayout = setNoMoreData(false)

    // MARK: - RefreshLayout: finishing

    private fun finishDelay(): Int = min(max(0, 300 - (System.currentTimeMillis() - mLastOpenTime).toInt()), 300) shl 16

    override fun finishRefresh(): RefreshLayout = finishRefresh(true)

    override fun finishLoadMore(): RefreshLayout = finishLoadMore(true)

    override fun finishRefresh(delayed: Int): RefreshLayout = finishRefresh(delayed, true, false)

    override fun finishRefresh(success: Boolean): RefreshLayout =
        if (success) finishRefresh(finishDelay(), true, false) else finishRefresh(0, false, null)

    override fun finishRefresh(delayed: Int, success: Boolean, noMoreData: Boolean?): RefreshLayout {
        // The upper 16 bits: the animation's remaining delay; the lower 16 bits: the caller's delay.
        val more = delayed shr 16
        val delay = delayed shl 16 shr 16
        val runnable = object : Runnable {
            var count = 0
            override fun run() {
                if (count == 0) {
                    val animator = reboundAnimator
                    if (mState == RefreshState.None && mViceState == RefreshState.Refreshing) {
                        // autoRefresh is about to run but has not started.
                        mViceState = RefreshState.None
                    } else if (animator != null && mState.isHeader && (mState.isDragging || mState == RefreshState.RefreshReleased)) {
                        // autoRefresh is running (2020-3-15, #1019; 2020-1-4, #1104).
                        animator.duration = 0
                        animator.cancel()
                        reboundAnimator = null
                        if (mKernel.animSpinner(0) == null) notifyStateChanged(RefreshState.None)
                        else notifyStateChanged(RefreshState.PullDownCanceled)
                    } else if (mState == RefreshState.Refreshing) {
                        count++
                        mHandler.postDelayed(this, more.toLong())
                        // Finished now, so a caller checking the state after finishRefresh sees it.
                        notifyStateChanged(RefreshState.RefreshFinish)
                        if (noMoreData == false) setNoMoreData(false)
                    }
                    if (noMoreData == true) setNoMoreData(true)
                } else {
                    var startDelay = 0
                    val header = mRefreshHeader
                    if (header != null) {
                        startDelay = header.onFinish(this@SmartRefreshLayout, success)
                        if (header is RefreshHeader) mOnMultiListener?.onHeaderFinish(header, success)
                    }
                    if (startDelay < Int.MAX_VALUE) {
                        if (mIsBeingDragged || mNestedInProgress) {
                            val time = System.currentTimeMillis()
                            if (mIsBeingDragged) {
                                mTouchY = mLastTouchY
                                mTouchSpinner = 0
                                mIsBeingDragged = false
                                superDispatch(MotionEvent.obtain(time, time, MotionEvent.ACTION_DOWN, mLastTouchX, mLastTouchY + mSpinner - mTouchSlop * 2, 0))
                                superDispatch(MotionEvent.obtain(time, time, MotionEvent.ACTION_MOVE, mLastTouchX, mLastTouchY + mSpinner, 0))
                            }
                            if (mNestedInProgress) {
                                mTotalUnconsumed = 0
                                superDispatch(MotionEvent.obtain(time, time, MotionEvent.ACTION_UP, mLastTouchX, mLastTouchY, 0))
                                mNestedInProgress = false
                                mTouchSpinner = 0
                            }
                        }
                        if (mSpinner > 0) {
                            val valueAnimator = animSpinner(0, startDelay, mReboundInterpolator, mReboundDuration)
                            val updateListener = if (mEnableScrollContentWhenRefreshed) mRefreshContent?.scrollContentWhenFinished(mSpinner) else null
                            if (valueAnimator != null && updateListener != null) valueAnimator.addUpdateListener(updateListener)
                        } else if (mSpinner < 0) {
                            animSpinner(0, startDelay, mReboundInterpolator, mReboundDuration)
                        } else {
                            mKernel.moveSpinner(0, false)
                            mKernel.setState(RefreshState.None)
                        }
                    }
                }
            }
        }
        if (delay > 0) mHandler.postDelayed(runnable, delay.toLong()) else runnable.run()
        return this
    }

    private fun superDispatch(event: MotionEvent) {
        super.dispatchTouchEvent(event)
    }

    override fun finishRefreshWithNoMoreData(): RefreshLayout = finishRefresh(finishDelay(), true, true)

    override fun finishLoadMore(delayed: Int): RefreshLayout = finishLoadMore(delayed, true, false)

    override fun finishLoadMore(success: Boolean): RefreshLayout = finishLoadMore(if (success) finishDelay() else 0, success, false)

    override fun finishLoadMore(delayed: Int, success: Boolean, noMoreData: Boolean): RefreshLayout {
        val more = delayed shr 16
        val delay = delayed shl 16 shr 16
        val runnable = object : Runnable {
            var count = 0
            override fun run() {
                if (count == 0) {
                    val animator = reboundAnimator
                    if (mState == RefreshState.None && mViceState == RefreshState.Loading) {
                        // autoLoadMore is about to run but has not started.
                        mViceState = RefreshState.None
                    } else if (animator != null && (mState.isDragging || mState == RefreshState.LoadReleased) && mState.isFooter) {
                        // autoLoadMore is running (#1019, #1104).
                        animator.duration = 0
                        animator.cancel()
                        reboundAnimator = null
                        if (mKernel.animSpinner(0) == null) notifyStateChanged(RefreshState.None)
                        else notifyStateChanged(RefreshState.PullUpCanceled)
                    } else if (mState == RefreshState.Loading && mRefreshFooter != null && mRefreshContent != null) {
                        count++
                        mHandler.postDelayed(this, more.toLong())
                        notifyStateChanged(RefreshState.LoadFinish)
                        return
                    }
                    if (noMoreData) {
                        // Still Loading without a footer or content: end it first, or setNoMoreData calls
                        // finishLoadMoreWithNoMoreData again, forever (StackOverflowError, issue #1350).
                        if (mState == RefreshState.Loading) notifyStateChanged(RefreshState.None)
                        setNoMoreData(true)
                    }
                } else {
                    val footer = mRefreshFooter ?: return
                    val content = mRefreshContent ?: return
                    val startDelay = footer.onFinish(this@SmartRefreshLayout, success)
                    if (footer is RefreshFooter) mOnMultiListener?.onFooterFinish(footer, success)
                    if (startDelay < Int.MAX_VALUE) {
                        val needHoldFooter = noMoreData && mEnableFooterFollowWhenNoMoreData && mSpinner < 0 && content.canLoadMore()
                        val offset = mSpinner - (if (needHoldFooter) max(mSpinner, -mFooterHeight) else 0)
                        if (mIsBeingDragged || mNestedInProgress) {
                            val time = System.currentTimeMillis()
                            if (mIsBeingDragged) {
                                mTouchY = mLastTouchY
                                mTouchSpinner = mSpinner - offset
                                mIsBeingDragged = false
                                val offsetY = if (mEnableFooterTranslationContent) offset else 0
                                superDispatch(MotionEvent.obtain(time, time, MotionEvent.ACTION_DOWN, mLastTouchX, mLastTouchY + offsetY + mTouchSlop * 2, 0))
                                superDispatch(MotionEvent.obtain(time, time, MotionEvent.ACTION_MOVE, mLastTouchX, mLastTouchY + offsetY, 0))
                            }
                            if (mNestedInProgress) {
                                mTotalUnconsumed = 0
                                superDispatch(MotionEvent.obtain(time, time, MotionEvent.ACTION_UP, mLastTouchX, mLastTouchY, 0))
                                mNestedInProgress = false
                                mTouchSpinner = 0
                            }
                        }
                        mHandler.postDelayed({
                            var updateListener: AnimatorUpdateListener? = null
                            if (mEnableScrollContentWhenLoaded && offset < 0) {
                                updateListener = content.scrollContentWhenFinished(mSpinner)
                                updateListener?.onAnimationUpdate(ValueAnimator.ofInt(0, 0))
                            }
                            val end = {
                                mFooterLocked = false
                                if (noMoreData) setNoMoreData(true)
                                if (mState == RefreshState.LoadFinish) notifyStateChanged(RefreshState.None)
                            }
                            val listenerAdapter = object : AnimatorListenerAdapter() {
                                override fun onAnimationEnd(animation: Animator) {
                                    if (animation.duration == 0L) return
                                    end()
                                }
                            }
                            var finishAnimator: ValueAnimator? = null
                            if (mSpinner > 0) {
                                finishAnimator = mKernel.animSpinner(0)
                            } else if (updateListener != null || mSpinner == 0) {
                                reboundAnimator?.let {
                                    it.duration = 0
                                    it.cancel()
                                    reboundAnimator = null
                                }
                                mKernel.moveSpinner(0, false)
                                mKernel.setState(RefreshState.None)
                            } else if (noMoreData && mEnableFooterFollowWhenNoMoreData) {
                                if (mSpinner >= -mFooterHeight) notifyStateChanged(RefreshState.None)
                                else finishAnimator = mKernel.animSpinner(-mFooterHeight)
                            } else {
                                finishAnimator = mKernel.animSpinner(0)
                            }
                            if (finishAnimator != null) finishAnimator.addListener(listenerAdapter) else end()
                        }, if (mSpinner < 0) startDelay.toLong() else 0L)
                    }
                }
            }
        }
        if (delay > 0) mHandler.postDelayed(runnable, delay.toLong()) else runnable.run()
        return this
    }

    override fun finishLoadMoreWithNoMoreData(): RefreshLayout = finishLoadMore(finishDelay(), true, true)

    override fun closeHeaderOrFooter(): RefreshLayout {
        if (mState == RefreshState.None && (mViceState == RefreshState.Refreshing || mViceState == RefreshState.Loading)) {
            mViceState = RefreshState.None
        }
        when (mState) {
            RefreshState.Refreshing -> finishRefresh()
            RefreshState.Loading -> finishLoadMore()
            else -> if (mKernel.animSpinner(0) == null) {
                notifyStateChanged(RefreshState.None)
            } else {
                notifyStateChanged(if (mState.isHeader) RefreshState.PullDownCanceled else RefreshState.PullUpCanceled)
            }
        }
        return this
    }

    // MARK: - RefreshLayout: auto refresh

    override fun autoRefresh(): Boolean =
        autoRefresh(if (mAttachedToWindow) 0 else 400, mReboundDuration, (mHeaderMaxDragRate + mHeaderTriggerRate) / 2, false)

    override fun autoRefresh(delayed: Int): Boolean =
        autoRefresh(delayed, mReboundDuration, (mHeaderMaxDragRate + mHeaderTriggerRate) / 2, false)

    override fun autoRefreshAnimationOnly(): Boolean =
        autoRefresh(if (mAttachedToWindow) 0 else 400, mReboundDuration, (mHeaderMaxDragRate + mHeaderTriggerRate) / 2, true)

    override fun autoRefresh(delayed: Int, duration: Int, dragRate: Float, animationOnly: Boolean): Boolean {
        if (mState != RefreshState.None || !isEnableRefreshOrLoadMore(mEnableRefresh)) return false
        val runnable = Runnable {
            if (mViceState != RefreshState.Refreshing) return@Runnable
            reboundAnimator?.let {
                it.duration = 0
                it.cancel()
                reboundAnimator = null
            }
            mLastTouchX = measuredWidth / 2f
            mKernel.setState(RefreshState.PullDownToRefresh)
            // 2022-11-03: a header can open itself for an auto refresh.
            if (mRefreshHeader?.autoOpen(duration, dragRate, animationOnly) == true) return@Runnable
            val height = if (mHeaderHeight == 0) mHeaderTriggerRate else mHeaderHeight.toFloat()
            val dragHeight = if (dragRate < 10) height * dragRate else dragRate
            val animator = ValueAnimator.ofInt(mSpinner, dragHeight.toInt())
            reboundAnimator = animator
            mAutoOpenAnimator = animator
            animator.duration = duration.toLong()
            animator.interpolator = SmartUtil(SmartUtil.INTERPOLATOR_VISCOUS_FLUID)
            animator.addUpdateListener { if (reboundAnimator != null) mKernel.moveSpinner(it.animatedValue as Int, true) }
            animator.addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    mKernel.onAutoRefreshAnimationEnd(animation, animationOnly)
                }
            })
            animator.start()
        }
        setViceState(RefreshState.Refreshing)
        // Pull request #1095: tells the header this refresh is an auto refresh, not a drag (#1268).
        mRefreshHeader?.onAutoRefresh(true)
        if (delayed > 0) mHandler.postDelayed(runnable, delayed.toLong()) else runnable.run()
        return true
    }

    override fun autoLoadMore(): Boolean = autoLoadMore(0, mReboundDuration, (mFooterMaxDragRate + mFooterTriggerRate) / 2, false)

    override fun autoLoadMore(delayed: Int): Boolean = autoLoadMore(delayed, mReboundDuration, (mFooterMaxDragRate + mFooterTriggerRate) / 2, false)

    override fun autoLoadMoreAnimationOnly(): Boolean = autoLoadMore(0, mReboundDuration, (mFooterMaxDragRate + mFooterTriggerRate) / 2, true)

    override fun autoLoadMore(delayed: Int, duration: Int, dragRate: Float, animationOnly: Boolean): Boolean {
        if (mState != RefreshState.None || !isEnableRefreshOrLoadMore(mEnableLoadMore) || mFooterNoMoreData) return false
        val runnable = Runnable {
            if (mViceState != RefreshState.Loading) return@Runnable
            reboundAnimator?.let {
                it.duration = 0
                it.cancel()
                reboundAnimator = null
            }
            mLastTouchX = measuredWidth / 2f
            mKernel.setState(RefreshState.PullUpToLoad)
            if (mRefreshFooter?.autoOpen(duration, dragRate, animationOnly) == true) return@Runnable
            val height = if (mFooterHeight == 0) mFooterTriggerRate else mFooterHeight.toFloat()
            val dragHeight = if (dragRate < 10) dragRate * height else dragRate
            val animator = ValueAnimator.ofInt(mSpinner, -dragHeight.toInt())
            reboundAnimator = animator
            mAutoOpenAnimator = animator
            animator.duration = duration.toLong()
            animator.interpolator = SmartUtil(SmartUtil.INTERPOLATOR_VISCOUS_FLUID)
            animator.addUpdateListener { if (reboundAnimator != null && mRefreshFooter != null) mKernel.moveSpinner(it.animatedValue as Int, true) }
            animator.addListener(object : AnimatorListenerAdapter() {
                override fun onAnimationEnd(animation: Animator) {
                    mKernel.onAutoLoadMoreAnimationEnd(animation, animationOnly)
                }
            })
            animator.start()
        }
        setViceState(RefreshState.Loading)
        mRefreshFooter?.onAutoRefresh(true)
        if (delayed > 0) mHandler.postDelayed(runnable, delayed.toLong()) else runnable.run()
        return true
    }

    override val isRefreshing: Boolean
        get() = mState == RefreshState.Refreshing

    override val isLoading: Boolean
        get() = mState == RefreshState.Loading

    // MARK: - Kernel

    /**
     * The layout's [RefreshKernel], given to its header and footer.
     */
    open inner class RefreshKernelImpl : RefreshKernel {
        override val refreshLayout: RefreshLayout
            get() = this@SmartRefreshLayout

        override val refreshContent: RefreshContent
            get() = mRefreshContent!!

        override fun setState(state: RefreshState): RefreshKernel? {
            when (state) {
                RefreshState.None -> {
                    if (mState != RefreshState.None && mSpinner == 0) notifyStateChanged(RefreshState.None)
                    else if (mSpinner != 0) animSpinner(0)
                }
                RefreshState.PullDownToRefresh, RefreshState.PullDownCanceled, RefreshState.ReleaseToRefresh,
                RefreshState.ReleaseToTwoLevel, RefreshState.RefreshReleased -> {
                    if (!mState.isOpening && isEnableRefreshOrLoadMore(mEnableRefresh)) {
                        notifyStateChanged(state)
                        if (state == RefreshState.PullDownCanceled) setState(RefreshState.None)
                    } else {
                        setViceState(state)
                    }
                }
                RefreshState.PullUpToLoad, RefreshState.ReleaseToLoad -> {
                    if (isEnableRefreshOrLoadMore(mEnableLoadMore) && !mState.isOpening && !mState.isFinishing &&
                        !(mFooterNoMoreData && mEnableFooterFollowWhenNoMoreData && mFooterNoMoreDataEffective)
                    ) {
                        notifyStateChanged(state)
                    } else {
                        setViceState(state)
                    }
                }
                RefreshState.PullUpCanceled -> {
                    if (isEnableRefreshOrLoadMore(mEnableLoadMore) && !mState.isOpening &&
                        !(mFooterNoMoreData && mEnableFooterFollowWhenNoMoreData && mFooterNoMoreDataEffective)
                    ) {
                        notifyStateChanged(RefreshState.PullUpCanceled)
                        setState(RefreshState.None)
                    } else {
                        setViceState(RefreshState.PullUpCanceled)
                    }
                }
                RefreshState.LoadReleased -> {
                    if (!mState.isOpening && isEnableRefreshOrLoadMore(mEnableLoadMore)) notifyStateChanged(RefreshState.LoadReleased)
                    else setViceState(RefreshState.LoadReleased)
                }
                RefreshState.Refreshing -> setStateRefreshing(true)
                RefreshState.Loading -> setStateLoading(true)
                else -> notifyStateChanged(state)
            }
            return null
        }

        override fun startTwoLevel(open: Boolean): RefreshKernel {
            if (open) {
                val toTwoLevel = { mKernel.setState(RefreshState.TwoLevel) }
                val animator = animSpinner(measuredHeight)
                if (animator != null && animator === reboundAnimator) {
                    animator.duration = mFloorDuration.toLong()
                    animator.addListener(object : AnimatorListenerAdapter() {
                        override fun onAnimationEnd(animation: Animator) {
                            if (animation.duration == 0L) return
                            toTwoLevel()
                        }
                    })
                } else {
                    toTwoLevel()
                }
            } else if (animSpinner(0) == null) {
                notifyStateChanged(RefreshState.None)
            }
            return this
        }

        override fun finishTwoLevel(): RefreshKernel {
            if (mState == RefreshState.TwoLevel) {
                mKernel.setState(RefreshState.TwoLevelFinish)
                if (mSpinner == 0) {
                    moveSpinner(0, false)
                    notifyStateChanged(RefreshState.None)
                } else {
                    animSpinner(0)?.duration = mFloorDuration.toLong()
                }
            }
            return this
        }

        override fun moveSpinner(spinner: Int, isDragging: Boolean): RefreshKernel {
            val header = mRefreshHeader
            val footer = mRefreshFooter
            if (mSpinner == spinner && (header == null || !header.isSupportHorizontalDrag) && (footer == null || !footer.isSupportHorizontalDrag)) {
                return this
            }
            val oldSpinner = mSpinner
            mSpinner = spinner
            if (isDragging && (mViceState.isDragging || mViceState.isOpening)) {
                if (mSpinner > triggerHeight(mHeaderTriggerRate, mHeaderHeight)) {
                    if (mState != RefreshState.ReleaseToTwoLevel) mKernel.setState(RefreshState.ReleaseToRefresh)
                } else if (-mSpinner > triggerHeight(mFooterTriggerRate, mFooterHeight) && !mFooterNoMoreData) {
                    mKernel.setState(RefreshState.ReleaseToLoad)
                } else if (mSpinner < 0 && !mFooterNoMoreData) {
                    mKernel.setState(RefreshState.PullUpToLoad)
                } else if (mSpinner > 0) {
                    mKernel.setState(RefreshState.PullDownToRefresh)
                }
            }
            val content = mRefreshContent
            if (content != null) {
                var tSpinner = 0
                var changed = false
                if (spinner >= 0) {
                    if (isEnableTranslationContent(mEnableHeaderTranslationContent, header)) {
                        changed = true
                        tSpinner = spinner
                    } else if (oldSpinner < 0) {
                        changed = true
                    }
                }
                if (spinner <= 0) {
                    if (isEnableTranslationContent(mEnableFooterTranslationContent, footer)) {
                        changed = true
                        tSpinner = spinner
                    } else if (oldSpinner > 0) {
                        changed = true
                    }
                }
                if (changed) {
                    content.moveSpinner(tSpinner, mHeaderTranslationViewId, mFooterTranslationViewId)
                    if (mFooterNoMoreData && mFooterNoMoreDataEffective && mEnableFooterFollowWhenNoMoreData && footer is RefreshFooter &&
                        footer.spinnerStyle == SpinnerStyle.Translate && isEnableRefreshOrLoadMore(mEnableLoadMore)
                    ) {
                        footer.view.translationY = max(0, tSpinner).toFloat()
                    }
                    val clipHeader = (mEnableClipHeaderWhenFixedBehind && header != null && header.spinnerStyle == SpinnerStyle.FixedBehind) || mHeaderBackgroundColor != 0
                    val clipFooter = (mEnableClipFooterWhenFixedBehind && footer != null && footer.spinnerStyle == SpinnerStyle.FixedBehind) || mFooterBackgroundColor != 0
                    if ((clipHeader && (tSpinner >= 0 || oldSpinner > 0)) || (clipFooter && (tSpinner <= 0 || oldSpinner < 0))) invalidate()
                }
            }
            if ((spinner >= 0 || oldSpinner > 0) && header != null) {
                val offset = max(spinner, 0)
                val headerHeight = mHeaderHeight
                val maxDragHeight = maxDragHeight(mHeaderMaxDragRate, mHeaderHeight)
                val percent = 1f * offset / triggerHeight(mHeaderTriggerRate, mHeaderHeight)
                if (isEnableRefreshOrLoadMore(mEnableRefresh) || (mState == RefreshState.RefreshFinish && !isDragging)) {
                    if (oldSpinner != mSpinner) {
                        if (header.spinnerStyle == SpinnerStyle.Translate) {
                            header.view.translationY = mSpinner.toFloat()
                            if (mHeaderBackgroundColor != 0 && mPaint != null && !isEnableTranslationContent(mEnableHeaderTranslationContent, header)) invalidate()
                        } else if (header.spinnerStyle.scale) {
                            val headerView = header.view
                            val mlp = marginsOf(headerView)
                            val widthSpec = MeasureSpec.makeMeasureSpec(headerView.measuredWidth, MeasureSpec.EXACTLY)
                            headerView.measure(widthSpec, MeasureSpec.makeMeasureSpec(max(mSpinner - mlp.bottomMargin - mlp.topMargin, 0), MeasureSpec.EXACTLY))
                            val left = mlp.leftMargin
                            val top = mlp.topMargin + mHeaderInsetStart
                            headerView.layout(left, top, left + headerView.measuredWidth, top + headerView.measuredHeight)
                        }
                        header.onMoving(isDragging, percent, offset, headerHeight, maxDragHeight)
                    }
                    if (isDragging && header.isSupportHorizontalDrag) {
                        val offsetX = mLastTouchX.toInt()
                        val offsetMax = width
                        header.onHorizontalDrag(mLastTouchX / (if (offsetMax == 0) 1 else offsetMax), offsetX, offsetMax)
                    }
                }
                if (oldSpinner != mSpinner && header is RefreshHeader) {
                    mOnMultiListener?.onHeaderMoving(header, isDragging, percent, offset, headerHeight, maxDragHeight)
                }
            }
            if ((spinner <= 0 || oldSpinner < 0) && footer != null) {
                val offset = -min(spinner, 0)
                val footerHeight = mFooterHeight
                val maxDragHeight = maxDragHeight(mFooterMaxDragRate, mFooterHeight)
                val percent = offset * 1f / triggerHeight(mFooterTriggerRate, mFooterHeight)
                if (isEnableRefreshOrLoadMore(mEnableLoadMore) || (mState == RefreshState.LoadFinish && !isDragging)) {
                    if (oldSpinner != mSpinner) {
                        if (footer.spinnerStyle == SpinnerStyle.Translate) {
                            footer.view.translationY = mSpinner.toFloat()
                            if (mFooterBackgroundColor != 0 && mPaint != null && !isEnableTranslationContent(mEnableFooterTranslationContent, footer)) invalidate()
                        } else if (footer.spinnerStyle.scale) {
                            val footerView = footer.view
                            val mlp = marginsOf(footerView)
                            val widthSpec = MeasureSpec.makeMeasureSpec(footerView.measuredWidth, MeasureSpec.EXACTLY)
                            footerView.measure(widthSpec, MeasureSpec.makeMeasureSpec(max(-mSpinner - mlp.bottomMargin - mlp.topMargin, 0), MeasureSpec.EXACTLY))
                            val left = mlp.leftMargin
                            val bottom = mlp.topMargin + measuredHeight - mFooterInsetStart
                            footerView.layout(left, bottom - footerView.measuredHeight, left + footerView.measuredWidth, bottom)
                        }
                        footer.onMoving(isDragging, percent, offset, footerHeight, maxDragHeight)
                    }
                    if (isDragging && footer.isSupportHorizontalDrag) {
                        val offsetX = mLastTouchX.toInt()
                        val offsetMax = width
                        footer.onHorizontalDrag(mLastTouchX / (if (offsetMax == 0) 1 else offsetMax), offsetX, offsetMax)
                    }
                }
                if (oldSpinner != mSpinner && footer is RefreshFooter) {
                    mOnMultiListener?.onFooterMoving(footer, isDragging, percent, offset, footerHeight, maxDragHeight)
                }
            }
            return this
        }

        override fun animSpinner(endSpinner: Int): ValueAnimator? =
            this@SmartRefreshLayout.animSpinner(endSpinner, 0, mReboundInterpolator, mReboundDuration)

        override fun requestDrawBackgroundFor(internal: RefreshComponent, backgroundColor: Int): RefreshKernel {
            if (mPaint == null && backgroundColor != 0) mPaint = Paint()
            if (internal == mRefreshHeader) mHeaderBackgroundColor = backgroundColor
            else if (internal == mRefreshFooter) mFooterBackgroundColor = backgroundColor
            return this
        }

        override fun requestNeedTouchEventFor(internal: RefreshComponent, request: Boolean): RefreshKernel {
            if (internal == mRefreshHeader) mHeaderNeedTouchEventWhenRefreshing = request
            else if (internal == mRefreshFooter) mFooterNeedTouchEventWhenLoading = request
            return this
        }

        override fun requestDefaultTranslationContentFor(internal: RefreshComponent, translation: Boolean): RefreshKernel {
            if (internal == mRefreshHeader) {
                if (!mManualHeaderTranslationContent) {
                    mManualHeaderTranslationContent = true
                    mComponentHeaderTranslationContent = true
                    mEnableHeaderTranslationContent = translation
                }
            } else if (internal == mRefreshFooter) {
                if (!mManualFooterTranslationContent) {
                    mManualFooterTranslationContent = true
                    mEnableFooterTranslationContent = translation
                }
            }
            return this
        }

        override fun requestRemeasureHeightFor(internal: RefreshComponent): RefreshKernel {
            if (internal == mRefreshHeader) {
                if (mHeaderHeightStatus.notified) mHeaderHeightStatus = mHeaderHeightStatus.unNotify()
            } else if (internal == mRefreshFooter) {
                if (mFooterHeightStatus.notified) mFooterHeightStatus = mFooterHeightStatus.unNotify()
            }
            return this
        }

        override fun requestFloorDuration(duration: Int): RefreshKernel = apply { mFloorDuration = duration }

        override fun requestFloorBottomPullUpToCloseRate(rate: Float): RefreshKernel = apply { mTwoLevelBottomPullUpToCloseRate = rate }

        override fun onAutoRefreshAnimationEnd(animation: Animator?, animationOnly: Boolean): RefreshKernel {
            if (animation != null && animation.duration == 0L) return this
            reboundAnimator = null
            if (mState != RefreshState.ReleaseToRefresh) setState(RefreshState.ReleaseToRefresh)
            setStateRefreshing(!animationOnly)
            return this
        }

        override fun onAutoLoadMoreAnimationEnd(animation: Animator?, animationOnly: Boolean): RefreshKernel {
            if (animation != null && animation.duration == 0L) return this
            reboundAnimator = null
            if (mRefreshFooter != null) {
                if (mState != RefreshState.ReleaseToLoad) setState(RefreshState.ReleaseToLoad)
                setStateLoading(!animationOnly)
            } else {
                setState(RefreshState.None)
            }
            return this
        }
    }

    /**
     * The defaults for every layout.
     */
    companion object {
        @JvmField protected var sFooterCreator: DefaultRefreshFooterCreator? = null
        @JvmField protected var sHeaderCreator: DefaultRefreshHeaderCreator? = null
        @JvmField protected var sRefreshInitializer: DefaultRefreshInitializer? = null
        @JvmField protected var sDefaultMarginLP = MarginLayoutParams(-1, -1)

        /**
         * Sets the header every layout gets when it has none.
         */
        @JvmStatic
        fun setDefaultRefreshHeaderCreator(creator: DefaultRefreshHeaderCreator) {
            sHeaderCreator = creator
        }

        /**
         * Sets the footer every layout gets when it has none.
         */
        @JvmStatic
        fun setDefaultRefreshFooterCreator(creator: DefaultRefreshFooterCreator) {
            sFooterCreator = creator
        }

        /**
         * Sets up every new layout.
         */
        @JvmStatic
        fun setDefaultRefreshInitializer(initializer: DefaultRefreshInitializer) {
            sRefreshInitializer = initializer
        }

        /**
         * A copy of the finger event with its pointers (ids and count) moved to ([x], [y]), for the events this layout
         * sends to its children. A single-pointer event lost the pointer a child tracks (ViewPager's active pointer)
         * and crashed it with "pointerIndex out of range" (issues #532, #1227, #1319, #1496).
         */
        @JvmStatic
        protected fun obtainLike(source: MotionEvent, action: Int, x: Float, y: Float): MotionEvent {
            val event = MotionEvent.obtain(source)
            event.action = action
            event.setLocation(x, y)
            return event
        }
    }
}
