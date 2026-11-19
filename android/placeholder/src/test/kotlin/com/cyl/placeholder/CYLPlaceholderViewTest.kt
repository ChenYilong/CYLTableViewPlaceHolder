package com.cyl.placeholder

import android.content.Context
import android.view.View
import androidx.test.core.app.ApplicationProvider
import com.cyl.animateditem.CYLAnimatedItemAxis
import com.cyl.animateditem.CYLAnimatedItemView
import org.junit.Assert.assertSame
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * CYLPlaceholderView with the iOS API (docs/Android-API-Map.md), a CYLAnimatedItemView of CYLTabBarController.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLPlaceholderViewTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    @Test
    fun everyStyleHasItsIconAndEveryMessageItsText() {
        CYLPlaceholderStyle.entries.forEach { assertNotNull(it.name, CYLPlaceholderView.imageForStyle(context, it)) }
        assertEquals("CYLPlaceholderWifiOff", CYLPlaceholderView.imageNameForStyle(CYLPlaceholderStyle.WifiOff))
        assertEquals("No internet connection", CYLPlaceholderView.localizedTextForMessage(context, CYLPlaceholderMessage.NoInternet))
        val view = CYLPlaceholderView(context, CYLPlaceholderStyle.WifiOff, CYLPlaceholderMessage.NoInternet)
        assertNotNull(view.imageView.drawable)
        assertEquals("No internet connection", view.textLabel.text.toString())
        assertEquals("No internet connection", view.itemAttributes["CYLPlaceholderItemTitle"].toString())
    }

    @Test
    fun aBadgeShowsDotsNumbersAndTexts() {
        val view = CYLPlaceholderView(context, CYLPlaceholderStyle.Inbox, "Inbox")
        view.badgeValue = "3"
        assertEquals(View.VISIBLE, view.badgeLabel.visibility)
        assertEquals("3", view.badgeLabel.text.toString())
        assertEquals("Inbox, 3", view.contentDescription)
        view.badgeValue = ""
        assertEquals("", view.badgeLabel.text.toString())
        view.badgeValue = null
        assertEquals(View.GONE, view.badgeLabel.visibility)
    }

    @Test
    fun aTapRunsTheHandlerUnlessTurnedOff() {
        var taps = 0
        val view = CYLPlaceholderView(context, CYLPlaceholderStyle.Refresh, "Reload")
        assertFalse(view.tapInteractive)
        view.tapHandler = { taps++ }
        assertTrue(view.tapInteractive)
        view.performClick()
        assertEquals(1, taps)
        view.tapInteractionEnabled = false
        assertFalse(view.performTap())
        assertEquals(1, taps)
    }

    @Test
    fun selectionChangesTheColors() {
        val view = CYLPlaceholderView(context, CYLPlaceholderStyle.Favorite, "Saved")
        view.defaultSelectedTitleColor = 0xFFFF0000.toInt()
        assertEquals(view.defaultTitleColor, view.textLabel.currentTextColor)
        view.selectedState = true
        assertEquals(0xFFFF0000.toInt(), view.textLabel.currentTextColor)
    }

    @Test
    fun anAnimationPlaysThroughTheRegisteredFactory() {
        val calls = ArrayList<String>()
        CYLPlaceholderView.registerAnimationFactory({ ctx, path ->
            object : CYLPlaceholderAnimationPlayer {
                override val view = View(ctx)
                override val ready = true
                override var errorHandler: ((Throwable) -> Unit)? = null
                override var readyHandler: (() -> Unit)? = null
                override fun play() { calls += "play:$path" }
                override fun stop() { calls += "stop" }
                override fun showLastFrame() { calls += "last" }
                override fun setAnimationProgress(progress: Float) { calls += "progress:$progress" }
                override fun setAnimationSpeed(speed: Float) { calls += "speed:$speed" }
                override fun setAnimationRepeatCount(count: Int) { calls += "repeat:$count" }
                override fun setAnimationColors(colors: List<Int>) {}
            }
        }, "json")
        try {
            val view = CYLPlaceholderView(context, CYLPlaceholderStyle.Empty, CYLPlaceholderMessage.Empty)
            assertFalse("no animator for the file type", view.setAnimationFile("a.unknownext"))
            assertTrue(view.setAnimationFile("CYLPlaceholderEmpty.json"))
            assertNotNull(view.animationView)
            assertEquals("the animation shows over the icon", View.INVISIBLE, view.imageView.visibility)
            assertTrue("repeats for ever by default", calls.contains("repeat:0"))
            calls.clear()
            view.playPlaceholderAnimation()
            view.setPlaceholderAnimationSpeed(2f)
            view.stopPlaceholderAnimation()
            assertEquals(listOf("play:CYLPlaceholderEmpty.json", "speed:2.0", "stop"),
                calls.filter { it.startsWith("play:") || it == "speed:2.0" || it == "stop" })
            view.animationRepeatCount = 1
            assertEquals("plays once", "repeat:1", calls.last())
        } finally {
            CYLPlaceholderView.registerAnimationFactory(null, "json")
        }
    }

    @Test
    fun isACYLAnimatedItemViewOnTheVerticalAxis() {
        val view = CYLPlaceholderView(context, CYLPlaceholderStyle.WifiOff, CYLPlaceholderMessage.NoInternet)
        val item: CYLAnimatedItemView = view
        assertEquals(CYLAnimatedItemAxis.Vertical, item.axis)
        assertSame("imageView is the inherited icon view", item.iconView, view.imageView)
        assertSame("textLabel is the inherited title view", item.titleView, view.textLabel)
        assertEquals("No internet connection", item.title.toString())
        assertNotNull(item.image)
    }

    @Test
    fun withoutAnAnimationLibraryTheCoreShowsTheStaticImage() {
        // [EN] The core depends on no animation library: the engine finds none of them by reflection here.
        for (name in listOf("com.airbnb.lottie.LottieAnimationView", "org.libpag.PAGView", "app.rive.runtime.kotlin.RiveAnimationView")) {
            assertFalse("$name is not on the core's classpath", runCatching { Class.forName(name) }.isSuccess)
        }
        val view = CYLPlaceholderView(context, CYLPlaceholderStyle.NoInternet, "Offline")
        val icon = view.imageView.drawable
        for (file in listOf("CYLPlaceholderLoading.json", "CYLPlaceholderLoading.pag", "CYLPlaceholderLoading.riv")) {
            assertFalse(file, view.setAnimationFile("asset:${CYLPlaceholderStackView.ANIMATION_FOLDER}/$file"))
            assertNull(file, view.animationView)
            assertEquals(file, View.VISIBLE, view.imageView.visibility)
            assertSame("the static image given at setup", icon, view.imageView.drawable)
        }
        // [EN] The file is kept, as CYLAnimatedItemView does; local options after '?' move behind '#'.
        assertFalse(view.setAnimationFile("asset:CYLRefreshIcon.riv?artboard=refresh&animation=active"))
        assertEquals("asset:CYLRefreshIcon.riv#artboard=refresh&animation=active", view.animationURL)
        // [EN] No static image: the inherited placeholder shows (CYLAnimatedItemView's display priority).
        val bare = CYLPlaceholderView(context, null, "Loading")
        assertFalse(bare.setAnimationFile("asset:${CYLPlaceholderStackView.ANIMATION_FOLDER}/CYLPlaceholderLoading.json"))
        assertNotNull("the component's placeholder", bare.imageView.drawable)
    }

    @Test
    fun anImageSequencePlaysAndScrubsLikeAnAnimationFile() {
        val view = CYLPlaceholderView(context, null, "Loading")
        val frames = listOf(android.graphics.drawable.ColorDrawable(1), android.graphics.drawable.ColorDrawable(2), android.graphics.drawable.ColorDrawable(3))
        assertFalse(view.setAnimationImages(emptyList()))
        assertTrue(view.setAnimationImages(frames, 0.3))
        val sequence = view.imageView.drawable as android.graphics.drawable.AnimationDrawable
        assertEquals(3, sequence.numberOfFrames)
        assertEquals(View.VISIBLE, view.imageView.visibility)
        // [EN] AnimationDrawable keeps its own copy of each frame: compare with its frame list.
        view.setPlaceholderAnimationProgress(1f)
        assertSame(sequence.getFrame(2), sequence.current)
        view.setPlaceholderAnimationProgress(0f)
        assertSame(sequence.getFrame(0), sequence.current)
        view.showPlaceholderAnimationLastFrame()
        assertSame(sequence.getFrame(2), sequence.current)
        assertEquals(frames, view.itemAttributes["CYLPlaceholderItemImages"])
        val one = CYLPlaceholderView(context, null, null)
        assertTrue(one.setAnimationImages(listOf(frames[0])))
        assertSame("a single image stays still", frames[0], one.imageView.drawable)
    }

    @Test
    fun itemAttributesTakeAnImageSequence() {
        val frames = listOf(android.graphics.drawable.ColorDrawable(1), android.graphics.drawable.ColorDrawable(2))
        val view = CYLPlaceholderView.fromItemAttributes(context, mapOf("CYLPlaceholderItemImages" to frames, "CYLPlaceholderItemAnimationDuration" to 0.4))!!
        assertTrue(view.imageView.drawable is android.graphics.drawable.AnimationDrawable)
        var message: String? = null
        assertEquals(null, CYLPlaceholderView.fromItemAttributes(context, mapOf("CYLPlaceholderItemImages" to listOf("x"))) { message = it.message })
        assertEquals("CYLPlaceholderItemImages must be a list of drawables.", message)
    }

    /** iOS `cyl_setBadgeValue:`: a new value pops the badge from 0.6 when animatesChanges is on and it is on screen. */
    @Test
    fun badgeChangesPopWhenAnimated() {
        val activity = org.robolectric.Robolectric.buildActivity(android.app.Activity::class.java).setup().get()
        val view = CYLPlaceholderView(activity)
        activity.setContentView(view)
        val appearance = CYLPlaceholderBadgeAppearance.sharedAppearance
        val wasAnimating = appearance.animatesChanges
        try {
            appearance.animatesChanges = true
            view.badgeValue = "7"
            assertEquals("starts small", 0.6f, view.badgeLabel.scaleX, 0.001f)
            org.robolectric.shadows.ShadowLooper.idleMainLooper(1, java.util.concurrent.TimeUnit.SECONDS)
            assertEquals("ends at its size", 1f, view.badgeLabel.scaleX, 0.001f)
            appearance.animatesChanges = false
            view.badgeValue = "8"
            assertEquals("no pop when off", 1f, view.badgeLabel.scaleX, 0.001f)
        } finally {
            appearance.animatesChanges = wasAnimating
        }
    }

    /** iOS reportsContentSize: off (default) the view fills a wrap-content limit; on, it measures to its content. */
    @Test
    fun reportsContentSizeChoosesBetweenFillingAndContent() {
        val view = CYLPlaceholderView(context, null, "Title")
        val limit = View.MeasureSpec.makeMeasureSpec(1000, View.MeasureSpec.AT_MOST)
        assertFalse(view.reportsContentSize)
        view.measure(limit, limit)
        assertEquals(1000, view.measuredWidth)
        assertEquals(1000, view.measuredHeight)
        view.reportsContentSize = true
        view.measure(limit, limit)
        assertTrue("content size", view.measuredWidth < 1000 && view.measuredHeight < 1000)
        val stack = CYLPlaceholderStackView(context, CYLPlaceholderScenario.NoSearchResults)
        assertTrue("stack items report their content", (stack.componentViews.first() as CYLPlaceholderView).reportsContentSize)
    }
}
