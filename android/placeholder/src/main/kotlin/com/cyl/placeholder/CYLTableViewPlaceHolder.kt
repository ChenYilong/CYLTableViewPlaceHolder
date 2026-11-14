package com.cyl.placeholder

import android.graphics.Rect
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.core.widget.NestedScrollView
import androidx.recyclerview.widget.RecyclerView

/**
 * Makes the placeholder of an empty list, or null for none (iOS `CYLTablePlaceholderViewBlock` and
 * `CYLCollectionPlaceholderViewBlock`; on Android both a table and a collection are a RecyclerView).
 */
typealias CYLTablePlaceholderViewBlock = (RecyclerView) -> View?

/**
 * Called when the list has data again (iOS `CYLTablePlaceholderNormalBlock`).
 */
typealias CYLTablePlaceholderNormalBlock = (RecyclerView) -> Unit

/**
 * The same as [CYLTablePlaceholderViewBlock] (iOS `CYLCollectionPlaceholderViewBlock`).
 */
typealias CYLCollectionPlaceholderViewBlock = CYLTablePlaceholderViewBlock

/**
 * The same as [CYLTablePlaceholderNormalBlock] (iOS `CYLCollectionPlaceholderNormalBlock`).
 */
typealias CYLCollectionPlaceholderNormalBlock = CYLTablePlaceholderNormalBlock

/**
 * Gives an empty list its placeholder (iOS `CYLTableViewPlaceHolderDelegate`); an adapter that implements it needs no
 * block: [cyl_reloadData] asks it.
 */
interface CYLTableViewPlaceHolderDelegate {
    /**
     * The placeholder to show while the list is empty (`makePlaceHolderView`).
     */
    fun makePlaceHolderView(): View

    /**
     * Whether the empty list still scrolls, so a pull to refresh works on it (`enableScrollWhenPlaceHolderViewShowing`).
     */
    fun enableScrollWhenPlaceHolderViewShowing(): Boolean = false

    /**
     * The placeholder's frame inside the list's bounds, in pixels, or null for all of them
     * (`frameForPlaceHolderViewInTableView:`).
     */
    fun frameForPlaceHolderViewInTableView(tableView: RecyclerView): Rect? = null
}

/**
 * What a list keeps for its placeholder.
 */
private class PlaceholderState(val list: RecyclerView) : RecyclerView.AdapterDataObserver() {
    var viewBlock: CYLTablePlaceholderViewBlock? = null
    var normalBlock: CYLTablePlaceholderNormalBlock? = null
    var host: ViewGroup? = null
    var hidden = false
    var observed: RecyclerView.Adapter<*>? = null
    var listVisibility = View.VISIBLE

    override fun onChanged() = update()

    override fun onItemRangeInserted(positionStart: Int, itemCount: Int) = update()

    override fun onItemRangeRemoved(positionStart: Int, itemCount: Int) = update()

    fun observe() {
        val adapter = list.adapter
        if (adapter === observed) return
        runCatching { observed?.unregisterAdapterDataObserver(this) }
        observed = adapter
        adapter?.registerAdapterDataObserver(this)
    }

    fun update() {
        observe()
        val adapter = list.adapter
        val delegate = adapter as? CYLTableViewPlaceHolderDelegate
        val empty = adapter == null || adapter.itemCount == 0
        if (!empty || hidden || (viewBlock == null && delegate == null)) {
            if (host != null) {
                remove()
                normalBlock?.invoke(list)
            }
            return
        }
        if (host != null) return
        val placeholder = viewBlock?.invoke(list) ?: delegate?.makePlaceHolderView() ?: return
        val parent = list.parent as? ViewGroup ?: return
        (placeholder.parent as? ViewGroup)?.removeView(placeholder)
        val scrolls = delegate?.enableScrollWhenPlaceHolderViewShowing() == true
        val frame = delegate?.frameForPlaceHolderViewInTableView(list)
        val content: ViewGroup = if (scrolls) NestedScrollView(list.context).apply { isFillViewport = true } else FrameLayout(list.context)
        val inner = if (frame == null) {
            FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        } else {
            FrameLayout.LayoutParams(frame.width(), frame.height()).apply {
                leftMargin = frame.left
                topMargin = frame.top
            }
        }
        if (content is NestedScrollView) {
            content.addView(FrameLayout(list.context).apply { addView(placeholder, inner) })
        } else {
            content.addView(placeholder, inner)
        }
        // The placeholder takes the list's place: the same layout parameters, at the list's position, while the list
        // is gone.
        val params = list.layoutParams
        val copy = runCatching { params.javaClass.getConstructor(params.javaClass).newInstance(params) as ViewGroup.LayoutParams }
            .getOrElse { ViewGroup.LayoutParams(params.width, params.height) }
        listVisibility = list.visibility
        list.visibility = View.GONE
        parent.addView(content, parent.indexOfChild(list) + 1, copy)
        host = content
    }

    fun remove() {
        host?.let { (it.parent as? ViewGroup)?.removeView(it) }
        host = null
        list.visibility = listVisibility
    }
}

private fun RecyclerView.placeholderState(): PlaceholderState {
    (getTag(R.id.cyl_placeholder_state) as? PlaceholderState)?.let { return it }
    return PlaceholderState(this).also { setTag(R.id.cyl_placeholder_state, it) }
}

/**
 * Shows the view [placeholderViewBlock] makes whenever the list is empty, from now on (iOS
 * `cyl_placeholderViewBlock:`); null stops it.
 */
fun RecyclerView.cyl_placeholderViewBlock(placeholderViewBlock: CYLTablePlaceholderViewBlock?) =
    cyl_placeholderViewBlock(placeholderViewBlock, null)

/**
 * As [cyl_placeholderViewBlock], calling [backToNormalBlock] when the list has data again (iOS
 * `cyl_placeholderViewBlock:backToNormalBlock:`).
 */
fun RecyclerView.cyl_placeholderViewBlock(placeholderViewBlock: CYLTablePlaceholderViewBlock?, backToNormalBlock: CYLTablePlaceholderNormalBlock?) {
    val state = placeholderState()
    state.viewBlock = placeholderViewBlock
    state.normalBlock = backToNormalBlock
    state.update()
}

/**
 * Reloads the list and shows or removes its placeholder (iOS `cyl_reloadData`); an adapter that is a
 * [CYLTableViewPlaceHolderDelegate] gives the placeholder.
 */
@Suppress("NotifyDataSetChanged")
fun RecyclerView.cyl_reloadData() {
    val state = placeholderState()
    state.observe()
    adapter?.notifyDataSetChanged()
    state.update()
}

/**
 * Hides the placeholder even while the list is empty (iOS `UIScrollView.cyl_placeholderHidden`).
 */
var RecyclerView.cyl_placeholderHidden: Boolean
    get() = placeholderState().hidden
    set(value) {
        val state = placeholderState()
        state.hidden = value
        state.update()
    }

/**
 * The placeholder now shown for the list, or null.
 */
val RecyclerView.cyl_placeholderView: View?
    get() = (getTag(R.id.cyl_placeholder_state) as? PlaceholderState)?.host
