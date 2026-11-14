package com.cyl.refresh.merged.example

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.os.Bundle
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.cyl.tabbar.CYLPlusButton
import com.cyl.tabbar.CYLPlusButtonSubclassing

/**
 * The example's plus button: a round blue button raised above the tab bar, in the middle of the tabs, with its own
 * page; its accessibility label is localized.
 */
class ExamplePlusButton(context: Context) : CYLPlusButton(context) {

    init {
        val density = resources.displayMetrics.density
        background = GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            setColor(Color.rgb(0, 122, 255))
        }
        setImageDrawable(ContextCompat.getDrawable(context, android.R.drawable.ic_input_add))
        imageView.setColorFilter(Color.WHITE)
        contentDescription = context.getString(R.string.merged_plus_button)
        minimumWidth = (56 * density).toInt()
        minimumHeight = (56 * density).toInt()
        touchableAreaScale = 1.2f
    }

    /**
     * Makes the plus button and its page for the tab bar of the example's configuration file.
     */
    object Provider : CYLPlusButtonSubclassing {
        private val page: Fragment by lazy { PlusPage() }

        override fun plusButton(context: Context) = ExamplePlusButton(context)

        // Raised: its top is above the tab bar's top.
        override fun multiplierOfTabBarHeight(tabBarHeight: Float) = 0.3f

        override fun plusChildViewController(): Fragment = page

        override fun tabBarContext() = "CYLRefreshMergedExample"
    }
}

/**
 * The plus button's own page.
 */
class PlusPage : Fragment() {

    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View =
        TextView(requireContext()).apply {
            gravity = Gravity.CENTER
            textSize = 20f
            setText(R.string.merged_plus_page)
        }
}
