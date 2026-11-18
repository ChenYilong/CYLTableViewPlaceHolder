// CYLRefreshVectorPathsParser: the HarmonyOS counterpart of iOS Support/CYLRefreshVectorPathsParser.h (SVGKit's path
// parser as used by CYLRefresh styles). The iOS NSScanner and CGMutablePathRef are `CYLRefreshScanner` and
// `CYLRefreshMutablePath` (a list of absolute move / line / quad / cubic / close commands, with Core Graphics' current
// point and control-point bounding box); the read methods keep the iOS names, grammar and relative-origin rules.
// No ArkUI dependency (host unit-tested); `CYLRefreshMutablePath.addToContext` traces a path on a canvas.
import { CYLPoint } from '../CYLRefreshComponent';
import { CYLRefreshAffineTransform, CYLRefreshRect } from './CYLRefreshDrawnSupport';

/** The kind of the last segment read (iOS `CYLRefreshCurveType`). */
export enum CYLRefreshCurveType {
  CurveTypePoint = 0,
  CurveTypeCubic = 1,
  CurveTypeQuadratic = 2
}

/** The last segment read: its control points and end point (iOS struct `CYLRefreshCurve`). */
export class CYLRefreshCurve {
  type: CYLRefreshCurveType;
  c1: CYLPoint;
  c2: CYLPoint;
  p: CYLPoint;

  constructor(type: CYLRefreshCurveType, c1: CYLPoint, c2: CYLPoint, p: CYLPoint) {
    this.type = type;
    this.c1 = c1;
    this.c2 = c2;
    this.p = p;
  }

  /** CurveMakePoint. */
  static point(p: CYLPoint): CYLRefreshCurve {
    return new CYLRefreshCurve(CYLRefreshCurveType.CurveTypePoint, p, p, p);
  }

  /** CurveReflectedControlPoint. */
  reflectedControlPoint(): CYLPoint {
    return new CYLPoint(this.p.x + (this.p.x - this.c2.x), this.p.y + (this.p.y - this.c2.y));
  }
}

const CYLRefreshNumberPattern: RegExp = new RegExp('^[+-]?(\\d+\\.?\\d*|\\.\\d+)([eE][+-]?\\d+)?');

/** An NSScanner over a string: skips whitespace before each scan, like NSScanner's charactersToBeSkipped. */
export class CYLRefreshScanner {
  readonly string: string;
  scanLocation: number = 0;

  constructor(string: string) {
    this.string = string;
  }

  static scannerWithString(string: string): CYLRefreshScanner {
    return new CYLRefreshScanner(string);
  }

  private static isSpace(ch: string): boolean {
    return ch === ' ' || ch === '\t' || ch === '\r' || ch === '\n';
  }

  private skip(): void {
    while (this.scanLocation < this.string.length && CYLRefreshScanner.isSpace(this.string.charAt(this.scanLocation))) {
      this.scanLocation++;
    }
  }

  /** Whether only skippable characters are left (`isAtEnd`). */
  get isAtEnd(): boolean {
    let i = this.scanLocation;
    while (i < this.string.length && CYLRefreshScanner.isSpace(this.string.charAt(i))) {
      i++;
    }
    return i >= this.string.length;
  }

  /** The longest run of characters in `set`, or null (`scanCharactersFromSet:intoString:`). */
  scanCharactersFromSet(set: string): string | null {
    this.skip();
    const start = this.scanLocation;
    while (this.scanLocation < this.string.length && set.indexOf(this.string.charAt(this.scanLocation)) >= 0) {
      this.scanLocation++;
    }
    return this.scanLocation > start ? this.string.substring(start, this.scanLocation) : null;
  }

  /** The characters up to one in `set`, or null when none (`scanUpToCharactersFromSet:intoString:`). */
  scanUpToCharactersFromSet(set: string): string | null {
    this.skip();
    const start = this.scanLocation;
    while (this.scanLocation < this.string.length && set.indexOf(this.string.charAt(this.scanLocation)) < 0) {
      this.scanLocation++;
    }
    return this.scanLocation > start ? this.string.substring(start, this.scanLocation) : null;
  }

  /** Scans `s` when it comes next (`scanString:intoString:`). */
  scanString(s: string): boolean {
    this.skip();
    if (this.string.startsWith(s, this.scanLocation)) {
      this.scanLocation += s.length;
      return true;
    }
    return false;
  }

