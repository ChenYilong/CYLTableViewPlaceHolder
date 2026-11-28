# Example demo scenario (`examples`)

Full text of the `examples` rules. Summaries: [instructions.md](../../instructions.md) and [AGENTS.md](../../AGENTS.md),
heading "Tag: Example demos". English only. The same rule lives in CollectionViewClassifyMenu
(`docs/instructions/examples.md`, "Sectioned lists in demos use the tag list") and its contract for the long press is in
`docs/tag-long-press-action.md` there.

## Sectioned lists in demos use the tag list (owner's rule, 2026-11-25)

- When an example (demo) screen needs a list with section groups, such as a table view with sections, a list with
  section headers or an inset-grouped list, build it with CollectionViewClassifyMenu's tag list (`CYLTagListView`,
  `CYLTagListState` on HarmonyOS) instead of the platform's own grouped list:
  - One tag list; one section per group; the section title is the section header.
  - A tag shows only the **main title and the icon**; the secondary line (detail, subtitle) is not drawn in the tag.
  - **Tags use the Liquid Glass style**: set the style's background style to the core's Liquid Glass value
    (`style.backgroundStyle = CYLTagBackgroundStyle.liquidGlass` on HarmonyOS; the same style key on the other platforms). The core
    draws glass where the device supports it and falls back to a flat tag elsewhere; never fake glass in an example. Set the style
    in one shared place per example, and make the glass visible in captures (a colorful background behind the list when the page
    background is plain).
  - **Every section header has a title**: a group without a natural title gets a localized one (never an empty header).
  - **Colourful page, library plate.** The page behind the list is colourful (a gradient or an image, set in one shared place per example). The library draws the plate itself, one Liquid Glass card per section (sectionStyle insetGrouped, the default, with sectionBackgroundStyle = liquidGlass); the example draws no plate.
  - **Headers and icon colours.** Long headers use headerMaxLines 2 (a named constant); icon colours are static colours passed through the item style (menuStyleForItem + setIconColor), template images, never .alwaysOriginal.
  - **The tail fold control is itself a Liquid Glass tag**, icon only (the same tag background style as the other tags).
  - **The board is Liquid Glass too, on a gradient page.** The example's tag list sets, in ONE place (its style builder):
    tag background style `liquidGlass`, section (board) background style `liquidGlass` (`sectionBackgroundStyle`, the rounded card
    of the default look), a CLEAR list background and an explicit `tintColor` for the built-in header and fold views when the page
    behind is a fixed color. The whole demo page background is a GRADIENT behind the list, to test the see-through of the glass.
  - **Fold with the tail control, icon only.** A section with more rows than `defaultVisibleRows` folds with the core's **tail**
    fold control: the last tag of the section is the expand / collapse button and shows only the chevron icon, with no More / Less
    text (`foldControl` position `tail`, content `icon`: `CYLMenuFoldControlPosition.tail` + `CYLMenuFoldControlContent.icon`,
    JSON `"foldControl": {"position": "tail", "content": "icon"}`). Never use the header trailing More / Less control in an example.
  - A tap on a tag does exactly what a tap on the replaced cell did (open the screen). The tag does not stay selected.
  - A **long press** shows the secondary line in a small floating callout with an arrow, through the tag list's
    long-press action API (`menuSubtitleForItem` / item key `subtitle`, `longPressAction` `"callout"`). Never draw a popup
    in the example.
  - **Tag width is adaptive**: leave `numberOfItemsPerRow` at 0 so a tag is as wide as its content and a row holds as many
    tags as fit; never fix a number of tags per row in a demo.
  - A title that does not fit one line wraps with the style's `titleMaxLines` (default 1; any number; every line shown with the
    named constant `CYLTagTitleMaxLinesUnlimited`, never a literal such as 0 or 999). The app picks the number; the
    placeholder example uses 3.
- If the tag list lacks an API the example needs, add it to CollectionViewClassifyMenu first (core first), then use it.
- This repository holds only the example: it vendors CollectionViewClassifyMenu's HarmonyOS modules at a pinned commit
  (the commit is in `classifymenu.commit` and in the copy's `UPSTREAM_COMMIT`, copied by `scripts/sync-harmonyos-classifymenu.sh`; never edit the copy by hand) and keeps `cylanimateditem` at the commit those modules need.
- After a change like this, ask for (or run) the contact-list long-press reordering check in CollectionViewClassifyMenu:
  reordering is the tag list's built-in `reorder` long-press action and must stay unchanged.
