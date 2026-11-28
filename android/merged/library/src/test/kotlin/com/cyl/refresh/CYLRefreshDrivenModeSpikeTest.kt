package com.cyl.refresh

import android.app.Activity
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * Spike for the Flutter "driven mode" (docs/Refresh-Library-Parity.md, step 4): can a [CYLRefreshComponent] run without a
 * CYLRefreshLayout when a host feeds it offsets and phases? Records what works and what does not.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLRefreshDrivenModeSpikeTest {
    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private fun texts(view: View): List<String> =
        if (view is TextView) listOf(view.text.toString()) else (view as? ViewGroup)?.let { g -> (0 until g.childCount).flatMap { texts(g.getChildAt(it)) } } ?: emptyList()

    @Test
    fun phaseMachineRunsWithoutALayout() {
        val header = CYLRefreshNormalHeader(activity)
        val seen = mutableListOf<CYLRefreshPhase>()
        header.addPhaseObserver { _, _, new -> seen += new }
        header.moved(40, 0.4f, true)
        header.setPhase(CYLRefreshPhase.PullToRefresh)
        header.moved(90, 1.0f, true)
        header.setPhase(CYLRefreshPhase.ReleaseToRefresh)
        header.setPhase(CYLRefreshPhase.Idle)
        assertEquals(listOf(CYLRefreshPhase.PullToRefresh, CYLRefreshPhase.ReleaseToRefresh, CYLRefreshPhase.Idle), seen)
        assertEquals(1.0f, header.pullingPercent, 0f)
    }

    @Test
    fun theDrawnTextFollowsThePhaseWithoutALayout() {
        val header = CYLRefreshNormalHeader(activity)
        val before = texts(header.view.view)
        header.setPhase(CYLRefreshPhase.ReleaseToRefresh)
        val after = texts(header.view.view)
        // The finding: the classic header's text is driven by the layout's RefreshState callbacks (they take a CYLRefreshLayout),
        // not by the component's phase, so a driven mode must also call the header's callbacks with a stand-in layout.
        assertEquals(before, after)
    }
}
