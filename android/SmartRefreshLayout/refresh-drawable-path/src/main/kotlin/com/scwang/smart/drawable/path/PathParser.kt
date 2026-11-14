// SmartRefreshLayout (https://github.com/scwang90/SmartRefreshLayout, Apache-2.0, Copyright scwang90; based on the
// Android Open Source Project's PathParser, Apache-2.0) translated to Kotlin; the JVM signatures match the Java version.
package com.scwang.smart.drawable.path

import android.graphics.Matrix
import android.graphics.Path
import kotlin.math.abs
import kotlin.math.atan2
import kotlin.math.ceil
import kotlin.math.cos
import kotlin.math.sin
import kotlin.math.sqrt
import kotlin.math.tan

/**
 * Parses SVG path data into [Path]s (`PathParser`).
 */
open class PathParser {

    /**
     * One command of the path data and its numbers (`PathParser.PathDataNode`).
     */
    open class PathDataNode internal constructor(@JvmField internal var type: Char, @JvmField internal var params: FloatArray) {

        /**
         * Adds the nodes to a path.
         */
        companion object {
            /**
             * Adds [node] to [path].
             */
            @JvmStatic
            fun nodesToPath(node: Array<PathDataNode>, path: Path) {
                val current = FloatArray(6)
                var previousCommand = 'm'
                for (aNode in node) {
                    addCommand(path, current, previousCommand, aNode.type, aNode.params)
                    previousCommand = aNode.type
                }
            }

            private fun addCommand(path: Path, current: FloatArray, previous: Char, cmd: Char, v: FloatArray) {
                var previousCmd = previous
                var currentX = current[0]
                var currentY = current[1]
                var ctrlPointX = current[2]
                var ctrlPointY = current[3]
                var currentSegmentStartX = current[4]
                var currentSegmentStartY = current[5]
                var reflectiveX: Float
                var reflectiveY: Float
                val inc = when (cmd) {
                    'z', 'Z' -> {
                        path.close()
                        currentX = currentSegmentStartX
                        currentY = currentSegmentStartY
                        ctrlPointX = currentSegmentStartX
                        ctrlPointY = currentSegmentStartY
                        path.moveTo(currentX, currentY)
                        2
                    }
                    'h', 'H', 'v', 'V' -> 1
                    'c', 'C' -> 6
                    's', 'S', 'q', 'Q' -> 4
                    'a', 'A' -> 7
                    else -> 2
                }
                var k = 0
                while (k < v.size) {
                    when (cmd) {
                        'm' -> {
                            currentX += v[k]
                            currentY += v[k + 1]
                            if (k > 0) {
                                path.rLineTo(v[k], v[k + 1])
                            } else {
                                path.rMoveTo(v[k], v[k + 1])
                                currentSegmentStartX = currentX
                                currentSegmentStartY = currentY
                            }
                        }
                        'M' -> {
                            currentX = v[k]
                            currentY = v[k + 1]
                            if (k > 0) {
                                path.lineTo(v[k], v[k + 1])
                            } else {
                                path.moveTo(v[k], v[k + 1])
                                currentSegmentStartX = currentX
                                currentSegmentStartY = currentY
                            }
                        }
                        'l' -> {
                            path.rLineTo(v[k], v[k + 1])
                            currentX += v[k]
                            currentY += v[k + 1]
                        }
                        'L' -> {
                            path.lineTo(v[k], v[k + 1])
                            currentX = v[k]
                            currentY = v[k + 1]
                        }
                        'h' -> {
                            path.rLineTo(v[k], 0f)
                            currentX += v[k]
                        }
                        'H' -> {
                            path.lineTo(v[k], currentY)
                            currentX = v[k]
                        }
                        'v' -> {
                            path.rLineTo(0f, v[k])
                            currentY += v[k]
                        }
                        'V' -> {
                            path.lineTo(currentX, v[k])
                            currentY = v[k]
                        }
                        'c' -> {
                            path.rCubicTo(v[k], v[k + 1], v[k + 2], v[k + 3], v[k + 4], v[k + 5])
                            ctrlPointX = currentX + v[k + 2]
                            ctrlPointY = currentY + v[k + 3]
                            currentX += v[k + 4]
                            currentY += v[k + 5]
                        }
                        'C' -> {
                            path.cubicTo(v[k], v[k + 1], v[k + 2], v[k + 3], v[k + 4], v[k + 5])
                            currentX = v[k + 4]
                            currentY = v[k + 5]
                            ctrlPointX = v[k + 2]
                            ctrlPointY = v[k + 3]
                        }
                        's' -> {
                            reflectiveX = 0f
                            reflectiveY = 0f
                            if (previousCmd == 'c' || previousCmd == 's' || previousCmd == 'C' || previousCmd == 'S') {
                                reflectiveX = currentX - ctrlPointX
                                reflectiveY = currentY - ctrlPointY
                            }
                            path.rCubicTo(reflectiveX, reflectiveY, v[k], v[k + 1], v[k + 2], v[k + 3])
                            ctrlPointX = currentX + v[k]
                            ctrlPointY = currentY + v[k + 1]
                            currentX += v[k + 2]
                            currentY += v[k + 3]
                        }
                        'S' -> {
                            reflectiveX = currentX
                            reflectiveY = currentY
                            if (previousCmd == 'c' || previousCmd == 's' || previousCmd == 'C' || previousCmd == 'S') {
                                reflectiveX = 2 * currentX - ctrlPointX
                                reflectiveY = 2 * currentY - ctrlPointY
                            }
                            path.cubicTo(reflectiveX, reflectiveY, v[k], v[k + 1], v[k + 2], v[k + 3])
                            ctrlPointX = v[k]
                            ctrlPointY = v[k + 1]
                            currentX = v[k + 2]
                            currentY = v[k + 3]
                        }
                        'q' -> {
                            path.rQuadTo(v[k], v[k + 1], v[k + 2], v[k + 3])
                            ctrlPointX = currentX + v[k]
                            ctrlPointY = currentY + v[k + 1]
                            currentX += v[k + 2]
                            currentY += v[k + 3]
                        }
                        'Q' -> {
                            path.quadTo(v[k], v[k + 1], v[k + 2], v[k + 3])
                            ctrlPointX = v[k]
                            ctrlPointY = v[k + 1]
                            currentX = v[k + 2]
                            currentY = v[k + 3]
                        }
                        't' -> {
                            reflectiveX = 0f
                            reflectiveY = 0f
                            if (previousCmd == 'q' || previousCmd == 't' || previousCmd == 'Q' || previousCmd == 'T') {
                                reflectiveX = currentX - ctrlPointX
                                reflectiveY = currentY - ctrlPointY
                            }
                            path.rQuadTo(reflectiveX, reflectiveY, v[k], v[k + 1])
                            ctrlPointX = currentX + reflectiveX
                            ctrlPointY = currentY + reflectiveY
                            currentX += v[k]
                            currentY += v[k + 1]
                        }
                        'T' -> {
                            reflectiveX = currentX
                            reflectiveY = currentY
                            if (previousCmd == 'q' || previousCmd == 't' || previousCmd == 'Q' || previousCmd == 'T') {
                                reflectiveX = 2 * currentX - ctrlPointX
                                reflectiveY = 2 * currentY - ctrlPointY
                            }
                            path.quadTo(reflectiveX, reflectiveY, v[k], v[k + 1])
                            ctrlPointX = reflectiveX
                            ctrlPointY = reflectiveY
                            currentX = v[k]
                            currentY = v[k + 1]
                        }
                        'a' -> {
                            drawArc(path, currentX, currentY, v[k + 5] + currentX, v[k + 6] + currentY, v[k], v[k + 1], v[k + 2], v[k + 3] != 0f, v[k + 4] != 0f)
                            currentX += v[k + 5]
                            currentY += v[k + 6]
                            ctrlPointX = currentX
                            ctrlPointY = currentY
                        }
                        'A' -> {
                            drawArc(path, currentX, currentY, v[k + 5], v[k + 6], v[k], v[k + 1], v[k + 2], v[k + 3] != 0f, v[k + 4] != 0f)
                            currentX = v[k + 5]
                            currentY = v[k + 6]
                            ctrlPointX = currentX
                            ctrlPointY = currentY
                        }
                    }
                    previousCmd = cmd
                    k += inc
                }
                current[0] = currentX
                current[1] = currentY
                current[2] = ctrlPointX
                current[3] = ctrlPointY
                current[4] = currentSegmentStartX
                current[5] = currentSegmentStartY
            }

            private fun drawArc(p: Path, x0: Float, y0: Float, x1: Float, y1: Float, a: Float, b: Float, theta: Float, isMoreThanHalf: Boolean, isPositiveArc: Boolean) {
                val thetaD = Math.toRadians(theta.toDouble())
                val cosTheta = cos(thetaD)
                val sinTheta = sin(thetaD)
                val x0p = (x0 * cosTheta + y0 * sinTheta) / a
                val y0p = (-x0 * sinTheta + y0 * cosTheta) / b
                val x1p = (x1 * cosTheta + y1 * sinTheta) / a
                val y1p = (-x1 * sinTheta + y1 * cosTheta) / b
                val dx = x0p - x1p
                val dy = y0p - y1p
                val xm = (x0p + x1p) / 2
                val ym = (y0p + y1p) / 2
                val dsq = dx * dx + dy * dy
                if (dsq == 0.0) return
                val disc = 1.0 / dsq - 1.0 / 4.0
                if (disc < 0.0) {
                    val adjust = (sqrt(dsq) / 1.99999).toFloat()
                    drawArc(p, x0, y0, x1, y1, a * adjust, b * adjust, theta, isMoreThanHalf, isPositiveArc)
                    return
                }
                val s = sqrt(disc)
                val sdx = s * dx
                val sdy = s * dy
                var cx: Double
                var cy: Double
                if (isMoreThanHalf == isPositiveArc) {
                    cx = xm - sdy
                    cy = ym + sdx
                } else {
                    cx = xm + sdy
                    cy = ym - sdx
                }
                val eta0 = atan2(y0p - cy, x0p - cx)
                val eta1 = atan2(y1p - cy, x1p - cx)
                var sweep = eta1 - eta0
                if (isPositiveArc != (sweep >= 0)) {
                    sweep += if (sweep > 0) -2 * Math.PI else 2 * Math.PI
                }
                cx *= a
                cy *= b
                val tcx = cx
                cx = cx * cosTheta - cy * sinTheta
                cy = tcx * sinTheta + cy * cosTheta
                arcToBezier(p, cx, cy, a.toDouble(), b.toDouble(), x0.toDouble(), y0.toDouble(), thetaD, eta0, sweep)
            }

            private fun arcToBezier(p: Path, cx: Double, cy: Double, a: Double, b: Double, startX: Double, startY: Double, theta: Double, start: Double, sweep: Double) {
                val numSegments = ceil(abs(sweep * 4 / Math.PI)).toInt()
                var eta1 = start
                var e1x = startX
                var e1y = startY
                val cosTheta = cos(theta)
                val sinTheta = sin(theta)
                val cosEta1 = cos(eta1)
                val sinEta1 = sin(eta1)
                var ep1x = -a * cosTheta * sinEta1 - b * sinTheta * cosEta1
                var ep1y = -a * sinTheta * sinEta1 + b * cosTheta * cosEta1
                val anglePerSegment = sweep / numSegments
                for (i in 0 until numSegments) {
                    val eta2 = eta1 + anglePerSegment
                    val sinEta2 = sin(eta2)
                    val cosEta2 = cos(eta2)
                    val e2x = cx + a * cosTheta * cosEta2 - b * sinTheta * sinEta2
                    val e2y = cy + a * sinTheta * cosEta2 + b * cosTheta * sinEta2
                    val ep2x = -a * cosTheta * sinEta2 - b * sinTheta * cosEta2
                    val ep2y = -a * sinTheta * sinEta2 + b * cosTheta * cosEta2
                    val tanDiff2 = tan((eta2 - eta1) / 2)
                    val alpha = sin(eta2 - eta1) * (sqrt(4 + 3 * tanDiff2 * tanDiff2) - 1) / 3
                    val q1x = e1x + alpha * ep1x
                    val q1y = e1y + alpha * ep1y
                    val q2x = e2x - alpha * ep2x
                    val q2y = e2y - alpha * ep2y
                    p.rLineTo(0f, 0f)
                    p.cubicTo(q1x.toFloat(), q1y.toFloat(), q2x.toFloat(), q2y.toFloat(), e2x.toFloat(), e2y.toFloat())
                    eta1 = eta2
                    e1x = e2x
                    e1y = e2y
                    ep1x = ep2x
                    ep1y = ep2y
                }
            }
        }
    }

