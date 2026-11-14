// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header.flyrefresh

import android.content.Context
import android.util.AttributeSet
import com.scwang.smart.drawable.view.PathsView
import com.scwang.smart.refresh.layout.util.SmartUtil

/**
 * The paper plane (`FlyView`).
 */
open class FlyView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : PathsView(context, attrs) {

    init {
        super.parserColors(0xffffffff.toInt())
        if (!mPathsDrawable.parserPaths("M2.01,21L23,12 2.01,3 2,10l15,2 -15,2z")) {
            mPathsDrawable.declareOriginal(2, 3, 20, 18)
        }
        val side = SmartUtil.dp2px(25f)
        mPathsDrawable.setBounds(0, 0, side, side)
    }
}
