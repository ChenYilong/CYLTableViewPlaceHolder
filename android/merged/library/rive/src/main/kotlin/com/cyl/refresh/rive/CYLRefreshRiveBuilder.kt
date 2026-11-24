package com.cyl.refresh.rive

import android.content.Context
import com.cyl.refresh.CYLRefreshDrawnFooter
import com.cyl.refresh.CYLRefreshFooter
import com.cyl.refresh.CYLRefreshHeader
import com.cyl.refresh.CYLRefreshRiveBuilding
import com.cyl.refresh.CYLRefreshRiveOptions
import java.io.File

/**
 * The builder the core finds by this class name (`CYLRefreshRiveSupport.BUILDER_CLASS`; iOS `CYLRefreshRiveBuilder`): it turns the `rive...`
 * creation parameters ([CYLRefreshRiveOptions]) into a [CYLRefreshRiveStyle] and the Rive header or footer. It needs a public
 * constructor without arguments, and the module's consumer rule keeps it from being shrunk away.
 */
class CYLRefreshRiveBuilder : CYLRefreshRiveBuilding {
    override fun header(context: Context, options: CYLRefreshRiveOptions): CYLRefreshHeader? =
        style(context, options)?.let { CYLRefreshRiveHeader.create(context, it) }

    override fun footer(context: Context, options: CYLRefreshRiveOptions): CYLRefreshFooter? =
        (header(context, options) as? CYLRefreshRiveHeader)?.let { CYLRefreshDrawnFooter(it) }

    /** The style for [options], or null when the file is not found: a path must be a readable file, a name must open as one of the asset candidates. */
    internal fun style(context: Context, options: CYLRefreshRiveOptions): CYLRefreshRiveStyle? {
        val file = options.file ?: return null
        val url = if (options.fileIsPath) file.takeIf { File(it.removePrefix("file://")).canRead() }
        else options.assetCandidates().firstOrNull { runCatching { context.assets.open(it).close() }.isSuccess }?.let { "asset:$it" }
        return url?.let { CYLRefreshRiveStyle(it).apply { copyFrom(options) } }
    }
}

/** Copies every key of [options] into this style (the names are the same without the `rive` prefix). */
internal fun CYLRefreshRiveStyle.copyFrom(options: CYLRefreshRiveOptions) {
    artboardName = options.artboard
    stateMachineName = options.stateMachine
    triggerOffset = options.triggerOffset
    minimumHeight = options.minimumHeight
    fitsWidth = options.fitsWidth
    pullInput = options.pullInput
    pullInputMinimum = options.pullInputMinimum
    pullInputMaximum = options.pullInputMaximum
    pullInputStart = options.pullInputStart
    pullInputRefreshingValue = options.pullInputRefreshingValue
    releaseTrigger = options.releaseTrigger
    finishTrigger = options.finishTrigger
    restartTrigger = options.restartTrigger
    finishTimeout = options.finishTimeout
    loadingBoolean = options.loadingBoolean
    loadingNumber = options.loadingNumber
    loadingNumberMaximum = options.loadingNumberMaximum
    loadingNumberFinished = options.loadingNumberFinished
    loadingNumberDuration = options.loadingNumberDuration
    pullAnimation = options.pullAnimation
    triggerAnimation = options.triggerAnimation
    loadingAnimation = options.loadingAnimation
    idleAnimation = options.idleAnimation
    drawnTable = options.drawnTable
}
