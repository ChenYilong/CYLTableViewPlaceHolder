// SVPullToRefresh (https://github.com/samvermette/SVPullToRefresh, MIT, Copyright (C) 2012 Sam Vermette) in Kotlin.
package com.cyl.svpulltorefresh

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Path
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView

/**
 * The view above (or below) the content that shows the pull: an arrow, a title and a subtitle per state, and a spinner
 * while loading (`SVPullToRefreshView`). Made by [SVPullToRefreshLayout.addPullToRefresh]; customize it there.
 */
class SVPullToRefreshView internal constructor(
    context: Context,
    /**
     * Above or below the content.
     */
    val position: SVPullToRefreshPosition,
) : FrameLayout(context) {

    /**
     * The current state. [SVPullToRefreshState.ALL] never is.
     */
    var state: SVPullToRefreshState = SVPullToRefreshState.STOPPED
        internal set(value) {
            if (field == value) return
            val old = field
            field = value
            updateForState()
            listener?.onStateChanged(this, old, value)
        }

    /**
     * Receives state changes and the pull progress (pull requests #159, #175, #223).
     */
    var listener: SVPullToRefreshViewListener? = null

    /**
     * The arrow's color (`arrowColor`). Default gray.
     */
    var arrowColor: Int = Color.GRAY
        set(value) { field = value; arrowView.invalidate() }

    /**
     * The color of the title and the subtitle (`textColor`). Default dark gray.
     */
    var textColor: Int = Color.DKGRAY
        set(value) {
            field = value
            titleLabel.setTextColor(value)
            subtitleLabel.setTextColor(value)
        }

    /**
     * The spinner's color (`activityIndicatorViewColor`); null keeps the theme's color.
     */
    var activityIndicatorViewColor: Int? = null
        set(value) {
            field = value
            activityIndicatorView.indeterminateDrawable?.mutate()?.setTint(value ?: Color.GRAY)
        }

    /**
     * The title (`titleLabel`).
     */
    val titleLabel = TextView(context).apply {
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
        setTypeface(typeface, android.graphics.Typeface.BOLD)
        gravity = Gravity.CENTER
        setTextColor(textColor)
    }

    /**
     * The subtitle under the title; hidden while it has no text (`subtitleLabel`).
     */
    val subtitleLabel = TextView(context).apply {
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 12f)
        gravity = Gravity.CENTER
        setTextColor(textColor)
        visibility = GONE
    }

    /**
     * The spinner shown while loading.
     */
    val activityIndicatorView = ProgressBar(context).apply {
        isIndeterminate = true
        visibility = GONE
    }

    /**
     * Replaces the drawn arrow (pull requests #107 and #190); null restores it.
     */
    var customArrowView: View? = null
        set(value) {
            field?.let { arrowContainer.removeView(it) }
            field = value
            value?.let { arrowContainer.addView(it, LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT, Gravity.CENTER)) }
            arrowView.visibility = if (value == null) VISIBLE else GONE
            updateForState()
        }

    /**
     * YES keeps a custom view at its own height, centred at the content's edge, instead of the view's height (pull
     * request #148, for custom views taller than the default 60 dp).
     */
    var customViewKeepsOwnHeight: Boolean = false

    private val titles = mutableMapOf<SVPullToRefreshState, String?>()
    private val subtitles = mutableMapOf<SVPullToRefreshState, String?>()
    private val customViews = mutableMapOf<SVPullToRefreshState, View?>()
    private val arrowView = ArrowView(context)
    private val arrowContainer = FrameLayout(context)
    private val textColumn = LinearLayout(context).apply {
        orientation = LinearLayout.VERTICAL
        gravity = Gravity.CENTER
    }
    private val defaultContent = LinearLayout(context).apply {
        orientation = LinearLayout.HORIZONTAL
        gravity = Gravity.CENTER
    }
    private var shownCustomView: View? = null

    init {
        val dp = resources.displayMetrics.density
        arrowContainer.addView(arrowView, LayoutParams((22 * dp).toInt(), (48 * dp).toInt(), Gravity.CENTER))
        arrowContainer.addView(activityIndicatorView, LayoutParams((24 * dp).toInt(), (24 * dp).toInt(), Gravity.CENTER))
        textColumn.addView(titleLabel)
        textColumn.addView(subtitleLabel)
        defaultContent.addView(arrowContainer, LinearLayout.LayoutParams((40 * dp).toInt(), LayoutParams.MATCH_PARENT))
        defaultContent.addView(textColumn, LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT).apply {
            marginStart = (8 * dp).toInt()
        })
        addView(defaultContent, LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT))
        // Accessibility: the view reads as one element whose label is the current title.
        importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_YES
        arrowView.importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        updateForState()
    }

    /**
     * Sets the title for [state] (`setTitle:forState:`); [SVPullToRefreshState.ALL] sets every state.
     */
    fun setTitle(title: String?, state: SVPullToRefreshState) {
        forStates(state) { titles[it] = title }
        updateForState()
    }

    /**
     * Sets the subtitle for [state] (`setSubtitle:forState:`); [SVPullToRefreshState.ALL] sets every state.
     */
    fun setSubtitle(subtitle: String?, state: SVPullToRefreshState) {
        forStates(state) { subtitles[it] = subtitle }
        updateForState()
    }

    /**
     * Shows [view] instead of the arrow and the texts in [state] (`setCustomView:forState:`); null removes it. A view
     * that is replaced is removed from this view (pull request #165); no placeholder is stored for empty states (#140).
     */
    fun setCustomView(view: View?, state: SVPullToRefreshState) {
        forStates(state) { customViews[it] = view }
        updateForState()
    }

    /**
     * Starts loading, as if the pull was released (`startAnimating`).
     */
    fun startAnimating() {
        layout?.startLoading(this, byUser = false)
    }

    /**
     * Ends loading and hides the view (`stopAnimating`).
     */
    fun stopAnimating() {
        layout?.stopLoading(this)
    }

    internal var layout: SVPullToRefreshLayout? = null

    internal fun reportPull(distance: Float, progress: Float) {
        // The arrow turns as the pull reaches the trigger distance.
        val turn = if (position == SVPullToRefreshPosition.TOP) 0f else 180f
        arrowView.rotation = turn + if (state == SVPullToRefreshState.TRIGGERED) 180f else 0f
        listener?.onPull(this, distance, progress)
    }

    private inline fun forStates(state: SVPullToRefreshState, block: (SVPullToRefreshState) -> Unit) {
        if (state == SVPullToRefreshState.ALL) {
            listOf(SVPullToRefreshState.STOPPED, SVPullToRefreshState.TRIGGERED, SVPullToRefreshState.LOADING).forEach(block)
        } else {
            block(state)
        }
    }

    private fun defaultTitle(state: SVPullToRefreshState): String = context.getString(
        when (state) {
            SVPullToRefreshState.TRIGGERED -> R.string.sv_release_to_refresh
            SVPullToRefreshState.LOADING -> R.string.sv_loading
            else -> if (position == SVPullToRefreshPosition.TOP) R.string.sv_pull_to_refresh else R.string.sv_pull_up_to_refresh
        }
    )

    private fun updateForState() {
        val custom = customViews[state]
        if (custom !== shownCustomView) {
            shownCustomView?.let { removeView(it) }
            shownCustomView = custom
            custom?.let {
                (it.parent as? android.view.ViewGroup)?.removeView(it)
                val height = if (customViewKeepsOwnHeight) LayoutParams.WRAP_CONTENT else LayoutParams.MATCH_PARENT
                addView(it, LayoutParams(LayoutParams.MATCH_PARENT, height, Gravity.CENTER))
            }
        }
        defaultContent.visibility = if (custom == null) VISIBLE else GONE
        val title = titles[state] ?: defaultTitle(state)
        titleLabel.text = title
        val subtitle = subtitles[state]
        subtitleLabel.text = subtitle
        subtitleLabel.visibility = if (subtitle.isNullOrEmpty()) GONE else VISIBLE
        val loading = state == SVPullToRefreshState.LOADING
        activityIndicatorView.visibility = if (loading) VISIBLE else GONE
        arrowView.visibility = if (loading || customArrowView != null) GONE else VISIBLE
        customArrowView?.visibility = if (loading) GONE else VISIBLE
        contentDescription = listOfNotNull(title, subtitle?.takeIf { it.isNotEmpty() }).joinToString(", ")
    }

    /**
     * The default arrow, drawn like SVPullToRefresh's SVPullToRefreshArrow: a shaft with a head, pointing down.
     */
    private inner class ArrowView(context: Context) : View(context) {
        private val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        private val path = Path()

        override fun onDraw(canvas: Canvas) {
            val w = width.toFloat()
            val h = height.toFloat()
            path.reset()
            // Shaft from the top to two thirds, then the head to the bottom.
            path.moveTo(w * 0.4f, 0f)
            path.lineTo(w * 0.6f, 0f)
            path.lineTo(w * 0.6f, h * 0.66f)
            path.lineTo(w, h * 0.66f)
            path.lineTo(w * 0.5f, h)
            path.lineTo(0f, h * 0.66f)
            path.lineTo(w * 0.4f, h * 0.66f)
            path.close()
            paint.color = arrowColor
            canvas.drawPath(path, paint)
        }
    }
}