  /** A decimal number, or null (`scanFloat:` / `scanDouble:`). */
  scanFloat(): number | null {
    this.skip();
    const m = CYLRefreshNumberPattern.exec(this.string.substring(this.scanLocation));
    if (m === null) {
      return null;
    }
    this.scanLocation += m[0].length;
    return Number(m[0]);
  }
}

/** One command of a path: 'M' / 'L' (x, y), 'Q' (cx, cy, x, y), 'C' (c1x, c1y, c2x, c2y, x, y), 'Z'. */
export class CYLRefreshPathCommand {
  op: string;
  values: number[];

  constructor(op: string, values: number[]) {
    this.op = op;
    this.values = values;
  }
}

/** A CGMutablePathRef: absolute commands, the current point and the subpath start. */
export class CYLRefreshMutablePath {
  commands: CYLRefreshPathCommand[] = [];
  private current: CYLPoint = new CYLPoint(0, 0);
  private subpathStart: CYLPoint = new CYLPoint(0, 0);

  /** CGPathGetCurrentPoint. */
  get currentPoint(): CYLPoint {
    return this.current;
  }

  moveTo(x: number, y: number): void {
    this.commands.push(new CYLRefreshPathCommand('M', [x, y]));
    this.current = new CYLPoint(x, y);
    this.subpathStart = this.current;
  }

  lineTo(x: number, y: number): void {
    this.commands.push(new CYLRefreshPathCommand('L', [x, y]));
    this.current = new CYLPoint(x, y);
  }

  quadTo(cx: number, cy: number, x: number, y: number): void {
    this.commands.push(new CYLRefreshPathCommand('Q', [cx, cy, x, y]));
    this.current = new CYLPoint(x, y);
  }

  curveTo(c1x: number, c1y: number, c2x: number, c2y: number, x: number, y: number): void {
    this.commands.push(new CYLRefreshPathCommand('C', [c1x, c1y, c2x, c2y, x, y]));
    this.current = new CYLPoint(x, y);
  }

  /** CGPathCloseSubpath. */
  closeSubpath(): void {
    this.commands.push(new CYLRefreshPathCommand('Z', []));
    this.current = this.subpathStart;
  }

  /**
   * CGPathAddRelativeArc: an arc of the unit circle mapped by `m`, from `startAngle` sweeping `delta`, as cubic
   * segments (as Core Graphics stores it); joined to the current point by a line.
   */
  addRelativeArc(m: CYLRefreshAffineTransform, x: number, y: number, radius: number, startAngle: number,
    delta: number): void {
    const segments = Math.max(1, Math.ceil(Math.abs(delta) / (Math.PI / 2)));
    const step = delta / segments;
    const k = 4 / 3 * Math.tan(step / 4);
    const pt = (a: number): CYLPoint => m.apply(x + radius * Math.cos(a), y + radius * Math.sin(a));
    const start = pt(startAngle);
    if (this.commands.length === 0) {
      this.moveTo(start.x, start.y);
    } else {
      this.lineTo(start.x, start.y);
    }
    let a = startAngle;
    for (let i = 0; i < segments; i++) {
      const b = a + step;
      const c1 = m.apply(x + radius * (Math.cos(a) - k * Math.sin(a)), y + radius * (Math.sin(a) + k * Math.cos(a)));
      const c2 = m.apply(x + radius * (Math.cos(b) + k * Math.sin(b)), y + radius * (Math.sin(b) - k * Math.cos(b)));
      const end = pt(b);
      this.curveTo(c1.x, c1.y, c2.x, c2.y, end.x, end.y);
      a = b;
    }
  }

  /** CGPathGetBoundingBox: every point, control points included. */
  boundingBox(): CYLRefreshRect {
    let x0 = Infinity;
    let y0 = Infinity;
    let x1 = -Infinity;
    let y1 = -Infinity;
    this.commands.forEach((c: CYLRefreshPathCommand) => {
      for (let i = 0; i + 1 < c.values.length; i += 2) {
        x0 = Math.min(x0, c.values[i]);
        x1 = Math.max(x1, c.values[i]);
        y0 = Math.min(y0, c.values[i + 1]);
        y1 = Math.max(y1, c.values[i + 1]);
      }
    });
    if (x0 === Infinity) {
      return CYLRefreshRect.zero();
    }
    return new CYLRefreshRect(x0, y0, x1 - x0, y1 - y0);
  }

