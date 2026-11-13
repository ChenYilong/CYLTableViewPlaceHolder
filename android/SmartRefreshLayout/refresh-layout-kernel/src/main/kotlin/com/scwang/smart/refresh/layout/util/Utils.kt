// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.layout.util

import android.content.res.Resources
import android.graphics.PointF
import android.view.View
import android.view.ViewGroup
import android.view.animation.Interpolator
import android.webkit.WebView
import android.widget.AbsListView
import android.widget.ScrollView
import androidx.coordinatorlayout.widget.CoordinatorLayout
import androidx.core.view.NestedScrollingChild
import androidx.core.view.NestedScrollingParent
import androidx.core.view.ScrollingView
import androidx.core.widget.NestedScrollView
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager.widget.ViewPager
import androidx.viewpager2.widget.ViewPager2
import com.google.android.material.appbar.AppBarLayout
import com.scwang.smart.refresh.layout.api.RefreshComponent
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.kernel.R
import com.scwang.smart.refresh.layout.listener.CoordinatorLayoutListener
import kotlin.math.exp

/**
 * Hooks a CoordinatorLayout content to its app bar (`DesignUtil`); works only when the app has the Material library.
 */
object DesignUtil {
    /**
     * When [content] is a CoordinatorLayout, nested scrolling is turned off and [listener] hears whether its app bar
     * allows refreshing (fully expanded) or loading more (fully collapsed).
     */
    @JvmStatic
    fun checkCoordinatorLayout(content: View, kernel: RefreshKernel, listener: CoordinatorLayoutListener) {
        try {
            if (content is CoordinatorLayout) {
                kernel.refreshLayout.setEnableNestedScroll(false)
                for (i in content.childCount - 1 downTo 0) {
                    val view = content.getChildAt(i)
                    if (view is AppBarLayout) {
                        view.addOnOffsetChangedListener { appBarLayout, verticalOffset ->
                            listener.onCoordinatorUpdate(verticalOffset >= 0, appBarLayout.totalScrollRange + verticalOffset <= 0)
                        }
                    }
                }
            }
        } catch (e: Throwable) {
            // The Material library may be missing at run time; then there is nothing to hook.
            e.printStackTrace()
        }
    }
}

/**
 * Helpers and the layout's interpolators (`SmartUtil`).
 */
class SmartUtil(private val type: Int) : Interpolator {

    override fun getInterpolation(input: Float): Float {
        if (type == INTERPOLATOR_DECELERATE) return 1.0f - (1.0f - input) * (1.0f - input)
        val interpolated = VISCOUS_FLUID_NORMALIZE * viscousFluid(input)
        return if (interpolated > 0) interpolated + VISCOUS_FLUID_OFFSET else interpolated
    }

    /**
     * The helpers.
     */
    companion object {
        /**
         * The viscous-fluid interpolator.
         */
        @JvmField var INTERPOLATOR_VISCOUS_FLUID = 0

        /**
         * The decelerate interpolator.
         */
        @JvmField var INTERPOLATOR_DECELERATE = 1

        private val density = Resources.getSystem().displayMetrics.density
        private const val VISCOUS_FLUID_SCALE = 8.0f
        private val VISCOUS_FLUID_NORMALIZE = 1.0f / viscousFluid(1.0f)
        private val VISCOUS_FLUID_OFFSET = 1.0f - VISCOUS_FLUID_NORMALIZE * viscousFluid(1.0f)

        private fun viscousFluid(input: Float): Float {
            var x = input * VISCOUS_FLUID_SCALE
            if (x < 1.0f) {
                x -= 1.0f - exp(-x)
            } else {
                val start = 0.36787944117f
                x = 1.0f - exp(1.0f - x)
                x = start + x * (1.0f - start)
            }
            return x
        }

        /**
         * Measures [view]'s height with its layout parameters.
         */
        @JvmStatic
        fun measureViewHeight(view: View): Int {
            val p = view.layoutParams ?: ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT)
            val childWidthSpec = ViewGroup.getChildMeasureSpec(0, 0, p.width)
            val childHeightSpec = if (p.height > 0) View.MeasureSpec.makeMeasureSpec(p.height, View.MeasureSpec.EXACTLY)
            else View.MeasureSpec.makeMeasureSpec(0, View.MeasureSpec.UNSPECIFIED)
            view.measure(childWidthSpec, childHeightSpec)
            return view.measuredHeight
        }

