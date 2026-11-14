// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin, with the issue fixes of the Java copy (docs/Android-Port.md); the JVM signatures match the Java version.
package com.scwang.smart.refresh.header

import android.content.Context
import android.content.SharedPreferences
import android.content.res.TypedArray
import android.os.Handler
import android.os.Looper
import android.util.AttributeSet
import android.util.TypedValue
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.annotation.ColorInt
import androidx.fragment.app.FragmentActivity
import com.scwang.smart.drawable.ProgressDrawable
import com.scwang.smart.refresh.classics.ArrowDrawable
import com.scwang.smart.refresh.classics.ClassicsAbstract
import com.scwang.smart.refresh.header.classics.R
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.util.SmartUtil
import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone

/**
 * The classic header: an arrow, a spinner, a title for every state and the last update time (`ClassicsHeader`).
 */
open class ClassicsHeader @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    ClassicsAbstract<ClassicsHeader>(context, attrs, 0), RefreshHeader {

    /**
     * The preferences key of the last update time (per activity class).
     */
    @JvmField protected var KEY_LAST_UPDATE_TIME = "LAST_UPDATE_TIME"

    /**
     * The last update time, or null for a custom text.
     */
    @JvmField protected var mLastTime: Date? = null

    /**
     * The last update text.
     */
    @JvmField protected var mLastUpdateText: TextView? = null

    /**
     * The preferences holding the last update time, once read.
     */
    @JvmField protected var mShared: SharedPreferences? = null

    /**
     * The format of the last update time.
     */
    @JvmField protected var mLastUpdateFormat: DateFormat? = null

    /**
     * Shows the last update time. Default true.
     */
    @JvmField protected var mEnableLastTime = true

    /**
     * Title while pulling.
     */
    @JvmField protected var mTextPulling: String? = null

    /**
     * Title while refreshing.
     */
    @JvmField protected var mTextRefreshing: String? = null

    /**
     * Title while the footer loads.
     */
    @JvmField protected var mTextLoading: String? = null

    /**
     * Title past the trigger.
     */
    @JvmField protected var mTextRelease: String? = null

    /**
     * Title when refreshing succeeded.
     */
    @JvmField protected var mTextFinish: String? = null

    /**
     * Title when refreshing failed.
     */
    @JvmField protected var mTextFailed: String? = null

    /**
     * The last update pattern.
     */
    @JvmField protected var mTextUpdate: String? = null

    /**
     * Title past the second-floor trigger.
     */
    @JvmField protected var mTextSecondary: String? = null

