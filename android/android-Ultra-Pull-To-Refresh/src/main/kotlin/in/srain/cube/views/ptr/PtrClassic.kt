// android-Ultra-Pull-To-Refresh (https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh, MIT, Copyright (c) 2015
// liaohuqiu.net) translated to Kotlin, with the open pull requests taken in docs/Android-Port.md.
package `in`.srain.cube.views.ptr

import android.content.Context
import android.util.AttributeSet
import android.view.LayoutInflater
import android.view.View
import android.view.animation.LinearInterpolator
import android.view.animation.RotateAnimation
import android.widget.FrameLayout
import android.widget.TextView
import `in`.srain.cube.views.ptr.indicator.PtrIndicator
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * The classic header: a rotating arrow, a title and the last update time (`PtrClassicDefaultHeader`).
 */
open class PtrClassicDefaultHeader @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = 0,
) : FrameLayout(context, attrs, defStyle), PtrUIHandler {

    private var rotateAniTime = 150

    /**
     * The arrow's turn when the pull crosses the refresh offset.
     */
    protected var mFlipAnimation: RotateAnimation = RotateAnimation(0f, -180f, RotateAnimation.RELATIVE_TO_SELF, 0.5f, RotateAnimation.RELATIVE_TO_SELF, 0.5f)

    /**
     * The arrow's turn back.
     */
    protected var mReverseFlipAnimation: RotateAnimation = RotateAnimation(-180f, 0f, RotateAnimation.RELATIVE_TO_SELF, 0.5f, RotateAnimation.RELATIVE_TO_SELF, 0.5f)

    /**
     * The title.
     */
    protected val mTitleTextView: TextView

    /**
     * The arrow.
     */
    protected val mRotateView: View

    /**
     * The spinner shown while refreshing.
     */
    protected val mProgressBar: View

    /**
     * The last update time under the title.
     */
    protected val mLastUpdateTextView: TextView

    private var lastUpdateTime = -1L
    private var lastUpdateTimeKey: String? = null
    private var shouldShowLastUpdate = false
    private val lastUpdateTimeUpdater = LastUpdateTimeUpdater()

    init {
        val arr = context.obtainStyledAttributes(attrs, R.styleable.PtrClassicHeader, 0, 0)
        // Recycled once read (issue #230).
        try {
            rotateAniTime = arr.getInt(R.styleable.PtrClassicHeader_ptr_rotate_ani_time, rotateAniTime)
        } finally {
            arr.recycle()
        }
        val header = LayoutInflater.from(context).inflate(R.layout.cube_ptr_classic_default_header, this)
        mRotateView = header.findViewById(R.id.ptr_classic_header_rotate_view)
        mTitleTextView = header.findViewById(R.id.ptr_classic_header_rotate_view_header_title)
        mLastUpdateTextView = header.findViewById(R.id.ptr_classic_header_rotate_view_header_last_update)
        mProgressBar = header.findViewById(R.id.ptr_classic_header_rotate_view_progressbar)
        mProgressBar.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        // Accessibility: the header reads as one element with its title and time, announced when it changes.
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        accessibilityLiveRegion = ACCESSIBILITY_LIVE_REGION_POLITE
        buildAnimation()
        resetView()
    }

    /**
     * YES for a footer: it follows pulls up instead of pulls down.
     */
    protected open val isFooter: Boolean
        get() = false

    private fun isMine(frame: PtrFrameLayout): Boolean = frame.ptrIndicator.isHeader != isFooter

    override fun onDetachedFromWindow() {
        super.onDetachedFromWindow()
        // No timer outlives the view (issues #254, #260, #310).
        lastUpdateTimeUpdater.stop()
    }

    /**
     * Sets the arrow's turn duration in milliseconds.
     */
    fun setRotateAniTime(time: Int) {
        if (time == rotateAniTime || time == 0) return
        rotateAniTime = time
        buildAnimation()
    }

    /**
     * Stores the last update time under [key]; frames with the same key share it.
     */
    fun setLastUpdateTimeKey(key: String?) {
        if (key.isNullOrEmpty()) return
        lastUpdateTimeKey = key
    }

    /**
     * Stores the last update time under [obj]'s class name.
     */
    fun setLastUpdateTimeRelateObject(obj: Any) {
        setLastUpdateTimeKey(obj.javaClass.name)
    }

    /**
     * Shows [time] (milliseconds since 1970) as the last update instead of the stored one (issue #137); 0 or less
     * clears it.
     */
    fun setLastUpdateTime(time: Long) {
        lastUpdateTime = if (time > 0) time else -1L
        if (time > 0) shouldShowLastUpdate = true
        tryUpdateLastUpdateTime()
    }

    /**
     * Builds the arrow's turns.
     */
    protected open fun buildAnimation() {
        mFlipAnimation = RotateAnimation(0f, -180f, RotateAnimation.RELATIVE_TO_SELF, 0.5f, RotateAnimation.RELATIVE_TO_SELF, 0.5f).apply {
            interpolator = LinearInterpolator()
            duration = rotateAniTime.toLong()
            fillAfter = true
        }
        mReverseFlipAnimation = RotateAnimation(-180f, 0f, RotateAnimation.RELATIVE_TO_SELF, 0.5f, RotateAnimation.RELATIVE_TO_SELF, 0.5f).apply {
            interpolator = LinearInterpolator()
            duration = rotateAniTime.toLong()
            fillAfter = true
        }
    }

    private fun resetView() {
        hideRotateView()
        mProgressBar.visibility = INVISIBLE
    }

    private fun hideRotateView() {
        mRotateView.clearAnimation()
        mRotateView.visibility = INVISIBLE
    }

    /**
     * The title at the start of a pull.
     */
    protected open fun pullTitle(frame: PtrFrameLayout): Int =
        if (frame.isPullToRefresh) R.string.cube_ptr_pull_down_to_refresh else R.string.cube_ptr_pull_down

    /**
     * The title past the refresh offset.
     */
    protected open fun releaseTitle(): Int = R.string.cube_ptr_release_to_refresh

    /**
     * The title while refreshing.
     */
    protected open fun loadingTitle(): Int = R.string.cube_ptr_refreshing

    /**
     * The title once completed.
     */
    protected open fun completeTitle(): Int = R.string.cube_ptr_refresh_complete

    override fun onUIReset(frame: PtrFrameLayout) {
        resetView()
        lastUpdateTimeUpdater.stop()
        shouldShowLastUpdate = true
        tryUpdateLastUpdateTime()
    }

    override fun onUIRefreshPrepare(frame: PtrFrameLayout) {
        if (!isMine(frame)) return
        shouldShowLastUpdate = true
        tryUpdateLastUpdateTime()
        lastUpdateTimeUpdater.start()
        mProgressBar.visibility = INVISIBLE
        mRotateView.visibility = VISIBLE
        setTitle(pullTitle(frame))
    }

    override fun onUIRefreshBegin(frame: PtrFrameLayout) {
        if (!isMine(frame)) return
        shouldShowLastUpdate = false
        hideRotateView()
        mProgressBar.visibility = VISIBLE
        setTitle(loadingTitle())
        tryUpdateLastUpdateTime()
        lastUpdateTimeUpdater.stop()
    }

    override fun onUIRefreshComplete(frame: PtrFrameLayout) {
        if (!isMine(frame)) return
        hideRotateView()
        mProgressBar.visibility = INVISIBLE
        setTitle(completeTitle())
        lastUpdateTimeUpdater.stop()
        val key = lastUpdateTimeKey
        if (!key.isNullOrEmpty()) {
            lastUpdateTime = Date().time
            context.getSharedPreferences(KEY_SHARED_PREFERENCES, 0).edit().putLong(key, lastUpdateTime).apply()
        }
    }

    private fun setTitle(res: Int) {
        mTitleTextView.visibility = VISIBLE
        mTitleTextView.setText(res)
        updateContentDescription()
    }

    private fun updateContentDescription() {
        contentDescription = listOfNotNull(
            mTitleTextView.text?.toString(),
            mLastUpdateTextView.text?.toString()?.takeIf { mLastUpdateTextView.visibility == VISIBLE },
        ).joinToString(", ")
    }

    private fun tryUpdateLastUpdateTime() {
        val time = if (shouldShowLastUpdate || lastUpdateTimeKey == null) getLastUpdateTime() else null
        if (time.isNullOrEmpty()) {
            mLastUpdateTextView.visibility = GONE
        } else {
            mLastUpdateTextView.visibility = VISIBLE
            // Only a changed text is set, so the timer does not lay out the header every second (issue #191).
            if (mLastUpdateTextView.text?.toString() != time) mLastUpdateTextView.text = time
        }
        updateContentDescription()
    }

    private fun getLastUpdateTime(): String? {
        val key = lastUpdateTimeKey
        if (lastUpdateTime == -1L && !key.isNullOrEmpty()) {
            lastUpdateTime = context.getSharedPreferences(KEY_SHARED_PREFERENCES, 0).getLong(key, -1)
        }
        if (lastUpdateTime == -1L) return null
        val diffTime = Date().time - lastUpdateTime
        val seconds = (diffTime / 1000).toInt()
        if (diffTime < 0 || seconds <= 0) return null
        // Whole phrases with arguments, so every language can order them (issue #125).
        val ago = when {
            seconds < 60 -> context.getString(R.string.cube_ptr_seconds_ago_format, seconds)
            seconds / 60 <= 60 -> context.getString(R.string.cube_ptr_minutes_ago_format, seconds / 60)
            seconds / 3600 <= 24 -> context.getString(R.string.cube_ptr_hours_ago_format, seconds / 3600)
            else -> SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date(lastUpdateTime))
        }
        return context.getString(R.string.cube_ptr_last_update_format, ago)
    }

    override fun onUIPositionChange(frame: PtrFrameLayout, isUnderTouch: Boolean, status: Byte, ptrIndicator: PtrIndicator) {
        if (!isMine(frame)) return
        val offsetToRefresh = ptrIndicator.getOffsetToTrigger()
        val currentPos = ptrIndicator.getCurrentPosY()
        val lastPos = ptrIndicator.getLastPosY()
        if (currentPos < offsetToRefresh && lastPos >= offsetToRefresh) {
            if (isUnderTouch && status == PtrFrameLayout.PTR_STATUS_PREPARE) {
                setTitle(pullTitle(frame))
                mRotateView.clearAnimation()
                mRotateView.startAnimation(mReverseFlipAnimation)
            }
        } else if (currentPos > offsetToRefresh && lastPos <= offsetToRefresh) {
            if (isUnderTouch && status == PtrFrameLayout.PTR_STATUS_PREPARE) {
                if (!frame.isPullToRefresh) setTitle(releaseTitle())
                mRotateView.clearAnimation()
                mRotateView.startAnimation(mFlipAnimation)
            }
        }
    }

    private inner class LastUpdateTimeUpdater : Runnable {
        private var running = false

        fun start() {
            if (lastUpdateTimeKey.isNullOrEmpty()) return
            running = true
            run()
        }

        fun stop() {
            running = false
            removeCallbacks(this)
        }

        override fun run() {
            tryUpdateLastUpdateTime()
            if (running) postDelayed(this, 1000)
        }
    }

    private companion object {
        const val KEY_SHARED_PREFERENCES = "cube_ptr_classic_last_update"
    }
}