        /**
         * Scrolls [listView] by [y] pixels.
         */
        @JvmStatic
        fun scrollListBy(listView: AbsListView, y: Int) {
            listView.scrollListBy(y)
        }

        /**
         * True for views that scroll by themselves (lists, scroll views, web views, nested scrolling children).
         */
        @JvmStatic
        fun isScrollableView(view: View): Boolean {
            if (view is RefreshComponent) return false
            return view is AbsListView || view is ScrollView || view is ScrollingView || view is WebView || view is NestedScrollingChild
        }

        /**
         * True for views that can be the content: scrolling views, pagers, nested scrolling parents.
         */
        @JvmStatic
        fun isContentView(view: View): Boolean {
            if (view is RefreshComponent) return false
            return isScrollableView(view) || view is ViewPager || view is ViewPager2 || view is NestedScrollingParent
        }

        /**
         * Flings [scrollableView] with [velocity].
         */
        @JvmStatic
        fun fling(scrollableView: View, velocity: Int) {
            when (scrollableView) {
                is ScrollView -> scrollableView.fling(velocity)
                is AbsListView -> scrollableView.fling(velocity)
                is WebView -> scrollableView.flingScroll(0, velocity)
                is NestedScrollView -> scrollableView.fling(velocity)
                is RecyclerView -> scrollableView.fling(0, velocity)
            }
        }

        /**
         * True when [targetView] (or the child under [touch]) is at its top.
         */
        @JvmStatic
        fun canRefresh(targetView: View, touch: PointF?): Boolean {
            if (targetView.canScrollVertically(-1) && targetView.visibility == View.VISIBLE) return false
            if (targetView is ViewGroup && touch != null) {
                val point = PointF()
                for (i in targetView.childCount downTo 1) {
                    val child = targetView.getChildAt(i - 1)
                    if (isTransformedTouchPointInView(targetView, child, touch.x, touch.y, point)) {
                        val tag = child.getTag(R.id.srl_tag)
                        if ("fixed" == tag || "fixed-bottom" == tag) return false
                        touch.offset(point.x, point.y)
                        val can = canRefresh(child, touch)
                        touch.offset(-point.x, -point.y)
                        return can
                    }
                }
            }
            return true
        }

        /**
         * True when [targetView] (or the child under [touch]) is at its end; [contentFull] false also needs content
         * that scrolls.
         */
        @JvmStatic
        fun canLoadMore(targetView: View, touch: PointF?, contentFull: Boolean): Boolean {
            if (targetView.canScrollVertically(1) && targetView.visibility == View.VISIBLE) return false
            if (targetView is ViewGroup && touch != null && !isScrollableView(targetView)) {
                val point = PointF()
                for (i in targetView.childCount downTo 1) {
                    val child = targetView.getChildAt(i - 1)
                    if (isTransformedTouchPointInView(targetView, child, touch.x, touch.y, point)) {
                        val tag = child.getTag(R.id.srl_tag)
                        if ("fixed" == tag || "fixed-top" == tag) return false
                        touch.offset(point.x, point.y)
                        val can = canLoadMore(child, touch, contentFull)
                        touch.offset(-point.x, -point.y)
                        return can
                    }
                }
            }
            return contentFull || targetView.canScrollVertically(-1)
        }

        /**
         * True when ([x], [y]) in [group] is inside [child]; [outLocalPoint] gets the offset into the child.
         */
        @JvmStatic
        fun isTransformedTouchPointInView(group: View, child: View, x: Float, y: Float, outLocalPoint: PointF?): Boolean {
            if (child.visibility != View.VISIBLE) return false
            val px = x + group.scrollX - child.left
            val py = y + group.scrollY - child.top
            val isInView = px >= 0 && py >= 0 && px < child.width && py < child.height
            if (isInView && outLocalPoint != null) outLocalPoint.set(px - x, py - y)
            return isInView
        }

        /**
         * [dpValue] in pixels.
         */
        @JvmStatic
        fun dp2px(dpValue: Float): Int = (0.5f + dpValue * density).toInt()

        /**
         * [pxValue] in dp.
         */
        @JvmStatic
        fun px2dp(pxValue: Int): Float = pxValue / density
    }
}
