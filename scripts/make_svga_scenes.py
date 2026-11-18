#!/usr/bin/env python3
"""Writes the SVGA twins of the SmartRefresh Rive scenes (Task-Log "SVGA animations, every Rive demo copied 1:1").

    py -3 scripts/make_svga_scenes.py <output folder>

The Rive scenes (CYLScenarioExampleRefresh{Bow,Bubbles,Halloween,Skating,Space,Squats}.riv) come from
flutter_easy_refresh; no SVGA artwork of them exists, so this script draws original vector scenes of the same subjects
and writes them as SVGA 2.x files (a zlib-deflated protobuf MovieEntity, svga.proto of SVGAPlayer): shapes only, no
images, so every SVGA player draws them (SVGAPlayer-Android, SVGAPlayerLite on iOS, CYLTabBarController's HarmonyOS and
mini program players). Each scene is 375 x 150, 30 fps, 60 frames, and loops seamlessly: a refresh header scrubs it
with the pull (CYLRefreshIconView updateForPullingPercent) and loops it while refreshing. The files are this
repository's own work (MIT, as the repository).
"""
import math
import os
import struct
import sys
import zlib

W, H, FPS, FRAMES = 375.0, 150.0, 30, 60


# ---- protobuf encoding (only what svga.proto needs) ------------------------------------------------------------

def _varint(value):
    out = bytearray()
    while True:
        byte = value & 0x7F
        value >>= 7
        if value:
            out.append(byte | 0x80)
        else:
            out.append(byte)
            return bytes(out)


def _key(field, wire):
    return _varint((field << 3) | wire)


def f32(field, value):
    return _key(field, 5) + struct.pack('<f', float(value))


def u32(field, value):
    return _key(field, 0) + _varint(int(value))


def blob(field, data):
    if isinstance(data, str):
        data = data.encode('utf-8')
    return _key(field, 2) + _varint(len(data)) + data


def color(rgba):
    r, g, b, a = rgba
    return f32(1, r / 255.0) + f32(2, g / 255.0) + f32(3, b / 255.0) + f32(4, a)


def style(fill=None, stroke=None, width=0.0, cap=1, join=1):
    """ShapeStyle: fill, stroke, strokeWidth, lineCap (0 butt, 1 round, 2 square), lineJoin (0 miter, 1 round)."""
    out = b''
    if fill is not None:
        out += blob(1, color(fill))
    if stroke is not None:
        out += blob(2, color(stroke)) + f32(3, width) + u32(4, cap) + u32(5, join) + f32(6, 4)
    return out


def path(d, **kw):
    """ShapeEntity of type SHAPE (0) with an SVG path."""
    return u32(1, 0) + blob(2, blob(1, d)) + blob(10, style(**kw))


def ellipse(x, y, rx, ry, **kw):
    return u32(1, 2) + blob(4, f32(1, x) + f32(2, y) + f32(3, rx) + f32(4, ry)) + blob(10, style(**kw))


def rect(x, y, w, h, r=0.0, **kw):
    return u32(1, 1) + blob(3, f32(1, x) + f32(2, y) + f32(3, w) + f32(4, h) + f32(5, r)) + blob(10, style(**kw))


IDENTITY = f32(1, 1) + f32(2, 0) + f32(3, 0) + f32(4, 1) + f32(5, 0) + f32(6, 0)
LAYOUT = f32(1, 0) + f32(2, 0) + f32(3, W) + f32(4, H)


def frame(shapes, alpha=1.0):
    """FrameEntity: alpha, layout (the whole view box), identity transform, shapes."""
    out = f32(1, alpha) + blob(2, LAYOUT) + blob(3, IDENTITY)
    for shape in shapes:
        out += blob(5, shape)
    return out


def movie(sprites):
    """MovieEntity: version, params, one sprite per layer (each a list of FRAMES shape lists)."""
    params = f32(1, W) + f32(2, H) + u32(3, FPS) + u32(4, FRAMES)
    out = blob(1, '2.0.0') + blob(2, params)
    for index, frames in enumerate(sprites):
        sprite = blob(1, 'layer%d' % index)
        for shapes in frames:
            sprite += blob(2, frame(shapes))
        out += blob(4, sprite)
    return zlib.compress(out, 9)


