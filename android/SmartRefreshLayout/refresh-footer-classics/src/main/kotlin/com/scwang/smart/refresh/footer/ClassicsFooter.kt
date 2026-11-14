// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.footer

import android.content.Context
import android.content.res.TypedArray
import android.util.AttributeSet
import android.util.TypedValue
import android.view.View
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.annotation.ColorInt
import com.scwang.smart.drawable.ProgressDrawable
import com.scwang.smart.refresh.classics.ArrowDrawable
import com.scwang.smart.refresh.classics.ClassicsAbstract
import com.scwang.smart.refresh.footer.classics.R
import com.scwang.smart.refresh.layout.api.RefreshFooter
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.util.SmartUtil

/**
 * The classic footer: an arrow, a spinner and a title for every state (`ClassicsFooter`).
 */
open class ClassicsFooter @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    ClassicsAbstract<ClassicsFooter>(context, attrs, 0), RefreshFooter {

    /**
     * Title while pulling.
     */
    @JvmField protected var mTextPulling: String? = null

    /**
     * Title past the trigger.
     */
    @JvmField protected var mTextRelease: String? = null

    /**
     * Title while loading.
     */
    @JvmField protected var mTextLoading: String? = null

    /**
     * Title while the header refreshes.
     */
    @JvmField protected var mTextRefreshing: String? = null

    /**
     * Title when loading succeeded.
     */
    @JvmField protected var mTextFinish: String? = null

    /**
     * Title when loading failed.
     */
    @JvmField protected var mTextFailed: String? = null

    /**
     * Title when there is no more data.
     */
    @JvmField protected var mTextNothing: String? = null

    /**
     * True while there is no more data.
     */
    @JvmField protected var mNoMoreData = false

    init {
        View.inflate(context, R.layout.srl_classics_footer, this)
        val arrowView = findViewById<ImageView>(R.id.srl_classics_arrow)
        val progressView = findViewById<ImageView>(R.id.srl_classics_progress)
        val titleText = findViewById<TextView>(R.id.srl_classics_title)
        mArrowView = arrowView
        mProgressView = progressView
        mTitleText = titleText
        setUpAccessibility()
        val ta = context.obtainStyledAttributes(attrs, R.styleable.ClassicsFooter)
        val lpArrow = arrowView.layoutParams as RelativeLayout.LayoutParams
        val lpProgress = progressView.layoutParams as RelativeLayout.LayoutParams
        lpProgress.rightMargin = ta.getDimensionPixelSize(R.styleable.ClassicsFooter_srlDrawableMarginRight, SmartUtil.dp2px(20f))
        lpArrow.rightMargin = lpProgress.rightMargin
        lpArrow.width = ta.getLayoutDimension(R.styleable.ClassicsFooter_srlDrawableArrowSize, lpArrow.width)
        lpArrow.height = ta.getLayoutDimension(R.styleable.ClassicsFooter_srlDrawableArrowSize, lpArrow.height)
        lpProgress.width = ta.getLayoutDimension(R.styleable.ClassicsFooter_srlDrawableProgressSize, lpProgress.width)
        lpProgress.height = ta.getLayoutDimension(R.styleable.ClassicsFooter_srlDrawableProgressSize, lpProgress.height)
        lpArrow.width = ta.getLayoutDimension(R.styleable.ClassicsFooter_srlDrawableSize, lpArrow.width)
        lpArrow.height = ta.getLayoutDimension(R.styleable.ClassicsFooter_srlDrawableSize, lpArrow.height)
        lpProgress.width = ta.getLayoutDimension(R.styleable.ClassicsFooter_srlDrawableSize, lpProgress.width)
        lpProgress.height = ta.getLayoutDimension(R.styleable.ClassicsFooter_srlDrawableSize, lpProgress.height)
        mFinishDuration = ta.getInt(R.styleable.ClassicsFooter_srlFinishDuration, mFinishDuration)
        mSpinnerStyle = SpinnerStyle.values[ta.getInt(R.styleable.ClassicsFooter_srlClassicsSpinnerStyle, mSpinnerStyle!!.ordinal)]
        if (ta.hasValue(R.styleable.ClassicsFooter_srlDrawableArrow)) {
            arrowView.setImageDrawable(ta.getDrawable(R.styleable.ClassicsFooter_srlDrawableArrow))
        } else if (arrowView.drawable == null) {
            mArrowDrawable = ArrowDrawable().apply { setColor(0xff666666.toInt()) }
            arrowView.setImageDrawable(mArrowDrawable)
        }
        if (ta.hasValue(R.styleable.ClassicsFooter_srlDrawableProgress)) {
            progressView.setImageDrawable(ta.getDrawable(R.styleable.ClassicsFooter_srlDrawableProgress))
        } else if (progressView.drawable == null) {
            mProgressDrawable = ProgressDrawable().apply { setColor(0xff666666.toInt()) }
            progressView.setImageDrawable(mProgressDrawable)
        }
        if (ta.hasValue(R.styleable.ClassicsFooter_srlTextSizeTitle)) {
            titleText.setTextSize(TypedValue.COMPLEX_UNIT_PX, ta.getDimensionPixelSize(R.styleable.ClassicsFooter_srlTextSizeTitle, SmartUtil.dp2px(16f)).toFloat())
        }
        if (ta.hasValue(R.styleable.ClassicsFooter_srlPrimaryColor)) super.setPrimaryColor(ta.getColor(R.styleable.ClassicsFooter_srlPrimaryColor, 0))
        if (ta.hasValue(R.styleable.ClassicsFooter_srlAccentColor)) super.setAccentColor(ta.getColor(R.styleable.ClassicsFooter_srlAccentColor, 0))
        mTextPulling = text(ta, R.styleable.ClassicsFooter_srlTextPulling, REFRESH_FOOTER_PULLING, R.string.srl_footer_pulling)
        mTextRelease = text(ta, R.styleable.ClassicsFooter_srlTextRelease, REFRESH_FOOTER_RELEASE, R.string.srl_footer_release)
        mTextLoading = text(ta, R.styleable.ClassicsFooter_srlTextLoading, REFRESH_FOOTER_LOADING, R.string.srl_footer_loading)
        mTextRefreshing = text(ta, R.styleable.ClassicsFooter_srlTextRefreshing, REFRESH_FOOTER_REFRESHING, R.string.srl_footer_refreshing)
        mTextFinish = text(ta, R.styleable.ClassicsFooter_srlTextFinish, REFRESH_FOOTER_FINISH, R.string.srl_footer_finish)
        mTextFailed = text(ta, R.styleable.ClassicsFooter_srlTextFailed, REFRESH_FOOTER_FAILED, R.string.srl_footer_failed)
        mTextNothing = text(ta, R.styleable.ClassicsFooter_srlTextNothing, REFRESH_FOOTER_NOTHING, R.string.srl_footer_nothing)
        ta.recycle()
        progressView.animate().interpolator = null
        titleText.text = if (isInEditMode) mTextLoading else mTextPulling
        if (isInEditMode) arrowView.visibility = GONE else progressView.visibility = GONE
    }

