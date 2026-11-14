// android-Ultra-Pull-To-Refresh (https://github.com/liaohuqiu/android-Ultra-Pull-To-Refresh, MIT, Copyright (c) 2015
// liaohuqiu.net) translated to Kotlin.
package `in`.srain.cube.views.ptr.header

import android.util.SparseArray

/**
 * The line segments of the letters A to Z (either case) and the digits 0 to 9 for the [StoreHouseHeader]
 * (`StoreHousePath`).
 */
object StoreHousePath {

    private val pointList = SparseArray<FloatArray>()

    private val LETTERS = arrayOf(
        // A
        floatArrayOf(
            24f, 0f, 1f, 22f,
            1f, 22f, 1f, 72f,
            24f, 0f, 47f, 22f,
            47f, 22f, 47f, 72f,
            1f, 48f, 47f, 48f,
        ),
        // B
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 0f, 37f, 0f,
            37f, 0f, 47f, 11f,
            47f, 11f, 47f, 26f,
            47f, 26f, 38f, 36f,
            38f, 36f, 0f, 36f,
            38f, 36f, 47f, 46f,
            47f, 46f, 47f, 61f,
            47f, 61f, 38f, 71f,
            37f, 72f, 0f, 72f,
        ),
        // C
        floatArrayOf(
            47f, 0f, 0f, 0f,
            0f, 0f, 0f, 72f,
            0f, 72f, 47f, 72f,
        ),
        // D
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 0f, 24f, 0f,
            24f, 0f, 47f, 22f,
            47f, 22f, 47f, 48f,
            47f, 48f, 23f, 72f,
            23f, 72f, 0f, 72f,
        ),
        // E
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 0f, 47f, 0f,
            0f, 36f, 37f, 36f,
            0f, 72f, 47f, 72f,
        ),
        // F
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 0f, 47f, 0f,
            0f, 36f, 37f, 36f,
        ),
        // G
        floatArrayOf(
            47f, 23f, 47f, 0f,
            47f, 0f, 0f, 0f,
            0f, 0f, 0f, 72f,
            0f, 72f, 47f, 72f,
            47f, 72f, 47f, 48f,
            47f, 48f, 24f, 48f,
        ),
        // H
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 36f, 47f, 36f,
            47f, 0f, 47f, 72f,
        ),
        // I
        floatArrayOf(
            0f, 0f, 47f, 0f,
            24f, 0f, 24f, 72f,
            0f, 72f, 47f, 72f,
        ),
        // J
        floatArrayOf(
            47f, 0f, 47f, 72f,
            47f, 72f, 24f, 72f,
            24f, 72f, 0f, 48f,
        ),
        // K
        floatArrayOf(
            0f, 0f, 0f, 72f,
            47f, 0f, 3f, 33f,
            3f, 38f, 47f, 72f,
        ),
        // L
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 72f, 47f, 72f,
        ),
        // M
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 0f, 24f, 23f,
            24f, 23f, 47f, 0f,
            47f, 0f, 47f, 72f,
        ),
        // N
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 0f, 47f, 72f,
            47f, 72f, 47f, 0f,
        ),
        // O
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 72f, 47f, 72f,
            47f, 72f, 47f, 0f,
            47f, 0f, 0f, 0f,
        ),
        // P
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 0f, 47f, 0f,
            47f, 0f, 47f, 36f,
            47f, 36f, 0f, 36f,
        ),
        // Q
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 72f, 23f, 72f,
            23f, 72f, 47f, 48f,
            47f, 48f, 47f, 0f,
            47f, 0f, 0f, 0f,
            24f, 28f, 47f, 71f,
        ),
        // R
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 0f, 47f, 0f,
            47f, 0f, 47f, 36f,
            47f, 36f, 0f, 36f,
            0f, 37f, 47f, 72f,
        ),
        // S
        floatArrayOf(
            47f, 0f, 0f, 0f,
            0f, 0f, 0f, 36f,
            0f, 36f, 47f, 36f,
            47f, 36f, 47f, 72f,
            47f, 72f, 0f, 72f,
        ),
        // T
        floatArrayOf(
            0f, 0f, 47f, 0f,
            24f, 0f, 24f, 72f,
        ),
        // U
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 72f, 47f, 72f,
            47f, 72f, 47f, 0f,
        ),
        // V
        floatArrayOf(
            0f, 0f, 24f, 72f,
            24f, 72f, 47f, 0f,
        ),
        // W
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 72f, 24f, 49f,
            24f, 49f, 47f, 72f,
            47f, 72f, 47f, 0f,
        ),
        // X
        floatArrayOf(
            0f, 0f, 47f, 72f,
            47f, 0f, 0f, 72f,
        ),
        // Y
        floatArrayOf(
            0f, 0f, 24f, 23f,
            47f, 0f, 24f, 23f,
            24f, 23f, 24f, 72f,
        ),
        // Z
        floatArrayOf(
            0f, 0f, 47f, 0f,
            47f, 0f, 0f, 72f,
            0f, 72f, 47f, 72f,
        ),
    )

    private val NUMBERS = arrayOf(
        // 0
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 72f, 47f, 72f,
            47f, 72f, 47f, 0f,
            47f, 0f, 0f, 0f,
        ),
        // 1
        floatArrayOf(
            24f, 0f, 24f, 72f,
        ),
        // 2
        floatArrayOf(
            0f, 0f, 47f, 0f,
            47f, 0f, 47f, 36f,
            47f, 36f, 0f, 36f,
            0f, 36f, 0f, 72f,
            0f, 72f, 47f, 72f,
        ),
        // 3
        floatArrayOf(
            0f, 0f, 47f, 0f,
            47f, 0f, 47f, 36f,
            47f, 36f, 0f, 36f,
            47f, 36f, 47f, 72f,
            47f, 72f, 0f, 72f,
        ),
        // 4
        floatArrayOf(
            0f, 0f, 0f, 36f,
            0f, 36f, 47f, 36f,
            47f, 0f, 47f, 72f,
        ),
        // 5
        floatArrayOf(
            0f, 0f, 0f, 36f,
            0f, 36f, 47f, 36f,
            47f, 36f, 47f, 72f,
            47f, 72f, 0f, 72f,
            0f, 0f, 47f, 0f,
        ),
        // 6
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 72f, 47f, 72f,
            47f, 72f, 47f, 36f,
            47f, 36f, 0f, 36f,
        ),
        // 7
        floatArrayOf(
            0f, 0f, 47f, 0f,
            47f, 0f, 47f, 72f,
        ),
        // 8
        floatArrayOf(
            0f, 0f, 0f, 72f,
            0f, 72f, 47f, 72f,
            47f, 72f, 47f, 0f,
            47f, 0f, 0f, 0f,
            0f, 36f, 47f, 36f,
        ),
        // 9
        floatArrayOf(
            47f, 0f, 0f, 0f,
            0f, 0f, 0f, 36f,
            0f, 36f, 47f, 36f,
            47f, 0f, 47f, 72f,
        ),
    )

    init {
        LETTERS.forEachIndexed { i, points -> pointList.append(i + 65, points) }
        LETTERS.forEachIndexed { i, points -> pointList.append(i + 65 + 32, points) }
        NUMBERS.forEachIndexed { i, points -> pointList.append(i + 48, points) }
        addChar(' ', floatArrayOf())
        addChar('-', floatArrayOf(0f, 36f, 47f, 36f))
        addChar('.', floatArrayOf(24f, 60f, 24f, 72f))
    }

    /**
     * Adds or replaces the segments of [c]: four numbers (x1, y1, x2, y2) per segment in a 47 x 72 box.
     */
    @JvmStatic
    fun addChar(c: Char, points: FloatArray) {
        pointList.append(c.code, points)
    }

    /**
     * The segments of [str] at scale 1 with 14 between letters.
     */
    @JvmStatic
    fun getPath(str: String): ArrayList<FloatArray> = getPath(str, 1f, 14)

    /**
     * The segments of [str], each {x1, y1, x2, y2}, scaled by [scale] with [gapBetweenLetter] between letters;
     * characters without segments are skipped.
     */
    @JvmStatic
    fun getPath(str: String, scale: Float, gapBetweenLetter: Int): ArrayList<FloatArray> {
        val list = ArrayList<FloatArray>()
        var offsetForWidth = 0f
        for (ch in str) {
            val points = pointList.get(ch.code) ?: continue
            for (j in 0 until points.size / 4) {
                list += FloatArray(4) { k ->
                    val l = points[j * 4 + k]
                    if (k % 2 == 0) (l + offsetForWidth) * scale else l * scale
                }
            }
            offsetForWidth += 57 + gapBetweenLetter
        }
        return list
    }
}
