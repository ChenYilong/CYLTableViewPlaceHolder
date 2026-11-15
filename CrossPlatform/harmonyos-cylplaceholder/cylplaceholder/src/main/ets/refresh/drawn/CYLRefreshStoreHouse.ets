// CYLRefreshStoreHouse: the HarmonyOS counterpart of iOS Support/CYLRefreshStoreHouseLine.h and
// CYLRefreshStoreHousePath.h: the line segments of the StoreHouse header and the letter table that turns a string into
// them (letters, digits, blank and the dash). No ArkUI dependency (host unit-tested).
import { CYLPoint } from '../CYLRefreshComponent';
import { CYLRefreshAffineTransform } from './CYLRefreshDrawnSupport';

/** One segment (iOS `CYLRefreshStoreHouseLine`). */
export class CYLRefreshStoreHouseLine {
  /** The start point (`start`). */
  start: CYLPoint = new CYLPoint(0, 0);
  /** The end point (`end`). */
  end: CYLPoint = new CYLPoint(0, 0);
  /** The middle point, the center of its rotation (`middle`). */
  middle: CYLPoint = new CYLPoint(0, 0);
  /** The stroke alpha (`alpha`). */
  alpha: number = 0;
  /** The random horizontal offset it flies in from, -1..1 widths (`offset`). */
  offset: number = 0;
  /** Its index in the drawing (`index`). */
  index: number = 0;
  /** Its current transform (`transform`). */
  transform: CYLRefreshAffineTransform = CYLRefreshAffineTransform.identity();
}

/** The segments of each character as x1, y1, x2, y2 quadruples, in a 47 x 72 cell (A-Z, then 0-9). */
const CYLRefreshStoreHouseLetters: number[][] = [
  [24, 0, 1, 22, 1, 22, 1, 72, 24, 0, 47, 22, 47, 22, 47, 72, 1, 48, 47, 48],
  [0, 0, 0, 72, 0, 0, 37, 0, 37, 0, 47, 11, 47, 11, 47, 26, 47, 26, 38, 36, 38, 36, 0, 36, 38, 36, 47, 46, 47, 46, 47, 61, 47, 61, 38, 71, 37, 72, 0, 72],
  [47, 0, 0, 0, 0, 0, 0, 72, 0, 72, 47, 72],
  [0, 0, 0, 72, 0, 0, 24, 0, 24, 0, 47, 22, 47, 22, 47, 48, 47, 48, 23, 72, 23, 72, 0, 72],
  [0, 0, 0, 72, 0, 0, 47, 0, 0, 36, 37, 36, 0, 72, 47, 72],
  [0, 0, 0, 72, 0, 0, 47, 0, 0, 36, 37, 36],
  [47, 23, 47, 0, 47, 0, 0, 0, 0, 0, 0, 72, 0, 72, 47, 72, 47, 72, 47, 48, 47, 48, 24, 48],
  [0, 0, 0, 72, 0, 36, 47, 36, 47, 0, 47, 72],
  [0, 0, 47, 0, 24, 0, 24, 72, 0, 72, 47, 72],
  [47, 0, 47, 72, 47, 72, 24, 72, 24, 72, 0, 48],
  [0, 0, 0, 72, 47, 0, 3, 33, 3, 38, 47, 72],
  [0, 0, 0, 72, 0, 72, 47, 72],
  [0, 0, 0, 72, 0, 0, 24, 23, 24, 23, 47, 0, 47, 0, 47, 72],
  [0, 0, 0, 72, 0, 0, 47, 72, 47, 72, 47, 0],
  [0, 0, 0, 72, 0, 72, 47, 72, 47, 72, 47, 0, 47, 0, 0, 0],
  [0, 0, 0, 72, 0, 0, 47, 0, 47, 0, 47, 36, 47, 36, 0, 36],
  [0, 0, 0, 72, 0, 72, 23, 72, 23, 72, 47, 48, 47, 48, 47, 0, 47, 0, 0, 0, 24, 28, 47, 71],
  [0, 0, 0, 72, 0, 0, 47, 0, 47, 0, 47, 36, 47, 36, 0, 36, 0, 37, 47, 72],
  [47, 0, 0, 0, 0, 0, 0, 36, 0, 36, 47, 36, 47, 36, 47, 72, 47, 72, 0, 72],
  [0, 0, 47, 0, 24, 0, 24, 72],
  [0, 0, 0, 72, 0, 72, 47, 72, 47, 72, 47, 0],
  [0, 0, 24, 72, 24, 72, 47, 0],
  [0, 0, 0, 72, 0, 72, 24, 49, 24, 49, 47, 72, 47, 72, 47, 0],
  [0, 0, 47, 72, 47, 0, 0, 72],
  [0, 0, 24, 23, 47, 0, 24, 23, 24, 23, 24, 72],
  [0, 0, 47, 0, 47, 0, 0, 72, 0, 72, 47, 72]
];
const CYLRefreshStoreHouseNumbers: number[][] = [
  [0, 0, 0, 72, 0, 72, 47, 72, 47, 72, 47, 0, 47, 0, 0, 0],
  [24, 0, 24, 72],
  [0, 0, 47, 0, 47, 0, 47, 36, 47, 36, 0, 36, 0, 36, 0, 72, 0, 72, 47, 72],
  [0, 0, 47, 0, 47, 0, 47, 36, 47, 36, 0, 36, 47, 36, 47, 72, 47, 72, 0, 72],
  [0, 0, 0, 36, 0, 36, 47, 36, 47, 0, 47, 72],
  [0, 0, 0, 36, 0, 36, 47, 36, 47, 36, 47, 72, 47, 72, 0, 72, 0, 0, 47, 0],
  [0, 0, 0, 72, 0, 72, 47, 72, 47, 72, 47, 36, 47, 36, 0, 36],
  [0, 0, 47, 0, 47, 0, 47, 72],
  [0, 0, 0, 72, 0, 72, 47, 72, 47, 72, 47, 0, 47, 0, 0, 0, 0, 36, 47, 36],
  [47, 0, 0, 0, 0, 0, 0, 36, 0, 36, 47, 36, 47, 0, 47, 72]
];
// iOS registers the dash and then the dot under the same key ('-'): the dash draws the dot shape and '.' is not
// drawn. Kept as is. The dash shape: [0, 36, 47, 36].
const CYLRefreshStoreHouseDash: number[] = [24, 60, 24, 72];

