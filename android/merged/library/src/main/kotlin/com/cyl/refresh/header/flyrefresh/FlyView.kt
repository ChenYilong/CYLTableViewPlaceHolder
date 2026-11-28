// Third-party refresh code (Apache-2.0, see the package's LICENSE.refresh-third-party.txt) translated to
// Kotlin; the JVM signatures match the Java version.
package com.cyl.refresh.header.flyrefresh

import android.content.Context
import android.util.AttributeSet
import com.cyl.refresh.drawable.view.PathsView
import com.cyl.refresh.layout.util.CYLRefreshUtil

/**
 * The paper plane (`FlyView`).
 */
open class FlyView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) : PathsView(context, attrs) {

    init {
        super.parserColors(0xffffffff.toInt())
        if (!mPathsDrawable.parserPaths("M2.01,21L23,12 2.01,3 2,10l15,2 -15,2z")) {
            mPathsDrawable.declareOriginal(2, 3, 20, 18)
        }
        val side = CYLRefreshUtil.dp2px(25f)
        mPathsDrawable.setBounds(0, 0, side, side)
    }
}
