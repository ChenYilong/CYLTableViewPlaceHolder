package com.cyl.refresh

import android.content.Context

/**
 * The refresh styles a cross-platform host (the Flutter plugin's native refresh view) names by one lower camel case string, the
 * same eight values on Android and iOS: `classic`, `cupertino`, `material`, `bezierRadar`, `bezierCircle`, `delivery`, `phoenix`
 * and `taurus`. Android has a header class for every style; a footer is the classic back footer for `classic`, the auto
 * [CYLRefreshCupertinoFooter] for `cupertino` and a [CYLRefreshDrawnFooter] around the style's header for the others (there is no
 * `CYLRefreshBezierCircleFooter` class, so `bezierCircle` wraps [CYLRefreshBezierCircleHeader] directly).
 */
enum class CYLRefreshStyle(val key: String) {
    Classic("classic"),
    Cupertino("cupertino"),
    Material("material"),
    BezierRadar("bezierRadar"),
    BezierCircle("bezierCircle"),
    Delivery("delivery"),
    Phoenix("phoenix"),
    Taurus("taurus");

    /** A new header of this style. */
    fun newHeader(context: Context): CYLRefreshHeader = when (this) {
        Classic -> CYLRefreshNormalHeader(context)
        Cupertino -> CYLRefreshCupertinoHeader(context)
        Material -> CYLRefreshMaterialHeader(context)
        BezierRadar -> CYLRefreshBezierRadarHeader(context)
        BezierCircle -> CYLRefreshBezierCircleHeader(context)
        Delivery -> CYLRefreshDeliveryHeader(context)
        Phoenix -> CYLRefreshPhoenixHeader(context)
        Taurus -> CYLRefreshTaurusHeader(context)
    }

    /** A new footer of this style. */
    fun newFooter(context: Context): CYLRefreshFooter = when (this) {
        Classic -> CYLRefreshBackNormalFooter(context)
        Cupertino -> CYLRefreshCupertinoFooter(context)
        Material -> CYLRefreshMaterialFooter(context)
        BezierRadar -> CYLRefreshBezierRadarFooter(context)
        BezierCircle -> CYLRefreshDrawnFooter(CYLRefreshBezierCircleHeader(context))
        Delivery -> CYLRefreshDeliveryFooter(context)
        Phoenix -> CYLRefreshPhoenixFooter(context)
        Taurus -> CYLRefreshTaurusFooter(context)
    }

    companion object {
        /** The style named [key], or null for a missing or unknown name (the caller falls back to [Classic] and reports it). */
        fun fromKey(key: Any?): CYLRefreshStyle? = values().firstOrNull { it.key == key }
    }
}
