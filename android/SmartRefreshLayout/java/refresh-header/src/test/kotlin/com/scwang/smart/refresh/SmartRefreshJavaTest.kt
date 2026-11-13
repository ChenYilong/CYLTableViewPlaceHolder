package com.scwang.smart.refresh

import android.animation.ValueAnimator
import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import android.content.SharedPreferences
import android.content.res.Configuration
import android.os.Handler
import android.os.SystemClock
import android.view.MotionEvent
import android.widget.FrameLayout
import java.util.Locale
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.ScrollView
import com.scwang.smart.refresh.footer.ClassicsFooter
import com.scwang.smart.refresh.header.ClassicsHeader
import com.scwang.smart.refresh.header.MaterialHeader
import com.scwang.smart.refresh.header.TwoLevelHeader
import com.scwang.smart.refresh.header.BezierRadarHeader
import com.scwang.smart.refresh.header.FalsifyHeader
import com.scwang.smart.refresh.footer.BallPulseFooter
import com.scwang.smart.drawable.PathsDrawable
import android.graphics.Bitmap
import android.graphics.Canvas
import com.scwang.smart.refresh.header.BezierCircleHeader
import com.scwang.smart.refresh.header.DeliveryHeader
import com.scwang.smart.refresh.header.DropBoxHeader
import com.scwang.smart.refresh.header.FlyRefreshHeader
import com.scwang.smart.refresh.header.FunGameBattleCityHeader
import com.scwang.smart.refresh.header.FunGameHitBlockHeader
import com.scwang.smart.refresh.header.PhoenixHeader
import com.scwang.smart.refresh.header.StoreHouseHeader
import com.scwang.smart.refresh.header.TaurusHeader
import com.scwang.smart.refresh.header.WaterDropHeader
import com.scwang.smart.refresh.header.WaveSwipeHeader
import com.scwang.smart.refresh.header.flyrefresh.FlyView
import com.scwang.smart.refresh.header.flyrefresh.MountainSceneView
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.SmartRefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.shadows.ShadowToast
import org.robolectric.annotation.Config
import org.robolectric.annotation.GraphicsMode
import java.time.Duration

