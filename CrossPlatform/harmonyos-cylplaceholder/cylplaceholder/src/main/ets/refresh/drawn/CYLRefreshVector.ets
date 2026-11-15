// CYLRefreshVector: the HarmonyOS counterpart of iOS Support/CYLRefreshVectorElement.h, CYLRefreshVectorPathElement.h,
// CYLRefreshVectorUtilities.h, CYLRefreshVectorImage.h and the model half of CYLRefreshVectorView.h (SmartRefreshControl's
// vector drawables). A CALayer is a `CYLRefreshVectorLayer` (the path with its fill, stroke and opacity) rendered on
// an ArkUI canvas; parsing, bounding boxes and sizing have no ArkUI dependency (host unit-tested).
import { CYLPoint, CYLSize } from '../CYLRefreshComponent';
import { CYLRefreshRect } from './CYLRefreshDrawnSupport';
import {
  CYLRefreshCurve,
  CYLRefreshMutablePath,
  CYLRefreshScanner,
  CYLRefreshVectorPathsParser
} from './CYLRefreshVectorPathsParser';

/** A rendered shape (the CAShapeLayer of iOS `CYLRefreshVectorUtilities`): a path, fill, stroke and opacity. */
export class CYLRefreshVectorLayer {
  name: string = '';
  path: CYLRefreshMutablePath;
  frame: CYLRefreshRect;
  fillColor: string | null = null;
  strokeColor: string | null = null;
  lineWidth: number = 0;
  opacity: number = 1;

  constructor(path: CYLRefreshMutablePath, frame: CYLRefreshRect) {
    this.path = path;
    this.frame = frame;
  }

  /** CALayer renderInContext: fills, then strokes, at the layer's opacity. */
  renderInContext(ctx: CanvasRenderingContext2D): void {
    const alpha = ctx.globalAlpha;
    ctx.globalAlpha = alpha * this.opacity;
    this.path.addToContext(ctx);
    if (this.fillColor !== null) {
      ctx.fillStyle = this.fillColor;
      ctx.fill();
    }
    if (this.strokeColor !== null && this.lineWidth > 0) {
      ctx.strokeStyle = this.strokeColor;
      ctx.lineWidth = this.lineWidth;
      ctx.stroke();
    }
    ctx.globalAlpha = alpha;
  }
}

/** One element of a vector image (iOS `CYLRefreshVectorElement`); setters mark it `changed`. */
export class CYLRefreshVectorElement {
  /** The element's name (`identifier`). */
  identifier: string = '';
  /** The viewport: the bounding box of the shape (`viewport`). */
  viewport: CYLRefreshRect = CYLRefreshRect.zero();
  /** Whether the layer must be rebuilt (`changed`). */
  changed: boolean = false;
  private strokeValue: string | null = null;
  private fillValue: string | null = '#ffffff';
  private opacityValue: number = 1;
  private strokeWidthValue: number = 0;
  private strokeOpacityValue: number = 1;
  private layerValue: CYLRefreshVectorLayer | null = null;

  /** The stroke color, or null (`stroke`). */
  get stroke(): string | null {
    return this.strokeValue;
  }

  set stroke(value: string | null) {
    this.strokeValue = value;
    this.changed = true;
  }

  /** The fill color (`fill`, white by default). */
  get fill(): string | null {
    return this.fillValue;
  }

  set fill(value: string | null) {
    this.fillValue = value;
    this.changed = true;
  }

  /** The opacity (`opacity`). */
  get opacity(): number {
    return this.opacityValue;
  }

  set opacity(value: number) {
    this.opacityValue = value;
    this.changed = true;
  }

  /** The stroke width (`strokeWidth`). */
  get strokeWidth(): number {
    return this.strokeWidthValue;
  }

  set strokeWidth(value: number) {
    this.strokeWidthValue = value;
    this.changed = true;
  }

  /** The stroke opacity, kept from iOS (`strokeOpacity`). */
  get strokeOpacity(): number {
    return this.strokeOpacityValue;
  }

  set strokeOpacity(value: number) {
    this.strokeOpacityValue = value;
  }

  /** The layer, rebuilt with `newLayer` when changed (`layer`). */
  get layer(): CYLRefreshVectorLayer | null {
    if (this.changed) {
      this.layerValue = this.newLayer();
      this.changed = false;
    }
    return this.layerValue;
  }

  set layer(value: CYLRefreshVectorLayer | null) {
    this.layerValue = value;
    this.changed = false;
  }

  /** A new layer for the element; null in the base class (`-newLayer`). */
  newLayer(): CYLRefreshVectorLayer | null {
    return null;
  }
}