def layer(draw):
    """One sprite: draw(t) gives its shapes at t in [0, 1)."""
    return [draw(i / FRAMES) for i in range(FRAMES)]


def n(v):
    return ('%.2f' % v).rstrip('0').rstrip('.')


def poly(points, close=True):
    d = 'M%s %s' % (n(points[0][0]), n(points[0][1]))
    for x, y in points[1:]:
        d += ' L%s %s' % (n(x), n(y))
    return d + (' Z' if close else '')


def ease(x):
    return 0.5 - 0.5 * math.cos(math.pi * max(0.0, min(1.0, x)))


# ---- the scenes ------------------------------------------------------------------------------------------------

INK = (51, 51, 51, 1.0)
SKY = (48, 176, 199, 1.0)


def bow():
    """An archer's bow: the string draws back, the arrow flies to the target and hits it."""
    bx, cy = 70.0, 75.0

    def draw_bow(t):
        pull = ease(t / 0.4) if t < 0.4 else (1 - ease((t - 0.4) / 0.08)) if t < 0.48 else 0.0
        sx = bx - 6 - 34 * pull
        bow_d = 'M%s %s C%s %s %s %s %s %s' % (n(bx), n(cy - 55), n(bx + 40), n(cy - 30), n(bx + 40), n(cy + 30), n(bx), n(cy + 55))
        return [path(bow_d, stroke=(139, 90, 43, 1.0), width=6),
                path(poly([(bx, cy - 55), (sx, cy), (bx, cy + 55)], close=False), stroke=INK, width=1.5)]

    def draw_target(t):
        hit = t >= 0.8
        shake = math.sin(t * 120) * 2 if 0.8 <= t < 0.9 else 0.0
        x = 320 + shake
        rings = [ellipse(x, cy, 12, 40, fill=(229, 57, 53, 1.0)), ellipse(x, cy, 8, 27, fill=(255, 255, 255, 1.0)),
                 ellipse(x, cy, 4, 13, fill=(229, 57, 53, 1.0))]
        if hit:
            rings.append(ellipse(x, cy, 18, 50, stroke=(255, 193, 7, 1.0 - (t - 0.8) * 5), width=2))
        return rings

    def draw_arrow(t):
        pull = ease(t / 0.4) if t < 0.4 else 0.0
        if t < 0.4:
            tail = bx - 6 - 34 * pull
        elif t < 0.8:
            tail = bx - 40 + (320 - 12 - 60 - (bx - 40)) * ease((t - 0.4) / 0.4)
        else:
            tail = 320 - 12 - 60
        if t >= 0.92:
            return []
        head = tail + 70
        return [path(poly([(tail, cy), (head, cy)], close=False), stroke=INK, width=3),
                path(poly([(head + 10, cy), (head - 2, cy - 7), (head - 2, cy + 7)]), fill=INK),
                path(poly([(tail, cy), (tail - 8, cy - 7), (tail + 4, cy - 7), (tail + 10, cy)]), fill=SKY)]

    return [layer(draw_target), layer(draw_bow), layer(draw_arrow)]


def bubbles():
    """Seven bubbles rise and wobble, each one with its own phase."""
    def bubble(k):
        x0 = 40 + k * 49
        phase = k / 7.0
        radius = 9 + (k * 5) % 11

        def draw(t):
            p = (t + phase) % 1.0
            y = H + radius - p * (H + 2 * radius)
            x = x0 + 10 * math.sin(2 * math.pi * (p * 2 + phase))
            a = min(1.0, (1 - p) * 4)
            return [ellipse(x, y, radius, radius, fill=(48, 176, 199, 0.18 * a), stroke=(48, 176, 199, a), width=2),
                    ellipse(x - radius * 0.35, y - radius * 0.35, radius * 0.25, radius * 0.25, fill=(255, 255, 255, 0.9 * a))]
        return draw
    return [layer(bubble(k)) for k in range(7)]