    init {
        View.inflate(context, R.layout.srl_classics_header, this)
        val arrowView = findViewById<ImageView>(R.id.srl_classics_arrow)
        val updateView = findViewById<TextView>(R.id.srl_classics_update)
        val progressView = findViewById<ImageView>(R.id.srl_classics_progress)
        val titleText = findViewById<TextView>(R.id.srl_classics_title)
        mArrowView = arrowView
        mLastUpdateText = updateView
        mProgressView = progressView
        mTitleText = titleText
        setUpAccessibility()
        val ta = context.obtainStyledAttributes(attrs, R.styleable.ClassicsHeader)
        val lpArrow = arrowView.layoutParams as RelativeLayout.LayoutParams
        val lpProgress = progressView.layoutParams as RelativeLayout.LayoutParams
        (updateView.layoutParams as? ViewGroup.MarginLayoutParams)?.let {
            it.topMargin = ta.getDimensionPixelSize(R.styleable.ClassicsHeader_srlTextTimeMarginTop, SmartUtil.dp2px(0f))
        }
        lpProgress.rightMargin = ta.getDimensionPixelSize(R.styleable.ClassicsHeader_srlDrawableMarginRight, SmartUtil.dp2px(20f))
        lpArrow.rightMargin = lpProgress.rightMargin
        lpArrow.width = ta.getLayoutDimension(R.styleable.ClassicsHeader_srlDrawableArrowSize, lpArrow.width)
        lpArrow.height = ta.getLayoutDimension(R.styleable.ClassicsHeader_srlDrawableArrowSize, lpArrow.height)
        lpProgress.width = ta.getLayoutDimension(R.styleable.ClassicsHeader_srlDrawableProgressSize, lpProgress.width)
        lpProgress.height = ta.getLayoutDimension(R.styleable.ClassicsHeader_srlDrawableProgressSize, lpProgress.height)
        lpArrow.width = ta.getLayoutDimension(R.styleable.ClassicsHeader_srlDrawableSize, lpArrow.width)
        lpArrow.height = ta.getLayoutDimension(R.styleable.ClassicsHeader_srlDrawableSize, lpArrow.height)
        lpProgress.width = ta.getLayoutDimension(R.styleable.ClassicsHeader_srlDrawableSize, lpProgress.width)
        lpProgress.height = ta.getLayoutDimension(R.styleable.ClassicsHeader_srlDrawableSize, lpProgress.height)
        mFinishDuration = ta.getInt(R.styleable.ClassicsHeader_srlFinishDuration, mFinishDuration)
        mEnableLastTime = ta.getBoolean(R.styleable.ClassicsHeader_srlEnableLastTime, mEnableLastTime)
        mSpinnerStyle = SpinnerStyle.values[ta.getInt(R.styleable.ClassicsHeader_srlClassicsSpinnerStyle, mSpinnerStyle!!.ordinal)]
        if (ta.hasValue(R.styleable.ClassicsHeader_srlDrawableArrow)) {
            arrowView.setImageDrawable(ta.getDrawable(R.styleable.ClassicsHeader_srlDrawableArrow))
        } else if (arrowView.drawable == null) {
            mArrowDrawable = ArrowDrawable().apply { setColor(0xff666666.toInt()) }
            arrowView.setImageDrawable(mArrowDrawable)
        }
        if (ta.hasValue(R.styleable.ClassicsHeader_srlDrawableProgress)) {
            progressView.setImageDrawable(ta.getDrawable(R.styleable.ClassicsHeader_srlDrawableProgress))
        } else if (progressView.drawable == null) {
            mProgressDrawable = ProgressDrawable().apply { setColor(0xff666666.toInt()) }
            progressView.setImageDrawable(mProgressDrawable)
        }
        if (ta.hasValue(R.styleable.ClassicsHeader_srlTextSizeTitle)) {
            titleText.setTextSize(TypedValue.COMPLEX_UNIT_PX, ta.getDimensionPixelSize(R.styleable.ClassicsHeader_srlTextSizeTitle, SmartUtil.dp2px(16f)).toFloat())
        }
        if (ta.hasValue(R.styleable.ClassicsHeader_srlTextSizeTime)) {
            updateView.setTextSize(TypedValue.COMPLEX_UNIT_PX, ta.getDimensionPixelSize(R.styleable.ClassicsHeader_srlTextSizeTime, SmartUtil.dp2px(12f)).toFloat())
        }
        if (ta.hasValue(R.styleable.ClassicsHeader_srlPrimaryColor)) super.setPrimaryColor(ta.getColor(R.styleable.ClassicsHeader_srlPrimaryColor, 0))
        if (ta.hasValue(R.styleable.ClassicsHeader_srlAccentColor)) setAccentColor(ta.getColor(R.styleable.ClassicsHeader_srlAccentColor, 0))
        mTextPulling = text(ta, R.styleable.ClassicsHeader_srlTextPulling, REFRESH_HEADER_PULLING, R.string.srl_header_pulling)
        mTextLoading = text(ta, R.styleable.ClassicsHeader_srlTextLoading, REFRESH_HEADER_LOADING, R.string.srl_header_loading)
        mTextRelease = text(ta, R.styleable.ClassicsHeader_srlTextRelease, REFRESH_HEADER_RELEASE, R.string.srl_header_release)
        mTextFinish = text(ta, R.styleable.ClassicsHeader_srlTextFinish, REFRESH_HEADER_FINISH, R.string.srl_header_finish)
        mTextFailed = text(ta, R.styleable.ClassicsHeader_srlTextFailed, REFRESH_HEADER_FAILED, R.string.srl_header_failed)
        mTextSecondary = text(ta, R.styleable.ClassicsHeader_srlTextSecondary, REFRESH_HEADER_SECONDARY, R.string.srl_header_secondary)
        mTextRefreshing = text(ta, R.styleable.ClassicsHeader_srlTextRefreshing, REFRESH_HEADER_REFRESHING, R.string.srl_header_refreshing)
        mTextUpdate = text(ta, R.styleable.ClassicsHeader_srlTextUpdate, REFRESH_HEADER_UPDATE, R.string.srl_header_update)
        mLastUpdateFormat = safeDateFormat(mTextUpdate)
        ta.recycle()
        progressView.animate().interpolator = null
        updateView.visibility = if (mEnableLastTime) VISIBLE else GONE
        titleText.text = if (isInEditMode) mTextRefreshing else mTextPulling
        if (isInEditMode) arrowView.visibility = GONE else progressView.visibility = GONE
        loadLastUpdateTime(context)
    }