  /** Traces the path as the canvas' current path (beginPath included). */
  addToContext(ctx: CanvasRenderingContext2D): void {
    ctx.beginPath();
    this.commands.forEach((c: CYLRefreshPathCommand) => {
      const v = c.values;
      if (c.op === 'M') {
        ctx.moveTo(v[0], v[1]);
      } else if (c.op === 'L') {
        ctx.lineTo(v[0], v[1]);
      } else if (c.op === 'Q') {
        ctx.quadraticCurveTo(v[0], v[1], v[2], v[3]);
      } else if (c.op === 'C') {
        ctx.bezierCurveTo(v[0], v[1], v[2], v[3], v[4], v[5]);
      } else {
        ctx.closePath();
      }
    });
  }
}

/** The SVG path grammar of SVG 1.1, read command by command (iOS `CYLRefreshVectorPathsParser`). */
export class CYLRefreshVectorPathsParser {
  /** The curve before the first command (`+startingCurve`). */
  static startingCurve(): CYLRefreshCurve {
    return CYLRefreshCurve.point(new CYLPoint(0, 0));
  }

  private static readWhitespace(scanner: CYLRefreshScanner): void {
    scanner.scanCharactersFromSet(' \t\r\n');
  }

  private static readCommaAndWhitespace(scanner: CYLRefreshScanner): void {
    CYLRefreshVectorPathsParser.readWhitespace(scanner);
    scanner.scanString(',');
    CYLRefreshVectorPathsParser.readWhitespace(scanner);
  }

  /** A number; on garbage the scanner skips a character so a malformed path cannot loop for ever. */
  private static readCoordinate(scanner: CYLRefreshScanner): number {
    const v = scanner.scanFloat();
    if (v === null) {
      if (!scanner.isAtEnd) {
        scanner.scanLocation++;
      }
      return 0;
    }
    return v;
  }

  private static readCoordinatePair(scanner: CYLRefreshScanner): CYLPoint {
    const x = CYLRefreshVectorPathsParser.readCoordinate(scanner);
    CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    const y = CYLRefreshVectorPathsParser.readCoordinate(scanner);
    return new CYLPoint(x, y);
  }

  /** moveto-drawto-command-groups (`+readMovetoDrawToCmdGroups:path:relativeTo:isRelative:`). */
  static readMovetoDrawToCmdGroups(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath, origin: CYLPoint,
    isRelative: boolean): CYLRefreshCurve {
    let lastCurve = CYLRefreshVectorPathsParser.readMovetoDrawto(scanner, path, origin, isRelative);
    CYLRefreshVectorPathsParser.readWhitespace(scanner);
    while (!scanner.isAtEnd) {
      const before = scanner.scanLocation;
      CYLRefreshVectorPathsParser.readWhitespace(scanner);
      lastCurve = CYLRefreshVectorPathsParser.readMovetoDrawto(scanner, path, origin, isRelative);
      if (scanner.scanLocation === before) {
        break;
      }
    }
    return lastCurve;
  }

  /** moveto-drawto-command-group (`+readMovetoDrawto:path:relativeTo:isRelative:`). */
  static readMovetoDrawto(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath, origin: CYLPoint,
    isRelative: boolean): CYLRefreshCurve {
    const lastCurve = CYLRefreshVectorPathsParser.readMoveto(scanner, path, origin, isRelative);
    CYLRefreshVectorPathsParser.readWhitespace(scanner);
    return lastCurve;
  }

  /** moveto: ("M" | "m") moveto-argument-sequence (`+readMoveto:path:relativeTo:isRelative:`). */
  static readMoveto(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath, origin: CYLPoint,
    isRelative: boolean): CYLRefreshCurve {
    if (scanner.scanCharactersFromSet('Mm') === null) {
      return CYLRefreshCurve.point(origin);
    }
    CYLRefreshVectorPathsParser.readWhitespace(scanner);
    return CYLRefreshVectorPathsParser.readMovetoArgumentSequence(scanner, path, origin, isRelative);
  }

