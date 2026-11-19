package com.cyl.refresh

import android.graphics.drawable.Drawable
import com.cyl.placeholder.CYLPlaceholderStackView
import com.cyl.refresh.merged.R

/*
 * The iOS categories of every refresh control, with the iOS names (docs/Android-API-Map.md): the state titles
 * (`CYLRefreshComponent (CYLRefreshStateTitles)`), the icon layout calls (`CYLRefreshComponent (CYLRefreshIconLayout)`)
 * and the no-more-data image (`CYLRefreshFooter (CYLRefreshNoMoreDataImage)`). A control with a state text (the state
 * header, the state footers and their subclasses) shows them; any other control keeps them, as iOS does.
 */

@Suppress("UNCHECKED_CAST")
private val CYLRefreshComponent.storedStateTitles: MutableMap<CYLRefreshState, String>
    get() = (view.view.getTag(R.id.cyl_refresh_state_titles) as? MutableMap<CYLRefreshState, String>)
        ?: mutableMapOf<CYLRefreshState, String>().also { view.view.setTag(R.id.cyl_refresh_state_titles, it) }

/**
 * The text of [state] (`cyl_setStateTitle:forState:`): shown by a control with a state text, kept by any other.
 */
fun CYLRefreshComponent.cyl_setStateTitle(title: String, state: CYLRefreshState) {
    storedStateTitles[state] = title
    when (this) {
        is CYLRefreshStateHeader -> setTitle(title, state)
        is CYLRefreshAutoStateFooter -> setTitle(title, state)
        is CYLRefreshBackStateFooter -> setTitle(title, state)
    }
}

/**
 * The text of [state], or null (`cyl_stateTitleForState:`).
 */
fun CYLRefreshComponent.cyl_stateTitleForState(state: CYLRefreshState): String? = when (this) {
    is CYLRefreshStateHeader -> titleForState(state)
    is CYLRefreshAutoStateFooter -> titleForState(state)
    is CYLRefreshBackStateFooter -> titleForState(state)
    else -> storedStateTitles[state]
}

/**
 * Image frames as the icon of [state], [duration] seconds in all (`cyl_setAnimationImages:duration:forState:`).
 */
fun CYLRefreshComponent.cyl_setAnimationImages(images: List<Drawable>, duration: Double, state: CYLRefreshState) =
    cyl_setIconImages(images, duration, state)

/**
 * One of the placeholder's bundled animation files, [name] in its `CYLPlaceholderAnimations` assets (the iOS
 * CYLTableViewPlaceHolder.bundle), as the icon of [state], [width] × [height] dp (`cyl_setBundledIconAnimation:size:forState:`).
 */
fun CYLRefreshComponent.cyl_setBundledIconAnimation(name: String, width: Float, height: Float, state: CYLRefreshState) =
    cyl_setIconAnimationAttributes(
        mapOf(
            CYLRefreshIconView.ANIMATION_FILE_PATH to "asset:${CYLPlaceholderStackView.ANIMATION_FOLDER}/$name",
            CYLRefreshIconView.SIZE to floatArrayOf(width, height),
        ),
        state,
    )

/**
 * Shown beside the text while there is no more data (`noMoreDataImage`): the normal footers show it, any other footer
 * keeps it.
 */
var CYLRefreshFooter.cyl_noMoreDataImage: Drawable?
    get() = when (this) {
        is CYLRefreshAutoNormalFooter -> noMoreDataImage
        is CYLRefreshBackNormalFooter -> noMoreDataImage
        else -> view.view.getTag(R.id.cyl_refresh_no_more_data_image) as? Drawable
    }
    set(value) {
        view.view.setTag(R.id.cyl_refresh_no_more_data_image, value)
        when (this) {
            is CYLRefreshAutoNormalFooter -> noMoreDataImage = value
            is CYLRefreshBackNormalFooter -> noMoreDataImage = value
        }
    }

/**
 * Sets [cyl_noMoreDataImage] (`cyl_updateNoMoreDataImage:`).
 */
fun CYLRefreshFooter.cyl_updateNoMoreDataImage(image: Drawable?) {
    cyl_noMoreDataImage = image
}