/** Builds the shape layers (iOS `CYLRefreshVectorUtilities`). */
export class CYLRefreshVectorUtilities {
  /** A layer drawing `path` with the element's colors (`+newLayerForElement:withPath:`). */
  static newLayerForElement(element: CYLRefreshVectorElement, path: CYLRefreshMutablePath): CYLRefreshVectorLayer {
    const strokeWidth = element.strokeWidth;
    const box = path.boundingBox();
    const frame = new CYLRefreshRect(box.x - strokeWidth / 2, box.y - strokeWidth / 2, box.width + strokeWidth,
      box.height + strokeWidth);
    const layer = new CYLRefreshVectorLayer(path, frame);
    layer.name = element.identifier;
    if (strokeWidth > 0 && element.stroke !== null) {
      layer.lineWidth = Math.hypot(strokeWidth, strokeWidth) / Math.SQRT2;
      layer.strokeColor = element.stroke;
    }
    layer.fillColor = element.fill;
    layer.opacity = element.opacity;
    return layer;
  }
}

const CYLRefreshKnownCommands: string = 'MmLlCcVvHhAaSsQqTtZz';

/** An element drawing SVG path data (iOS `CYLRefreshVectorPathElement`). */
export class CYLRefreshVectorPathElement extends CYLRefreshVectorElement {
  private shape: CYLRefreshMutablePath = new CYLRefreshMutablePath();

  /** An element parsed from SVG path data (`+newWith:`). */
  static newWith(data: string): CYLRefreshVectorPathElement {
    const element = new CYLRefreshVectorPathElement();
    element.parseData(data);
    return element;
  }

  /** The parsed path (`pathForShape`). */
  get pathForShape(): CYLRefreshMutablePath {
    return this.shape;
  }

  private parseData(data: string): void {
    const path = new CYLRefreshMutablePath();
    const dataScanner = CYLRefreshScanner.scannerWithString(data);
    let lastCurve: CYLRefreshCurve = CYLRefreshVectorPathsParser.startingCurve();
    const zero = new CYLPoint(0, 0);
    let foundCmd = false;
    do {
      let command = dataScanner.scanCharactersFromSet(CYLRefreshKnownCommands);
      foundCmd = command !== null;
      if (command !== null && command.length > 1) {
        dataScanner.scanLocation -= command.length - 1;
        command = command.substring(0, 1);
      }
      if (command === null) {
        break;
      }
      if (command === 'z' || command === 'Z') {
        lastCurve = CYLRefreshVectorPathsParser.readCloseCommand(CYLRefreshScanner.scannerWithString(command), path,
          lastCurve.p);
        continue;
      }
      const cmdArgs = dataScanner.scanUpToCharactersFromSet(CYLRefreshKnownCommands);
      if (cmdArgs === null) {
        continue;
      }
      const s = CYLRefreshScanner.scannerWithString(command + cmdArgs);
      const rel = command === command.toLowerCase();
      const origin = rel ? lastCurve.p : zero;
      switch (command.toUpperCase()) {
        case 'M':
          lastCurve = CYLRefreshVectorPathsParser.readMovetoDrawToCmdGroups(s, path, origin, rel);
          break;
        case 'L':
          lastCurve = CYLRefreshVectorPathsParser.readLineToCmd(s, path, origin, rel);
          break;
        case 'V':
          lastCurve = CYLRefreshVectorPathsParser.readVerticalLineToCmd(s, path, origin);
          break;
        case 'H':
          lastCurve = CYLRefreshVectorPathsParser.readHorizontalLineToCmd(s, path, origin);
          break;
        case 'C':
          lastCurve = CYLRefreshVectorPathsParser.readCurveToCmd(s, path, origin, rel);
          break;
        case 'S':
          lastCurve = CYLRefreshVectorPathsParser.readSmoothCurveToCmd(s, path, origin, lastCurve, rel);
          break;
        case 'Q':
          lastCurve = CYLRefreshVectorPathsParser.readQuadraticCurveToCmd(s, path, origin, rel);
          break;
        case 'T':
          lastCurve = CYLRefreshVectorPathsParser.readSmoothQuadraticCurveToCmd(s, path, origin, lastCurve);
          break;
        case 'A':
          lastCurve = CYLRefreshVectorPathsParser.readEllipticalArcArguments(s, path, origin, rel);
          break;
        default:
          break;
      }
    } while (foundCmd);
    this.shape = path;
    this.viewport = path.boundingBox();
    this.changed = true;
  }

  newLayer(): CYLRefreshVectorLayer | null {
    return CYLRefreshVectorUtilities.newLayerForElement(this, this.shape);
  }
}

/** Several filled paths drawn into a frame (iOS `CYLRefreshVectorImage`). */
export class CYLRefreshVectorImage {
  /** The frame the image is drawn into; zero for the viewport's size at the origin (`frame`). */
  frame: CYLRefreshRect = CYLRefreshRect.zero();
  /** The union of the elements' viewports (`viewport`). */
  viewport: CYLRefreshRect = CYLRefreshRect.zero();
  private items: CYLRefreshVectorElement[] = [];
  private opacityValue: number = 0;

  /** An image of `paths` filled with `colors` (iOS: `new`, then `parserPaths:` and `parserColors:`). */
  static newWithPaths(paths: string[], colors: string[]): CYLRefreshVectorImage {
    const image = new CYLRefreshVectorImage();
    image.parserPaths(paths);
    image.parserColors(colors);
    return image;
  }

  /** The elements (`elements`). */
  get elements(): CYLRefreshVectorElement[] {
    return this.items;
  }