  /** A move, then implicit line-tos (`+readMovetoArgumentSequence:path:relativeTo:isRelative:`). */
  static readMovetoArgumentSequence(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath, origin: CYLPoint,
    isRelative: boolean): CYLRefreshCurve {
    const p = CYLRefreshVectorPathsParser.readCoordinatePair(scanner);
    const coord = new CYLPoint(p.x + origin.x, p.y + origin.y);
    path.moveTo(coord.x, coord.y);
    CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    if (scanner.isAtEnd) {
      return CYLRefreshCurve.point(coord);
    }
    return CYLRefreshVectorPathsParser.readLinetoArgumentSequence(scanner, path, isRelative ? coord : origin,
      isRelative);
  }

  /** lineto: ("L" | "l") lineto-argument-sequence (`+readLineToCmd:path:relativeTo:isRelative:`). */
  static readLineToCmd(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath, origin: CYLPoint,
    isRelative: boolean): CYLRefreshCurve {
    if (scanner.scanCharactersFromSet('Ll') === null) {
      return CYLRefreshCurve.point(origin);
    }
    CYLRefreshVectorPathsParser.readWhitespace(scanner);
    return CYLRefreshVectorPathsParser.readLinetoArgumentSequence(scanner, path, origin, isRelative);
  }

  /** Coordinate pairs, each a line (`+readLinetoArgumentSequence:path:relativeTo:isRelative:`). */
  static readLinetoArgumentSequence(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath, origin: CYLPoint,
    isRelative: boolean): CYLRefreshCurve {
    let p = CYLRefreshVectorPathsParser.readCoordinatePair(scanner);
    let coord = new CYLPoint(p.x + origin.x, p.y + origin.y);
    path.lineTo(coord.x, coord.y);
    CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    let o = origin;
    while (!scanner.isAtEnd) {
      o = isRelative ? coord : o;
      p = CYLRefreshVectorPathsParser.readCoordinatePair(scanner);
      coord = new CYLPoint(p.x + o.x, p.y + o.y);
      path.lineTo(coord.x, coord.y);
      CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    }
    return CYLRefreshCurve.point(coord);
  }

  /** vertical-lineto: ("V" | "v") (`+readVerticalLineToCmd:path:relativeTo:`). */
  static readVerticalLineToCmd(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath,
    origin: CYLPoint): CYLRefreshCurve {
    if (scanner.scanCharactersFromSet('Vv') === null) {
      return CYLRefreshCurve.point(origin);
    }
    CYLRefreshVectorPathsParser.readWhitespace(scanner);
    return CYLRefreshVectorPathsParser.readVerticalLinetoArgumentSequence(scanner, path, origin);
  }

  /** One y coordinate (`+readVerticalLinetoArgumentSequence:path:relativeTo:`). */
  static readVerticalLinetoArgumentSequence(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath,
    origin: CYLPoint): CYLRefreshCurve {
    const yValue = CYLRefreshVectorPathsParser.readCoordinate(scanner);
    const current = path.currentPoint;
    const coord = new CYLPoint(current.x, origin.y + yValue);
    path.lineTo(coord.x, coord.y);
    return CYLRefreshCurve.point(coord);
  }

  /** One x coordinate (`+readHorizontalLinetoArgumentSequence:path:relativeTo:`). */
  static readHorizontalLinetoArgumentSequence(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath,
    origin: CYLPoint): CYLRefreshCurve {
    const xValue = CYLRefreshVectorPathsParser.readCoordinate(scanner);
    const current = path.currentPoint;
    const coord = new CYLPoint(origin.x + xValue, current.y);
    path.lineTo(coord.x, coord.y);
    return CYLRefreshCurve.point(coord);
  }

  /** horizontal-lineto: ("H" | "h") (`+readHorizontalLineToCmd:path:relativeTo:`). */
  static readHorizontalLineToCmd(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath,
    origin: CYLPoint): CYLRefreshCurve {
    if (scanner.scanCharactersFromSet('Hh') === null) {
      return CYLRefreshCurve.point(origin);
    }
    CYLRefreshVectorPathsParser.readWhitespace(scanner);
    return CYLRefreshVectorPathsParser.readHorizontalLinetoArgumentSequence(scanner, path, origin);
  }

