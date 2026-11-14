// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header

import android.view.View
import com.scwang.smart.refresh.layout.constant.RefreshState

// Accessibility shared by this module's animated headers (added in the Kotlin port; the Java headers had none): a
// polite live region that reads "Refreshing" while refreshing and "Refreshed" when done, hidden while idle.

/**
 * Makes this header a polite live region, hidden from accessibility services until it refreshes.
 */
internal fun View.initRefreshAccessibility() {
    accessibilityLiveRegion = View.ACCESSIBILITY_LIVE_REGION_POLITE
    importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
}

/**
 * Updates the description for [state]: read while refreshing and when done, hidden again when idle.
 */
internal fun View.updateRefreshAccessibility(state: RefreshState) {
    when (state) {
        RefreshState.Refreshing, RefreshState.RefreshReleased -> {
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_YES
            contentDescription = context.getString(R.string.srl_header_refreshing)
        }
        RefreshState.RefreshFinish -> contentDescription = context.getString(R.string.srl_header_refreshed)
        RefreshState.None -> importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
        else -> Unit
    }
}
