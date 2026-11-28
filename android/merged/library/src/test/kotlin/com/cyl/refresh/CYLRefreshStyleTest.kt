package com.cyl.refresh

import android.app.Activity
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/** The string to header / footer mapping the Flutter plugin's native refresh view uses (`style` creation parameter). */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLRefreshStyleTest {
    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    @Test
    fun theNineKeysMapToTheirStylesAndUnknownOrMissingKeysToNull() {
        val keys = listOf("classic", "cupertino", "material", "bezierRadar", "bezierCircle", "delivery", "phoenix", "taurus", "rive")
        assertEquals(keys, keys.map { CYLRefreshStyle.fromKey(it)!!.key })
        assertEquals(9, CYLRefreshStyle.values().size)
        listOf(null, "", "Classic", "bezier_radar", "storeHouse", 3, true).forEach { assertNull("$it", CYLRefreshStyle.fromKey(it)) }
    }

    @Test
    fun everyStyleBuildsAHeaderOfItsClass() {
        val expected = mapOf(
            "classic" to CYLRefreshNormalHeader::class.java, "cupertino" to CYLRefreshCupertinoHeader::class.java,
            "material" to CYLRefreshMaterialHeader::class.java, "bezierRadar" to CYLRefreshBezierRadarHeader::class.java,
            "bezierCircle" to CYLRefreshBezierCircleHeader::class.java, "delivery" to CYLRefreshDeliveryHeader::class.java,
            "phoenix" to CYLRefreshPhoenixHeader::class.java, "taurus" to CYLRefreshTaurusHeader::class.java,
        )
        expected.forEach { (key, type) -> assertEquals(key, type, CYLRefreshStyle.fromKey(key)!!.newHeader(activity).javaClass) }
    }

    @Test
    fun everyStyleBuildsAFooterOfItsClass() {
        val expected = mapOf(
            "classic" to CYLRefreshBackNormalFooter::class.java, "cupertino" to CYLRefreshCupertinoFooter::class.java,
            "material" to CYLRefreshMaterialFooter::class.java, "bezierRadar" to CYLRefreshBezierRadarFooter::class.java,
            "bezierCircle" to CYLRefreshDrawnFooter::class.java, "delivery" to CYLRefreshDeliveryFooter::class.java,
            "phoenix" to CYLRefreshPhoenixFooter::class.java, "taurus" to CYLRefreshTaurusFooter::class.java,
        )
        expected.forEach { (key, type) -> assertEquals(key, type, CYLRefreshStyle.fromKey(key)!!.newFooter(activity).javaClass) }
        val circle = CYLRefreshStyle.BezierCircle.newFooter(activity) as CYLRefreshDrawnFooter
        assertTrue(circle.style is CYLRefreshBezierCircleHeader)
    }
}
