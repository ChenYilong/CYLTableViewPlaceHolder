// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90) translated to
// Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.refresh.header.storehouse

import android.util.SparseArray

/**
 * The StoreHouse header's letters, as line segments (`StoreHousePath`).
 */
object StoreHousePath {

    private val sPointList = SparseArray<FloatArray>()

    init {
        val letters = arrayOf(
                floatArrayOf(
                        // A
                        24f, 0f, 1f, 22f,
                        1f, 22f, 1f, 72f,
                        24f, 0f, 47f, 22f,
                        47f, 22f, 47f, 72f,
                        1f, 48f, 47f, 48f
                ),

                floatArrayOf(
                        // B
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

                floatArrayOf(
                        // C
                        47f, 0f, 0f, 0f,
                        0f, 0f, 0f, 72f,
                        0f, 72f, 47f, 72f,
                ),

                floatArrayOf(
                        // D
                        0f, 0f, 0f, 72f,
                        0f, 0f, 24f, 0f,
                        24f, 0f, 47f, 22f,
                        47f, 22f, 47f, 48f,
                        47f, 48f, 23f, 72f,
                        23f, 72f, 0f, 72f,
                ),

                floatArrayOf(
                        // E
                        0f, 0f, 0f, 72f,
                        0f, 0f, 47f, 0f,
                        0f, 36f, 37f, 36f,
                        0f, 72f, 47f, 72f,
                ),

                floatArrayOf(
                        // F
                        0f, 0f, 0f, 72f,
                        0f, 0f, 47f, 0f,
                        0f, 36f, 37f, 36f,
                ),

                floatArrayOf(
                        // G
                        47f, 23f, 47f, 0f,
                        47f, 0f, 0f, 0f,
                        0f, 0f, 0f, 72f,
                        0f, 72f, 47f, 72f,
                        47f, 72f, 47f, 48f,
                        47f, 48f, 24f, 48f,
                ),

                floatArrayOf(
                        // H
                        0f, 0f, 0f, 72f,
                        0f, 36f, 47f, 36f,
                        47f, 0f, 47f, 72f,
                ),

                floatArrayOf(
                        // I
                        0f, 0f, 47f, 0f,
                        24f, 0f, 24f, 72f,
                        0f, 72f, 47f, 72f,
                ),

                floatArrayOf(
                        // J
                        47f, 0f, 47f, 72f,
                        47f, 72f, 24f, 72f,
                        24f, 72f, 0f, 48f,
                ),

                floatArrayOf(
                        // K
                        0f, 0f, 0f, 72f,
                        47f, 0f, 3f, 33f,
                        3f, 38f, 47f, 72f,
                ),

                floatArrayOf(
                        // L
                        0f, 0f, 0f, 72f,
                        0f, 72f, 47f, 72f,
                ),

                floatArrayOf(
                        // M
                        0f, 0f, 0f, 72f,
                        0f, 0f, 24f, 23f,
                        24f, 23f, 47f, 0f,
                        47f, 0f, 47f, 72f,
                ),

                floatArrayOf(
                        // N
                        0f, 0f, 0f, 72f,
                        0f, 0f, 47f, 72f,
                        47f, 72f, 47f, 0f,
                ),

                floatArrayOf(
                        // O
                        0f, 0f, 0f, 72f,
                        0f, 72f, 47f, 72f,
                        47f, 72f, 47f, 0f,
                        47f, 0f, 0f, 0f,
                ),

                floatArrayOf(
                        // P
                        0f, 0f, 0f, 72f,
                        0f, 0f, 47f, 0f,
                        47f, 0f, 47f, 36f,
                        47f, 36f, 0f, 36f,
                ),

                floatArrayOf(
                        // Q
                        0f, 0f, 0f, 72f,
                        0f, 72f, 23f, 72f,
                        23f, 72f, 47f, 48f,
                        47f, 48f, 47f, 0f,
                        47f, 0f, 0f, 0f,
                        24f, 28f, 47f, 71f,
                ),

                floatArrayOf(
                        // R
                        0f, 0f, 0f, 72f,
                        0f, 0f, 47f, 0f,
                        47f, 0f, 47f, 36f,
                        47f, 36f, 0f, 36f,
                        0f, 37f, 47f, 72f,
                ),

                floatArrayOf(
                        // S
                        47f, 0f, 0f, 0f,
                        0f, 0f, 0f, 36f,
                        0f, 36f, 47f, 36f,
                        47f, 36f, 47f, 72f,
                        47f, 72f, 0f, 72f,
                ),

                floatArrayOf(
                        // T
                        0f, 0f, 47f, 0f,
                        24f, 0f, 24f, 72f,
                ),

                floatArrayOf(
                        // U
                        0f, 0f, 0f, 72f,
                        0f, 72f, 47f, 72f,
                        47f, 72f, 47f, 0f,
                ),

                floatArrayOf(
                        // V
                        0f, 0f, 24f, 72f,
                        24f, 72f, 47f, 0f,
                ),

                floatArrayOf(
                        // W
                        0f, 0f, 0f, 72f,
                        0f, 72f, 24f, 49f,
                        24f, 49f, 47f, 72f,
                        47f, 72f, 47f, 0f
                ),

                floatArrayOf(
                        // X
                        0f, 0f, 47f, 72f,
                        47f, 0f, 0f, 72f
                ),

                floatArrayOf(
                        // Y
                        0f, 0f, 24f, 23f,
                        47f, 0f, 24f, 23f,
                        24f, 23f, 24f, 72f
                ),

                floatArrayOf(
                        // Z
                        0f, 0f, 47f, 0f,
                        47f, 0f, 0f, 72f,
                        0f, 72f, 47f, 72f
                ),
        )
        val numbers = arrayOf(
                floatArrayOf(
                        // 0f
                        0f, 0f, 0f, 72f,
                        0f, 72f, 47f, 72f,
                        47f, 72f, 47f, 0f,
                        47f, 0f, 0f, 0f,
                ),
                floatArrayOf(
                        // 1f
                        24f, 0f, 24f, 72f,
                ),

                floatArrayOf(
                        // 2f
                        0f, 0f, 47f, 0f,
                        47f, 0f, 47f, 36f,
                        47f, 36f, 0f, 36f,
                        0f, 36f, 0f, 72f,
                        0f, 72f, 47f, 72f
                ),

                floatArrayOf(
                        // 3f
                        0f, 0f, 47f, 0f,
                        47f, 0f, 47f, 36f,
                        47f, 36f, 0f, 36f,
                        47f, 36f, 47f, 72f,
                        47f, 72f, 0f, 72f,
                ),

                floatArrayOf(
                        // 4f
                        0f, 0f, 0f, 36f,
                        0f, 36f, 47f, 36f,
                        47f, 0f, 47f, 72f,
                ),

                floatArrayOf(
                        // 5f
                        0f, 0f, 0f, 36f,
                        0f, 36f, 47f, 36f,
                        47f, 36f, 47f, 72f,
                        47f, 72f, 0f, 72f,
                        0f, 0f, 47f, 0f
                ),

                floatArrayOf(
                        // 6f
                        0f, 0f, 0f, 72f,
                        0f, 72f, 47f, 72f,
                        47f, 72f, 47f, 36f,
                        47f, 36f, 0f, 36f
                ),

                floatArrayOf(
                        // 7f
                        0f, 0f, 47f, 0f,
                        47f, 0f, 47f, 72f
                ),

                floatArrayOf(
                        // 8f
                        0f, 0f, 0f, 72f,
                        0f, 72f, 47f, 72f,
                        47f, 72f, 47f, 0f,
                        47f, 0f, 0f, 0f,
                        0f, 36f, 47f, 36f
                ),

                floatArrayOf(
                        // 9f
                        47f, 0f, 0f, 0f,
                        0f, 0f, 0f, 36f,
                        0f, 36f, 47f, 36f,
                        47f, 0f, 47f, 72f,
                )
        )
        // A - Z and a - z
        for (i in letters.indices) {
            sPointList.append(i + 65, letters[i])
            sPointList.append(i + 65 + 32, letters[i])
        }
        // 0 - 9
        for (i in numbers.indices) sPointList.append(i + 48, numbers[i])
        sPointList.append(' '.code, floatArrayOf())
        sPointList.append('-'.code, floatArrayOf(0f, 36f, 47f, 36f))
        sPointList.append('.'.code, floatArrayOf(24f, 60f, 24f, 72f))
    }

    /**
     * The line segments {x1, y1, x2, y2} of [str], scaled by [scale], with [gapBetweenLetter] between letters.
     */
    @JvmStatic
    fun getPath(str: String, scale: Float, gapBetweenLetter: Int): List<FloatArray> {
        val list = ArrayList<FloatArray>()
        var offsetForWidth = 0f
        for (c in str) {
            val points = sPointList.get(c.code) ?: continue
            for (j in 0 until points.size / 4) {
                list.add(FloatArray(4) { k ->
                    val l = points[j * 4 + k]
                    if (k % 2 == 0) (l + offsetForWidth) * scale else l * scale
                })
            }
            offsetForWidth += 57 + gapBetweenLetter
        }
        return list
    }
}