    // The XML attribute, else the app's static text, else the localized default.
    private fun text(ta: TypedArray, index: Int, global: String?, defaultRes: Int): String? = when {
        ta.hasValue(index) -> ta.getString(index)
        global != null -> global
        else -> context.getString(defaultRes)
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        super.onFinish(refreshLayout, success)
        if (!mNoMoreData) {
            mTitleText?.text = if (success) mTextFinish else mTextFailed
            return mFinishDuration
        }
        return 0
    }

    @Deprecated("Only called by the layout; use RefreshLayout.setPrimaryColorsId.")
    override fun setPrimaryColors(@ColorInt vararg colors: Int) {
        if (mSpinnerStyle == SpinnerStyle.FixedBehind) {
            super.setPrimaryColors(*colors)
        } else if (colors.size > 1 && !mSetAccentColor) {
            // Issue #1212: the layout's accent color (srlAccentColor) is the footer's text color in every style, as it
            // is the header's; only the background stays the footer's own outside FixedBehind.
            setAccentColor(colors[1])
            mSetAccentColor = false
        }
    }

    override fun setNoMoreData(noMoreData: Boolean): Boolean {
        if (mNoMoreData != noMoreData) {
            mNoMoreData = noMoreData
            if (noMoreData) {
                mTitleText?.text = mTextNothing
                mArrowView?.visibility = GONE
            } else {
                mTitleText?.text = mTextPulling
                mArrowView?.visibility = VISIBLE
            }
        }
        return true
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        if (mNoMoreData) return
        val arrowView = mArrowView ?: return
        when (newState) {
            RefreshState.None, RefreshState.PullUpToLoad -> {
                if (newState == RefreshState.None) arrowView.visibility = VISIBLE
                mTitleText?.text = mTextPulling
                arrowView.animate().rotation(180f)
            }
            RefreshState.Loading, RefreshState.LoadReleased -> {
                arrowView.visibility = GONE
                mTitleText?.text = mTextLoading
            }
            RefreshState.ReleaseToLoad -> {
                mTitleText?.text = mTextRelease
                arrowView.animate().rotation(0f)
            }
            RefreshState.Refreshing -> {
                mTitleText?.text = mTextRefreshing
                arrowView.visibility = GONE
            }
            else -> {}
        }
    }

    /**
     * Texts every new footer uses instead of the localized defaults (null: the default).
     */
    companion object {
        /**
         * Title while pulling.
         */
        @JvmField var REFRESH_FOOTER_PULLING: String? = null

        /**
         * Title past the trigger.
         */
        @JvmField var REFRESH_FOOTER_RELEASE: String? = null

        /**
         * Title while loading.
         */
        @JvmField var REFRESH_FOOTER_LOADING: String? = null

        /**
         * Title while the header refreshes.
         */
        @JvmField var REFRESH_FOOTER_REFRESHING: String? = null

        /**
         * Title when loading succeeded.
         */
        @JvmField var REFRESH_FOOTER_FINISH: String? = null

        /**
         * Title when loading failed.
         */
        @JvmField var REFRESH_FOOTER_FAILED: String? = null

        /**
         * Title when there is no more data.
         */
        @JvmField var REFRESH_FOOTER_NOTHING: String? = null
    }
}
