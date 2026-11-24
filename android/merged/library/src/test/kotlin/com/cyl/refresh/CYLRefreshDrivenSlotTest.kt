package com.cyl.refresh

import android.app.Activity
import android.view.View
import com.cyl.refresh.merged.R
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The Flutter plugin's slot height for the driven layout and the drawn footers' "no more data" drawing.
 * Written, not run (docs/Task-Log.md, "Batch hand-off W1b: Android static items (written, not built)").
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLRefreshDrivenSlotTest {
    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    @Test
    fun theSlotHeightIsThePullOrTheWholeSlotWhileHeldAndNeverZero() {
        assertEquals("a header pull is its offset", 40, CYLRefreshDrivenLayout.slotHeight(158, 40, false))
        assertEquals("a footer pull (negative) is its size", 40, CYLRefreshDrivenLayout.slotHeight(158, -40, false))
        assertEquals("held open: the whole slot, whatever the pull", 158, CYLRefreshDrivenLayout.slotHeight(158, 12, true))
        assertEquals("a pull past the slot is the pull", 200, CYLRefreshDrivenLayout.slotHeight(158, 200, true))
        assertEquals("at rest it is 1 pixel, not 0", 1, CYLRefreshDrivenLayout.slotHeight(158, 0, false))
    }

    @Test
    fun aDrawnFooterShowsTheLocalizedNoMoreDataTextAndHidesTheStyle() {
        for (style in listOf(CYLRefreshStyle.Material, CYLRefreshStyle.BezierRadar, CYLRefreshStyle.Delivery, CYLRefreshStyle.Phoenix, CYLRefreshStyle.Taurus, CYLRefreshStyle.BezierCircle)) {
            val footer = style.newFooter(activity) as CYLRefreshDrawnFooter
            val view = footer.view as CYLDrawnFooterView
            assertEquals("${style.key}: no label before", View.GONE, view.noMoreDataLabel.visibility)
            assertTrue("${style.key}: the footer supports no more data", view.setNoMoreData(true))
            assertEquals(style.key, View.VISIBLE, view.noMoreDataLabel.visibility)
            assertEquals(style.key, activity.getString(R.string.srl_footer_nothing), view.noMoreDataLabel.text.toString())
            assertEquals("${style.key}: the style is hidden", View.INVISIBLE, footer.style.view.view.visibility)
        }
    }

    @Test
    fun clearingNoMoreDataBringsTheStyleBack() {
        val footer = CYLRefreshStyle.Phoenix.newFooter(activity) as CYLRefreshDrawnFooter
        val view = footer.view as CYLDrawnFooterView
        view.setNoMoreData(true)
        assertTrue(view.setNoMoreData(false))
        assertEquals(View.GONE, view.noMoreDataLabel.visibility)
        assertEquals(View.VISIBLE, footer.style.view.view.visibility)
    }
}
