// Third-party refresh code (Apache-2.0, see the package's LICENSE.refresh-third-party.txt) translated to
// Kotlin; the JVM signatures match the Java version.
package com.cyl.refresh.header.listener

import com.cyl.refresh.layout.api.RefreshLayout

/**
 * Called when the second floor opens; return false to keep it closed (`OnTwoLevelListener`).
 */
fun interface OnTwoLevelListener {
    /**
     * True opens the second floor.
     */
    fun onTwoLevel(refreshLayout: RefreshLayout): Boolean
}
