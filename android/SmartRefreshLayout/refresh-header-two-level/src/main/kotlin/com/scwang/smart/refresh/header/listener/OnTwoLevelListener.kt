// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header.listener

import com.scwang.smart.refresh.layout.api.RefreshLayout

/**
 * Called when the second floor opens; return false to keep it closed (`OnTwoLevelListener`).
 */
fun interface OnTwoLevelListener {
    /**
     * True opens the second floor.
     */
    fun onTwoLevel(refreshLayout: RefreshLayout): Boolean
}