  /** quadratic-bezier-curveto: ("Q" | "q") (`+readQuadraticCurveToCmd:path:relativeTo:isRelative:`). */
  static readQuadraticCurveToCmd(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath, origin: CYLPoint,
    isRelative: boolean): CYLRefreshCurve {
    if (scanner.scanCharactersFromSet('Qq') === null) {
      return CYLRefreshCurve.point(origin);
    }
    CYLRefreshVectorPathsParser.readWhitespace(scanner);
    return CYLRefreshVectorPathsParser.readQuadraticCurvetoArgumentSequence(scanner, path, origin, isRelative);
  }

  /** `+readQuadraticCurvetoArgumentSequence:path:relativeTo:isRelative:`. */
  static readQuadraticCurvetoArgumentSequence(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath,
    origin: CYLPoint, isRelative: boolean): CYLRefreshCurve {
    let curve = CYLRefreshVectorPathsParser.readQuadraticCurvetoArgument(scanner, path, origin);
    while (!scanner.isAtEnd) {
      curve = CYLRefreshVectorPathsParser.readQuadraticCurvetoArgument(scanner, path, isRelative ? curve.p : origin);
    }
    return curve;
  }

  /** Control point and end point (`+readQuadraticCurvetoArgument:path:relativeTo:`). */
  static readQuadraticCurvetoArgument(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath,
    origin: CYLPoint): CYLRefreshCurve {
    const c = CYLRefreshVectorPathsParser.readCoordinatePair(scanner);
    const c1 = new CYLPoint(c.x + origin.x, c.y + origin.y);
    CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    const e = CYLRefreshVectorPathsParser.readCoordinatePair(scanner);
    const p = new CYLPoint(e.x + origin.x, e.y + origin.y);
    CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    path.quadTo(c1.x, c1.y, p.x, p.y);
    return new CYLRefreshCurve(CYLRefreshCurveType.CurveTypeQuadratic, c1, c1, p);
  }

  /** smooth-quadratic-bezier-curveto: ("T" | "t") (`+readSmoothQuadraticCurveToCmd:path:relativeTo:withPrevCurve:`). */
  static readSmoothQuadraticCurveToCmd(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath, origin: CYLPoint,
    prevCurve: CYLRefreshCurve): CYLRefreshCurve {
    if (scanner.scanCharactersFromSet('Tt') === null) {
      return prevCurve;
    }
    CYLRefreshVectorPathsParser.readWhitespace(scanner);
    return CYLRefreshVectorPathsParser.readSmoothQuadraticCurvetoArgumentSequence(scanner, path, origin, prevCurve);
  }

  /** `+readSmoothQuadraticCurvetoArgumentSequence:path:relativeTo:withPrevCurve:` (relative to each end, as iOS). */
  static readSmoothQuadraticCurvetoArgumentSequence(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath,
    origin: CYLPoint, prevCurve: CYLRefreshCurve): CYLRefreshCurve {
    let curve = CYLRefreshVectorPathsParser.readSmoothQuadraticCurvetoArgument(scanner, path, origin, prevCurve);
    while (!scanner.isAtEnd) {
      curve = CYLRefreshVectorPathsParser.readSmoothQuadraticCurvetoArgument(scanner, path, curve.p, curve);
    }
    return curve;
  }

  /** The reflected control point and an end point (`+readSmoothQuadraticCurvetoArgument:path:relativeTo:withPrevCurve:`). */
  static readSmoothQuadraticCurvetoArgument(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath,
    origin: CYLPoint, prevCurve: CYLRefreshCurve): CYLRefreshCurve {
    const c2 = prevCurve.type === CYLRefreshCurveType.CurveTypeQuadratic ? prevCurve.reflectedControlPoint() :
      prevCurve.p;
    const e = CYLRefreshVectorPathsParser.readCoordinatePair(scanner);
    const p = new CYLPoint(e.x + origin.x, e.y + origin.y);
    CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    path.quadTo(c2.x, c2.y, p.x, p.y);
    return new CYLRefreshCurve(CYLRefreshCurveType.CurveTypeQuadratic, c2, c2, p);
  }

  /** curveto: ("C" | "c") (`+readCurveToCmd:path:relativeTo:isRelative:`). */
  static readCurveToCmd(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath, origin: CYLPoint,
    isRelative: boolean): CYLRefreshCurve {
    if (scanner.scanCharactersFromSet('Cc') === null) {
      return CYLRefreshCurve.point(origin);
    }
    CYLRefreshVectorPathsParser.readWhitespace(scanner);
    return CYLRefreshVectorPathsParser.readCurvetoArgumentSequence(scanner, path, origin, isRelative);
  }

