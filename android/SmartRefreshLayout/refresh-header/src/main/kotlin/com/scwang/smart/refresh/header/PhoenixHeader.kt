// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header

import android.content.Context
import android.content.res.Resources
import android.graphics.Canvas
import android.graphics.Matrix
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.animation.Animation
import android.view.animation.Interpolator
import android.view.animation.LinearInterpolator
import android.view.animation.Transformation
import androidx.annotation.ColorInt
import com.scwang.smart.drawable.PathsDrawable
import com.scwang.smart.refresh.layout.api.RefreshHeader
import com.scwang.smart.refresh.layout.api.RefreshKernel
import com.scwang.smart.refresh.layout.api.RefreshLayout
import com.scwang.smart.refresh.layout.constant.RefreshState
import com.scwang.smart.refresh.layout.constant.SpinnerStyle
import com.scwang.smart.refresh.layout.simple.SimpleComponent
import com.scwang.smart.refresh.layout.util.SmartUtil
import kotlin.math.max
import kotlin.math.min

/**
 * A town under a rising, spinning sun, from Yalantis' Phoenix (`PhoenixHeader`).
 */
open class PhoenixHeader @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null) :
    SimpleComponent(context, attrs, 0), RefreshHeader {

    /**
     * The sun.
     */
    @JvmField protected var mDrawableSun: Drawable

    /**
     * The sky.
     */
    @JvmField protected var mDrawableSky: Drawable

    /**
     * The town.
     */
    @JvmField protected var mDrawableTown: Drawable

    /**
     * The sun's matrix.
     */
    @JvmField protected var mMatrix = Matrix()

    /**
     * The pull percent.
     */
    @JvmField protected var mPercent = 0f

    /**
     * The sun's rotation, 0 to 1.
     */
    @JvmField protected var mRotate = 0f

    /**
     * The current offset.
     */
    @JvmField protected var mHeight = 0

    /**
     * The header's height.
     */
    @JvmField protected var mHeaderHeight = 0

    /**
     * The background color.
     */
    @JvmField protected var mBackgroundColor: Int

    /**
     * The sun's size.
     */
    @JvmField protected var mSunSize: Int

    /**
     * True while refreshing.
     */
    @JvmField protected var isRefreshing = false

    /**
     * Spins the sun while refreshing.
     */
    @JvmField protected var mAnimation: Animation

    /**
     * The layout's kernel, once initialized.
     */
    @JvmField protected var mKernel: RefreshKernel? = null

    init {
        mSunSize = SmartUtil.dp2px(40f)
        mBackgroundColor = skyColors[0]
        minimumHeight = SmartUtil.dp2px(100f)
        mSpinnerStyle = SpinnerStyle.FixedBehind
        mAnimation = object : Animation() {
            override fun applyTransformation(interpolatedTime: Float, t: Transformation) {
                mRotate = interpolatedTime
                invalidate()
            }
        }.apply {
            repeatCount = Animation.INFINITE
            repeatMode = Animation.RESTART
            interpolator = LINEAR_INTERPOLATOR
            duration = ANIMATION_DURATION.toLong()
        }
        val widthPixels = Resources.getSystem().displayMetrics.widthPixels
        mDrawableTown = PathsDrawable().apply {
            parserColors(*townColors)
            if (!parserPaths(*townPaths)) declareOriginal(1, 0, 1870, 416)
            val b = bounds
            setBounds(0, 0, widthPixels, widthPixels * b.height() / b.width())
        }
        val skyDrawable = PathsDrawable().apply {
            parserColors(*skyColors)
            if (!parserPaths(*skyPaths)) declareOriginal(0, 0, 1600, 1040)
            val b = bounds
            setBounds(0, 0, widthPixels, widthPixels * b.height() / b.width())
        }
        mDrawableSky = skyDrawable
        mDrawableSun = PathsDrawable().apply {
            parserColors(*sunColors)
            if (!parserPaths(*sunPaths)) declareOriginal(5, 5, 240, 240)
            setBounds(0, 0, mSunSize, mSunSize)
        }
        val ta = context.obtainStyledAttributes(attrs, R.styleable.PhoenixHeader)
        var primaryColor = ta.getColor(R.styleable.PhoenixHeader_srlPrimaryColor, 0)
        var accentColor = ta.getColor(R.styleable.PhoenixHeader_srlAccentColor, 0)
        if (ta.hasValue(R.styleable.PhoenixHeader_phPrimaryColor)) primaryColor = ta.getColor(R.styleable.PhoenixHeader_phPrimaryColor, 0)
        if (ta.hasValue(R.styleable.PhoenixHeader_phAccentColor)) accentColor = ta.getColor(R.styleable.PhoenixHeader_phAccentColor, 0)
        if (primaryColor != 0) {
            mBackgroundColor = primaryColor
            if (accentColor != 0) skyDrawable.parserColors(primaryColor, accentColor) else skyDrawable.parserColors(primaryColor)
        }
        ta.recycle()
        initRefreshAccessibility()
    }

    override fun onInitialized(kernel: RefreshKernel, height: Int, maxDragHeight: Int) {
        mKernel = kernel
        kernel.requestDrawBackgroundFor(this, mBackgroundColor)
    }

    override fun onMoving(isDragging: Boolean, percent: Float, offset: Int, height: Int, maxDragHeight: Int) {
        mHeight = offset
        mHeaderHeight = height
        // max(1, …): a zero header height made the sun NaN in the Java version.
        mPercent = 1f * offset / max(1, height)
        mRotate = mPercent
        invalidate()
    }

    override fun onReleased(refreshLayout: RefreshLayout, height: Int, maxDragHeight: Int) {
        isRefreshing = true
        startAnimation(mAnimation)
    }

    override fun onStateChanged(refreshLayout: RefreshLayout, oldState: RefreshState, newState: RefreshState) {
        updateRefreshAccessibility(newState)
    }

    override fun onFinish(refreshLayout: RefreshLayout, success: Boolean): Int {
        isRefreshing = false
        clearAnimation()
        return 0
    }

    @Deprecated("Only called by the layout; use RefreshLayout.setPrimaryColorsId.")
    override fun setPrimaryColors(@ColorInt vararg colors: Int) {
        val sky = mDrawableSky as? PathsDrawable ?: return
        if (colors.size > 1) {
            mBackgroundColor = colors[0]
            sky.parserColors(*colors)
        } else if (colors.isNotEmpty()) {
            mBackgroundColor = colors[0]
            sky.parserColors(colors[0], skyColors[1])
        }
        mKernel?.requestDrawBackgroundFor(this, mBackgroundColor)
    }

    override fun dispatchDraw(canvas: Canvas) {
        val width = width
        val height = mHeight
        val footer = mKernel?.refreshLayout?.refreshFooter?.let { this == it } == true
        if (footer) {
            canvas.save()
            canvas.translate(0f, (getHeight() - mHeight).toFloat())
        }
        drawSky(canvas, width, height)
        drawSun(canvas, width)
        drawTown(canvas, width, height)
        if (footer) canvas.restore()
        super.dispatchDraw(canvas)
    }

    /**
     * Draws the sky, centered on the offset.
     */
    protected open fun drawSky(canvas: Canvas, width: Int, height: Int) {
        val bHeight = mDrawableSky.bounds.height()
        val saveCount = canvas.saveCount
        canvas.save()
        canvas.translate(0f, height / 2f - bHeight / 2f)
        mDrawableSky.draw(canvas)
        canvas.restoreToCount(saveCount)
    }

    /**
     * Draws the town, growing when pulled past the header.
     */
    protected open fun drawTown(canvas: Canvas, width: Int, height: Int) {
        val bWidth = mDrawableTown.bounds.width()
        val bHeight = mDrawableTown.bounds.height()
        val amplification = 0.3f * max(mPercent - 1, 0f) + 1
        val offsetX = width / 2f - (width * amplification).toInt() / 2f
        var offsetY = mHeaderHeight * 0.1f * mPercent
        val townScale = amplification * width / bWidth
        if (offsetY + bHeight * townScale < height) offsetY = height - bHeight * townScale
        val saveCount = canvas.saveCount
        canvas.save()
        canvas.translate(offsetX, offsetY)
        canvas.scale(townScale, townScale)
        mDrawableTown.draw(canvas)
        canvas.restoreToCount(saveCount)
    }

    /**
     * Draws the sun, rising with the pull and spinning while refreshing.
     */
    protected open fun drawSun(canvas: Canvas, width: Int) {
        val matrix = mMatrix
        matrix.reset()
        var sunRadius = mSunSize / 2.0f
        val offsetX = 0.3f * width + sunRadius
        val offsetY = mHeaderHeight * 0.1f + (mHeaderHeight / 2f) * (1.0f - min(mPercent, 1f))
        var sunScale = 1f * mSunSize / mDrawableSun.bounds.width()
        if (mPercent > 1) {
            sunScale *= 1.0f - 0.5f * (mPercent - 1)
            sunRadius *= 1.0f - 0.5f * (mPercent - 1)
        }
        matrix.preScale(sunScale, sunScale)
        matrix.postRotate(
            (if (isRefreshing) -360 else 360) * mRotate * (if (isRefreshing) 1f else SUN_INITIAL_ROTATE_GROWTH),
            sunRadius, sunRadius,
        )
        val saveCount = canvas.saveCount
        canvas.save()
        canvas.translate(offsetX, offsetY)
        canvas.concat(matrix)
        mDrawableSun.draw(canvas)
        canvas.restoreToCount(saveCount)
    }

    /**
     * The animation constants and the drawings' SVG paths and colors.
     */
    companion object {
        /**
         * One turn of the sun, in milliseconds.
         */
        @JvmStatic protected val ANIMATION_DURATION = 1000

        /**
         * How much faster the sun turns while pulled.
         */
        @JvmStatic protected val SUN_INITIAL_ROTATE_GROWTH = 1.2f

        /**
         * The sun's interpolator.
         */
        @JvmStatic protected val LINEAR_INTERPOLATOR: Interpolator = LinearInterpolator()

        /**
         * The townPaths (from the Java version).
         */
        @JvmStatic protected var townPaths = arrayOf(

        "M2,415a35 35,0,0,1,50 -40a50 50,0,0,1,40 -40a40 40,0,0,1,72 -18a30,30,0,0,1,26,-3a30,30,0,0,1,38,-15a40,40,0,0,1,75,-6a40,40,0,0,1,40,20a30,30,0,0,1,20,5a40,40,0,0,1,55,0a30,30,0,0,1,12,-2a35,35,0,0,1,67,5a50,50,0,0,1,50,20L1400,300a40,40,0,0,1,45,20a20,20,0,0,1,15,2a30,30,0,0,1,50,-2a20,20,0,0,1,20,-7a30,30,0,0,1,40,-17a40,40,0,0,1,75,5a30,30,0,0,1,40,15a20,20,0,0,1,22,3a40,40,0,0,1,72,15a55,55,0,0,1,40,45a32,32,0,0,1,50,35",
        "M2,415a35 35,0,0,1,50 -30a50 50,0,0,1,40 -40a40 40,0,0,1,72 -18a30,30,0,0,1,26,-3a30,30,0,0,1,38,-15a40,40,0,0,1,75,-6a40,40,0,0,1,40,20a30,30,0,0,1,20,5a40,40,0,0,1,55,0a30,30,0,0,1,12,-2a35,35,0,0,1,67,5a50,50,0,0,1,50,20L1400,307a40,40,0,0,1,45,20a20,20,0,0,1,15,2a30,30,0,0,1,50,-2a20,20,0,0,1,20,-7a30,30,0,0,1,40,-17a40,40,0,0,1,75,5a30,30,0,0,1,40,15a20,20,0,0,1,22,3a40,40,0,0,1,72,15a55,55,0,0,1,40,45a32,32,0,0,1,50,28",
        "M2,415a35 35,0,0,1,50 -20a50 50,0,0,1,40 -40a40 40,0,0,1,72 -18a30,30,0,0,1,26,-3a30,30,0,0,1,38,-15a40,40,0,0,1,75,-6a40,40,0,0,1,40,20a30,30,0,0,1,20,5a40,40,0,0,1,55,0a30,30,0,0,1,12,-2a35,35,0,0,1,67,5a50,50,0,0,1,50,20L1400,317a40,40,0,0,1,45,20a20,20,0,0,1,15,2a30,30,0,0,1,50,-2a20,20,0,0,1,20,-7a30,30,0,0,1,40,-17a40,40,0,0,1,75,5a30,30,0,0,1,40,15a20,20,0,0,1,22,3a40,40,0,0,1,72,15a55,55,0,0,1,40,45a32,32,0,0,1,50,18",

        "M 520,270h250v-30h110v170h-360zM1285,240l55,-50l60,50v170h-115z",
        "M515,265h250v-30h120v180h-370M525,275v130h240v-130zM525,290h240v10h-240zM775,245v160h100v-160zM590,300h3v50h-3zM605,335h55v3h-55zM675,335h10v3h-10zM700,335h50v3h-50zM525,385h80v3h-80zM630,385h135v3h-135zM605,370h3v35h-3zM625,370h3v35h-3zM545,270h2v20h-2zM565,270h2v20h-2zM585,270h2v20h-2zM605,270h2v20h-2zM625,270h2v20h-2zM645,270h2v20h-2zM665,270h2v20h-2zM685,270h2v20h-2zM705,270h2v20h-2zM725,270h2v20h-2zM745,270h2v20h-2zM770,270h110v2h-110zM770,280h110v2h-110zM805,240h2v40h-2zM840,240h2v40h-2zM785,240h2v30h-2zM795,240h2v30h-2zM815,240h2v30h-2zM827,240h2v30h-2zM851,240h2v30h-2zM862,240h2v30h-2zM795,290h20v30h3v7h-26v-7h3m3,0h14v-15h-14m0,-3h14v-7h-14zM837,290h20v30h3v7h-26v-7h3m3,0h14v-15h-14m0,-3h14v-7h-14zM795,340h20v30h3v7h-26v-7h3m3,0h14v-15h-14m0,-3h14v-7h-14zM837,340h20v30h3v7h-26v-7h3m3,0h14v-15h-14m0,-3h14v-7h-14zM1280,240l60,-55l65,55v175h-125zM1300,235h85l-45,-38zM1290,245v160h105v-160zM1290,270h105v3h-105zM1290,280h105v3h-105zM1310,305h20v30h3v7h-26v-7h3m3,0h14v-15h-14m0,-3h14v-7h-14zM1355,305h20v30h3v7h-26v-7h3m3,0h14v-15h-14m0,-3h14v-7h-14zM1355,350h20v30h3v7h-26v-7h3m3,0h14v-15h-14m0,-3h14v-7h-14zM1305,350h30v60h-30m5,-55v60h20v-60m-15,20h3v3h-3m-5,10h20v3h-20m0,5h20v3h-20z",

        "M495,375q4,-30 30,-30h238v30",
        "M500,370q3,-14 17,-17h245v17",

        "M1045,205h100v-65h120v65h25v210h-245z",
        "M1045,205h100v-65h120v65h25v210h-245zM1055,215v190h225v-190zM1155,150v55h100v-55zM1055,232h225v8h-225zM1055,375h225v10h-225zM1055,260h225v4h-225zM1055,285h225v4h-225zM1055,310h225v4h-225zM1055,332h225v4h-225zM1055,355h225v4h-225zM1075,225h4v150h-4zM1100,225h4v150h-4zM1125,225h4v150h-4zM1150,225h4v150h-4zM1175,225h4v150h-4zM1200,225h4v150h-4zM1225,225h4v150h-4zM1250,225h4v150h-4zM1180,195a 25 25 ,0,0,1, 50 0v10h-50m10,0h30v-10a15 15,0,0,0 -30,0zM1150,160h105v5h-105z",

        "M875,40h180v375h-180zM915,0h105v50h-105z",
        "M925,5h10v35h-10zM940,5h10v35h-10zM955,5h10v35h-10zM970,5h10v35h-10zM985,5h10v35h-10zM1000,5h10v35h-10zM885,50h160v355h-160z",
        "M900,70h5v320h-5zM1025,70h5v320h-5zM915,75h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,75h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,75h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM915,110h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,110h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,110h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM915,145h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,145h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,145h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM915,180h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,180h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,180h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM915,215h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,215h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,215h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM915,250h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,250h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,250h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM915,285h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,285h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,285h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM915,320h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,320h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,320h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM915,355h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM952,355h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15zM990,355h25v25h-25v-25m5,4v9h15v-9h-5m -10,12.5v5h15v-5h-15z"
        )

        /**
         * The townColors (from the Java version).
         */
        @JvmStatic protected var townColors = intArrayOf(
            0xff679893.toInt(),
            0xff98d2d0.toInt(),
            0xff69b3af.toInt(),
            0xfff2ebe0.toInt(),
            0xff847079.toInt(),
            0xff360000.toInt(),
            0xffb65649.toInt(),
            0xffafa68b.toInt(),
            0xff434343.toInt(),
            0xff2b4247.toInt(),
            0xff85acbe.toInt(),
            0xff000000.toInt()
        )

        /**
         * The skyColors (from the Java version).
         */
        @JvmStatic protected var skyColors = intArrayOf(
            0xff38adc1.toInt(),
            0x88ffffff.toInt()
        )

        /**
         * The skyPaths (from the Java version).
         */
        @JvmStatic protected var skyPaths = arrayOf(

        "M0,0L1600,0L1600,1040L0,1040z",
        "M437 373C395 373 366 405 361 433C341 433 317 449 313 472C292 469 255 478 255 520L0 520L0 524C0 524 174 524 261 524C259 486 289 474 318 479C321 458 337 440 365 438C374 405 399 378 441 378C476 378 513 405 517 448C553 450 567 475 570 497C581 501 587 509 588 524C637 523 735 524 735 524L735 520L593 520C592 509 589 500 575 493C572 470 555 445 522 444C517 402 478 372 442 373C440 373 439 373 437 373zM1208 392L1208 401L1241 401L1241 392L1208 392zM1280 392L1280 400L1428 400L1428 392L1280 392zM1118 475C1097 475 1077 485 1063 509C1041 491 1012 508 1012 535C988 547 988 576 988 576L852 576L852 580L992 580C992 580 991 550 1016 538C1015 511 1046 496 1065 518C1098 451 1178 484 1178 538C1207 553 1204 580 1204 580L1600 580L1600 576L1208 576C1208 576 1208 545 1184 535C1182 499 1150 474 1118 475zM184 608L184 612L328 612L328 608L184 608zM904 636L904 640L1016 640L1016 636L904 636zM1200 651L1200 656L1352 656L1352 651L1200 651zM412 656L412 664L564 664L564 656L412 656z"
        )

        /**
         * The sunColors (from the Java version).
         */
        @JvmStatic protected var sunColors = intArrayOf(
            0xfffef9e8.toInt(),
            0xfff3e59c.toInt()
        )

        /**
         * The sunPaths (from the Java version).
         */
        @JvmStatic protected var sunPaths = arrayOf(

        "M75 125a50 50 0 0 1 100 0a50 50 0 0 1 -100 0zM10 130a5 5 0 0 1 0 -10h40a5 5 0 0 1 0 10zM200 130a5 5 0 0 1 0 -10h40a5 5 0 0 1 0 10zM120 10a5 5 0 0 1 10 0v40a5 5 0 0 1 -10 0zM120 200a5 5 0 0 1 10 0v40a5 5 0 0 1 -10 0zM23 72A5 5 0 0 1 28 63L63 84A5 5 0 0 1 58 92zM187 167A5 5 0 0 1 192 158L227 178A5 5 0 0 1 222 187zM63 28A5 5 0 0 1 72 23L92 58A5 5 0 0 1 83 63zM158 193A5 5 0 0 1 167 188L187 222A5 5 0 0 1 178 227zM72 227A5 5 0 0 1 63 222L83 187A5 5 0 0 1 92 193zM167 63A5 5 0 0 1 158 58L178 23A5 5 0 0 1 187 28zM28 187A5 5 0 0 1 23 178L58 158A5 5 0 0 1 63 167zM193 92A5 5 0 0 1 187 83L222 63A5 5 0 0 1 227 72z",
        "M85,125 a40,40,0,0,1,80,0 a40,40,0,0,1,-80,0"
        )
    }
}
