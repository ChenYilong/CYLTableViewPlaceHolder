package com.cyl.refresh

import android.app.Activity
import android.content.Context
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import org.robolectric.shadows.ShadowLog

/**
 * The `rive` style of the core (docs/Refresh-Library-Parity.md, "The rive style: creation parameters"): the parameter parsing and the
 * fallback to classic with one log line. The module `:merged-rive` is not on this test's class path, as in an app without Rive.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class CYLRefreshRiveTest {
    private val activity: Activity = Robolectric.buildActivity(Activity::class.java).setup().get()

    @After
    fun noBuilder() {
        CYLRefreshRiveSupport.builder = null
    }

    private class Fake(val header: CYLRefreshHeader?, val footer: CYLRefreshFooter?) : CYLRefreshRiveBuilding {
        var asked: CYLRefreshRiveOptions? = null
        override fun header(context: Context, options: CYLRefreshRiveOptions): CYLRefreshHeader? = header.also { asked = options }
        override fun footer(context: Context, options: CYLRefreshRiveOptions): CYLRefreshFooter? = footer.also { asked = options }
    }

    private fun riveLogLines() = ShadowLog.getLogs().filter { it.tag == "CYLRefresh" }.map { it.msg }

    @Test
    fun theFinishTimeoutIsParsedAndKeepsItsDefaultForABadValue() {
        assertEquals(1.5, CYLRefreshRiveOptions.from(emptyMap<String, Any?>()).finishTimeout, 0.0)
        assertEquals(2.5, CYLRefreshRiveOptions.from(mapOf("riveFinishTimeout" to 2.5)).finishTimeout, 0.0)
        assertEquals(1.5, CYLRefreshRiveOptions.from(mapOf("riveFinishTimeout" to 0)).finishTimeout, 0.0)
        assertEquals(1.5, CYLRefreshRiveOptions.from(mapOf("riveFinishTimeout" to "2")).finishTimeout, 0.0)
    }

    @Test
    fun theKeysAreParsedWithTheirTypes() {
        val options = CYLRefreshRiveOptions.from(mapOf(
            "riveFile" to "Bow", "riveArtboard" to "Main", "riveStateMachine" to "numberSimulation", "riveTriggerOffset" to 200.0,
            "riveMinimumHeight" to 140, "riveFitsWidth" to true, "rivePullInput" to "pull", "rivePullInputMinimum" to 10.0,
            "rivePullInputStart" to 0.5, "rivePullInputRefreshingValue" to 100, "riveReleaseTrigger" to "advance",
            "riveLoadingNumber" to "numLoad", "riveLoadingNumberDuration" to 3.0, "rivePullAnimation" to "Pull", "unknownKey" to 1,
        ))
        assertEquals("Bow", options.file)
        assertEquals("Main", options.artboard)
        assertEquals("numberSimulation", options.stateMachine)
        assertEquals(200f, options.triggerOffset, 0f)
        assertEquals(140f, options.minimumHeight, 0f)
        assertTrue(options.fitsWidth)
        assertEquals("pull", options.pullInput)
        assertEquals(10.0, options.pullInputMinimum, 0.0)
        assertEquals(0.5, options.pullInputStart, 0.0)
        assertEquals(100.0, options.pullInputRefreshingValue, 0.0)
        assertEquals("advance", options.releaseTrigger)
        assertEquals("numLoad", options.loadingNumber)
        assertEquals(3.0, options.loadingNumberDuration, 0.0)
        assertEquals("Pull", options.pullAnimation)
        assertNull(options.finishTrigger)
    }

    private val bow = listOf(listOf(30.0, 0.0), listOf(31.8, 0.14), listOf(35.9, 0.43), listOf(39.8, 0.66), listOf(43.6, 0.82), listOf(47.3, 0.94), listOf(50.0, 1.0))

    @Test
    fun theDrawnTableInterpolatesLinearlyAndHoldsTheEndValues() {
        val table = CYLRefreshRiveOptions.from(mapOf("riveDrawnTable" to bow)).drawnTable
        assertFalse(table.isEmpty)
        assertEquals(7, table.pairs.size)
        assertEquals(0.0, table.fraction(0.0)!!, 1e-9)
        assertEquals(0.0, table.fraction(30.0)!!, 1e-9)
        assertEquals(0.14, table.fraction(31.8)!!, 1e-9)
        assertEquals(0.07, table.fraction(30.9)!!, 1e-9)
        assertEquals((0.43 + 0.66) / 2, table.fraction(37.85)!!, 1e-9)
        assertEquals(1.0, table.fraction(50.0)!!, 1e-9)
        assertEquals(1.0, table.fraction(80.0)!!, 1e-9)
    }

    @Test
    fun aTableOfOnePairIsConstantAndNoTableMeansNoClip() {
        val one = CYLRefreshRiveDrawnTable.parse(listOf(listOf(10, 0.5)))
        assertEquals(0.5, one.fraction(-5.0)!!, 0.0)
        assertEquals(0.5, one.fraction(99.0)!!, 0.0)
        listOf(null, emptyMap<String, Any?>(), mapOf("riveDrawnTable" to emptyList<Any>()), mapOf("riveDrawnTable" to "x"), mapOf("riveDrawnTable" to listOf(listOf("a", 1), listOf(1)))).forEach {
            val table = CYLRefreshRiveOptions.from(it as Map<*, *>?).drawnTable
            assertTrue(table.isEmpty)
            assertNull(table.fraction(40.0))
        }
    }

    @Test
    fun theDrawnTableIgnoresMalformedPairsSortsAndClampsTheFractions() {
        val table = CYLRefreshRiveDrawnTable.parse(listOf(
            listOf(50, 2.0), "bad", listOf(10), listOf(10, "x"), listOf(Double.NaN, 0.5), listOf(20, Double.POSITIVE_INFINITY),
            listOf(30, -1), listOf(40, 0.5, 9), null,
        ))
        assertEquals(listOf(30.0 to 0.0, 40.0 to 0.5, 50.0 to 1.0), table.pairs)
        assertEquals(0.25, table.fraction(35.0)!!, 1e-9)
        assertEquals(listOf(1.0 to 0.2, 2.0 to 0.4), CYLRefreshRiveDrawnTable.of(2.0 to 0.4, 1.0 to 0.2).pairs)
    }

    @Test
    fun missingOrInvalidValuesKeepTheDefaults() {
        listOf(null, emptyMap(), mapOf("riveTriggerOffset" to 0, "riveMinimumHeight" to -3, "riveFitsWidth" to "yes", "riveFile" to "",
            "rivePullInput" to 5, "rivePullInputRefreshingValue" to -2, "riveLoadingNumberDuration" to 0)).forEach { parameters ->
            val options = CYLRefreshRiveOptions.from(parameters)
            assertNull(options.file)
            assertNull(options.pullInput)
            assertEquals(180f, options.triggerOffset, 0f)
            assertEquals(0f, options.minimumHeight, 0f)
            assertFalse(options.fitsWidth)
            assertEquals(0.0, options.pullInputMinimum, 0.0)
            assertEquals(100.0, options.pullInputMaximum, 0.0)
            assertEquals(-1.0, options.pullInputRefreshingValue, 0.0)
            assertEquals(99.0, options.loadingNumberMaximum, 0.0)
            assertEquals(100.0, options.loadingNumberFinished, 0.0)
            assertEquals(2.0, options.loadingNumberDuration, 0.0)
        }
    }

    @Test
    fun anAssetNameFindsTheFlutterAssetAndAPathIsNotAnAsset() {
        listOf("Bow", "Bow.riv", "assets/animations/Bow.riv").forEach { name ->
            val candidates = CYLRefreshRiveOptions.from(mapOf("riveFile" to name)).assetCandidates()
            assertTrue(name, "flutter_assets/assets/animations/Bow.riv" in candidates)
            assertEquals(name, candidates.size, candidates.distinct().size)
        }
        assertTrue("assets/animations/Bow.riv" in CYLRefreshRiveOptions.from(mapOf("riveFile" to "Bow")).assetCandidates())
        val path = CYLRefreshRiveOptions.from(mapOf("riveFile" to "/sdcard/Bow.riv"))
        assertTrue(path.fileIsPath)
        assertEquals(emptyList<String>(), path.assetCandidates())
    }

    @Test
    fun theRiveKeyIsTheNinthStyle() {
        assertSame(CYLRefreshStyle.Rive, CYLRefreshStyle.fromKey("rive"))
        assertEquals("rive", CYLRefreshStyle.Rive.key)
    }

    @Test
    fun withoutTheRiveModuleTheHeaderAndFooterAreClassicWithOneLogLine() {
        ShadowLog.clear()
        val reasons = ArrayList<String>()
        val header = CYLRefreshStyle.Rive.newHeader(activity, mapOf("riveFile" to "Bow")) { reasons.add(it) }
        assertEquals(CYLRefreshNormalHeader::class.java, header.javaClass)
        assertEquals(listOf(CYLRefreshRiveSupport.NOT_LINKED), reasons)
        reasons.clear()
        assertEquals(CYLRefreshBackNormalFooter::class.java, CYLRefreshStyle.Rive.newFooter(activity, mapOf("riveFile" to "Bow")) { reasons.add(it) }.javaClass)
        assertEquals(listOf(CYLRefreshRiveSupport.NOT_LINKED), reasons)
        // The default report is one line in the log: "CYLRefresh: <reason>, using classic".
        ShadowLog.clear()
        CYLRefreshStyle.Rive.newHeader(activity, mapOf("riveFile" to "Bow"))
        assertEquals(listOf("CYLRefresh: ${CYLRefreshRiveSupport.NOT_LINKED}, using classic"), riveLogLines())
    }

    @Test
    fun withoutARiveFileTheStyleIsClassicAndSaysSo() {
        CYLRefreshRiveSupport.builder = Fake(CYLRefreshNormalHeader(activity), null)
        ShadowLog.clear()
        val header = CYLRefreshStyle.Rive.newHeader(activity, mapOf("riveStateMachine" to "x"))
        assertEquals(CYLRefreshNormalHeader::class.java, header.javaClass)
        assertEquals(listOf("CYLRefresh: ${CYLRefreshRiveSupport.NO_FILE}, using classic"), riveLogLines())
        assertNull((CYLRefreshRiveSupport.builder as Fake).asked)
    }

    @Test
    fun anUnreadableFileMakesClassicAndNamesTheFile() {
        CYLRefreshRiveSupport.builder = Fake(null, null)
        val reasons = ArrayList<String>()
        val footer = CYLRefreshStyle.Rive.newFooter(activity, mapOf("riveFile" to "Missing.riv")) { reasons.add(it) }
        assertEquals(CYLRefreshBackNormalFooter::class.java, footer.javaClass)
        assertEquals(listOf("rive file Missing.riv not found or unreadable"), reasons)
    }

    @Test
    fun aBuilderThatMakesTheViewIsUsedWithTheParsedOptionsAndNothingIsLogged() {
        val made = CYLRefreshNormalHeader(activity)
        val fake = Fake(made, CYLRefreshDrawnFooter(CYLRefreshBezierRadarHeader(activity)))
        CYLRefreshRiveSupport.builder = fake
        ShadowLog.clear()
        assertSame(made, CYLRefreshStyle.Rive.newHeader(activity, mapOf("riveFile" to "Bow", "rivePullInput" to "pull")))
        assertEquals("pull", fake.asked!!.pullInput)
        assertSame(fake.footer, CYLRefreshStyle.Rive.newFooter(activity, mapOf("riveFile" to "Bow")))
        assertEquals(emptyList<String>(), riveLogLines())
    }

    @Test
    fun aBuilderThatThrowsFallsBackToClassic() {
        CYLRefreshRiveSupport.builder = object : CYLRefreshRiveBuilding {
            override fun header(context: Context, options: CYLRefreshRiveOptions): CYLRefreshHeader? = throw IllegalStateException("no runtime")
            override fun footer(context: Context, options: CYLRefreshRiveOptions): CYLRefreshFooter? = throw NoClassDefFoundError("app/rive")
        }
        val reasons = ArrayList<String>()
        assertEquals(CYLRefreshNormalHeader::class.java, CYLRefreshStyle.Rive.newHeader(activity, mapOf("riveFile" to "Bow")) { reasons.add(it) }.javaClass)
        assertEquals(CYLRefreshBackNormalFooter::class.java, CYLRefreshStyle.Rive.newFooter(activity, mapOf("riveFile" to "Bow")) { reasons.add(it) }.javaClass)
        assertEquals(2, reasons.size)
    }
}