  /** `+readCurvetoArgumentSequence:path:relativeTo:isRelative:`. */
  static readCurvetoArgumentSequence(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath, origin: CYLPoint,
    isRelative: boolean): CYLRefreshCurve {
    let curve = CYLRefreshVectorPathsParser.readCurvetoArgument(scanner, path, origin);
    while (!scanner.isAtEnd) {
      curve = CYLRefreshVectorPathsParser.readCurvetoArgument(scanner, path, isRelative ? curve.p : origin);
    }
    return curve;
  }

  /** Two control points and an end point (`+readCurvetoArgument:path:relativeTo:`). */
  static readCurvetoArgument(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath,
    origin: CYLPoint): CYLRefreshCurve {
    const a = CYLRefreshVectorPathsParser.readCoordinatePair(scanner);
    const c1 = new CYLPoint(a.x + origin.x, a.y + origin.y);
    CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    const b = CYLRefreshVectorPathsParser.readCoordinatePair(scanner);
    const c2 = new CYLPoint(b.x + origin.x, b.y + origin.y);
    CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    const e = CYLRefreshVectorPathsParser.readCoordinatePair(scanner);
    const p = new CYLPoint(e.x + origin.x, e.y + origin.y);
    CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    path.curveTo(c1.x, c1.y, c2.x, c2.y, p.x, p.y);
    return new CYLRefreshCurve(CYLRefreshCurveType.CurveTypeCubic, c1, c2, p);
  }

  /** smooth-curveto: ("S" | "s") (`+readSmoothCurveToCmd:path:relativeTo:withPrevCurve:isRelative:`). */
  static readSmoothCurveToCmd(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath, origin: CYLPoint,
    prevCurve: CYLRefreshCurve, isRelative: boolean): CYLRefreshCurve {
    if (scanner.scanCharactersFromSet('Ss') === null) {
      return prevCurve;
    }
    CYLRefreshVectorPathsParser.readWhitespace(scanner);
    return CYLRefreshVectorPathsParser.readSmoothCurvetoArgumentSequence(scanner, path, origin, prevCurve,
      isRelative);
  }

  /** `+readSmoothCurvetoArgumentSequence:path:relativeTo:withPrevCurve:isRelative:`. */
  static readSmoothCurvetoArgumentSequence(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath,
    origin: CYLPoint, prevCurve: CYLRefreshCurve, isRelative: boolean): CYLRefreshCurve {
    let curve = CYLRefreshVectorPathsParser.readSmoothCurvetoArgument(scanner, path, origin, prevCurve);
    while (!scanner.isAtEnd) {
      curve = CYLRefreshVectorPathsParser.readSmoothCurvetoArgument(scanner, path, isRelative ? curve.p : origin,
        curve);
    }
    return curve;
  }

  /** The reflected first control point, a second one and an end point (`+readSmoothCurvetoArgument:path:relativeTo:withPrevCurve:`). */
  static readSmoothCurvetoArgument(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath, origin: CYLPoint,
    prevCurve: CYLRefreshCurve): CYLRefreshCurve {
    const c1 = prevCurve.type === CYLRefreshCurveType.CurveTypeCubic ? prevCurve.reflectedControlPoint() :
      prevCurve.p;
    CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    const b = CYLRefreshVectorPathsParser.readCoordinatePair(scanner);
    const c2 = new CYLPoint(b.x + origin.x, b.y + origin.y);
    CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    const e = CYLRefreshVectorPathsParser.readCoordinatePair(scanner);
    const p = new CYLPoint(e.x + origin.x, e.y + origin.y);
    CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    path.curveTo(c1.x, c1.y, c2.x, c2.y, p.x, p.y);
    return new CYLRefreshCurve(CYLRefreshCurveType.CurveTypeCubic, c1, c2, p);
  }

  /** elliptical-arc: ("A" | "a") (`+readEllipticalArcArguments:path:relativeTo:isRelative:`). */
  static readEllipticalArcArguments(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath, origin: CYLPoint,
    isRelative: boolean): CYLRefreshCurve {
    if (scanner.scanCharactersFromSet('Aa') === null) {
      return CYLRefreshCurve.point(origin);
    }
    let endPoint = CYLRefreshVectorPathsParser.readEllipticalArcArgumentsSequence(scanner, path, origin);
    while (!scanner.isAtEnd) {
      endPoint = CYLRefreshVectorPathsParser.readEllipticalArcArgumentsSequence(scanner, path,
        isRelative ? endPoint : origin);
    }
    return CYLRefreshCurve.point(endPoint);
  }