/** A random offset in -1..0.99 (arc4random() % 200 - 100) / 100; tests replace it. */
let cylStoreHouseRandom: () => number = () => (Math.floor(Math.random() * 200) - 100) / 100;

/** Replaces the random segment offset (tests). */
export function cylRefreshStoreHouseSetRandom(random: () => number): void {
  cylStoreHouseRandom = random;
}

function cylStoreHouseLine(index: number, x1: number, y1: number, x2: number, y2: number): CYLRefreshStoreHouseLine {
  const item = new CYLRefreshStoreHouseLine();
  item.index = index;
  item.start = new CYLPoint(x1, y1);
  item.end = new CYLPoint(x2, y2);
  item.middle = new CYLPoint((x1 + x2) / 2, (y1 + y2) / 2);
  item.offset = cylStoreHouseRandom();
  return item;
}

/** CGPointFromString: '{x, y}'. */
function cylPointFromString(s: string): CYLPoint {
  const m = s.match(new RegExp('-?[\\d.]+(?:[eE][-+]?\\d+)?', 'g'));
  if (m === null || m.length < 2) {
    return new CYLPoint(0, 0);
  }
  return new CYLPoint(Number(m[0]), Number(m[1]));
}

/** The character table (iOS `CYLRefreshStoreHousePath`). */
export class CYLRefreshStoreHousePath {
  /** The segments of a character, or null when it is not drawn. */
  static cyl_segmentsOf(ch: string): number[] | null {
    const code = ch.charCodeAt(0);
    if (code >= 65 && code <= 90) {
      return CYLRefreshStoreHouseLetters[code - 65];
    }
    if (code >= 97 && code <= 122) {
      return CYLRefreshStoreHouseLetters[code - 97];
    }
    if (code >= 48 && code <= 57) {
      return CYLRefreshStoreHouseNumbers[code - 48];
    }
    if (ch === ' ') {
      return [];
    }
    if (ch === '-') {
      return CYLRefreshStoreHouseDash;
    }
    return null;
  }

  /** Segments from point strings like '{24, 0}', two per segment (`+linesFromArray:`). */
  static linesFromArray(array: string[]): CYLRefreshStoreHouseLine[] {
    const items: CYLRefreshStoreHouseLine[] = [];
    for (let i = 0; i * 2 + 1 < array.length; i++) {
      const s = cylPointFromString(array[i * 2]);
      const e = cylPointFromString(array[i * 2 + 1]);
      items.push(cylStoreHouseLine(items.length, s.x, s.y, e.x, e.y));
    }
    return items;
  }

  /** The segments of `str`, each character 57 + `space` wide, scaled by `scale` × 0.25 (`+linesFrom:scale:space:`). */
  static linesFrom(str: string, scale: number, space: number): CYLRefreshStoreHouseLine[] {
    const s = scale * 0.25;
    let offsetX = 0;
    const items: CYLRefreshStoreHouseLine[] = [];
    for (let i = 0; i < str.length; i++) {
      const points = CYLRefreshStoreHousePath.cyl_segmentsOf(str.charAt(i));
      if (points !== null) {
        for (let k = 0; k + 3 < points.length; k += 4) {
          items.push(cylStoreHouseLine(items.length, (offsetX + points[k]) * s, points[k + 1] * s,
            (offsetX + points[k + 2]) * s, points[k + 3] * s));
        }
      }
      offsetX += 57 + space;
    }
    return items;
  }

  /** The point strings of the 'AKTA' logo (`+arrayAkta`). */
  static arrayAkta(): string[] {
    return [
      '{22,0}', '{0,30}', '{22,0}', '{30,0}', '{30,0}', '{52,30}', '{0,30}', '{26,30}', '{60,0}', '{60,15}',
      '{60,15}', '{60,30}', '{60,15}', '{85,15}', '{85,15}', '{108,0}', '{85,15}', '{108,30}', '{117,0}', '{147,0}',
      '{147,0}', '{177,0}', '{147,0}', '{147,32}', '{198,0}', '{176,30}', '{198,0}', '{206,0}', '{206,0}', '{228,30}',
      '{176,30}', '{202,30}'
    ];
  }

  /** The point strings of the StoreHouse logo (`+arrayStoreHouse`). */
  static arrayStoreHouse(): string[] {
    return [
      '{0,35}', '{12,42}', '{12,42}', '{24,35}', '{24,35}', '{12,28}', '{0,35}', '{12,28}', '{0,21}', '{12,28}',
      '{12,28}', '{24,21}', '{24,35}', '{24,21}', '{24,21}', '{12,14}', '{0,21}', '{12,14}', '{0,21}', '{0,7}',
      '{12,14}', '{0,7}', '{12,14}', '{24,7}', '{24,7}', '{12,0}', '{0,7}', '{12,0}'
    ];
  }
}