def halloween():
    """A jack-o'-lantern bobs and glows while two bats flap around it."""
    cx, cy = W / 2, 82.0

    def draw_pumpkin(t):
        bob = 5 * math.sin(2 * math.pi * t)
        y = cy + bob
        glow = 0.6 + 0.4 * math.sin(4 * math.pi * t)
        orange = (245, 124, 0, 1.0)
        shapes = [ellipse(cx - 22, y, 26, 34, fill=orange), ellipse(cx + 22, y, 26, 34, fill=orange),
                  ellipse(cx, y, 30, 36, fill=(251, 140, 0, 1.0)),
                  path('M%s %s C%s %s %s %s %s %s' % (n(cx), n(y - 34), n(cx - 2), n(y - 46), n(cx + 6), n(y - 50), n(cx + 12), n(y - 50)),
                       stroke=(85, 139, 47, 1.0), width=5)]
        lit = (255, 235, 59, glow)
        shapes += [path(poly([(cx - 22, y - 6), (cx - 10, y - 6), (cx - 16, y - 18)]), fill=lit),
                   path(poly([(cx + 22, y - 6), (cx + 10, y - 6), (cx + 16, y - 18)]), fill=lit),
                   path(poly([(cx - 24, y + 8), (cx - 12, y + 14), (cx - 4, y + 8), (cx + 4, y + 14), (cx + 12, y + 8),
                              (cx + 24, y + 8), (cx + 14, y + 22), (cx - 14, y + 22)]), fill=lit)]
        return shapes

    def bat(offset, radius):
        def draw(t):
            a = 2 * math.pi * (t + offset)
            x = cx + radius * math.cos(a)
            y = 60 + 0.4 * radius * math.sin(a)
            flap = 10 * math.sin(2 * math.pi * t * 6)
            wing = [(x - 22, y - flap), (x - 12, y + 2), (x - 6, y - 2), (x, y + 4), (x + 6, y - 2), (x + 12, y + 2), (x + 22, y - flap),
                    (x + 8, y + 8), (x, y + 6), (x - 8, y + 8)]
            return [path(poly(wing), fill=(66, 66, 66, 1.0)), ellipse(x, y + 3, 4, 4, fill=(66, 66, 66, 1.0))]
        return draw

    return [layer(draw_pumpkin), layer(bat(0.0, 130)), layer(bat(0.5, 120))]


def skating():
    """A skateboard rolls across the ground; its wheels turn and it hops once per pass."""
    ground = 120.0

    def draw_ground(t):
        shapes = [path(poly([(0, ground + 12), (W, ground + 12)], close=False), stroke=(158, 158, 158, 1.0), width=2)]
        for k in range(6):
            x = (k * 75 - t * 150) % (W + 75) - 40
            shapes.append(path(poly([(x, ground + 20), (x + 24, ground + 20)], close=False), stroke=(189, 189, 189, 1.0), width=2))
        return shapes

    def draw_board(t):
        x = -60 + (W + 120) * t
        hop = 30 * math.sin(math.pi * min(1.0, max(0.0, (t - 0.4) / 0.2))) if 0.4 <= t <= 0.6 else 0.0
        tilt = 8 * math.sin(math.pi * (t - 0.4) / 0.2) if 0.4 <= t <= 0.6 else 0.0
        y = ground - hop
        deck = path('M%s %s L%s %s Q%s %s %s %s L%s %s Q%s %s %s %s Z' % (
            n(x - 40), n(y - 4 + tilt), n(x + 40), n(y - 4 - tilt), n(x + 50), n(y - 4 - tilt), n(x + 50), n(y - 12 - tilt),
            n(x + 46), n(y - 12 - tilt), n(x - 50), n(y - 12 + tilt), n(x - 46), n(y - 12 + tilt)), fill=SKY)
        shapes = [deck]
        angle = t * 2 * math.pi * 6
        for wx in (x - 28, x + 28):
            wy = y + 4
            shapes.append(ellipse(wx, wy, 7, 7, fill=INK))
            shapes.append(path(poly([(wx + 5 * math.cos(angle), wy + 5 * math.sin(angle)),
                                     (wx - 5 * math.cos(angle), wy - 5 * math.sin(angle))], close=False),
                               stroke=(255, 255, 255, 1.0), width=1.5))
        return shapes

    return [layer(draw_ground), layer(draw_board)]


