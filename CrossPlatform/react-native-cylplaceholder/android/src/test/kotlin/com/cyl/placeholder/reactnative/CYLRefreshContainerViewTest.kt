package com.cyl.placeholder.reactnative

import android.app.Activity
import android.widget.ScrollView
import com.cyl.refresh.CYLRefreshPhase
import com.cyl.refresh.cyl_header
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLRefreshContainerViewTest {
    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private fun idle(ms: Long) = shadowOf(android.os.Looper.getMainLooper()).idleFor(java.time.Duration.ofMillis(ms))

    private fun container(): CYLRefreshContainerView {
        val view = CYLRefreshContainerView(activity)
        view.addView(ScrollView(activity))
        activity.setContentView(view)
        idle(100)
        return view
    }

    @Test
    fun theIosNamedHeaderIsAttached() {
        val view = container()
        assertNotNull(view.cyl_header)
    }

    @Test
    fun refreshingFromJsRunsThePhaseMachineWithoutCallingOnRefresh() {
        val view = container()
        var pulled = 0
        view.onRefresh = { pulled++ }
        view.setRefreshingFromJs(true)
        idle(100)
        assertTrue(view.cyl_header!!.isRefreshing)
        assertEquals(0, pulled)
        view.setRefreshingFromJs(false)
        idle(3000)
        assertTrue(view.cyl_header!!.phase != CYLRefreshPhase.Refreshing)
    }
}
