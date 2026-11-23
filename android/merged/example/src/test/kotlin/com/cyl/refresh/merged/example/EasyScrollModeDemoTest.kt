package com.cyl.refresh.merged.example

import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.fragment.app.FragmentActivity
import androidx.recyclerview.widget.RecyclerView
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import java.io.File
import javax.xml.parsers.DocumentBuilderFactory

/**
 * The "Scroll mode" demo of the easy-refresh page: its four rows, the tap that switches the mode, the strings in every
 * language of the example and the entry in the page list.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class EasyScrollModeDemoTest {
    private val activity: FragmentActivity = Robolectric.buildActivity(FragmentActivity::class.java).setup().get()

    private fun demoList(): RecyclerView {
        val page = RefreshExamplesPage()
        activity.supportFragmentManager.beginTransaction().add(android.R.id.content, page).commitNow()
        val root = page.easyPage("Scroll mode", "easyScrollMode")
        val list = findList(root)
        assertNotNull("the page has its list", list)
        list!!.measure(View.MeasureSpec.makeMeasureSpec(1080, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(4000, View.MeasureSpec.EXACTLY))
        list.layout(0, 0, 1080, 4000)
        return list
    }

    private fun findList(view: View): RecyclerView? {
        if (view is RecyclerView && view.tag == "easyRefreshDemo") return view
        if (view is ViewGroup) for (i in 0 until view.childCount) findList(view.getChildAt(i))?.let { return it }
        return null
    }

    private fun rowText(list: RecyclerView, index: Int): String = (list.getChildAt(index) as TextView).text.toString()

    @Test
    fun theListStartsWithTheFourScrollModesAndTheFirstIsMarked() {
        val list = demoList()
        assertEquals(4 + 30, list.adapter!!.itemCount)
        assertEquals("✓ Move", rowText(list, 0))
        assertEquals("Stretch", rowText(list, 1))
        assertEquals("Front", rowText(list, 2))
        assertEquals("Behind", rowText(list, 3))
        for (i in 0..3) assertTrue("row $i is a button", list.getChildAt(i).isClickable)
        assertFalse("a test row is not a button", list.getChildAt(4).isClickable)
    }

    @Test
    fun aTapOnAModeRowMarksThatModeAndNoOther() {
        val list = demoList()
        list.getChildAt(3).performClick()
        list.measure(View.MeasureSpec.makeMeasureSpec(1080, View.MeasureSpec.EXACTLY), View.MeasureSpec.makeMeasureSpec(4000, View.MeasureSpec.EXACTLY))
        list.layout(0, 0, 1080, 4000)
        assertEquals("✓ Behind", rowText(list, 3))
        assertEquals("Move", rowText(list, 0))
        assertEquals(1, (0..3).count { rowText(list, it).startsWith("✓ ") })
    }

    @Test
    fun theDemoIsInThePageList() {
        assertTrue(easyPages.any { it.second == "easyScrollMode" && it.first == R.string.merged_easy_scroll_mode })
    }

    @Test
    fun everyLanguageOfTheExampleHasTheSixStrings() {
        val keys = listOf(
            "merged_easy_scroll_mode", "merged_easy_scroll_move", "merged_easy_scroll_stretch", "merged_easy_scroll_front",
            "merged_easy_scroll_behind", "merged_easy_scroll_mode_selected",
        )
        val res = File("src/main/res")
        val folders = res.listFiles { f -> f.isDirectory && f.name.startsWith("values") }!!.filter { File(it, "strings.xml").exists() }
        assertEquals("the example's 7 languages", 7, folders.size)
        for (folder in folders) {
            val doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(File(folder, "strings.xml"))
            val names = (0 until doc.getElementsByTagName("string").length).associate {
                val node = doc.getElementsByTagName("string").item(it)
                node.attributes.getNamedItem("name").nodeValue to node.textContent
            }
            for (key in keys) assertTrue("${folder.name} has $key", !names[key].isNullOrBlank())
        }
    }
}
