package com.cyl.refresh

import android.app.Activity
import android.view.View
import com.cyl.refresh.merged.R
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
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
    fun theSlotIsNeverShorterThanTheIndicatorWhileRefreshing() {
        assertEquals("held: the indicator's own height, not the whole slot", 59, CYLRefreshDrivenLayout.slotHeight(158, 12, true, 59))
        assertEquals("held and pulled past it: the pull", 300, CYLRefreshDrivenLayout.slotHeight(158, 300, true, 59))
        assertEquals("a footer held open: its height", 59, CYLRefreshDrivenLayout.slotHeight(158, 0, true, 59))
        assertEquals("not held, a small pull: the pull", 20, CYLRefreshDrivenLayout.slotHeight(158, 20, false, 59))
    }

    @Test
    fun theIndicatorIsAnchoredAtTheSlotEdgeWhateverTheLayoutHeight() {
        // The header sits `shown` pixels into the layout, so a taller layout moves down by the difference (a footer up).
        assertEquals(0, CYLRefreshDrivenLayout.anchorShift(300, 300, false))
        assertEquals(47, CYLRefreshDrivenLayout.anchorShift(59, 12, false))
        assertEquals(-47, CYLRefreshDrivenLayout.anchorShift(59, 12, true))
        assertEquals("never negative for a header", 0, CYLRefreshDrivenLayout.anchorShift(10, 20, false))
        // Behind: the indicator stays at the far edge at its own height.
        assertEquals(59, CYLRefreshDrivenLayout.behindShift(0, 59, false))
        assertEquals(-241, CYLRefreshDrivenLayout.behindShift(300, 59, false))
        assertEquals(-59, CYLRefreshDrivenLayout.behindShift(0, 59, true))
    }

    @Test
    fun theLayoutReportsTheShownPullAndTheIndicatorsOwnHeight() {
        val layout = CYLRefreshDrivenLayout(activity)
        layout.cyl_header = CYLRefreshNormalHeader(activity)
        assertEquals(0, layout.shownPull)
        layout.drive(80, true)
        assertEquals(80, layout.shownPull)
        assertTrue("the extent is the header's height", layout.indicatorExtent > 0)
        val footerLayout = CYLRefreshDrivenLayout(activity)
        footerLayout.cyl_footer = CYLRefreshBackNormalFooter(activity)
        footerLayout.drive(-50, true)
        assertEquals("a footer pull counts positive", 50, footerLayout.shownPull)
    }

    @Test
    fun aDrivenLayoutWithAnEmptyFloorOpensAndClosesItAsTheFlutterPlatformViewDoes() {
        // The Flutter platform view gives the core an empty floor view (the content is a Flutter widget) and calls these.
        val frame = android.widget.FrameLayout(activity)
        activity.setContentView(frame, android.view.ViewGroup.LayoutParams(300, 600))
        val layout = CYLRefreshDrivenLayout(activity)
        frame.addView(layout, android.widget.FrameLayout.LayoutParams(300, 600))
        val header = CYLRefreshNormalHeader(activity)
        layout.cyl_header = header
        header.secondaryView = View(activity)
        header.secondaryTriggerOffset = 40f
        header.secondaryCloseTriggerOffset = 30f
        val phases = ArrayList<CYLRefreshPhase>()
        header.addPhaseObserver { _, _, new -> phases += new }
        var opened = 0
        var closed = 0
        header.secondaryOpenedBlock = { opened++ }
        header.secondaryClosedBlock = { closed++ }
        header.openSecondary()
        assertTrue(header.secondaryOpen)
        assertTrue("the floor is announced as the secondaryOpen phase", phases.contains(CYLRefreshPhase.SecondaryOpen))
        header.openSecondary()
        assertEquals("opening an open floor is a no-op", 1, phases.count { it == CYLRefreshPhase.SecondaryOpen })
        shadowOf(android.os.Looper.getMainLooper()).idleFor(java.time.Duration.ofMillis(1500))
        assertEquals(1, opened)
        header.closeSecondary()
        shadowOf(android.os.Looper.getMainLooper()).idleFor(java.time.Duration.ofMillis(1500))
        assertFalse(header.secondaryOpen)
        assertEquals(1, closed)
        assertTrue(phases.contains(CYLRefreshPhase.SecondaryClosing))
        header.closeSecondary()
        assertEquals("closing a closed floor is a no-op", 1, closed)
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