/**
 * The classic footer, pulled up to load more: the classic header with its arrow turned the other way and the load-more
 * titles (pull request #157, `PtrClassicDefaultFooter`).
 */
open class PtrClassicDefaultFooter @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = 0,
) : PtrClassicDefaultHeader(context, attrs, defStyle) {

    override val isFooter: Boolean
        get() = true

    override fun buildAnimation() {
        super.buildAnimation()
        val flip = mFlipAnimation
        mFlipAnimation = mReverseFlipAnimation
        mReverseFlipAnimation = flip
    }

    init {
        mRotateView.rotation = 180f
    }

    override fun pullTitle(frame: PtrFrameLayout): Int =
        if (frame.isPullToRefresh) R.string.cube_ptr_pull_up_to_load else R.string.cube_ptr_pull_up

    override fun releaseTitle(): Int = R.string.cube_ptr_release_to_load

    override fun loadingTitle(): Int = R.string.cube_ptr_loading_more

    override fun completeTitle(): Int = R.string.cube_ptr_load_more_complete
}

/**
 * A [PtrFrameLayout] with the classic header (`PtrClassicFrameLayout`); [addClassicFooter] adds the classic footer.
 */
open class PtrClassicFrameLayout @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyle: Int = 0,
) : PtrFrameLayout(context, attrs, defStyle) {

    /**
     * The classic header.
     */
    val header: PtrClassicDefaultHeader = PtrClassicDefaultHeader(context)

    /**
     * The classic footer, once [addClassicFooter] added it.
     */
    var footer: PtrClassicDefaultFooter? = null
        private set

    init {
        headerView = header
        addPtrUIHandler(header)
    }

    /**
     * Adds the classic footer for loading more (pull request #157); the handler must be a [PtrHandler2].
     */
    fun addClassicFooter(): PtrClassicDefaultFooter {
        footer?.let { return it }
        val view = PtrClassicDefaultFooter(context)
        footerView = view
        addPtrUIHandler(view)
        footer = view
        return view
    }

    /**
     * Stores the header's last update time under [key].
     */
    fun setLastUpdateTimeKey(key: String?) = header.setLastUpdateTimeKey(key)

    /**
     * Stores the header's last update time under [obj]'s class name.
     */
    fun setLastUpdateTimeRelateObject(obj: Any) = header.setLastUpdateTimeRelateObject(obj)

    /**
     * Shows [time] as the header's last update (issue #137).
     */
    fun setLastUpdateTime(time: Long) = header.setLastUpdateTime(time)
}
