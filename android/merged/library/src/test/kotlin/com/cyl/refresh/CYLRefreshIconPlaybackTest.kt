package com.cyl.refresh

import android.app.Activity
import android.graphics.Color
import android.graphics.drawable.AnimationDrawable
import android.graphics.drawable.ColorDrawable
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The refresh icon's playback controls (docs/Example-Animation-Playback.md): speed, loop and replay, as HarmonyOS
 * `CYLRefreshIconViewModel` (refreshIconSpeedAndLoopDefaultsAndValidation).
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLRefreshIconPlaybackTest {

    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    private fun frames(count: Int) = List(count) { ColorDrawable(Color.rgb(it * 20, 0, 0)) }

    @Test
    fun speedAndLoopDefaultsAndValidation() {
        val icon = CYLRefreshIconView(activity)
        assertEquals(1f, icon.animationSpeed)
        assertTrue(icon.loopsWhilePlaying)
        icon.animationSpeed = 2.5f
        assertEquals(2.5f, icon.animationSpeed)
        assertEquals(2.5f, icon.placeholderView.animationSpeed)
        icon.animationSpeed = 0f
        icon.animationSpeed = -1f
        icon.animationSpeed = Float.NaN
        assertEquals(2.5f, icon.animationSpeed)
        icon.loopsWhilePlaying = false
        assertFalse(icon.loopsWhilePlaying)
        assertEquals(1, icon.placeholderView.animationRepeatCount)
        icon.loopsWhilePlaying = true
        assertEquals(0, icon.placeholderView.animationRepeatCount)
        // Nothing shown yet: replaying does nothing.
        icon.replayAnimation()
    }

    @Test
    fun imageFramesFollowSpeedAndLoop() {
        val icon = CYLRefreshIconView(activity)
        icon.setAnimationAttributes(mapOf(
            CYLRefreshIconView.IMAGES to frames(8),
            CYLRefreshIconView.DURATION to 0.8,
            CYLRefreshIconView.SIZE to floatArrayOf(40f, 40f),
        ), CYLRefreshState.Refreshing)
        icon.loopsWhilePlaying = false
        icon.updateForState(CYLRefreshState.Refreshing)
        var sequence = icon.placeholderView.imageView.drawable as AnimationDrawable
        assertTrue(sequence.isOneShot)
        assertEquals(100, sequence.getDuration(0))
        // A new speed builds the shown frames again, each 1 / speed as long.
        icon.animationSpeed = 4f
        sequence = icon.placeholderView.imageView.drawable as AnimationDrawable
        assertEquals(25, sequence.getDuration(0))
        assertTrue(sequence.isOneShot)
        icon.loopsWhilePlaying = true
        assertFalse(sequence.isOneShot)
        icon.replayAnimation()
        assertTrue(sequence.isRunning)
    }
}