    private fun loadLastUpdateTime(context: Context) {
        // Inside fragments the time is not stored: each one shows "now".
        try {
            if (context is FragmentActivity && context.supportFragmentManager.fragments.isNotEmpty()) {
                setLastUpdateTime(Date())
                return
            }
        } catch (e: Throwable) {
            e.printStackTrace()
        }
        KEY_LAST_UPDATE_TIME += context.javaClass.name
        // The preferences are read off the main thread, so StrictMode's disk-read policy is not broken (issue #1591).
        val appContext = context.applicationContext ?: context
        val key = KEY_LAST_UPDATE_TIME
        val main = Handler(Looper.getMainLooper())
        Thread({
            val shared = appContext.getSharedPreferences("ClassicsHeader", Context.MODE_PRIVATE)
            val time = shared.getLong(key, System.currentTimeMillis())
            main.post {
                mShared = shared
                setLastUpdateTime(Date(time))
            }
        }, "ClassicsHeader-last-update").start()
    }

    // The XML attribute, else the app's static text, else the localized default.
    private fun text(ta: TypedArray, index: Int, global: String?, defaultRes: Int): String? = when {
        ta.hasValue(index) -> ta.getString(index)
        global != null -> global
        else -> context.getString(defaultRes)
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        if (success) {
            mTitleText?.text = mTextFinish
            if (mLastTime != null) setLastUpdateTime(Date())
        } else {
            mTitleText?.text = mTextFailed
        }
        return super.onFinish(refreshLayout, success)
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        val arrowView = mArrowView ?: return
        val updateView = mLastUpdateText ?: return
        when (newState) {
            RefreshState.None, RefreshState.PullDownToRefresh -> {
                if (newState == RefreshState.None) updateView.visibility = if (mEnableLastTime) VISIBLE else GONE
                mTitleText?.text = mTextPulling
                arrowView.visibility = VISIBLE
                arrowView.animate().rotation(0f)
            }
            RefreshState.Refreshing, RefreshState.RefreshReleased -> {
                mTitleText?.text = mTextRefreshing
                arrowView.visibility = GONE
            }
            RefreshState.ReleaseToRefresh -> {
                mTitleText?.text = mTextRelease
                arrowView.animate().rotation(180f)
            }
            RefreshState.ReleaseToTwoLevel -> {
                mTitleText?.text = mTextSecondary
                arrowView.animate().rotation(0f)
            }
            RefreshState.Loading -> {
                arrowView.visibility = GONE
                updateView.visibility = if (mEnableLastTime) INVISIBLE else GONE
                mTitleText?.text = mTextLoading
            }
            else -> {}
        }
    }

    /**
     * Shows [time] as the last update and stores it.
     */
    open fun setLastUpdateTime(time: Date): ClassicsHeader {
        mLastTime = time
        val format = mLastUpdateFormat ?: return this
        format.calendar = Calendar.getInstance(TimeZone.getDefault(), Locale.getDefault())
        mLastUpdateText?.text = format.format(time)
        if (!isInEditMode) mShared?.edit()?.putLong(KEY_LAST_UPDATE_TIME, time.time)?.apply()
        return this
    }

