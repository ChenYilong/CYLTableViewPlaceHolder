package com.cyl.placeholder

import android.content.Context
import android.view.View
import android.widget.ImageView
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The animation engine: the animator registry, the factory, the short path and CYLPlaceholderAnimationView (iOS
 * `CYLPlaceholderItemAnimatorRegistry`, `CYLPlaceholderItemAnimationFactory`, `CYLPlaceholderItemViewAnimator`,
 * `CYLPlaceholderAnimationView`).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLPlaceholderAnimationTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    private class FakeView(context: Context, val calls: MutableList<String>) : View(context), CYLPlaceholderItemAnimationPlayableView {
        override var cyl_animationViewReadyHandler: (() -> Unit)? = null
        override var cyl_animationViewErrorHandler: ((Throwable) -> Unit)? = null
        override fun cyl_playAnimationView() { calls += "play" }
        override fun cyl_showAnimationViewLastFrame() { calls += "last" }
        override fun cyl_stopAnimationView() { calls += "stop" }
        override fun cyl_setAnimationViewRepeatCount(repeatCount: Int): Boolean { calls += "repeat:$repeatCount"; return true }
    }

    private fun fake(calls: MutableList<String>) = CYLPlaceholderItemViewAnimator("Fake", listOf(".FAKE"), mapOf(CYLPlaceholderItemAnimatorRegistry.ANIMATION_FILE_PATH to "CYLFakeFilePath")) { ctx, _, _, _ -> FakeView(ctx, calls) }

    @Test
    fun aRegistryFindsAnimatorsByFileAndAttributes() {
        val registry = CYLPlaceholderItemAnimatorRegistry()
        val animator = fake(ArrayList())
        registry.registerAnimator(animator)
        assertEquals(listOf("fake"), registry.fileExtensions())
        assertSame(animator, registry.animatorForURL("a/b.fake"))
        assertNull(registry.animatorForURL("a/b.json"))
        registry.bindURL("a/b.json", animator)
        assertSame("bound whatever its extension", animator, registry.animatorForURL("a/b.json"))
        assertEquals(listOf("CYLFakeFilePath", CYLPlaceholderItemAnimatorRegistry.ANIMATION_FILE_PATH), registry.attributeKeysForGenericKey(CYLPlaceholderItemAnimatorRegistry.ANIMATION_FILE_PATH))
        assertSame(animator, registry.animatorForAttributes(mapOf("CYLFakeFilePath" to "x.fake")))
        assertSame(animator, registry.animatorWithIdentifier("Fake"))
        registry.unregisterAnimatorWithIdentifier("Fake")
        assertTrue(registry.animators().isEmpty())
    }

    @Test
    fun theSharedRegistryPlaysGIFFromTheStart() {
        val gif = CYLPlaceholderItemAnimatorRegistry.animatorForURL("spinner.GIF")
        assertSame(CYLGIFPlaceholderItemAnimator.animator, gif)
        assertEquals("GIF", gif!!.identifier)
        assertTrue(CYLPlaceholderItemAnimatorRegistry.fileExtensions().contains("gif"))
    }

    @Test
    fun aFactoryMakesViewsAndTheirPlayers() {
        val calls = ArrayList<String>()
        val registry = CYLPlaceholderItemAnimatorRegistry().also { it.registerAnimator(fake(calls)) }
        val factory = CYLPlaceholderItemAnimationFactory(registry)
        assertNull(factory.animationViewWithURL(context, "a.json", 10, 10, ImageView.ScaleType.FIT_CENTER))
        val view = factory.animationViewWithURL(context, "a.fake", 10, 10, ImageView.ScaleType.FIT_CENTER)
        assertTrue(factory.isAnimationView(view))
        assertFalse(factory.isAnimationView(View(context)))
        val player = factory.playerForView(view)!!
        player.play()
        player.setAnimationRepeatCount(2)
        player.stop()
        assertEquals(listOf("play", "repeat:2", "stop"), calls)
    }

    @Test
    fun anAnimationViewPlaysARegisteredFile() {
        val calls = ArrayList<String>()
        CYLPlaceholderItemAnimatorRegistry.registerAnimator(fake(calls))
        try {
            var error: Throwable? = null
            assertNull(CYLPlaceholderAnimationView.withFileURL(context, "a.unknown", 40, 40, errorHandler = { error = it }))
            assertNotNull(error)
            val view = CYLPlaceholderAnimationView.withFileURL(context, "a.fake", 40, 40)!!
            assertEquals("Fake", view.animatorIdentifier)
            assertEquals(CYLPlaceholderAnimationBackend.Custom, view.backend)
            view.play()
            assertTrue(view.playing)
            view.showLastFrame()
            assertFalse(view.playing)
            assertEquals(listOf("play", "last"), calls)

            // CYLPlaceholderView finds the animator through the registry.
            val placeholder = CYLPlaceholderView(context, CYLPlaceholderStyle.Empty, CYLPlaceholderMessage.Empty)
            assertTrue(placeholder.setAnimationFile("b.fake"))
            placeholder.playPlaceholderAnimation()
            assertEquals("play", calls.last())
        } finally {
            CYLPlaceholderItemAnimatorRegistry.unregisterAnimatorWithIdentifier("Fake")
        }
    }
}
