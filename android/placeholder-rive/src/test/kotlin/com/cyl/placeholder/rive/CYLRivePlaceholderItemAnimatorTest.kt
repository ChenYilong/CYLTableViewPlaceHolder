package com.cyl.placeholder.rive

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The Rive animator's file handling; rive-android itself loads native code, which the JVM cannot.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLRivePlaceholderItemAnimatorTest {

    @Test
    fun theQueryPicksTheArtboardAndTheAnimation() {
        val options = CYLRivePlaceholderItemAnimator.options("asset:Animations/CYLRefreshIcon.riv?artboard=refresh&animation=active")
        assertEquals(mapOf("artboard" to "refresh", "animation" to "active"), options)
        assertEquals(emptyMap<String, String>(), CYLRivePlaceholderItemAnimator.options("asset:Animations/CYLRefreshIcon.riv"))
    }

    @Test
    fun aQueryDoesNotHideTheExtension() {
        val animator = CYLRivePlaceholderItemAnimator.animator
        assertTrue(animator.canAnimateFileAtURL("asset:Animations/CYLRefreshIcon.riv?artboard=refresh"))
        assertFalse(animator.canAnimateFileAtURL("asset:Animations/CYLRefreshIcon.json"))
    }
}