    /**
     * The format of the last update time.
     */
    open fun setTimeFormat(format: DateFormat): ClassicsHeader {
        mLastUpdateFormat = format
        mLastTime?.let { mLastUpdateText?.text = format.format(it) }
        return this
    }

    /**
     * A custom last update text instead of the time.
     */
    open fun setLastUpdateText(text: CharSequence?): ClassicsHeader {
        mLastTime = null
        mLastUpdateText?.text = text
        return this
    }

    override fun setAccentColor(@ColorInt accentColor: Int): ClassicsHeader {
        mLastUpdateText?.setTextColor(accentColor and 0x00ffffff or 0xcc000000.toInt())
        return super.setAccentColor(accentColor)
    }

    /**
     * Shows or hides the last update time.
     */
    open fun setEnableLastTime(enable: Boolean): ClassicsHeader {
        mEnableLastTime = enable
        mLastUpdateText?.visibility = if (enable) VISIBLE else GONE
        mRefreshKernel?.requestRemeasureHeightFor(this)
        return this
    }

    /**
     * The time's text size in sp.
     */
    open fun setTextSizeTime(size: Float): ClassicsHeader {
        mLastUpdateText?.textSize = size
        mRefreshKernel?.requestRemeasureHeightFor(this)
        return this
    }

    /**
     * The time's text size in [unit].
     */
    open fun setTextSizeTime(unit: Int, size: Float): ClassicsHeader {
        mLastUpdateText?.setTextSize(unit, size)
        mRefreshKernel?.requestRemeasureHeightFor(this)
        return this
    }

    /**
     * The space above the time, in dp.
     */
    open fun setTextTimeMarginTop(dp: Float): ClassicsHeader = setTextTimeMarginTopPx(SmartUtil.dp2px(dp))

    /**
     * The space above the time, in pixels.
     */
    open fun setTextTimeMarginTopPx(px: Int): ClassicsHeader {
        val view = mLastUpdateText ?: return this
        val lp = view.layoutParams as ViewGroup.MarginLayoutParams
        lp.topMargin = px
        view.layoutParams = lp
        return this
    }

    /**
     * Texts every new header uses instead of the localized defaults (null: the default).
     */
    companion object {
        /**
         * The last update text's id.
         */
        @JvmField val ID_TEXT_UPDATE = R.id.srl_classics_update

        /**
         * Title while pulling.
         */
        @JvmField var REFRESH_HEADER_PULLING: String? = null

        /**
         * Title while refreshing.
         */
        @JvmField var REFRESH_HEADER_REFRESHING: String? = null

        /**
         * Title while the footer loads.
         */
        @JvmField var REFRESH_HEADER_LOADING: String? = null

        /**
         * Title past the trigger.
         */
        @JvmField var REFRESH_HEADER_RELEASE: String? = null

        /**
         * Title when refreshing succeeded.
         */
        @JvmField var REFRESH_HEADER_FINISH: String? = null

        /**
         * Title when refreshing failed.
         */
        @JvmField var REFRESH_HEADER_FAILED: String? = null

        /**
         * The last update pattern, a SimpleDateFormat pattern.
         */
        @JvmField var REFRESH_HEADER_UPDATE: String? = null

        /**
         * Title past the second-floor trigger.
         */
        @JvmField var REFRESH_HEADER_SECONDARY: String? = null

        /**
         * A date format for the last update text; a text that is not a valid pattern (letters such as "t" without
         * quotes, from a translation or an app's string) falls back to the default instead of crashing (issues #1431,
         * #1603).
         */
        @JvmStatic
        protected fun safeDateFormat(pattern: String?): DateFormat = try {
            SimpleDateFormat(pattern, Locale.getDefault())
        } catch (e: IllegalArgumentException) {
            SimpleDateFormat("'Last Update' M-d HH:mm", Locale.getDefault())
        } catch (e: NullPointerException) {
            SimpleDateFormat("'Last Update' M-d HH:mm", Locale.getDefault())
        }
    }
}
