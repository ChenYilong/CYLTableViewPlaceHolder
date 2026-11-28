package com.cyl.placeholder.reactnative

import android.app.Activity
import android.os.SystemClock
import android.view.MotionEvent
import android.widget.LinearLayout
import android.widget.ScrollView
import com.cyl.refresh.CYLRefreshAutoNormalFooter
import com.cyl.refresh.CYLRefreshBackFooter
import com.cyl.refresh.CYLRefreshBackNormalFooter
import com.cyl.refresh.CYLRefreshFooter
import com.cyl.refresh.CYLRefreshHeader
import com.cyl.refresh.CYLRefreshMaterialFooter
import com.cyl.refresh.CYLRefreshMaterialHeader
import com.cyl.refresh.CYLRefreshNormalHeader
import com.cyl.refresh.CYLRefreshPhase
import com.cyl.refresh.CYLRefreshRiveBuilding
import com.cyl.refresh.CYLRefreshRiveOptions
import com.cyl.refresh.CYLRefreshRiveSupport
import com.cyl.refresh.cyl_footer
import com.cyl.refresh.cyl_header
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNotSame
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import org.robolectric.shadows.ShadowLog

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

    // [EN] A finger drag on the container, as the system delivers it (down, moves, a pause, up).
    // [CN] 容器上的手指拖动，与系统派发的触摸序列一致（按下、移动、停顿、抬起）。
    private fun drag(view: CYLRefreshContainerView, dy: Float) {
        val down = SystemClock.uptimeMillis()
        var y = 100f
        view.dispatchTouchEvent(MotionEvent.obtain(down, down, MotionEvent.ACTION_DOWN, 100f, y, 0))
        repeat(20) {
            y += dy / 20
            view.dispatchTouchEvent(MotionEvent.obtain(down, down + 16L * (it + 1), MotionEvent.ACTION_MOVE, 100f, y, 0))
        }
        view.dispatchTouchEvent(MotionEvent.obtain(down, down + 700, MotionEvent.ACTION_MOVE, 100f, y, 0))
        view.dispatchTouchEvent(MotionEvent.obtain(down, down + 716, MotionEvent.ACTION_UP, 100f, y, 0))
    }

    private fun scrollingContainer(): CYLRefreshContainerView {
        val view = CYLRefreshContainerView(activity)
        view.addView(ScrollView(activity).apply {
            addView(LinearLayout(activity).apply { addView(android.view.View(activity), LinearLayout.LayoutParams(-1, 3000)) })
        })
        activity.setContentView(view)
        idle(100)
        return view
    }

    @Test
    fun aRealPullGestureReachesOnRefresh() {
        val view = scrollingContainer()
        var pulled = 0
        view.onRefresh = { pulled++ }
        drag(view, 900f)
        idle(500)
        assertEquals(1, pulled)
        assertTrue(view.cyl_header!!.isRefreshing)
        view.setRefreshingFromJs(false)
        idle(3000)
    }

    @Test
    fun aPullOnADisabledContainerDoesNotReachOnRefresh() {
        val view = scrollingContainer()
        var pulled = 0
        view.onRefresh = { pulled++ }
        view.setPullEnabled(false)
        drag(view, 900f)
        idle(500)
        assertEquals(0, pulled)
        assertFalse(view.cyl_header!!.isRefreshing)
    }

    @Test
    fun theFooterIsAttachedAndLoadMoreIsOffByDefault() {
        val view = scrollingContainer()
        assertNotNull(view.cyl_footer)
        var loaded = 0
        view.onLoadMore = { loaded++ }
        drag(view, -900f)
        idle(500)
        assertEquals(0, loaded)
        assertFalse(view.cyl_footer!!.isRefreshing)
    }

    @Test
    fun loadingMoreFromJsRunsTheFooterWithoutCallingOnLoadMore() {
        val view = scrollingContainer()
        var loaded = 0
        view.onLoadMore = { loaded++ }
        view.setLoadMoreEnabled(true)
        view.setLoadingMoreFromJs(true)
        idle(100)
        assertTrue(view.cyl_footer!!.isRefreshing)
        assertEquals(0, loaded)
        view.setLoadingMoreFromJs(false)
        idle(3000)
        assertFalse(view.cyl_footer!!.isRefreshing)
    }

    @Test
    fun noMoreDataFromJsShowsAndClearsTheFooterState() {
        val view = scrollingContainer()
        view.setLoadMoreEnabled(true)
        view.setNoMoreDataFromJs(true)
        idle(100)
        assertTrue(view.cyl_footer!!.noMoreData)
        view.setNoMoreDataFromJs(false)
        idle(100)
        assertFalse(view.cyl_footer!!.noMoreData)
    }

    @Test
    fun endingALoadWithNoMoreDataKeepsTheNoMoreDataState() {
        val view = scrollingContainer()
        view.setLoadMoreEnabled(true)
        view.setLoadingMoreFromJs(true)
        idle(100)
        view.setNoMoreDataFromJs(true)
        idle(3000)
        assertTrue(view.cyl_footer!!.noMoreData)
        assertFalse(view.cyl_footer!!.isRefreshing)
    }

    // The floor's content: a child with nativeID "cyl.refresh.secondary" (React Native stores it under this tag).
    private fun floorContent(): android.view.View = android.view.View(activity).also {
        it.setTag(com.facebook.react.R.id.view_tag_native_id, CYLRefreshContainerView.SECONDARY_NATIVE_ID)
    }

    @Test
    fun theSecondaryNativeIdChildIsTheFloorAndNotAChildOfTheLayout() {
        val view = CYLRefreshContainerView(activity)
        val scroll = ScrollView(activity)
        val floor = floorContent()
        view.addReactChild(scroll, 0)
        view.addReactChild(floor, 1)
        activity.setContentView(view)
        idle(100)
        assertEquals("React Native counts both children", 2, view.reactChildCount)
        assertTrue(view.reactChildAt(1) === floor)
        assertEquals("the floor is not a child of the layout", null, floor.parent)
        assertTrue("the header got it as the floor's content", view.cyl_header!!.secondaryView === floor)
        view.removeReactChildAt(1)
        assertEquals(1, view.reactChildCount)
        assertEquals(null, view.cyl_header!!.secondaryView)
    }

    @Test
    fun secondaryOpenFromJsOpensWithoutTheEventAndAPullOrPushReportsIt() {
        val view = CYLRefreshContainerView(activity)
        view.addReactChild(ScrollView(activity), 0)
        view.addReactChild(floorContent(), 1)
        activity.setContentView(view)
        idle(100)
        var opened = 0
        var closed = 0
        view.onSecondaryOpen = { opened++ }
        view.onSecondaryClose = { closed++ }
        view.setSecondaryTriggerOffset(120f)
        view.setSecondaryDimension(300f)
        view.setSecondaryCloseTriggerOffset(80f)
        assertEquals(120f, view.cyl_header!!.secondaryTriggerOffset, 0f)
        view.setSecondaryOpenFromJs(true)
        idle(1500)
        assertTrue(view.cyl_header!!.secondaryOpen)
        assertEquals("opened by the prop: no event", 0, opened)
        view.setSecondaryOpenFromJs(false)
        idle(1500)
        assertFalse(view.cyl_header!!.secondaryOpen)
        assertEquals("closed by the prop: no event", 0, closed)
        // Opened and closed by the native side (a pull or a push): the events are sent.
        view.cyl_header!!.openSecondary()
        idle(1500)
        assertEquals(1, opened)
        view.cyl_header!!.closeSecondary()
        idle(1500)
        assertEquals(1, closed)
    }

    @Test
    fun noFloorContentOrWhileRefreshingSecondaryOpenDoesNothing() {
        val view = container()
        view.setSecondaryOpenFromJs(true)
        assertFalse("no floor content: nothing opens", view.cyl_header!!.secondaryOpen)
        val withFloor = CYLRefreshContainerView(activity)
        withFloor.addReactChild(ScrollView(activity), 0)
        withFloor.addReactChild(floorContent(), 1)
        activity.setContentView(withFloor)
        idle(100)
        withFloor.setRefreshingFromJs(true)
        idle(100)
        withFloor.setSecondaryOpenFromJs(true)
        assertFalse("no second floor while refreshing", withFloor.cyl_header!!.secondaryOpen)
    }

    @Test
    fun aRealPullUpReachesOnLoadMoreWhenItIsOn() {
        val view = container()
        var loaded = 0
        view.onLoadMore = { loaded++ }
        view.setLoadMoreEnabled(true)
        drag(view, -900f)
        idle(500)
        assertEquals(1, loaded)
        assertTrue(view.cyl_footer!!.isRefreshing)
        view.setLoadingMoreFromJs(false)
        idle(3000)
    }

    // --- headerStyle / footerStyle / headerRive / footerRive and loadsAfterNoMoreData ---

    @Test
    fun loadsAfterNoMoreDataReachesTheFooterAndSurvivesAStyleChange() {
        val view = container()
        assertFalse(view.cyl_footer!!.loadsAfterNoMoreData)
        view.setLoadsAfterNoMoreData(true)
        assertTrue(view.cyl_footer!!.loadsAfterNoMoreData)
        view.setFooterStyle("material")
        view.applyStyles()
        assertEquals(CYLRefreshMaterialFooter::class.java, view.cyl_footer!!.javaClass)
        assertTrue("the new footer keeps the prop", view.cyl_footer!!.loadsAfterNoMoreData)
        view.setLoadsAfterNoMoreData(false)
        assertFalse(view.cyl_footer!!.loadsAfterNoMoreData)
    }

    @Test
    fun styleKeysMakeTheStyleHeaderAndFooterAndKeepLoadMoreOn() {
        val view = container()
        view.setHeaderStyle("material")
        view.setFooterStyle("classic")
        view.applyStyles()
        assertEquals(CYLRefreshMaterialHeader::class.java, view.cyl_header!!.javaClass)
        assertEquals(CYLRefreshBackNormalFooter::class.java, view.cyl_footer!!.javaClass)
        // Load more stays on after the footer was replaced: a pull up of the auto Cupertino footer reaches onLoadMore.
        val more = container()
        var loaded = 0
        more.onLoadMore = { loaded++ }
        more.setLoadMoreEnabled(true)
        more.setFooterStyle("cupertino")
        more.applyStyles()
        drag(more, -900f)
        idle(500)
        assertEquals(1, loaded)
        more.setLoadingMoreFromJs(false)
        idle(3000)
    }

    @Test
    fun aMissingOrUnknownStyleKeepsTheDefaultHeaderAndFooter() {
        val view = container()
        val header = view.cyl_header
        val footer = view.cyl_footer
        view.setHeaderStyle("storeHouse")
        view.setFooterStyle(null)
        view.applyStyles()
        assertSame(header, view.cyl_header)
        assertSame(footer, view.cyl_footer)
        assertEquals(CYLRefreshAutoNormalFooter::class.java, view.cyl_footer!!.javaClass)
        view.applyStyles()
        assertSame("applying the same styles again replaces nothing", header, view.cyl_header)
    }

    @Test
    fun theRiveStyleWithoutTheRiveModuleIsClassicWithOneLogLine() {
        CYLRefreshRiveSupport.builder = null
        ShadowLog.clear()
        val view = container()
        view.setHeaderStyle("rive")
        view.setHeaderRive(mapOf("riveFile" to "Bow"))
        view.applyStyles()
        assertEquals(CYLRefreshNormalHeader::class.java, view.cyl_header!!.javaClass)
        val lines = ShadowLog.getLogs().filter { it.tag == "CYLRefresh" }.map { it.msg }
        assertEquals(listOf("CYLRefresh: ${CYLRefreshRiveSupport.NOT_LINKED}, using classic"), lines)
    }

    @Test
    fun headerRiveAndFooterRiveReachTheBuilderAndAnUnreadableFileIsClassic() {
        val asked = ArrayList<String?>()
        val made = CYLRefreshNormalHeader(activity)
        CYLRefreshRiveSupport.builder = object : CYLRefreshRiveBuilding {
            override fun header(context: android.content.Context, options: CYLRefreshRiveOptions): CYLRefreshHeader? { asked.add(options.file); return made }
            override fun footer(context: android.content.Context, options: CYLRefreshRiveOptions): CYLRefreshFooter? { asked.add(options.file); return null }
        }
        try {
            ShadowLog.clear()
            val view = container()
            view.setHeaderStyle("rive")
            view.setHeaderRive(mapOf("riveFile" to "Bow", "rivePullInput" to "pull"))
            view.setFooterStyle("rive")
            view.setFooterRive(mapOf("riveFile" to "Missing.riv"))
            view.applyStyles()
            assertSame(made, view.cyl_header)
            assertEquals(listOf<String?>("Bow", "Missing.riv"), asked)
            assertEquals(CYLRefreshBackNormalFooter::class.java, view.cyl_footer!!.javaClass)
            val lines = ShadowLog.getLogs().filter { it.tag == "CYLRefresh" }.map { it.msg }
            assertEquals(listOf("CYLRefresh: rive file Missing.riv not found or unreadable, using classic"), lines)
        } finally {
            CYLRefreshRiveSupport.builder = null
        }
    }

    @Test
    fun theSecondFloorSettingsSurviveAStyleChange() {
        val view = container()
        view.setSecondaryTriggerOffset(120f)
        view.setSecondaryDimension(300f)
        view.setSecondaryCloseTriggerOffset(60f)
        val before = view.cyl_header
        view.setHeaderStyle("material")
        view.applyStyles()
        assertNotSame(before, view.cyl_header)
        assertEquals(120f, view.cyl_header!!.secondaryTriggerOffset, 0f)
        assertEquals(300f, view.cyl_header!!.secondaryDimension, 0f)
        assertEquals(60f, view.cyl_header!!.secondaryCloseTriggerOffset, 0f)
    }

    // --- the footer's second floor (nativeID "cyl.refresh.secondary.footer") and riveFinishTimeout ---

    private fun footerFloorContent(): android.view.View = android.view.View(activity).also {
        it.setTag(com.facebook.react.R.id.view_tag_native_id, CYLRefreshContainerView.FOOTER_SECONDARY_NATIVE_ID)
    }

    @Test
    fun theFooterSecondaryNativeIdChildIsTheFooterFloorAndTheHeaderFloorIsUntouched() {
        val view = CYLRefreshContainerView(activity)
        val scroll = ScrollView(activity)
        val headerFloor = floorContent()
        val footerFloor = footerFloorContent()
        view.addReactChild(scroll, 0)
        view.addReactChild(footerFloor, 1)
        view.addReactChild(headerFloor, 2)
        view.setFooterStyle("classic")
        view.applyStyles()
        activity.setContentView(view)
        idle(100)
        assertEquals(3, view.reactChildCount)
        assertEquals("the footer floor is not a child of the layout", null, footerFloor.parent)
        assertTrue((view.cyl_footer as CYLRefreshBackFooter).secondaryView === footerFloor)
        assertTrue(view.cyl_header!!.secondaryView === headerFloor)
        view.removeReactChildAt(1)
        assertEquals(null, (view.cyl_footer as CYLRefreshBackFooter).secondaryView)
        assertTrue(view.cyl_header!!.secondaryView === headerFloor)
    }

    @Test
    fun footerSecondaryPropsReachTheBackFooterAndSurviveAStyleChange() {
        val view = container()
        view.setFooterSecondaryTriggerOffset(120f)
        view.setFooterSecondaryDimension(300f)
        view.setFooterSecondaryCloseTriggerOffset(60f)
        view.setFooterStyle("classic")
        view.applyStyles()
        val footer = view.cyl_footer as CYLRefreshBackFooter
        assertEquals(120f, footer.secondaryTriggerOffset, 0f)
        assertEquals(300f, footer.secondaryDimension, 0f)
        assertEquals(60f, footer.secondaryCloseTriggerOffset, 0f)
        // The header's floor is a separate one.
        assertEquals(0f, view.cyl_header!!.secondaryTriggerOffset, 0f)
    }

    @Test
    fun footerSecondaryOpenFromJsHasNoEventAndANativeOpenOrCloseReportsTheFooterEdge() {
        val view = CYLRefreshContainerView(activity)
        view.addReactChild(ScrollView(activity), 0)
        view.addReactChild(footerFloorContent(), 1)
        view.setFooterStyle("classic")
        view.applyStyles()
        activity.setContentView(view)
        idle(100)
        val events = ArrayList<String>()
        view.onSecondaryOpen = { events.add("open:$it") }
        view.onSecondaryClose = { events.add("close:$it") }
        val footer = view.cyl_footer as CYLRefreshBackFooter
        view.setFooterSecondaryOpenFromJs(true)
        idle(1500)
        assertTrue(footer.secondaryOpen)
        view.setFooterSecondaryOpenFromJs(false)
        idle(1500)
        assertFalse(footer.secondaryOpen)
        assertEquals("by the prop: no events", emptyList<String>(), events)
        footer.openSecondary()
        idle(1500)
        footer.closeSecondary()
        idle(1500)
        assertEquals(listOf("open:footer", "close:footer"), events)
    }

    @Test
    fun theHeaderFloorEventsStillCarryTheHeaderEdge() {
        val view = CYLRefreshContainerView(activity)
        view.addReactChild(ScrollView(activity), 0)
        view.addReactChild(floorContent(), 1)
        activity.setContentView(view)
        idle(100)
        val events = ArrayList<String>()
        view.onSecondaryOpen = { events.add("open:$it") }
        view.onSecondaryClose = { events.add("close:$it") }
        view.cyl_header!!.openSecondary()
        idle(1500)
        view.cyl_header!!.closeSecondary()
        idle(1500)
        assertEquals(listOf("open:header", "close:header"), events)
    }

    @Test
    fun footerSecondaryOpenNeedsABackFooterAndTheFloorContent() {
        val auto = CYLRefreshContainerView(activity)
        auto.addReactChild(ScrollView(activity), 0)
        auto.addReactChild(footerFloorContent(), 1)
        activity.setContentView(auto)
        idle(100)
        assertTrue("the default footer is the auto one", auto.cyl_footer is CYLRefreshAutoNormalFooter)
        auto.setFooterSecondaryTriggerOffset(100f)
        auto.setFooterSecondaryOpenFromJs(true)
        idle(500)
        val noContent = container()
        noContent.setFooterStyle("classic")
        noContent.applyStyles()
        noContent.setFooterSecondaryOpenFromJs(true)
        assertFalse((noContent.cyl_footer as CYLRefreshBackFooter).secondaryOpen)
    }

    @Test
    fun riveFinishTimeoutInHeaderRiveAndFooterRiveReachesTheBuilder() {
        val timeouts = ArrayList<Double>()
        CYLRefreshRiveSupport.builder = object : CYLRefreshRiveBuilding {
            override fun header(context: android.content.Context, options: CYLRefreshRiveOptions): CYLRefreshHeader? { timeouts.add(options.finishTimeout); return null }
            override fun footer(context: android.content.Context, options: CYLRefreshRiveOptions): CYLRefreshFooter? { timeouts.add(options.finishTimeout); return null }
        }
        try {
            val view = container()
            view.setHeaderStyle("rive")
            view.setHeaderRive(mapOf("riveFile" to "Bow", "riveFinishTimeout" to 2.5))
            view.setFooterStyle("rive")
            view.setFooterRive(mapOf("riveFile" to "Bow", "riveFinishTimeout" to 3))
            view.applyStyles()
            assertEquals(listOf(2.5, 3.0), timeouts)
            timeouts.clear()
            val unset = container()
            unset.setHeaderStyle("rive")
            unset.setHeaderRive(mapOf("riveFile" to "Bow"))
            unset.applyStyles()
            assertEquals("the default stays 1.5", listOf(1.5), timeouts)
        } finally {
            CYLRefreshRiveSupport.builder = null
        }
    }
}