  /** One arc: radii, rotation, flags and end point, as an arc of the unit circle mapped onto the ellipse. */
  private static readEllipticalArcArgumentsSequence(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath,
    origin: CYLPoint): CYLPoint {
    CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    const currentPt = path.currentPoint;
    const x1 = currentPt.x;
    const y1 = currentPt.y;
    const radii = CYLRefreshVectorPathsParser.readCoordinatePair(scanner);
    let rx = Math.abs(radii.x);
    let ry = Math.abs(radii.y);
    CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    let phi = CYLRefreshVectorPathsParser.readCoordinate(scanner);
    phi *= Math.PI / 180;
    phi = phi % (2 * Math.PI);
    CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    const flags = CYLRefreshVectorPathsParser.readCoordinatePair(scanner);
    const largeArcFlag = flags.x !== 0;
    const sweepFlag = flags.y !== 0;
    CYLRefreshVectorPathsParser.readCommaAndWhitespace(scanner);
    const end = CYLRefreshVectorPathsParser.readCoordinatePair(scanner);
    const x2 = origin.x + end.x;
    const y2 = origin.y + end.y;
    if (rx === 0 || ry === 0) {
      path.lineTo(x2, y2);
      return new CYLPoint(x2, y2);
    }
    const cosPhi = Math.cos(phi);
    const sinPhi = Math.sin(phi);
    const x1p = cosPhi * (x1 - x2) / 2 + sinPhi * (y1 - y2) / 2;
    const y1p = -sinPhi * (x1 - x2) / 2 + cosPhi * (y1 - y2) / 2;
    let rx2 = rx * rx;
    let ry2 = ry * ry;
    const xp2 = x1p * x1p;
    const yp2 = y1p * y1p;
    const delta = xp2 / rx2 + yp2 / ry2;
    if (delta > 1.0) {
      rx *= Math.sqrt(delta);
      ry *= Math.sqrt(delta);
      rx2 = rx * rx;
      ry2 = ry * ry;
    }
    const sign = largeArcFlag === sweepFlag ? -1 : 1;
    const numerator = Math.max(0, rx2 * ry2 - rx2 * yp2 - ry2 * xp2);
    const denom = rx2 * yp2 + ry2 * xp2;
    const lhs = denom === 0 ? 0 : sign * Math.sqrt(numerator / denom);
    const cxp = lhs * (rx * y1p) / ry;
    const cyp = lhs * -((ry * x1p) / rx);
    const cx = cosPhi * cxp + -sinPhi * cyp + (x1 + x2) / 2;
    const cy = cxp * sinPhi + cyp * cosPhi + (y1 + y2) / 2;
    const tr = CYLRefreshAffineTransform.makeScale(1 / rx, 1 / ry).rotate(-phi).translate(-cx, -cy);
    const arcPt1 = tr.apply(x1, y1);
    const arcPt2 = tr.apply(x2, y2);
    const startAngle = Math.atan2(arcPt1.y, arcPt1.x);
    const endAngle = Math.atan2(arcPt2.y, arcPt2.x);
    let angleDelta = endAngle - startAngle;
    if (sweepFlag) {
      if (angleDelta < 0) {
        angleDelta += 2 * Math.PI;
      }
    } else if (angleDelta > 0) {
      angleDelta = angleDelta - 2 * Math.PI;
    }
    const trInv = CYLRefreshAffineTransform.makeTranslation(cx, cy).rotate(phi).scale(rx, ry);
    path.addRelativeArc(trInv, 0, 0, 1, startAngle, angleDelta);
    return new CYLPoint(x2, y2);
  }

  /** closepath: ("Z" | "z") (`+readCloseCommand:path:relativeTo:`). */
  static readCloseCommand(scanner: CYLRefreshScanner, path: CYLRefreshMutablePath, origin: CYLPoint): CYLRefreshCurve {
    if (scanner.scanCharactersFromSet('Zz') === null) {
      return CYLRefreshCurve.point(origin);
    }
    path.closeSubpath();
    return CYLRefreshCurve.point(path.currentPoint);
  }
}
