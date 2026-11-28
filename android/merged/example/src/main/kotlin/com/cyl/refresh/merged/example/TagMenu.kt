package com.cyl.refresh.merged.example

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.ColorFilter
import android.graphics.Paint
import android.graphics.PixelFormat
import android.graphics.drawable.Drawable
import android.graphics.drawable.GradientDrawable
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ScrollView
import com.cyl.classifymenu.CYLControlState
import com.cyl.classifymenu.CYLIndexPath
import com.cyl.classifymenu.CYLMenuDataSource
import com.cyl.classifymenu.CYLMenuDelegate
import com.cyl.classifymenu.CYLMenuFoldControl
import com.cyl.classifymenu.CYLMenuFoldControlContent
import com.cyl.classifymenu.CYLMenuFoldControlPosition
import com.cyl.classifymenu.CYLMenuSelectionMode
import com.cyl.classifymenu.CYLMenuStyle
import com.cyl.classifymenu.CYLSize
import com.cyl.classifymenu.CYLTagBackgroundStyle
import com.cyl.classifymenu.CYLTagListView
import com.cyl.classifymenu.CYLTagLongPressActions

/*
 * The example's menu and index screens as one CollectionViewClassifyMenu tag list (docs/instructions/examples.md,
 * "Sectioned lists in demos use the tag list"): one section per group, the section title is the header, a tag shows the
 * main title and the icon only, a tap does what the replaced row did (the tag does not stay selected), a long press shows
 * the row's subtitle in the tag list's callout (its built-in long-press action, never a popup of the example), a section
 * longer than DEFAULT_VISIBLE_ROWS rows folds behind the core's TAIL control (its last tag, only the built-in icon), and a tag is as wide as its title
 * (numberOfItemsPerRow 0), wrapping to TITLE_MAX_LINES lines. Screens that show the library on a real list (placeholder on
 * an empty list, refresh and HUD demos) stay tables.
 */

/** One entry of a menu: [title] and [icon] are drawn, [subtitle] is the long-press callout, [onTap] is the old row's tap. */
internal class MenuItem(val title: String, val subtitle: String?, val icon: String?, val onTap: () -> Unit)

/** One group of a menu; its [title] is the section header and is never empty. */
internal class MenuSection(val title: String, val items: List<MenuItem>) {
    init {
        require(title.isNotBlank()) { "a menu section needs a title" }
    }
}

/** Rows a folded section shows before the More control. */
internal const val DEFAULT_VISIBLE_ROWS = 3

/** Lines a tag's title may take before it is cut (the placeholder example uses 3). */
internal const val TITLE_MAX_LINES = 3

/** Lines a long section header wraps onto instead of ending in an ellipsis (iOS `CYLTagListScreen.headerMaxLines`). */
internal const val HEADER_MAX_LINES = 2

/** The static icon colour of every tag (systemTeal, light value), passed through the item style (iOS `CYLTagEntry.tint`). */
internal const val ICON_COLOR = 0xFF30B0C7.toInt()

/**
 * The pure mapping from menu sections to the tag list: sections and items for the data source, the subtitle for the
 * long press, and the tap that runs the original action. Empty sections are left out (a header with no tag).
 */
internal class MenuMapping(
    sections: List<MenuSection>,
    private val iconFor: (MenuItem) -> Drawable? = { null },
    private val baseStyle: () -> CYLMenuStyle? = { null },
) : CYLMenuDataSource, CYLMenuDelegate {

    val sections: List<MenuSection> = sections.filter { it.items.isNotEmpty() }

    private fun item(indexPath: CYLIndexPath): MenuItem = sections[indexPath.section].items[indexPath.item]

    override fun numberOfSectionsInMenu(): Int = sections.size
    override fun menuNumberOfItemsInSection(section: Int): Int = sections[section].items.size
    override fun menuTitleForSection(section: Int): String = sections[section].title
    override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath): String = item(indexPath).title
    override fun menuSubtitleForItemAtIndexPath(indexPath: CYLIndexPath): String? = item(indexPath).subtitle?.takeIf { it.isNotEmpty() }
    override fun menuImageForItemAtIndexPath(indexPath: CYLIndexPath): Drawable? = iconFor(item(indexPath))

    /**
     * The list style with the static icon colour (docs/instructions/examples.md, "Headers and icon colours"): the glyph is a
     * template, the colour comes from the item style, so the core can lift it under dark glass. Selection is off, so the
     * normal state is the only one drawn.
     */
    override fun menuStyleForItemAtIndexPath(indexPath: CYLIndexPath): CYLMenuStyle? =
        baseStyle()?.copy()?.apply { setIconColor(ICON_COLOR, CYLControlState.NORMAL) }

    override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath) {
        item(indexPath).onTap()
    }
}

/**
 * The tag list of [sections] inside a scroll view (the tag list reports its height there, so a refresh layout or a page
 * can scroll it as before). Selection is off: a tap only reports the item, so no tag stays selected.
 */