/**
 * SmartRefreshLayout's Java source with the taken pull requests and the issue fixes (docs/Android-Port.md); each test
 * names its pull requests and issues.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class SmartRefreshJavaTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private fun idle(millis: Long = 2000) = shadowOf(Looper.getMainLooper()).idleFor(Duration.ofMillis(millis))

    private fun content(height: Int) = ScrollView(activity).apply {
        addView(LinearLayout(activity).apply { addView(View(activity), LinearLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, height)) })
    }

    private var refreshes = 0
    private var loads = 0

    private fun layout(contentHeight: Int = 3000): SmartRefreshLayout {
        val layout = SmartRefreshLayout(activity)
        layout.setRefreshContent(content(contentHeight))
        layout.setRefreshHeader(ClassicsHeader(activity))
        layout.setRefreshFooter(ClassicsFooter(activity))
        // A listener that keeps refreshing until the test finishes it (without one the layout finishes after 3 s).
        layout.setOnRefreshListener { refreshes++ }
        layout.setOnLoadMoreListener { loads++ }
        activity.setContentView(layout)
        idle(100)
        return layout
    }

    private fun translationContent(layout: SmartRefreshLayout): Boolean {
        val f = SmartRefreshLayout::class.java.getDeclaredField("mEnableHeaderTranslationContent")
        f.isAccessible = true
        return f.getBoolean(layout)
    }

    @Test
    fun autoRefreshIsToldToTheHeader() {
        // Pull request #1095; #1268: an auto refresh is told apart from a drag.
        val layout = layout()
        val header = layout.refreshHeader as ClassicsHeader
        assertFalse(header.isAutoRefresh)
        layout.autoRefresh()
        idle()
        assertEquals(RefreshState.Refreshing, layout.state)
        assertTrue(header.isAutoRefresh)
        layout.finishRefresh(0)
        idle()
        assertEquals(RefreshState.None, layout.state)
        assertFalse(header.isAutoRefresh)
    }

    @Test
    fun aHeadersTranslationDefaultDoesNotStayForTheNextHeader() {
        // Pull request #1095; #1075, #1396: after a MaterialHeader, a ClassicsHeader moves the content again.
        val layout = layout()
        val material = MaterialHeader(activity)
        material.setProgressAlpha(128)
        layout.setRefreshHeader(material)
        idle(100)
        assertFalse("the MaterialHeader keeps the content in place", translationContent(layout))
        layout.setRefreshHeader(ClassicsHeader(activity))
        idle(100)
        assertTrue("the next header moves the content again", translationContent(layout))
        layout.setEnableHeaderTranslationContent(false)
        layout.setRefreshHeader(ClassicsHeader(activity))
        idle(100)
        assertFalse("the app's own setting stays", translationContent(layout))
    }

    private fun field(obj: Any, name: String): java.lang.reflect.Field {
        var c: Class<*>? = obj.javaClass
        while (c != null) {
            try { return c.getDeclaredField(name).apply { isAccessible = true } } catch (_: NoSuchFieldException) { c = c.superclass }
        }
        throw NoSuchFieldException(name)
    }

    private fun method(obj: Any, name: String, vararg types: Class<*>): java.lang.reflect.Method {
        var c: Class<*>? = obj.javaClass
        while (c != null) {
            try { return c.getDeclaredMethod(name, *types).apply { isAccessible = true } } catch (_: NoSuchMethodException) { c = c.superclass }
        }
        throw NoSuchMethodException(name)
    }

    /** A content that records the pointer ids of every event it gets. */
    private class Recorder(context: Context) : FrameLayout(context) {
        val pointerSets = mutableListOf<Pair<Int, Set<Int>>>()
        override fun dispatchTouchEvent(ev: MotionEvent): Boolean {
            pointerSets += ev.actionMasked to (0 until ev.pointerCount).map { ev.getPointerId(it) }.toSet()
            return true
        }
    }

    private fun twoFingers(down: Long, time: Long, action: Int, y: Float): MotionEvent {
        val props = arrayOf(MotionEvent.PointerProperties().apply { id = 0 }, MotionEvent.PointerProperties().apply { id = 1 })
        val coords = arrayOf(MotionEvent.PointerCoords().apply { x = 150f; this.y = y }, MotionEvent.PointerCoords().apply { x = 150f; this.y = y + 50f })
        return MotionEvent.obtain(down, time, action, 2, props, coords, 0, 0, 1f, 1f, 0, 0, 0, 0)
    }

    @Test
    fun eventsSentToChildrenKeepTheFingers() {
        // #532, #1227, #1319, #1496: the events the layout sends to its children keep both fingers, so a ViewPager
        // finds the pointer it tracks.
        val layout = SmartRefreshLayout(activity)
        val recorder = Recorder(activity)
        layout.setRefreshContent(recorder)
        layout.setRefreshHeader(ClassicsHeader(activity))
        layout.setOnRefreshListener { }
        activity.setContentView(layout)
        idle(100)
        val t = SystemClock.uptimeMillis()
        // The first finger starts where the two fingers' middle will be, so the move reads as vertical.
        layout.dispatchTouchEvent(MotionEvent.obtain(t, t, MotionEvent.ACTION_DOWN, 150f, 300f, 0))
        layout.dispatchTouchEvent(twoFingers(t, t + 10, MotionEvent.ACTION_POINTER_DOWN or (1 shl MotionEvent.ACTION_POINTER_INDEX_SHIFT), 300f))
        var y = 300f
        var time = t + 10
        repeat(20) { y += 15f; time += 16; layout.dispatchTouchEvent(twoFingers(t, time, MotionEvent.ACTION_MOVE, y)) }
        repeat(40) { y -= 15f; time += 16; layout.dispatchTouchEvent(twoFingers(t, time, MotionEvent.ACTION_MOVE, y)) }
        val afterSecond = recorder.pointerSets.dropWhile { it.first != MotionEvent.ACTION_POINTER_DOWN }.drop(1)
        assertTrue("the content got events after the pull went back", afterSecond.isNotEmpty())
        val moves = afterSecond.filter { it.first == MotionEvent.ACTION_MOVE }
        assertTrue("the content got moves", moves.isNotEmpty())
        assertTrue("every move keeps the second finger: $afterSecond", moves.all { 1 in it.second })
    }

    @Test
    fun theHandlerRunsOnTheMainThreadWhenBuiltOnAnother() {
        // #1129: AsyncLayoutInflater builds the layout on a background thread; finishing still works (fixed in the
        // source since; checked here).
        var built: SmartRefreshLayout? = null
        val thread = Thread {
            android.os.Looper.prepare()
            built = SmartRefreshLayout(activity)
        }
        thread.start()
        thread.join()
        val handler = field(built!!, "mHandler").get(built) as Handler
        assertEquals(android.os.Looper.getMainLooper(), handler.looper)
    }

    @Test
    fun anInvalidLastUpdatePatternDoesNotCrash() {
        // #1431, #1603: "Illegal pattern character 't'" from an unquoted last-update text.
        val old = ClassicsHeader.REFRESH_HEADER_UPDATE
        ClassicsHeader.REFRESH_HEADER_UPDATE = "Last update M-d HH:mm"
        try {
            ClassicsHeader(activity)
        } finally {
            ClassicsHeader.REFRESH_HEADER_UPDATE = old
        }
    }

    @Test
    fun lastUpdatePreferencesAreReadOffTheMainThread() {
        // #1591: StrictMode disk reads.
        val threads = mutableListOf<String>()
        val context = object : ContextWrapper(activity) {
            override fun getApplicationContext(): Context = this
            override fun getSharedPreferences(name: String?, mode: Int): SharedPreferences {
                threads += Thread.currentThread().name
                return super.getSharedPreferences(name, mode)
            }
        }
        ClassicsHeader(context)
        Thread.sleep(300)
        idle(100)
        assertTrue("read at all", threads.isNotEmpty())
        assertTrue("never on the main thread: $threads", threads.none { it == Thread.currentThread().name })
    }

    @Test
    fun noEasterEggToast() {
        // #1105, #1110: no surprise toast after a very long pull at the top left.
        val layout = layout()
        field(layout, "mLastTouchX").setFloat(layout, 1f)
        field(layout, "mLastTouchY").setFloat(layout, 1f)
        val screen = field(layout, "mScreenHeightPixels").getInt(layout)
        method(layout, "moveSpinnerInfinitely", Float::class.javaPrimitiveType!!).invoke(layout, screen * 6f)
        idle(100)
        assertEquals(null, ShadowToast.getLatestToast())
    }

    @Test
    fun materialAutoOpenEndsWithoutTheKernel() {
        // #1547, #1584, #1589: a MaterialHeader whose kernel is gone when its open animation ends does not crash.
        val layout = layout()
        val material = MaterialHeader(activity)
        layout.setRefreshHeader(material)
        idle(100)
        assertTrue(material.autoOpen(300, 1f, false))
        field(material, "mKernel").set(material, null)
        idle(1000)
    }

    @Test
    fun noMoreDataWhileLoadingWithoutAFooterDoesNotRecurse() {
        // #1350: StackOverflowError from setNoMoreData -> finishLoadMoreWithNoMoreData -> setNoMoreData.
        val layout = layout()
        method(layout, "notifyStateChanged", RefreshState::class.java).invoke(layout, RefreshState.Loading)
        field(layout, "mRefreshFooter").set(layout, null)
        layout.setNoMoreData(true)
        idle(500)
        assertEquals(RefreshState.None, layout.state)
    }

    @Test
    fun classicsTextsInSevenLanguages() {
        // #1291: languages beyond Chinese and English.
        val expected = mapOf("ja" to "引っ張って更新", "ko" to "당겨서 새로고침", "ru" to "Потяните, чтобы обновить",
            "uk" to "Потягніть, щоб оновити", "zh-Hant" to "下拉可以重新整理", "zh-Hans" to "下拉可以刷新", "en" to "Pull Down To Refresh")
        for ((tag, text) in expected) {
            val config = Configuration(activity.resources.configuration).apply { setLocale(Locale.forLanguageTag(tag)) }
            val localized = activity.createConfigurationContext(config)
            assertEquals(tag, text, localized.getString(com.scwang.smart.refresh.header.classics.R.string.srl_header_pulling))
        }
        val config = Configuration(activity.resources.configuration).apply { setLocale(Locale.forLanguageTag("ja")) }
        assertEquals("これ以上データはありません", activity.createConfigurationContext(config).getString(com.scwang.smart.refresh.footer.classics.R.string.srl_footer_nothing))
    }

    @Test
    fun twoLevelHeaderOpensAndClosesTheSecondFloor() {
        // The two-level header wraps a classics header by default, asks its listener, opens and closes the second floor.
        val layout = layout()
        val twoLevel = TwoLevelHeader(activity)
        layout.setRefreshHeader(twoLevel)
        idle(100)
        assertTrue("wraps a ClassicsHeader", (0 until twoLevel.childCount).any { twoLevel.getChildAt(it) is ClassicsHeader })
        var asked = 0
        twoLevel.setOnTwoLevelListener { asked++; false }
        twoLevel.openTwoLevel(true)
        idle()
        assertEquals(1, asked)
        assertFalse("the listener kept it closed", layout.state == RefreshState.TwoLevel)
        twoLevel.setOnTwoLevelListener { asked++; true }
        twoLevel.openTwoLevel(true)
        idle()
        assertEquals(2, asked)
        assertEquals(RefreshState.TwoLevel, layout.state)
        twoLevel.finishTwoLevel()
        idle()
        assertEquals(RefreshState.None, layout.state)
    }

    @Test
    fun radarHeaderAndBallFooterRefreshAndLoad() {
        val layout = layout()
        layout.setRefreshHeader(BezierRadarHeader(activity))
        layout.setRefreshFooter(BallPulseFooter(activity))
        idle(100)
        layout.autoRefresh()
        idle()
        assertEquals(RefreshState.Refreshing, layout.state)
        layout.finishRefresh(0)
        idle()
        assertEquals(RefreshState.None, layout.state)
        layout.autoLoadMore()
        idle()
        assertEquals(RefreshState.Loading, layout.state)
        layout.finishLoadMore(0)
        idle()
        assertEquals(RefreshState.None, layout.state)
    }

    @Test
    fun falsifyHeaderNeverRefreshes() {
        val layout = layout()
        layout.setRefreshHeader(FalsifyHeader(activity))
        idle(100)
        layout.autoRefresh()
        idle()
        assertEquals(RefreshState.None, layout.state)
        assertEquals(0, refreshes)
    }

    @Test
    @GraphicsMode(GraphicsMode.Mode.NATIVE)
    fun pathsDrawableParsesAndScalesSvgPaths() {
        // Native graphics: the legacy shadows do not compute a path's region.
        val drawable = PathsDrawable()
        // A path drawable measured every path empty on API 34 (a Region clipped to +/-Int.MAX_VALUE is empty in Skia).
        assertTrue(drawable.parserPaths("M0,0 L10,0 L10,20 Z", "M2,2 h4 v4 h-4 z"))
        assertEquals(10, drawable.bounds.width())
        assertEquals(20, drawable.bounds.height())
        drawable.setBounds(0, 0, 20, 40)
        assertEquals(20, drawable.bounds.width())
        assertEquals(40, drawable.bounds.height())
        assertFalse("empty data", PathsDrawable().parserPaths(""))
        assertTrue("arcs parse", com.scwang.smart.drawable.path.PathParser.createPathFromPathData("M0,0 a5,5 0 1,1 10,0")?.isEmpty == false)
    }

    private fun drawFrame(view: View) {
        val bitmap = Bitmap.createBitmap(maxOf(1, view.width), maxOf(1, view.height), Bitmap.Config.ARGB_8888)
        view.draw(Canvas(bitmap))
    }

    @Test
    fun everyHeaderInRefreshHeaderRefreshesDrawsAndFinishes() {
        // The Kotlin headers also read "Refreshing" / "Refreshed" to accessibility services; the Java ones do not.
        val kotlin = runCatching { Class.forName("com.scwang.smart.refresh.header.HeaderAccessibilityKt") }.isSuccess
        val headers: List<Pair<String, (Context) -> RefreshHeader>> = listOf(
            "StoreHouse" to { c -> StoreHouseHeader(c) }, "WaterDrop" to { c -> WaterDropHeader(c) }, "Delivery" to { c -> DeliveryHeader(c) },
            "DropBox" to { c -> DropBoxHeader(c) }, "BezierCircle" to { c -> BezierCircleHeader(c) }, "Phoenix" to { c -> PhoenixHeader(c) },
            "Taurus" to { c -> TaurusHeader(c) }, "WaveSwipe" to { c -> WaveSwipeHeader(c) }, "HitBlock" to { c -> FunGameHitBlockHeader(c) },
            "BattleCity" to { c -> FunGameBattleCityHeader(c) },
        )
        // Frames only when the test advances the clock: DropBox animates without end while refreshing, and Robolectric
        // otherwise advances the clock with each frame, so idle() never returned.
        org.robolectric.shadows.ShadowChoreographer.setPaused(true)
        try {
            refreshDrawAndFinishEach(headers, kotlin)
        } finally {
            org.robolectric.shadows.ShadowChoreographer.setPaused(false)
        }
    }

    // 16 ms frames: with the choreographer paused, one long idle would jump to the end in a single frame.
    private fun frames(millis: Long) = repeat((millis / 16).toInt()) { idle(16) }

    private fun refreshDrawAndFinishEach(headers: List<Pair<String, (Context) -> RefreshHeader>>, kotlin: Boolean) {
        for ((name, create) in headers) {
            val layout = layout()
            val header = create(activity)
            layout.setRefreshHeader(header)
            frames(100)
            layout.autoRefresh()
            frames(1000)
            assertEquals(name, RefreshState.Refreshing, layout.state)
            drawFrame(layout)
            if (kotlin) {
                assertEquals(name, "Refreshing", header.view.contentDescription)
                assertEquals(name, View.IMPORTANT_FOR_ACCESSIBILITY_YES, header.view.importantForAccessibility)
            }
            layout.finishRefresh(0)
            frames(2000)
            assertEquals(name, RefreshState.None, layout.state)
            drawFrame(layout)
            if (kotlin) assertEquals(name, View.IMPORTANT_FOR_ACCESSIBILITY_NO, header.view.importantForAccessibility)
        }
    }

    @Test
    fun flyRefreshHeaderFliesThePlaneAndLandsIt() {
        val layout = layout()
        val header = FlyRefreshHeader(activity)
        val scene = MountainSceneView(activity)
        val plane = FlyView(activity)
        header.setUp(scene, plane)
        layout.setRefreshHeader(header)
        idle(100)
        header.onMoving(true, 1f, 100, 100, 100)
        assertTrue("the plane tilts with the pull", plane.rotation < 0)
        header.onReleased(layout, 100, 100)
        idle()
        assertTrue("the plane flew off", plane.translationX > 0)
        header.finishRefresh()
        idle()
        assertEquals("the plane is back", 0f, plane.translationX, 0.01f)
        drawFrame(scene)
    }
}