  /** The drawn size: the viewport's while the frame is zero (`size`). */
  get size(): CYLSize {
    if (this.items.length > 0 && this.frame.isZero()) {
      return new CYLSize(this.viewport.width, this.viewport.height);
    }
    return new CYLSize(this.frame.width, this.frame.height);
  }

  set size(size: CYLSize) {
    this.frame = new CYLRefreshRect(this.frame.x, this.frame.y, size.width, size.height);
  }

  /** The opacity, given to every element (`opacity`). */
  get opacity(): number {
    return this.opacityValue;
  }

  set opacity(value: number) {
    this.opacityValue = value;
    this.items.forEach((e: CYLRefreshVectorElement) => {
      e.opacity = value;
    });
  }

  /** Adds an element and grows the viewport (`-addElement:`). */
  addElement(element: CYLRefreshVectorElement): void {
    this.items.push(element);
    this.viewport = this.viewport.union(element.viewport);
  }

  /** Replaces the elements with SVG path data (`-parserPaths:`). */
  parserPaths(paths: string[]): void {
    this.viewport = CYLRefreshRect.zero();
    this.items = [];
    paths.forEach((p: string) => this.addElement(CYLRefreshVectorPathElement.newWith(p)));
  }

  /** Fills the elements in order; the last color fills the rest (`-parserColors:`). */
  parserColors(colors: string[]): void {
    if (colors.length === 0) {
      return;
    }
    let color = colors[0];
    for (let i = 0; i < this.items.length; i++) {
      if (i < colors.length) {
        color = colors[i];
      }
      this.items[i].fill = color;
    }
  }

  /** Scales the size to fit inside `maxSize`, keeping the ratio (`-scaleToFitInside:`). */
  scaleToFitInside(maxSize: CYLSize): void {
    const size = this.size;
    if ((size.width === 0 && size.height === 0) || (maxSize.width === 0 && maxSize.height === 0)) {
      this.size = maxSize;
      return;
    }
    const scale = Math.min(maxSize.width / size.width, maxSize.height / size.height);
    this.size = new CYLSize(size.width * scale, size.height * scale);
  }

  /** Draws the elements scaled from the viewport into the frame (`-renderInContext:`). */
  renderInContext(ctx: CanvasRenderingContext2D): void {
    if (this.viewport.isZero() || this.viewport.width === 0 || this.viewport.height === 0) {
      return;
    }
    const size = this.size;
    const scaleX = size.width / this.viewport.width;
    const scaleY = size.height / this.viewport.height;
    ctx.save();
    ctx.translate(this.frame.x, this.frame.y);
    ctx.translate(-scaleX * this.viewport.x, -scaleY * this.viewport.y);
    ctx.scale(scaleX, scaleY);
    this.items.forEach((e: CYLRefreshVectorElement) => {
      const layer = e.layer;
      if (layer !== null) {
        layer.renderInContext(ctx);
      }
    });
    ctx.restore();
  }

  /** Sets the width, keeping the ratio (`-setGeometricWidth:`). */
  setGeometricWidth(width: number): void {
    const size = this.size;
    if (size.width !== 0 || size.height !== 0) {
      this.size = new CYLSize(width, size.height * width / size.width);
    }
  }

  /** Sets the height, keeping the ratio (`-setGeometricHeight:`). */
  setGeometricHeight(height: number): void {
    const size = this.size;
    if (size.width !== 0 || size.height !== 0) {
      this.size = new CYLSize(size.width * height / size.height, height);
    }
  }

  /** Moves the frame's origin to `pt`, keeping the size (`-moveTo:`). */
  moveTo(pt: CYLPoint): void {
    const size = this.size;
    this.frame = new CYLRefreshRect(pt.x, pt.y, size.width, size.height);
  }
}

/**
 * The model of a view showing a vector image (iOS `CYLRefreshVectorView`): draw it with `CYLRefreshVectorViewComponent`.
 * The image is scaled to fit inside the view, as the iOS view does on layout.
 */
export class CYLRefreshVectorViewModel {
  /** The image, or null (`image`). */
  image: CYLRefreshVectorImage | null = null;

  /** Parses path data into the image, creating it (`-parserPaths:`). */
  parserPaths(paths: string[]): void {
    if (this.image === null) {
      this.image = new CYLRefreshVectorImage();
    }
    (this.image as CYLRefreshVectorImage).parserPaths(paths);
  }

  /** Colors the image (`-parserColors:`). */
  parserColors(colors: string[]): void {
    if (this.image !== null) {
      (this.image as CYLRefreshVectorImage).parserColors(colors);
    }
  }

  /** Draws the image fitted and centered in a `width` x `height` view. */
  drawInContext(ctx: CanvasRenderingContext2D, width: number, height: number): void {
    const image = this.image;
    if (image === null) {
      return;
    }
    image.scaleToFitInside(new CYLSize(width, height));
    const size = image.size;
    image.moveTo(new CYLPoint((width - size.width) / 2, (height - size.height) / 2));
    image.renderInContext(ctx);
  }
}
