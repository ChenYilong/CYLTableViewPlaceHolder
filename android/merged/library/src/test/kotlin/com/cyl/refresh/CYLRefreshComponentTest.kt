package com.cyl.refresh

import android.app.Activity
import android.os.Looper
import android.os.SystemClock
import android.view.MotionEvent
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.cyl.refresh.layout.listener.ScrollBoundaryDecider
import com.cyl.refresh.layout.CYLRefreshLayout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNotSame
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.time.Duration

/**
 * The iOS-named refresh API of android/merged (`CYLRefreshComponent`, `CYLRefreshHeader`, `CYLRefreshFooter`,
 * `cyl_header` / `cyl_footer`), checked against the iOS behavior (docs/Android-API-Map.md).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLRefreshComponentTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private fun idle(ms: Long = 2000) = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(ms))

    private fun layout(contentHeight: Int = 3000): CYLRefreshLayout {
        val layout = CYLRefreshLayout(activity)
        layout.setRefreshContent(ScrollView(activity).apply {
            addView(LinearLayout(activity).apply { addView(View(activity), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, contentHeight)) })
        })
        return layout
    }

    private fun show(layout: CYLRefreshLayout): CYLRefreshLayout {
        activity.setContentView(layout)
        idle(100)
        return layout
    }

    private fun drag(view: View, dy: Float) {
        val down = SystemClock.uptimeMillis()
        var y = 300f
        view.dispatchTouchEvent(MotionEvent.obtain(down, down, MotionEvent.ACTION_DOWN, 200f, y, 0))
        repeat(20) {
            y += dy / 20
            view.dispatchTouchEvent(MotionEvent.obtain(down, down + 16L * (it + 1), MotionEvent.ACTION_MOVE, 200f, y, 0))
        }
        view.dispatchTouchEvent(MotionEvent.obtain(down, down + 700, MotionEvent.ACTION_MOVE, 200f, y, 0))
        view.dispatchTouchEvent(MotionEvent.obtain(down, down + 716, MotionEvent.ACTION_UP, 200f, y, 0))
    }

    @Test
    fun aPlainHeaderDrawsNothingAndReportsThePull() {
        val layout = show(layout())
        var largest = 0f
        var refreshes = 0
        // As a plain iOS CYLRefreshHeader: no drawing, the pull reaches the subclass hook (a listener header).
        val listener = object : CYLRefreshHeader(activity) {
            override fun didScrollWithOffset(offset: Int, percent: Float, dragging: Boolean) {
                largest = maxOf(largest, percent)
            }
        }.apply { refreshingBlock = { refreshes++ } }
        layout.cyl_header = listener
        idle(100)
        drag(layout, 900f)
        idle()
        assertTrue("the pull is reported", largest > 0f)
        assertEquals(1, refreshes)
        listener.endRefreshing()
        idle()
    }

    @Test
    fun removingTheHeaderTurnsPullToRefreshOff() {
        val layout = show(layout())
        var refreshes = 0
        layout.cyl_header = CYLRefreshNormalHeader(activity).apply { refreshingBlock = { refreshes++ } }
        layout.cyl_header = null
        assertNull(layout.cyl_header)
        drag(layout, 900f)
        idle()
        assertEquals("no header, no refresh", 0, refreshes)
    }

    @Test
    fun aHeaderRefreshesWithTheIOSCalls() {
        var refreshes = 0
        var began = 0
        var ended = 0
        val phases = ArrayList<CYLRefreshPhase>()
        val layout = show(layout())
        val header = CYLRefreshHeader.headerWithRefreshingBlock(activity) { refreshes++ }
        layout.cyl_header = header
        assertSame(header, layout.cyl_header)
        assertTrue(header.attached)
        assertNotNull(header.scrollView)
        header.addPhaseObserver { _, _, new -> phases += new }
        header.beginRefreshingWithCompletionBlock { began++ }
        idle()
        assertEquals(1, refreshes)
        assertEquals(1, began)
        assertTrue(header.isRefreshing)
        assertEquals(CYLRefreshState.Refreshing, header.state)
        header.endRefreshingWithCompletionBlock { ended++ }
        idle()
        assertEquals(1, ended)
        assertEquals(CYLRefreshState.Idle, header.state)
        assertFalse(header.isRefreshing)
        assertTrue(phases.containsAll(listOf(CYLRefreshPhase.Refreshing, CYLRefreshPhase.Finishing, CYLRefreshPhase.Idle)))
        assertNotNull("a successful refresh records the time", header.lastUpdatedTime)
    }

    @Test
    fun aPullMovesThePhasesAndThePercent() {
        val layout = show(layout())
        val header = CYLRefreshHeader.headerWithRefreshingBlock(activity) { }
        header.automaticallyChangeAlpha = true
        header.attach(layout)
        drag(layout, 600f)
        assertTrue("pulled: ${header.pullingPercent}", header.pullingPercent > 0f)
        assertTrue(header.dragOffset > 0)
        idle()
        assertEquals(CYLRefreshPhase.Refreshing, header.phase)
        assertEquals(1f, header.view.view.alpha)
        header.endRefreshingWithSuccess(false)
        assertFalse(header.lastRefreshSucceeded)
        idle()
        assertTrue(header.isInAnyPhase(CYLRefreshPhase.Idle))
    }

    @Test
    fun aFooterLoadsAndShowsNoMoreData() {
        var loads = 0
        val layout = show(layout(300))
        val footer = CYLRefreshFooter.footerWithRefreshingBlock(activity) { loads++ }
        layout.cyl_footer = footer
        footer.beginRefreshing()
        idle()
        assertEquals(1, loads)
        assertEquals(CYLRefreshState.Refreshing, footer.state)
        footer.endRefreshingWithNoMoreData()
        idle(3000)
        assertTrue(footer.noMoreData)
        assertEquals(CYLRefreshState.NoMoreData, footer.state)
        footer.resetNoMoreData()
        assertEquals(CYLRefreshState.Idle, footer.state)
    }

    @Test
    fun refreshEnabledAndDetaching() {
        var refreshes = 0
        val layout = show(layout())
        val header = CYLRefreshHeader.headerWithRefreshingBlock(activity) { refreshes++ }
        layout.cyl_header = header
        header.refreshEnabled = false
        drag(layout, 600f)
        idle()
        assertEquals(0, refreshes)
        layout.cyl_header = null
        assertNull(layout.cyl_header)
        assertFalse(header.attached)
    }

    @Test
    fun chainingSetsTheBlocks() {
        val layout = show(layout())
        var order = ""
        CYLRefreshHeader.headerWithRefreshingBlock(activity) { order += "r" }
            .cyl_afterBeginningAction { order += "b" }
            .cyl_endingAnimationBeginningAction { order += "e" }
            .cyl_afterEndingAction { order += "a" }
            .cyl_linkTo(layout)
        layout.cyl_header!!.beginRefreshing()
        idle()
        layout.cyl_header!!.endRefreshing()
        idle()
        assertEquals("rbea", order)
    }

    @Test
    fun anIconPerStateShowsAndScrubs() {
        // CYLRefreshIconView through the component's cyl_ calls: image frames per state, scrubbed while pulling.
        val layout = show(layout())
        val header = CYLRefreshHeader.headerWithRefreshingBlock(activity) { }
        layout.cyl_header = header
        assertFalse(header.cyl_usesIconView)
        val frames = listOf(android.graphics.drawable.ColorDrawable(1), android.graphics.drawable.ColorDrawable(2), android.graphics.drawable.ColorDrawable(3))
        header.cyl_setIconImages(frames, 0.3, CYLRefreshState.Refreshing)
        assertTrue(header.cyl_usesIconView)
        val icon = header.cyl_iconView
        assertSame(icon, header.cyl_iconView)
        assertNotNull(icon.animationAttributesForState(CYLRefreshState.Refreshing))
        assertEquals(40f, icon.iconSize[0])
        header.beginRefreshing()
        idle()
        assertEquals(View.VISIBLE, icon.visibility)
        assertTrue(icon.placeholderView.imageView.drawable is android.graphics.drawable.AnimationDrawable)
        header.cyl_showIconImageFrameOf(frames, 1f)
        assertSame(frames[2], icon.placeholderView.imageView.drawable)
        icon.title = "Loading"
        assertEquals("Loading", icon.placeholderView.textLabel.text.toString())
        assertTrue(icon.fittingSize[0] > 0)
        val attrs = CYLRefreshIconView.attributesForAnimationFilePath("a.json", 30f, 30f)
        assertEquals("a.json", attrs[CYLRefreshIconView.ANIMATION_FILE_PATH])
    }


    @Test
    fun theClassicHeadersAndFootersHaveTheIOSNames() {
        val layout = show(layout(300))
        val header = CYLRefreshNormalHeader(activity)
        var refreshes = 0
        header.refreshingBlock = { refreshes++ }
        header.setTitle("Pull me", CYLRefreshState.Idle).setTitle("Working", CYLRefreshState.Refreshing)
        header.cyl_modifyLastUpdatedTimeText { time -> if (time == null) "Never" else "Just now" }
        layout.cyl_header = header
        assertNotNull(header.stateLabel)
        assertNotNull(header.arrowView)
        assertNotNull(header.loadingView)
        assertEquals("Never", header.lastUpdatedTimeString)
        header.beginRefreshing()
        idle()
        assertEquals(1, refreshes)
        assertEquals("Working", header.stateLabel!!.text.toString())
        header.endRefreshing()
        idle()
        assertEquals("Just now", header.lastUpdatedTimeString)

        var loads = 0
        val footer = CYLRefreshAutoNormalFooter(activity)
        footer.refreshingBlock = { loads++ }
        footer.setTitle("That is all", CYLRefreshState.NoMoreData)
        layout.cyl_footer = footer
        assertEquals("That is all", footer.titleForState(CYLRefreshState.NoMoreData))
        footer.beginRefreshing()
        idle()
        assertEquals(1, loads)
        footer.endRefreshingWithNoMoreData()
        idle(3000)
        assertEquals("That is all", footer.stateLabel!!.text.toString())

        val gif = CYLRefreshBackGifFooter(activity)
        gif.setImages(listOf(android.graphics.drawable.ColorDrawable(1), android.graphics.drawable.ColorDrawable(2)), CYLRefreshState.Refreshing)
        assertTrue(gif.cyl_usesIconView)
        assertNotNull(gif.gifView)
    }


    @Test
    fun pagingRefreshesLoadsMoreAndStopsAtTheEnd() {
        val layout = show(layout(300))
        val header = CYLRefreshNormalHeader(activity)
        val footer = CYLRefreshBackNormalFooter(activity)
        layout.cyl_header = header
        layout.cyl_footer = footer
        val requested = ArrayList<Int>()
        var changes = 0
        val paging = CYLRefreshPaging(header, footer) { page, completion ->
            requested += page
            completion(List(10) { "p$page-$it" }, 25, 0, null)
        }
        paging.itemsDidChange = { changes++ }
        paging.start()
        idle()
        assertEquals(listOf(1), requested)
        assertEquals(10, paging.count)
        assertFalse(paging.isNoMore)
        assertEquals(CYLRefreshState.Idle, header.state)
        paging.loadMore()
        idle(3000)
        paging.loadMore()
        idle(3000)
        assertEquals(listOf(1, 2, 3), requested)
        assertEquals(30, paging.count)
        assertTrue("25 items in all: the third page is the last", paging.isNoMore)
        assertTrue(footer.noMoreData)
        paging.loadMore()
        idle()
        assertEquals("nothing after the last page", 3, requested.size)
        paging.refresh()
        idle()
        assertEquals(10, paging.count)
        assertFalse("a refresh clears no-more-data", footer.noMoreData)
        assertEquals("three pages and one refresh", 4, changes)
    }

    @Test
    fun theLeftoverComponentOptions() {
        val layout = show(layout())
        val header = CYLRefreshHeader.headerWithRefreshingBlock(activity) { }
        val footer = CYLRefreshFooter.footerWithRefreshingBlock(activity) { }
        layout.cyl_header = header
        layout.cyl_footer = footer
        header.autoHideRefresh = true
        assertTrue(header.isReadyToAutoHide())
        assertEquals(View.INVISIBLE, header.view.view.visibility)
        assertTrue(layout.cyl_autoHideRefreshHeader)
        header.beginRefreshingWithDuration(0.2, 20f, false)
        idle()
        assertTrue(header.expanded)
        assertEquals(View.VISIBLE, header.view.view.visibility)
        assertTrue(header.expandHeight > 0)
        var blocked = 0
        footer.blockedByOtherRefreshBlock = { blocked++ }
        footer.beginRefreshing()
        assertEquals("a load is refused while refreshing", 1, blocked)
        header.endRefreshing()
        idle()
        assertFalse(header.expanded)
        assertEquals(0, layout.cyl_totalDataCount())
        CYLRefreshConfig.defaultConfig.languageCode = "ko"
        assertEquals("ko", com.cyl.placeholder.CYLPlaceholderLocalization.language)
        CYLRefreshConfig.defaultConfig.languageCode = null
    }


    private class HookedMaterial(context: android.content.Context, val log: MutableList<String>) : CYLRefreshMaterialHeader(context) {
        override fun setUpComponent() { log += "setUp" }
        override fun onStartAnimationWhenRealeasing() { log += "releasing" }
        override fun onStartAnimationWhenRefreshing() { log += "refreshing" }
        override fun onRefreshFinishing(success: Boolean): Double { log += "finishing:$success"; return 0.0 }
        override fun onRefreshFinished(success: Boolean) { log += "finished:$success" }
    }

    @Test
    fun theDrawnHeadersRefreshAndCallTheirHooks() {
        val log = ArrayList<String>()
        val layout = show(layout())
        val header = HookedMaterial(activity, log)
        layout.cyl_header = header
        header.beginRefresh()
        idle()
        assertTrue(header.inStatus(CYLRefreshPhase.Refreshing))
        assertTrue(header.width > 0)
        header.finishRefreshWithSuccess(false)
        idle()
        assertFalse(header.isSuccess)
        assertEquals(listOf("setUp", "releasing", "refreshing", "finishing:false", "finished:false"), log)

        // Every drawn header attaches, refreshes and ends.
        val makers: List<(android.content.Context) -> CYLRefreshDrawnHeader> = listOf(
            { CYLRefreshBezierCircleHeader(it) }, { CYLRefreshBezierRadarHeader(it) }, { CYLRefreshDeliveryHeader(it) },
            { CYLRefreshPhoenixHeader(it) }, { CYLRefreshTaurusHeader(it) }, { CYLRefreshWaveSwipeHeader(it) },
            { CYLRefreshStoreHouseHeader.newWithString(it, "CYL") }, { CYLRefreshOriginalHeader(it) },
        )
        org.robolectric.shadows.ShadowChoreographer.setPaused(true)
        try {
            for (make in makers) {
                val drawn = make(activity)
                var refreshes = 0
                drawn.refreshingBlock = { refreshes++ }
                layout.cyl_header = drawn
                repeat(6) { idle(16) }
                drawn.beginRefresh()
                repeat(80) { idle(16) }
                assertEquals(drawn.javaClass.simpleName, 1, refreshes)
                drawn.finishRefresh()
                repeat(200) { idle(16) }
                assertEquals(drawn.javaClass.simpleName, CYLRefreshState.Idle, drawn.state)
            }
        } finally {
            org.robolectric.shadows.ShadowChoreographer.setPaused(false)
        }
    }


    @Test
    fun theSecondFloorOpensFromAPullAndClosesAgain() {
        val layout = show(layout())
        val header = CYLRefreshNormalHeader(activity)
        layout.cyl_header = header
        var refreshes = 0
        header.refreshingBlock = { refreshes++ }
        val page = View(activity)
        header.secondaryView = page
        header.secondaryDimension = 300f
        var opened = 0
        var closed = 0
        header.secondaryOpenedBlock = { opened++ }
        header.secondaryClosedBlock = { closed++ }
        header.openSecondary()
        assertTrue(header.secondaryOpen)
        assertEquals(CYLRefreshPhase.SecondaryOpen, header.phase)
        assertNotNull(page.parent)
        idle(1500)
        assertEquals(1, opened)
        header.closeSecondary()
        idle(1500)
        assertFalse(header.secondaryOpen)
        assertEquals(1, closed)
        assertNull("the content leaves the layout's parent", (page.parent as? android.view.ViewGroup)?.parent)
        assertEquals(0, refreshes)
        header.secondaryView = null
        header.openSecondary()
        assertFalse("no content: nothing opens", header.secondaryOpen)
    }

    @Test
    fun theBackFooterHoldsNoMoreDataAndOpensItsSecondFloor() {
        val layout = show(layout(300))
        val footer = CYLRefreshBackNormalFooter(activity)
        layout.cyl_footer = footer
        footer.noMoreDataDisplayDuration = 1.0
        footer.beginRefreshing()
        idle(1500)
        assertTrue(footer.isRefreshing)
        footer.endRefreshingWithNoMoreData()
        idle(300)
        assertTrue("held open while the text shows", footer.state == CYLRefreshState.Refreshing || footer.phase == CYLRefreshPhase.Finishing)
        idle(3000)
        assertEquals(CYLRefreshState.NoMoreData, footer.state)
        footer.secondaryView = View(activity)
        footer.openSecondary()
        assertTrue(footer.secondaryOpen)
        footer.closeSecondary()
        idle(1500)
        assertFalse(footer.secondaryOpen)
    }


    @Test
    fun aFarPullOpensTheSecondFloorInsteadOfRefreshing() {
        val layout = show(layout())
        val header = CYLRefreshNormalHeader(activity)
        layout.cyl_header = header
        var refreshes = 0
        header.refreshingBlock = { refreshes++ }
        header.secondaryView = View(activity)
        header.secondaryTriggerOffset = 200f
        drag(layout, 700f)
        idle(2500)
        assertTrue("a pull past 200dp opens the second floor", header.secondaryOpen)
        assertEquals("and does not refresh", 0, refreshes)
        header.closeSecondary()
        idle(1500)
        // A short pull still refreshes.
        drag(layout, 260f)
        idle(2500)
        assertFalse(header.secondaryOpen)
        assertEquals(1, refreshes)
    }


    @Test
    fun cupertinoAndDrawnFootersPullAndLoad() {
        val layout = show(layout(300))
        val header = CYLRefreshCupertinoHeader(activity)
        layout.cyl_header = header
        header.beginRefreshing()
        idle(1500)
        assertTrue(header.activityIndicator.isAnimating)
        header.endRefreshing()
        idle(2000)
        assertFalse(header.activityIndicator.isAnimating)

        val makers: List<(android.content.Context) -> CYLRefreshFooter> = listOf(
            { CYLRefreshCupertinoFooter(it) }, { CYLRefreshMaterialFooter(it) }, { CYLRefreshBezierRadarFooter(it) },
            { CYLRefreshDeliveryFooter(it) }, { CYLRefreshPhoenixFooter(it) }, { CYLRefreshTaurusFooter(it) },
        )
        org.robolectric.shadows.ShadowChoreographer.setPaused(true)
        try {
            for (make in makers) {
                val footer = make(activity)
                var loads = 0
                footer.refreshingBlock = { loads++ }
                layout.cyl_footer = footer
                repeat(6) { idle(16) }
                footer.beginRefreshing()
                repeat(80) { idle(16) }
                assertEquals(footer.javaClass.simpleName, 1, loads)
                footer.endRefreshing()
                repeat(200) { idle(16) }
                assertEquals(footer.javaClass.simpleName, CYLRefreshState.Idle, footer.state)
            }
        } finally {
            org.robolectric.shadows.ShadowChoreographer.setPaused(false)
        }
    }


    @Test
    fun drawnFootersShowTheirDrawingWhileLoading() {
        val layout = show(layout(300))
        for (footer in listOf(CYLRefreshBezierRadarFooter(activity), CYLRefreshPhoenixFooter(activity))) {
            layout.cyl_footer = footer
            idle(50)
            footer.beginRefreshing()
            idle(600)
            val drawn = footer.style.view.view
            val name = footer.javaClass.simpleName
            // The drawing keeps the footer's height (not the layout's), inside the layout, so it shows.
            assertTrue(name, drawn.height in 1 until layout.height)
            assertTrue(name, footer.view.view.bottom <= layout.height)
            footer.endRefreshing()
            idle(1500)
        }
    }


    @Test
    fun secondFloorCoversTheLayoutInsideALinearLayout() {
        // A bar above the layout: the floor must start at the layout, not at the window's top.
        val layout = layout(300)
        val column = LinearLayout(activity).apply {
            orientation = LinearLayout.VERTICAL
            addView(View(activity), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 100))
            addView(layout, LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f))
        }
        activity.setContentView(column)
        idle(100)
        val header = CYLRefreshNormalHeader(activity)
        layout.cyl_header = header
        val page = View(activity)
        header.secondaryView = page
        header.secondaryTriggerOffset = 50f
        idle(50)
        header.floor.open()
        idle(1000)
        val floorAt = IntArray(2).also { (page.parent as View).getLocationInWindow(it) }
        val layoutAt = IntArray(2).also(layout::getLocationInWindow)
        assertEquals("top", layoutAt[1], floorAt[1])
        assertEquals("height", layout.height, (page.parent as View).height)
    }


    @Test
    fun theStateClassesShowResultAndNoMoreDataImages() {
        val layout = show(layout())
        val header = CYLRefreshNormalHeader(activity)
        layout.cyl_header = header
        val ok = android.graphics.drawable.ColorDrawable(0xFF00AA00.toInt())
        val bad = android.graphics.drawable.ColorDrawable(0xFFAA0000.toInt())
        header.succeededImage = ok
        header.failedImage = bad
        // The layout finishes a refresh within one animation pass, so the view is driven the way the layout does.
        val classics = header.view as CYLClassicsHeaderView
        val spinner = header.loadingView!!.drawable
        classics.onFinish(layout, true)
        assertSame("the spinner shows the check", ok, header.loadingView!!.drawable)
        assertEquals(View.VISIBLE, header.loadingView!!.visibility)
        classics.onStateChanged(layout, com.cyl.refresh.layout.constant.RefreshState.RefreshFinish, com.cyl.refresh.layout.constant.RefreshState.None)
        assertSame("the spinner is back and hidden", spinner, header.loadingView!!.drawable)
        assertEquals(View.GONE, header.loadingView!!.visibility)
        classics.onFinish(layout, false)
        assertSame("the cross after a failure", bad, header.loadingView!!.drawable)
        classics.onStartAnimator(layout, 100, 200)
        assertSame("a new refresh shows the spinner again", spinner, header.loadingView!!.drawable)

        val lp = { v: View -> v.layoutParams as android.widget.RelativeLayout.LayoutParams }
        assertTrue(lp(header.arrowView!!).getRule(android.widget.RelativeLayout.LEFT_OF) != 0)
        header.iconOnTrailingSide = true
        assertEquals(0, lp(header.arrowView!!).getRule(android.widget.RelativeLayout.LEFT_OF))
        assertTrue(lp(header.arrowView!!).getRule(android.widget.RelativeLayout.RIGHT_OF) != 0)
        header.iconOnTrailingSide = false
        assertTrue(lp(header.arrowView!!).getRule(android.widget.RelativeLayout.LEFT_OF) != 0)

        val footer = CYLRefreshBackNormalFooter(activity)
        layout.cyl_footer = footer
        val done = android.graphics.drawable.ColorDrawable(0xFF0000AA.toInt())
        footer.noMoreDataImage = done
        footer.noticeNoMoreData()
        idle(100)
        assertSame(done, footer.arrowView!!.drawable)
        assertEquals(View.VISIBLE, footer.arrowView!!.visibility)
        footer.resetNoMoreData()
        idle(100)
        assertNotSame(done, footer.arrowView!!.drawable)
    }




    @Test
    fun triggerModeOnEdgeBlocksAPullThatStartedInTheMiddle() {
        val list = RecyclerView(activity).apply {
            layoutManager = LinearLayoutManager(activity)
            adapter = object : RecyclerView.Adapter<RecyclerView.ViewHolder>() {
                override fun getItemCount() = 50
                override fun onCreateViewHolder(parent: ViewGroup, viewType: Int) =
                    object : RecyclerView.ViewHolder(TextView(activity).apply { layoutParams = RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, 100) }) {}
                override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) = Unit
            }
        }
        val layout = CYLRefreshLayout(activity).apply { setRefreshContent(list) }
        show(layout)
        val header = CYLRefreshNormalHeader(activity)
        layout.cyl_header = header
        assertEquals("default, as on iOS", CYLRefreshTriggerMode.Anywhere, header.triggerMode)
        header.triggerMode = CYLRefreshTriggerMode.OnEdge
        idle(50)
        val field = CYLRefreshLayout::class.java.getDeclaredField("mScrollBoundaryDecider").apply { isAccessible = true }
        val decider = field.get(layout) as ScrollBoundaryDecider
        val bridge = CYLRefreshBridge.of(layout)
        // The drag starts in the middle, then scrolls back to the top: no pull.
        list.scrollBy(0, 1000)
        bridge.dragStarted(list)
        list.scrollBy(0, -1000)
        assertFalse("started in the middle", decider.canRefresh(list))
        // A drag that starts at the top pulls.
        bridge.dragStarted(list)
        assertTrue("started at the top", decider.canRefresh(list))
        // Anywhere removes the decider.
        header.triggerMode = CYLRefreshTriggerMode.Anywhere
        assertNull(field.get(layout))
    }



    @Test
    fun flyHeaderBringsItsSceneAndRestoresTheContent() {
        val layout = show(layout())
        val content = layout.cyl_header.let { (0 until layout.childCount).map(layout::getChildAt).first() }
        val header = CYLRefreshFlyHeader(activity)
        layout.cyl_header = header
        idle(100)
        val density = activity.resources.displayMetrics.density
        assertEquals("scene height", (150 * density).toInt(), header.mountainView.height)
        val sceneAt = IntArray(2).also(header.mountainView::getLocationInWindow)
        val contentAt = IntArray(2).also(content::getLocationInWindow)
        assertEquals("content below the scene", sceneAt[1] + header.mountainView.height, contentAt[1])
        assertTrue("plane shown", header.flyView.width > 0 && header.flyView.isShown)
        layout.cyl_header = null
        idle(50)
        assertSame("content restored", layout, content.parent)
        assertNull(header.mountainView.parent)
    }



    /** iOS `enableReverseFlash` / `enableFadeAnimation` reach the drawn StoreHouse view. */
    @Test
    fun storeHouseReverseFlashAndFadeOptions() {
        val header = CYLRefreshStoreHouseHeader(activity)
        val view = header.view as com.cyl.refresh.header.StoreHouseHeader
        assertEquals(false, header.enableReverseFlash)
        assertEquals(true, header.enableFadeAnimation)
        header.enableReverseFlash = true
        header.enableFadeAnimation = false
        assertEquals(true, view.mReverseFlash)
        assertEquals(false, view.mFadeAnimation)
    }

    /** The iOS categories on every control: state titles, animation images, bundled icons, the no-more-data image. */
    @Test
    fun iosCategoriesOnEveryControl() {
        val state = CYLRefreshNormalHeader(activity)
        state.cyl_setStateTitle("Pull me", CYLRefreshState.Idle)
        assertEquals("Pull me", state.cyl_stateTitleForState(CYLRefreshState.Idle))
        assertEquals("shown by the state header", "Pull me", state.titleForState(CYLRefreshState.Idle))
        val drawn = CYLRefreshMaterialHeader(activity)
        drawn.cyl_setStateTitle("Kept", CYLRefreshState.Refreshing)
        assertEquals("kept by a control without text", "Kept", drawn.cyl_stateTitleForState(CYLRefreshState.Refreshing))
        val footer = CYLRefreshBackNormalFooter(activity)
        val image = android.graphics.drawable.ColorDrawable(android.graphics.Color.RED)
        footer.cyl_updateNoMoreDataImage(image)
        assertEquals(image, footer.noMoreDataImage)
        assertEquals(image, footer.cyl_noMoreDataImage)
        val header = CYLRefreshAnimationHeader(activity)
        header.cyl_setBundledIconAnimation("CYLPlaceholderLoading.json", 30f, 30f, CYLRefreshState.Refreshing)
        assertTrue(header.cyl_usesIconView)
        header.cyl_setAnimationImages(listOf(image, image), 0.4, CYLRefreshState.Idle)
        assertTrue(header.cyl_iconView.hasAnimations)
        val icon = CYLRefreshIconView(activity)
        icon.titleTypeface = android.graphics.Typeface.DEFAULT_BOLD
        assertEquals(android.graphics.Typeface.DEFAULT_BOLD, icon.placeholderView.defaultTitleTypeface)
    }

    /** iOS triggersWhenReached on a header: it refreshes when the pull arms it, before the finger lifts. */
    @Test
    fun headerTriggersWhenReachedRefreshesBeforeTheRelease() {
        val layout = show(layout())
        val header = CYLRefreshNormalHeader(activity)
        layout.cyl_header = header
        header.triggersWhenReached = true
        val down = SystemClock.uptimeMillis()
        var y = 300f
        layout.dispatchTouchEvent(MotionEvent.obtain(down, down, MotionEvent.ACTION_DOWN, 200f, y, 0))
        repeat(20) {
            y += 45f
            layout.dispatchTouchEvent(MotionEvent.obtain(down, down + 16L * (it + 1), MotionEvent.ACTION_MOVE, 200f, y, 0))
        }
        idle(600)
        assertTrue("refreshing while the finger is still down", header.isRefreshing)
    }

    /** iOS finishingDurationWithSuccess: a subclass's hold is what the classic view returns to the layout. */
    @Test
    fun classicViewsHoldAsLongAsTheComponentSays() {
        val layout = show(layout())
        val header = object : CYLRefreshNormalHeader(activity) {
            override fun finishingDurationWithSuccess(success: Boolean) = if (success) 1.5 else 0.25
        }
        layout.cyl_header = header
        val view = header.view as com.cyl.refresh.layout.api.RefreshHeader
        assertEquals(1500, view.onFinish(layout, true))
        assertEquals(250, view.onFinish(layout, false))
        header.finishDuration = 0.8
        val plain = CYLRefreshNormalHeader(activity).apply { finishDuration = 0.8 }
        assertEquals(800, (plain.view as com.cyl.refresh.layout.api.RefreshHeader).onFinish(layout, true))
    }

    /** iOS notifiesWhenHidden off: a hidden component skips the pull. scrollMode reaches drawn styles too. */
    @Test
    fun hiddenComponentsSkipThePullAndDrawnStylesTakeScrollMode() {
        val header = CYLRefreshNormalHeader(activity)
        header.notifiesWhenHidden = false
        header.view.view.visibility = View.GONE
        header.moved(40, 0.5f, true)
        assertEquals(0f, header.pullingPercent, 0f)
        header.view.view.visibility = View.VISIBLE
        header.moved(40, 0.5f, true)
        assertEquals(0.5f, header.pullingPercent, 0f)
        val material = CYLRefreshMaterialHeader(activity)
        material.scrollMode = CYLRefreshScrollMode.Front
        assertEquals(CYLRefreshScrollMode.Front, material.scrollMode)
    }
}