def space():
    """A rocket hovers with a flickering flame while stars stream past."""
    cx, cy = W / 2, 70.0

    def star(k):
        y = 12 + (k * 37) % 126
        speed = 1 + (k % 3)
        phase = (k * 0.137) % 1.0

        def draw(t):
            x = W - ((t * speed + phase) % 1.0) * (W + 40) + 20
            length = 6 + 6 * speed
            return [path(poly([(x, y), (x + length, y)], close=False), stroke=(144, 164, 174, 0.5 + 0.15 * speed), width=2)]
        return draw

    def draw_rocket(t):
        y = cy + 6 * math.sin(2 * math.pi * t)
        flicker = 1 + 0.3 * math.sin(2 * math.pi * t * 8)
        body = 'M%s %s C%s %s %s %s %s %s L%s %s L%s %s C%s %s %s %s %s %s Z' % (
            n(cx + 50), n(y), n(cx + 30), n(y - 18), n(cx + 10), n(y - 18), n(cx - 20), n(y - 16),
            n(cx - 30), n(y - 12), n(cx - 30), n(y + 12), n(cx - 20), n(y + 16), n(cx + 10), n(y + 18), n(cx + 30), n(y + 18))
        return [path(poly([(cx - 30 - 30 * flicker, y), (cx - 30, y - 9), (cx - 30, y + 9)]), fill=(255, 152, 0, 0.9)),
                path(poly([(cx - 30 - 16 * flicker, y), (cx - 30, y - 5), (cx - 30, y + 5)]), fill=(255, 235, 59, 1.0)),
                path(poly([(cx - 22, y - 15), (cx - 36, y - 30), (cx - 8, y - 17)]), fill=(229, 57, 53, 1.0)),
                path(poly([(cx - 22, y + 15), (cx - 36, y + 30), (cx - 8, y + 17)]), fill=(229, 57, 53, 1.0)),
                path(body, fill=(236, 239, 241, 1.0), stroke=(96, 125, 139, 1.0), width=2),
                ellipse(cx + 14, y, 8, 8, fill=SKY, stroke=(96, 125, 139, 1.0), width=2)]

    return [layer(star(k)) for k in range(14)] + [layer(draw_rocket)]


def squats():
    """A figure does two squats per loop, arms forward as it goes down."""
    cx, floor = W / 2, 140.0
    thigh, shin, torso = 30.0, 30.0, 36.0

    def draw(t):
        depth = ease((math.sin(4 * math.pi * t - math.pi / 2) + 1) / 2)
        knee_angle = math.radians(10 + 80 * depth)
        ankle = (cx, floor)
        knee = (cx + shin * math.sin(knee_angle * 0.6), floor - shin * math.cos(knee_angle * 0.6))
        hip = (knee[0] - thigh * math.sin(knee_angle * 1.1), knee[1] - thigh * math.cos(knee_angle * 1.1))
        lean = math.radians(5 + 30 * depth)
        neck = (hip[0] + torso * math.sin(lean), hip[1] - torso * math.cos(lean))
        arm_angle = math.radians(80 * depth)
        hand = (neck[0] + 30 * math.sin(arm_angle), neck[1] + 30 * math.cos(arm_angle))
        limb = dict(stroke=INK, width=7)
        return [path(poly([(cx - 60, floor + 3), (cx + 60, floor + 3)], close=False), stroke=(189, 189, 189, 1.0), width=3),
                path(poly([ankle, knee, hip], close=False), **limb),
                path(poly([(ankle[0] - 2, floor), (ankle[0] + 14, floor)], close=False), **limb),
                path(poly([hip, neck], close=False), stroke=SKY, width=10),
                path(poly([neck, hand], close=False), **limb),
                ellipse(neck[0] + 4 * math.sin(lean), neck[1] - 13, 10, 10, fill=INK)]

    return [layer(draw)]


SCENES = {
    'Bow': bow,
    'Bubbles': bubbles,
    'Halloween': halloween,
    'Skating': skating,
    'Space': space,
    'Squats': squats,
}


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else '.'
    os.makedirs(out, exist_ok=True)
    for name, scene in SCENES.items():
        data = movie(scene())
        target = os.path.join(out, 'CYLScenarioExampleRefresh%s.svga' % name)
        with open(target, 'wb') as handle:
            handle.write(data)
        print('wrote', target, len(data), 'bytes')


if __name__ == '__main__':
    main()
