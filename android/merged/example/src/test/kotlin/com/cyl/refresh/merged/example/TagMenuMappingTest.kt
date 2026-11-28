package com.cyl.refresh.merged.example

import androidx.test.core.app.ApplicationProvider
import android.content.Context
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuFoldControlContent
import com.cyl.classifymenu.CYLMenuFoldControlPosition
import com.cyl.classifymenu.CYLMenuSelectionMode
import com.cyl.classifymenu.CYLTagBackgroundStyle
import com.cyl.classifymenu.CYLTagListView
import com.cyl.classifymenu.CYLTagLongPressActions
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

/**
 * The example's menu screens as CollectionViewClassifyMenu tag lists: the pure mapping from rows to sections and items
 * (every header has a title, the subtitle goes to the long press, a tap runs the old row's action) and the list's settings.
 */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class TagMenuMappingTest {
    private val taps = ArrayList<String>()

    private fun sections() = listOf(
        MenuSection("Group A", listOf(
            MenuItem("One", "the first row", "A") { taps += "one" },
            MenuItem("Two", null, null) { taps += "two" },
        )),
        MenuSection("Group B", listOf(MenuItem("Three", "", null) { taps += "three" })),
        MenuSection("Empty group", emptyList()),
    )

    @Test
    fun rowsBecomeSectionsAndItemsAndEmptyGroupsAreLeftOut() {
        val mapping = MenuMapping(sections())
        assertEquals(2, mapping.numberOfSectionsInMenu())
        assertEquals(2, mapping.menuNumberOfItemsInSection(0))
        assertEquals(1, mapping.menuNumberOfItemsInSection(1))
        assertEquals("Two", mapping.menuTitleForItemAtIndexPath(CYLIndexPath(1, 0)))
        assertEquals("Three", mapping.menuTitleForItemAtIndexPath(CYLIndexPath(0, 1)))
    }

    @Test
    fun everySectionHeaderHasANonEmptyTitle() {
        val mapping = MenuMapping(sections())
        for (section in 0 until mapping.numberOfSectionsInMenu()) {
            assertTrue(mapping.menuTitleForSection(section).isNotBlank())
        }
        try {
            MenuSection("  ", listOf(MenuItem("x", null, null) {}))
            fail("a section without a title must be refused")
        } catch (expected: IllegalArgumentException) {
        }
    }

    @Test
    fun theSubtitleIsCarriedToTheLongPressAndEmptyOnesAreNone() {
        val mapping = MenuMapping(sections())
        assertEquals("the first row", mapping.menuSubtitleForItemAtIndexPath(CYLIndexPath(0, 0)))
        assertNull(mapping.menuSubtitleForItemAtIndexPath(CYLIndexPath(1, 0)))
        assertNull(mapping.menuSubtitleForItemAtIndexPath(CYLIndexPath(0, 1)))
    }

    @Test
    fun aTapRunsExactlyTheOriginalAction() {
        val mapping = MenuMapping(sections())
        mapping.menuDidSelectItemAtIndexPath(Any(), CYLIndexPath(1, 0))
        mapping.menuDidSelectItemAtIndexPath(Any(), CYLIndexPath(0, 1))
        assertEquals(listOf("two", "three"), taps)
    }

    @Test
    fun theListUsesTheCalloutNoSelectionAdaptiveWidthAndThreeTitleLines() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        val menu = tagMenu(context, sections())
        val list = tagListOf(menu)
        // The backing plate is the first child, behind the scrolling list.
        assertEquals(BACKING_PLATE_TAG, menu.getChildAt(0).tag)
        // The glass samples the plate: a sibling behind the list, not one of its ancestors.
        assertSame(menu.getChildAt(0), list.backdropSource)
        var ancestor = list.parent
        while (ancestor != null) {
            assertTrue(ancestor !== list.backdropSource)
            ancestor = ancestor.parent
        }
        assertSame(CYLTagLongPressActions.callout, list.longPressAction)
        assertEquals(CYLMenuSelectionMode.CYLMenuSelectionModeNone, list.selectionMode)
        assertEquals(DEFAULT_VISIBLE_ROWS, list.defaultVisibleRows)
        assertEquals(CYLMenuFoldControlPosition.TAIL, list.foldControl!!.position)
        assertEquals(CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon, list.foldControl!!.content)
        assertTrue(list.foldControl!!.usesDefaultImage)
        assertEquals(TITLE_MAX_LINES, list.style!!.titleMaxLines)
        assertEquals(HEADER_MAX_LINES, list.style!!.headerMaxLines)
        // The library draws one Liquid Glass card per section; the example draws none.
        assertEquals(CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass, list.style!!.sectionBackgroundStyle)
        assertEquals(0, list.style!!.numberOfItemsPerRow)
        // One shared style: the tail fold control copies the list style (CYLTagFoldButton.inlineStyleForFoldControl), so glass here is glass for the tail.
        assertEquals(CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass, list.style!!.backgroundStyle)
        assertEquals(2, list.menuDataSource!!.numberOfSectionsInMenu())
    }

    @Test
    fun theIconColourIsAStaticColourOfTheItemStyleOnACopyOfTheListStyle() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        val list = tagListOf(tagMenu(context, sections()))
        val itemStyle = list.menuDataSource!!.menuStyleForItemAtIndexPath(CYLIndexPath(0, 0))!!
        assertEquals(ICON_COLOR, itemStyle.iconColorForState(CYLControlState.NORMAL))
        // A copy: the list style itself keeps no icon colour, and the copy keeps the list's settings.
        assertTrue(itemStyle !== list.style)
        assertTrue(list.style!!.iconColorForState(CYLControlState.NORMAL) != ICON_COLOR)
        assertEquals(CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass, itemStyle.backgroundStyle)
        assertEquals(TITLE_MAX_LINES, itemStyle.titleMaxLines)
    }
}