    private class ExtractFloatResult {
        var mEndPosition = 0
        var mEndWithNegOrDot = false
    }

    /**
     * Parsing and scaling.
     */
    companion object {
        /**
         * Scales [originPaths] by [ratioWidth] × [ratioHeight]. [orginSvgs] is kept for compatibility: the Java version
         * re-parsed it below API 17, which minSdk 23 never runs (that code also scaled `q` commands twice, by a
         * missing `break`).
         */
        @JvmStatic
        fun transformScale(ratioWidth: Float, ratioHeight: Float, originPaths: List<Path>, orginSvgs: List<String>?): List<Path> {
            val matrix = Matrix()
            matrix.setScale(ratioWidth, ratioHeight)
            return originPaths.map { path -> Path().also { path.transform(matrix, it) } }
        }

        /**
         * The path of SVG [pathData], or null for null data.
         */
        @JvmStatic
        fun createPathFromPathData(pathData: String?): Path? {
            val nodes = createNodesFromPathData(pathData) ?: return null
            val path = Path()
            try {
                PathDataNode.nodesToPath(nodes, path)
            } catch (e: RuntimeException) {
                throw RuntimeException("Error in parsing $pathData", e)
            }
            return path
        }

        /**
         * The nodes of SVG [pathData], or null for null data.
         */
        @JvmStatic
        fun createNodesFromPathData(pathData: String?): Array<PathDataNode>? {
            if (pathData == null) return null
            var start = 0
            var end = 1
            val list = ArrayList<PathDataNode>()
            while (end < pathData.length) {
                end = nextStart(pathData, end)
                val s = pathData.substring(start, end).trim()
                if (s.isNotEmpty()) list.add(PathDataNode(s[0], getFloats(s)))
                start = end
                end++
            }
            if (end - start == 1 && start < pathData.length) list.add(PathDataNode(pathData[start], FloatArray(0)))
            return list.toTypedArray()
        }

        private fun nextStart(s: String, from: Int): Int {
            var end = from
            while (end < s.length) {
                val c = s[end]
                if (((c - 'A') * (c - 'Z') <= 0 || (c - 'a') * (c - 'z') <= 0) && c != 'e' && c != 'E') return end
                end++
            }
            return end
        }

        private fun getFloats(s: String): FloatArray {
            if (s[0] == 'z' || s[0] == 'Z') return FloatArray(0)
            try {
                val results = FloatArray(s.length)
                var count = 0
                var startPosition = 1
                val result = ExtractFloatResult()
                while (startPosition < s.length) {
                    extract(s, startPosition, result)
                    val endPosition = result.mEndPosition
                    if (startPosition < endPosition) results[count++] = s.substring(startPosition, endPosition).toFloat()
                    startPosition = if (result.mEndWithNegOrDot) endPosition else endPosition + 1
                }
                return results.copyOfRange(0, count)
            } catch (e: NumberFormatException) {
                throw RuntimeException("error in parsing \"$s\"", e)
            }
        }

        private fun extract(s: String, start: Int, result: ExtractFloatResult) {
            var currentIndex = start
            var foundSeparator = false
            result.mEndWithNegOrDot = false
            var secondDot = false
            var isExponential = false
            while (currentIndex < s.length) {
                val isPrevExponential = isExponential
                isExponential = false
                when (s[currentIndex]) {
                    ' ', ',' -> foundSeparator = true
                    '-' -> if (currentIndex != start && !isPrevExponential) {
                        foundSeparator = true
                        result.mEndWithNegOrDot = true
                    }
                    '.' -> if (!secondDot) {
                        secondDot = true
                    } else {
                        foundSeparator = true
                        result.mEndWithNegOrDot = true
                    }
                    'e', 'E' -> isExponential = true
                }
                if (foundSeparator) break
                currentIndex++
            }
            result.mEndPosition = currentIndex
        }
    }
}
