package com.cyl.placeholder.lottie

import android.content.Context
import android.view.View
import androidx.test.core.app.ApplicationProvider
import com.cyl.placeholder.CYLPlaceholderItemAnimatorRegistry
import com.cyl.placeholder.CYLPlaceholderScenario
import com.cyl.placeholder.CYLPlaceholderStackView
import com.airbnb.lottie.LottieAnimationView
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * With this module the scenarios' Lottie animations play in place of the still icons (docs/Android-Port.md).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLLottiePlaceholderItemAnimatorTest {

    private val context: Context = ApplicationProvider.getApplicationContext()

    @Test
    fun theAnimatorIsRegisteredAndPlaysJSON() {
        CYLLottiePlaceholderItemAnimator.register()
        val registry = CYLPlaceholderItemAnimatorRegistry.sharedRegistry
        assertEquals("Lottie", registry.animatorForURL("asset:CYLPlaceholderAnimations/CYLPlaceholderEmpty.json")?.identifier)
    }

    @Test
    fun theStackViewPlaysItsScenariosAnimation() {
        CYLLottiePlaceholderItemAnimator.register()
        val view = CYLPlaceholderStackView(context, CYLPlaceholderScenario.NoContent)
        val animation = assertNotNullAndGet(view.animationView)
        assertEquals("Lottie", animation.animatorIdentifier)
        assertTrue(animation.animationView is LottieAnimationView)
        assertEquals(View.GONE, view.imageView.visibility)
    }

    @Test
    fun aMissingFileGivesNoViewSoTheImageStays() {
        CYLLottiePlaceholderItemAnimator.register()
        assertNull(CYLLottiePlaceholderItemAnimator.animator.animationViewWithURL(
            context, "asset:CYLPlaceholderAnimations/Missing.json", 100, 100, android.widget.ImageView.ScaleType.FIT_CENTER))
    }

    private fun <T> assertNotNullAndGet(value: T?): T {
        assertNotNull(value)
        return value!!
    }
}