internal fun tagMenu(context: Context, sections: List<MenuSection>): FrameLayout {
    val list = CYLTagListView(context)
    // The item styles copy the list style, so the mapping reads it from the list (set below, before the first reload).
    val mapping = MenuMapping(sections, { item -> item.icon?.let { GlyphDrawable(context, it) } }, { list.style })
    val plate = backingPlate(context)
    list.apply {
        // The glass tags, the tail control and the section cards blur and refract the plate: a sibling view BEHIND the list,
        // never an ancestor of it (CYLTagListView.backdropSource); null would sample the window root, which contains the list.
        backdropSource = plate
        style = CYLMenuStyle.defaultStyle().apply {
            // The list's own background is transparent so the page gradient (the plate) shows through; the section cards
            // (the library's insetGrouped default) sit on it, so the gradient is drawn once, behind everything.
            backgroundColor = Color.TRANSPARENT
            titleMaxLines = TITLE_MAX_LINES
            headerMaxLines = HEADER_MAX_LINES
            numberOfItemsPerRow = 0
            imageSize = CYLSize(20f, 20f)
            // One shared place: every converted tag list uses the Liquid Glass tag background; where the device cannot draw
            // glass the library falls back to flat (CYLMenuStyle.resolvedBackgroundStyle), the example fakes nothing.
            backgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass
            // The card behind each section's tags is the library's (sectionStyle insetGrouped, the default), Liquid Glass too,
            // so the page gradient shows through it; the example draws no card.
            sectionBackgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleLiquidGlass
        }
        selectionMode = CYLMenuSelectionMode.CYLMenuSelectionModeNone
        showsSectionHeaders = true
        defaultVisibleRows = DEFAULT_VISIBLE_ROWS
        foldControl = CYLMenuFoldControl.foldControlWithPosition(
            CYLMenuFoldControlPosition.TAIL,
            CYLMenuFoldControlContent.CYLMenuFoldControlContentIcon,
        )
        longPressAction = CYLTagLongPressActions.callout
        isScrollEnabled = false
        menuDataSource = mapping
        menuDelegate = mapping
        reloadMenuData()
    }
    val scroll = ScrollView(context).apply {
        addView(list, ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
    }
    return FrameLayout(context).apply {
        addView(plate, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
        addView(scroll, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT))
    }
}

/** The tag list inside [menu] made by [tagMenu] (for tests and callers that need it). */
internal fun tagListOf(menu: FrameLayout): CYLTagListView = (menu.getChildAt(1) as ScrollView).getChildAt(0) as CYLTagListView

// The colourful page behind the tag list (one shared place, docs/instructions/examples.md): a pastel gradient the Liquid
// Glass tags and section cards sample through CYLTagListView.backdropSource. It is the page, not a card: the library draws those.
internal const val PLATE_TOP = 0xFFFFD6E8.toInt()
internal const val PLATE_MIDDLE = 0xFFD6E4FF.toInt()
internal const val PLATE_BOTTOM = 0xFFD9FFE3.toInt()
// The same plate in dark mode: deep tones, so light titles and glass tags stay readable.
internal const val PLATE_NIGHT_TOP = 0xFF4A2F55.toInt()
internal const val PLATE_NIGHT_MIDDLE = 0xFF27355E.toInt()
internal const val PLATE_NIGHT_BOTTOM = 0xFF1F4A3C.toInt()
internal const val BACKING_PLATE_TAG = "backingPlate"

/** The pastel gradient, shared: the plate behind every tag list and the background of a page that hosts one. */
internal fun plateDrawable(context: Context): GradientDrawable {
    val night = (context.resources.configuration.uiMode and android.content.res.Configuration.UI_MODE_NIGHT_MASK) ==
        android.content.res.Configuration.UI_MODE_NIGHT_YES
    val colors = if (night) intArrayOf(PLATE_NIGHT_TOP, PLATE_NIGHT_MIDDLE, PLATE_NIGHT_BOTTOM) else intArrayOf(PLATE_TOP, PLATE_MIDDLE, PLATE_BOTTOM)
    return GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, colors)
}

/** The shared backing plate: a view with [plateDrawable]; the list and its scroll view above it are transparent. */
internal fun backingPlate(context: Context): View = View(context).apply {
    tag = BACKING_PLATE_TAG
    importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
    background = plateDrawable(context)
}

/**
 * A text glyph (the example's row icons are emoji and symbols) as a template drawable: drawn in one opaque colour, and the
 * tag tints it with the item style's icon colour ([ICON_COLOR]).
 */
private class GlyphDrawable(context: Context, private val glyph: String) : Drawable() {
    private val density = context.resources.displayMetrics.density
    private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = Color.BLACK
        textAlign = Paint.Align.CENTER
    }

    override fun getIntrinsicWidth(): Int = (20 * density).toInt()
    override fun getIntrinsicHeight(): Int = (20 * density).toInt()

    override fun draw(canvas: Canvas) {
        val bounds = bounds
        paint.textSize = bounds.height() * 0.85f
        val baseline = bounds.exactCenterY() - (paint.descent() + paint.ascent()) / 2
        canvas.drawText(glyph, bounds.exactCenterX(), baseline, paint)
    }

    override fun setAlpha(alpha: Int) {
        paint.alpha = alpha
    }

    override fun setColorFilter(colorFilter: ColorFilter?) {
        paint.colorFilter = colorFilter
    }

    @Deprecated("Required by Drawable", ReplaceWith("PixelFormat.TRANSLUCENT"))
    override fun getOpacity(): Int = PixelFormat.TRANSLUCENT
}
