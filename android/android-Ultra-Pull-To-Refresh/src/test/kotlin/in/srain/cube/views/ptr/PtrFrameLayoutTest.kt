package `in`.srain.cube.views.ptr

import android.app.Activity
import android.content.Context
import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.view.accessibility.AccessibilityNodeInfo
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.ScrollView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import androidx.test.core.app.ApplicationProvider
import `in`.srain.cube.views.ptr.header.MaterialHeader
import `in`.srain.cube.views.ptr.header.StoreHouseHeader
import `in`.srain.cube.views.ptr.header.StoreHousePath
import `in`.srain.cube.views.ptr.indicator.PtrIndicator
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.time.Duration

/**
 * android-Ultra-Pull-To-Refresh in Kotlin: the source's behavior, the taken pull requests and the fixed issues
 * (docs/Android-Port.md); each test names them.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class PtrFrameLayoutTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    private class Calls : PtrDefaultHandler2() {
        var refreshes = 0
        var loads = 0
        override fun onRefreshBegin(frame: PtrFrameLayout) { refreshes++ }
        override fun onLoadMoreBegin(frame: PtrFrameLayout) { loads++ }
    }

    private class UiCounter : PtrUIHandler {
        val events = mutableListOf<String>()
        override fun onUIReset(frame: PtrFrameLayout) { events += "reset" }
        override fun onUIRefreshPrepare(frame: PtrFrameLayout) { events += "prepare" }
        override fun onUIRefreshBegin(frame: PtrFrameLayout) { events += "begin" }
        override fun onUIRefreshComplete(frame: PtrFrameLayout) { events += "complete" }
        override fun onUIPositionChange(frame: PtrFrameLayout, isUnderTouch: Boolean, status: Byte, ptrIndicator: PtrIndicator) {}
    }

    private fun scrollContent(height: Int): ScrollView {
        val scrollView = ScrollView(context)
        val inner = LinearLayout(context).apply { orientation = LinearLayout.VERTICAL }
        inner.addView(View(context), LinearLayout.LayoutParams(400, height))
        scrollView.addView(inner)
        return scrollView
    }

    private fun header(height: Int = 60) = View(context).apply { layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, height) }

    private fun measure(frame: View) {
        frame.measure(View.MeasureSpec.makeMeasureSpec(400, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(800, View.MeasureSpec.EXACTLY))
        frame.layout(0, 0, 400, 800)
    }

    /** A 400 x 800 frame made in code: a 60 px header, a ScrollView whose content is [contentHeight] high. */
    private fun makeFrame(contentHeight: Int = 2000, footer: Boolean = false, calls: Calls = Calls()): Triple<PtrFrameLayout, View, Calls> {
        val frame = PtrFrameLayout(context)
        frame.headerView = header()
        val content = scrollContent(contentHeight)
        frame.addView(content)
        if (footer) frame.footerView = header()
        frame.setPtrHandler(calls)
        frame.loadingMinTime = 0
        measure(frame)
        return Triple(frame, content, calls)
    }

    private var downTime = 0L

    private fun down(frame: View, x: Float = 200f, y: Float = 300f) {
        downTime = SystemClock.uptimeMillis()
        frame.dispatchTouchEvent(MotionEvent.obtain(downTime, downTime, MotionEvent.ACTION_DOWN, x, y, 0))
    }

    private fun move(frame: View, x: Float, y: Float) {
        frame.dispatchTouchEvent(MotionEvent.obtain(downTime, SystemClock.uptimeMillis(), MotionEvent.ACTION_MOVE, x, y, 0))
    }

    private fun up(frame: View, x: Float = 200f, y: Float = 300f) {
        frame.dispatchTouchEvent(MotionEvent.obtain(downTime, SystemClock.uptimeMillis(), MotionEvent.ACTION_UP, x, y, 0))
    }

    /** A finger drag of [dy] pixels (and [dx] sideways) in 20 steps, from (200, 300). */
    private fun drag(frame: View, dy: Float, release: Boolean = true, dx: Float = 0f) {
        down(frame)
        for (i in 1..20) move(frame, 200f + dx * i / 20, 300f + dy * i / 20)
        if (release) up(frame, 200f + dx, 300f + dy)
    }

    private fun idle(millis: Long = 1500) = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(millis))

    @Test
    fun pullPastTheOffsetRefreshesAndCompleteCloses() {
        val (frame, content, calls) = makeFrame()
        drag(frame, 300f, release = false)
        assertEquals(PtrFrameLayout.PTR_STATUS_PREPARE, frame.ptrStatus)
        assertTrue("past 72 (1.2 x 60)", frame.ptrIndicator.getCurrentPosY() >= 72)
        up(frame)
        idle()
        assertEquals(PtrFrameLayout.PTR_STATUS_LOADING, frame.ptrStatus)
        assertEquals(1, calls.refreshes)
        assertEquals("kept at the header's height", 60, content.top)
        frame.refreshComplete()
        idle()
        assertEquals(PtrFrameLayout.PTR_STATUS_INIT, frame.ptrStatus)
        assertEquals(0, content.top)
    }

    @Test
    fun shortPullAndTapsDoNotRefresh() {
        // #119, #167, #257, #266: a tap that moves a little stays a tap (pull request #178's slop).
        val (frame, content, calls) = makeFrame()
        drag(frame, 4f)
        assertEquals("within the touch slop", 0, frame.ptrIndicator.getCurrentPosY())
        drag(frame, 80f)
        idle()
        assertEquals(0, calls.refreshes)
        assertEquals(0, content.top)
    }

    @Test
    fun sidewaysMovesGoToTheChildren() {
        // #91, #106, #132, #136, #164, #220, #252, #261, #279, #282, #287, #295, #299, #307, #312, #325 (pull
        // requests #124, #178, #209, #270).
        val (frame, _, calls) = makeFrame()
        frame.disableWhenHorizontalMove(true)
        drag(frame, 60f, dx = 200f)
        idle()
        assertEquals(0, frame.ptrIndicator.getCurrentPosY())
        assertEquals(0, calls.refreshes)
        drag(frame, 300f, dx = 20f)
        idle()
        assertEquals("a mostly vertical pull still refreshes", 1, calls.refreshes)
    }

    @Test
    fun pullUpLoadsMoreWithAFooter() {
        // Pull request #157; #118, #126, #171, #262, #265, #269, #294; #301 and #337: the content comes back whole and
        // keeps its scroll position.
        val (frame, content, calls) = makeFrame(contentHeight = 300, footer = true)
        drag(frame, -300f, release = false)
        assertFalse(frame.ptrIndicator.isHeader)
        assertTrue("the content moved up", content.top < 0)
        up(frame)
        idle()
        assertEquals(1, calls.loads)
        assertTrue(frame.isLoadingMore)
        assertEquals(-60, content.top)
        assertEquals("the footer sits under the content", 800 - 60, frame.footerView!!.top)
        frame.refreshComplete()
        idle()
        assertEquals(0, content.top)
        assertEquals(800, frame.footerView!!.top)
        assertEquals(0, content.scrollY)
        frame.autoLoadMore()
        idle()
        assertEquals(2, calls.loads)
    }

    @Test
    fun modeLimitsTheDirections() {
        // Pull request #157.
        val (frame, _, calls) = makeFrame(contentHeight = 300, footer = true)
        frame.mode = PtrFrameLayout.Mode.REFRESH
        drag(frame, -300f)
        idle()
        assertEquals(0, calls.loads)
        frame.mode = PtrFrameLayout.Mode.LOAD_MORE
        drag(frame, 300f)
        idle()
        assertEquals(0, calls.refreshes)
    }

    @Test
    fun pinHeaderAndPinContent() {
        // Pull request #236; #29, #154, #199.
        val (frame, content, _) = makeFrame()
        frame.isPinHeader = true
        drag(frame, 400f, release = false)
        assertEquals("the header stops once shown", 0, frame.headerView!!.top)
        assertTrue(content.top > 60)
        up(frame)
        idle()
        frame.refreshComplete()
        idle()
        frame.isPinHeader = false
        frame.isPinContent = true
        drag(frame, 300f, release = false)
        assertEquals(0, content.top)
        assertTrue(frame.headerView!!.top > -60)
    }

    @Test
    fun deadZone() {
        // Pull request #288; #328.
        val (frame, _, _) = makeFrame()
        frame.deadZone = 100
        drag(frame, 90f, release = false)
        assertEquals(0, frame.ptrIndicator.getCurrentPosY())
        up(frame)
        drag(frame, 300f, release = false)
        assertTrue(frame.ptrIndicator.getCurrentPosY() > 0)
    }

    @Test
    fun autoRefreshBeforeTheFirstLayoutWaitsForIt() {
        // #122, #189, #247, #300, #333: the header comes down once, and refreshing starts once.
        val frame = PtrFrameLayout(context)
        frame.headerView = header()
        val content = scrollContent(2000)
        frame.addView(content)
        val calls = Calls()
        frame.setPtrHandler(calls)
        val ui = UiCounter()
        frame.addPtrUIHandler(ui)
        frame.autoRefresh()
        assertEquals(0, calls.refreshes)
        measure(frame)
        idle()
        assertEquals(1, calls.refreshes)
        assertEquals(listOf("prepare", "begin"), ui.events)
        assertTrue(content.top > 0)
    }

    @Test
    fun autoRefreshScrollsTheContentToItsTop() {
        // #249.
        val (frame, content, _) = makeFrame()
        content.scrollTo(0, 500)
        frame.autoRefresh()
        idle()
        assertEquals(0, content.scrollY)
    }

    @Test
    fun enabledNextPtrAtOnceWithAutoRefresh() {
        // #123 (pull request #176); #223: one prepare per pull.
        val (frame, _, calls) = makeFrame()
        val ui = UiCounter()
        frame.addPtrUIHandler(ui)
        frame.isEnabledNextPtrAtOnce = true
        frame.autoRefresh()
        idle()
        frame.refreshComplete()
        idle(100)
        assertEquals(PtrFrameLayout.PTR_STATUS_COMPLETE, frame.ptrStatus)
        frame.autoRefresh()
        idle()
        assertEquals(2, calls.refreshes)
        assertEquals(2, ui.events.count { it == "prepare" })
    }

    @Test
    fun zeroCloseDurationClosesAtOnce() {
        // #242, #245; pull request #240 (#239, #276): the scroll ends exactly at its target.
        val (frame, content, _) = makeFrame()
        frame.durationToCloseHeader = 0
        frame.durationToClose = 0
        drag(frame, 300f)
        idle(50)
        assertEquals(60, content.top)
        frame.refreshComplete()
        idle(50)
        assertEquals(0, content.top)
        assertEquals(PtrFrameLayout.PTR_STATUS_INIT, frame.ptrStatus)
    }

    @Test
    fun headerCanBeRemovedAndContentAddedInCode() {
        // Pull request #144 (#112); #234, #272, #292: a frame made in code, its content replaced.
        val (frame, content, _) = makeFrame()
        frame.headerView = null
        assertNull(frame.headerView)
        drag(frame, 300f)
        idle()
        assertEquals(0, content.top)
        frame.headerView = header()
        frame.removeView(content)
        val other = scrollContent(2000)
        frame.addView(other)
        assertEquals(other, frame.contentView)
        measure(frame)
        drag(frame, 300f)
        idle()
        assertEquals(60, other.top)
    }

    @Test
    fun aSecondFingerTakesOver() {
        // #41: multi-touch.
        val (frame, _, _) = makeFrame()
        down(frame)
        for (i in 1..10) move(frame, 200f, 300f + 10f * i)
        val before = frame.ptrIndicator.getCurrentPosY()
        val t = SystemClock.uptimeMillis()
        val props = arrayOf(MotionEvent.PointerProperties().apply { id = 0 }, MotionEvent.PointerProperties().apply { id = 1 })
        fun coords(y0: Float, y1: Float) = arrayOf(MotionEvent.PointerCoords().apply { x = 200f; y = y0 }, MotionEvent.PointerCoords().apply { x = 100f; y = y1 })
        frame.dispatchTouchEvent(MotionEvent.obtain(downTime, t, MotionEvent.ACTION_POINTER_DOWN or (1 shl MotionEvent.ACTION_POINTER_INDEX_SHIFT), 2, props, coords(400f, 100f), 0, 0, 1f, 1f, 0, 0, 0, 0))
        assertEquals("a new finger does not jump the pull", before, frame.ptrIndicator.getCurrentPosY())
        frame.dispatchTouchEvent(MotionEvent.obtain(downTime, t + 10, MotionEvent.ACTION_MOVE, 2, props, coords(400f, 200f), 0, 0, 1f, 1f, 0, 0, 0, 0))
        assertTrue("the second finger pulls", frame.ptrIndicator.getCurrentPosY() > before)
    }

    @Test
    fun aChildThatKeepsTheGestureIsNotPulled() {
        // #83, #133, #233: a slider calls requestDisallowInterceptTouchEvent for its sideways drag.
        val (frame, _, calls) = makeFrame()
        down(frame)
        frame.contentView!!.parent.requestDisallowInterceptTouchEvent(true)
        for (i in 1..20) move(frame, 200f + 15f * i, 300f + 10f * i)
        up(frame, 500f, 500f)
        idle()
        assertEquals(0, frame.ptrIndicator.getCurrentPosY())
        assertEquals(0, calls.refreshes)
    }

    @Test
    fun maxPullDistance() {
        // #275, #308.
        val (frame, _, _) = makeFrame()
        frame.maxPullDistance = 100
        drag(frame, 600f, release = false)
        assertEquals(100, frame.ptrIndicator.getCurrentPosY())
    }

    @Test
    fun completedStateStaysForAWhile() {
        // #139, #302.
        val (frame, content, _) = makeFrame()
        frame.durationToKeepCompleted = 1000
        frame.autoRefresh()
        idle()
        frame.refreshComplete()
        idle(500)
        assertEquals(PtrFrameLayout.PTR_STATUS_COMPLETE, frame.ptrStatus)
        assertTrue(content.top > 0)
        idle(2000)
        assertEquals(0, content.top)
        assertEquals(PtrFrameLayout.PTR_STATUS_INIT, frame.ptrStatus)
    }

    @Test
    fun headerOffset() {
        // #135, #165: setProgressViewOffset.
        val (frame, _, _) = makeFrame()
        frame.headerOffset = 100
        measure(frame)
        assertEquals(100 - 60, frame.headerView!!.top)
        assertEquals(View.INVISIBLE, frame.headerView!!.visibility)
        drag(frame, 300f, release = false)
        assertEquals(View.VISIBLE, frame.headerView!!.visibility)
    }

    @Test
    fun touchesBlockedWhileRefreshing() {
        // #264.
        val (frame, content, _) = makeFrame()
        var clicks = 0
        content.setOnTouchListener { _, _ -> clicks++; false }
        frame.isContentTouchBlockedWhileRefreshing = true
        frame.autoRefresh()
        idle()
        down(frame)
        up(frame)
        assertEquals(0, clicks)
    }

    @Test
    fun aContainerAroundTheListAsksTheList() {
        // #224: a FrameLayout around a scrolled list is not pulled; #42, #206: the list's own scrolling decides.
        val calls = Calls()
        val frame = PtrFrameLayout(context)
        frame.headerView = header()
        val wrapper = FrameLayout(context)
        val list = scrollContent(2000)
        wrapper.addView(list)
        frame.addView(wrapper)
        frame.setPtrHandler(calls)
        measure(frame)
        list.scrollTo(0, 300)
        assertFalse(PtrDefaultHandler.checkContentCanBePulledDown(frame, wrapper, frame.headerView))
        list.scrollTo(0, 0)
        assertTrue(PtrDefaultHandler.checkContentCanBePulledDown(frame, wrapper, frame.headerView))
    }

    @Test
    fun refreshCompleteBeforeLoadingDoesNotOverflow() {
        // Pull request #319; #246, #339.
        val (frame, _, _) = makeFrame()
        frame.loadingMinTime = 500
        frame.refreshComplete()
        assertEquals(PtrFrameLayout.PTR_STATUS_INIT, frame.ptrStatus)
        frame.autoRefresh()
        idle(100)
        frame.refreshComplete()
        idle(2000)
        assertEquals(PtrFrameLayout.PTR_STATUS_INIT, frame.ptrStatus)
    }

    @Test
    fun completionIsNotifiedOnce() {
        // #77: a touch before the header closed does not complete again.
        val (frame, _, _) = makeFrame()
        val ui = UiCounter()
        frame.addPtrUIHandler(ui)
        frame.autoRefresh()
        idle()
        frame.refreshComplete()
        idle(100)
        down(frame)
        up(frame)
        idle()
        assertEquals(1, ui.events.count { it == "complete" })
        assertEquals("reset", ui.events.last())
    }

    @Test
    fun detachedMidScrollClosesTheHeader() {
        // Pull request #268 (#200): a fragment switched away while the header closes.
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val (frame, _, _) = makeFrame()
        activity.setContentView(frame)
        frame.autoRefresh()
        idle()
        frame.refreshComplete()
        idle(50)
        assertTrue(frame.ptrIndicator.getCurrentPosY() > 0)
        (frame.parent as ViewGroup).removeView(frame)
        assertEquals(0, frame.ptrIndicator.getCurrentPosY())
    }

    @Test
    fun scrollFinishesOnce() {
        // #48.
        var finishes = 0
        val frame = object : PtrFrameLayout(context) {
            override fun onPtrScrollFinish() {
                finishes++
                super.onPtrScrollFinish()
            }
        }
        frame.headerView = header()
        frame.addView(scrollContent(2000))
        frame.setPtrHandler(Calls())
        measure(frame)
        frame.autoRefresh(false)
        idle()
        assertEquals(1, finishes)
    }

    @Test
    fun aScrollingParentKeepsOutWhilePulling() {
        // #284: inside a HorizontalScrollView.
        var disallowed = false
        val parent = object : FrameLayout(context) {
            override fun requestDisallowInterceptTouchEvent(disallowIntercept: Boolean) {
                disallowed = disallowed || disallowIntercept
                super.requestDisallowInterceptTouchEvent(disallowIntercept)
            }
        }
        val (frame, _, _) = makeFrame()
        parent.addView(frame)
        drag(frame, 300f, release = false)
        assertTrue(disallowed)
    }

    @Test
    fun pullBackPastTheStartAndPullAgain() {
        // #323: dragging back to the start and on does not get stuck.
        val (frame, _, _) = makeFrame()
        down(frame)
        for (i in 1..10) move(frame, 200f, 300f + 20f * i)
        assertTrue(frame.ptrIndicator.getCurrentPosY() > 0)
        for (i in 1..20) move(frame, 200f, 500f - 20f * i)
        assertEquals(0, frame.ptrIndicator.getCurrentPosY())
        for (i in 1..20) move(frame, 200f, 100f + 20f * i)
        assertTrue("pulled again", frame.ptrIndicator.getCurrentPosY() > 0)
    }

    @Test
    fun recyclerViewContent() {
        // #27, #105, #164, #231, #296, #297, #303, #338 (pull request #114).
        val frame = PtrFrameLayout(context)
        frame.headerView = header()
        val recycler = RecyclerView(context)
        recycler.layoutManager = LinearLayoutManager(context)
        recycler.adapter = object : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
            override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
                object : RecyclerView.ViewHolder(View(parent.context).apply { layoutParams = ViewGroup.LayoutParams(400, 100) }) {}
            override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {}
            override fun getItemCount() = 30
        }
        frame.addView(recycler)
        val calls = Calls()
        frame.setPtrHandler(calls)
        frame.loadingMinTime = 0
        measure(frame)
        drag(frame, 300f)
        idle()
        assertEquals(1, calls.refreshes)
        frame.refreshComplete()
        idle()
        recycler.scrollBy(0, 500)
        drag(frame, 300f)
        idle()
        assertEquals("not at its top", 1, calls.refreshes)
    }

    @Test
    fun accessibilityRefreshAction() {
        // Accessibility: refreshing without a pull.
        val (frame, _, calls) = makeFrame()
        val info = AccessibilityNodeInfo.obtain()
        frame.onInitializeAccessibilityNodeInfo(info)
        assertTrue(info.actionList.any { it.id == R.id.cube_ptr_action_refresh })
        frame.performAccessibilityAction(R.id.cube_ptr_action_refresh, null)
        idle()
        assertEquals(1, calls.refreshes)
    }

    @Test
    fun classicHeaderTextsAndLastUpdate() {
        // #125: whole phrases with arguments; #137: a custom last update time; #230, #191.
        val frame = PtrClassicFrameLayout(context)
        frame.addView(scrollContent(2000))
        val calls = Calls()
        frame.setPtrHandler(calls)
        frame.loadingMinTime = 0
        measure(frame)
        val header = frame.header
        frame.setLastUpdateTimeKey("test")
        frame.setLastUpdateTime(System.currentTimeMillis() - 125_000)
        val last = header.findViewById<android.widget.TextView>(R.id.ptr_classic_header_rotate_view_header_last_update)
        assertEquals("Last update: 2 minutes ago", last.text.toString())
        frame.measure(View.MeasureSpec.makeMeasureSpec(400, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(800, View.MeasureSpec.EXACTLY))
        frame.layout(0, 0, 400, 800)
        drag(frame, 400f, release = false)
        val title = header.findViewById<android.widget.TextView>(R.id.ptr_classic_header_rotate_view_header_title)
        assertEquals(context.getString(R.string.cube_ptr_release_to_refresh), title.text.toString())
        assertTrue(header.contentDescription.toString().startsWith(context.getString(R.string.cube_ptr_release_to_refresh)))
        up(frame)
        idle()
        assertEquals(context.getString(R.string.cube_ptr_refreshing), title.text.toString())
    }

    @Test
    fun classicFooter() {
        // Pull request #157: PtrClassicDefaultFooter.
        val frame = PtrClassicFrameLayout(context)
        frame.addView(scrollContent(300))
        val footer = frame.addClassicFooter()
        val calls = Calls()
        frame.setPtrHandler(calls)
        frame.loadingMinTime = 0
        measure(frame)
        drag(frame, -400f)
        idle()
        assertEquals(1, calls.loads)
        val title = footer.findViewById<android.widget.TextView>(R.id.ptr_classic_header_rotate_view_header_title)
        assertEquals(context.getString(R.string.cube_ptr_loading_more), title.text.toString())
        val headerTitle = frame.header.findViewById<android.widget.TextView>(R.id.ptr_classic_header_rotate_view_header_title)
        assertFalse("the header ignores pulls up", headerTitle.text.toString() == context.getString(R.string.cube_ptr_refreshing))
    }

    @Test
    fun materialHeaderStartsFullSizeAfterTheLastPull() {
        // #129, #186: no blank or shrunken spinner with enabledNextPtrAtOnce; #192: the spinner spins.
        val frame = PtrFrameLayout(context)
        val header = MaterialHeader(context)
        frame.headerView = header
        frame.addPtrUIHandler(header)
        header.setPtrFrameLayout(frame)
        header.setCustomMaterialHeaderBackground(0xff00ff00.toInt())
        frame.addView(scrollContent(2000))
        frame.setPtrHandler(Calls())
        frame.loadingMinTime = 0
        frame.isEnabledNextPtrAtOnce = true
        measure(frame)
        frame.autoRefresh()
        idle()
        assertTrue(header.isSpinning)
        header.onUIRefreshComplete(frame)
        header.onUIRefreshPrepare(frame)
        assertEquals(1f, header.spinnerScale)
    }

    @Test
    fun storeHouseHeader() {
        // #150: refreshing before initWithString does not crash; #306: the color; #141 and pull request #177.
        val frame = PtrFrameLayout(context)
        val header = StoreHouseHeader(context)
        frame.headerView = header
        frame.addPtrUIHandler(header)
        frame.addView(scrollContent(2000))
        frame.setPtrHandler(Calls())
        header.onUIRefreshBegin(frame)
        header.onUIReset(frame)
        header.initWithString("ULTRA")
        header.setTextColor(0xff000000.toInt())
        assertEquals(StoreHousePath.getPath("ULTRA", 0.25f, 14).size, header.mItemList.size)
        measure(frame)
        frame.autoRefresh()
        idle()
        assertTrue(header.isLoading)
        frame.refreshComplete()
        idle()
        assertFalse(header.isLoading)
    }

    @Test
    fun uiHandlersAreAddedOnce() {
        val (frame, _, _) = makeFrame()
        val ui = UiCounter()
        frame.addPtrUIHandler(ui)
        frame.addPtrUIHandler(ui)
        frame.autoRefresh()
        idle()
        assertEquals(1, ui.events.count { it == "prepare" })
        frame.removePtrUIHandler(ui)
        frame.refreshComplete()
        idle()
        assertFalse(ui.events.contains("complete"))
    }

    @Test
    fun classicHeaderTimerStops() {
        // #254, #260, #310: the last-update timer stops on a short pull, after refreshing and when detached.
        val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        val frame = PtrClassicFrameLayout(context)
        frame.addView(scrollContent(2000))
        frame.setPtrHandler(Calls())
        frame.loadingMinTime = 0
        frame.setLastUpdateTimeKey("timer")
        frame.setLastUpdateTime(System.currentTimeMillis() - 5_000)
        activity.setContentView(frame)
        measure(frame)
        val looper = shadowOf(Looper.getMainLooper())
        drag(frame, 40f, release = false)
        idle(100)
        assertTrue("the timer ticks while pulling", looper.nextScheduledTaskTime.toMillis() > 0)
        up(frame)
        idle(3000)
        assertEquals("nothing left after the short pull", 0L, looper.nextScheduledTaskTime.toMillis())
        drag(frame, 300f, release = false)
        idle(100)
        (frame.parent as ViewGroup).removeView(frame)
        idle(3000)
        assertEquals("nothing left after detaching", 0L, looper.nextScheduledTaskTime.toMillis())
    }
}
