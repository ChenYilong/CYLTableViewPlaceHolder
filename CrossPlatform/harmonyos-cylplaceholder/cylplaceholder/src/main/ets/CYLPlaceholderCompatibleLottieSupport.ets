// Pure helpers of CYLPlaceholderCompatibleLottie.ets (no @ohos/lottie, host unit-tested): lottie-ios loop counts,
// durations, and keypath color overrides written into the Lottie JSON (lottie-ohos recolors whole layers only, so the
// lottie-ios value provider for "Layer.**.Color" is applied to the matching fills and strokes of the data instead).

/**
 * lottie-ohos `loop` for lottie-ios 2's `loopAnimationCount`: -1 loops forever (`.loop`), N plays N times
 * (`.repeat(N)`; 0 and 1 play once).
 */
export function CYLCompatibleLOTLoopValue(loopAnimationCount: number): boolean | number {
  if (loopAnimationCount === -1) {
    return true;
  }
  const count = Math.floor(loopAnimationCount);
  return count <= 1 ? false : count - 1;
}

function numberField(data: Record<string, Object>, key: string): number {
  const value: Object | undefined = data[key];
  return typeof value === 'number' ? value as number : NaN;
}

/** The animation's duration in seconds ((op - ip) / fr), 0 for missing data (iOS `animation.duration ?? 0`). */
export function CYLCompatibleLOTDurationOfData(data: Object | null): number {
  if (data === null || data === undefined || typeof data !== 'object') {
    return 0;
  }
  const json = data as Record<string, Object>;
  const ip = numberField(json, 'ip');
  const op = numberField(json, 'op');
  const fr = numberField(json, 'fr');
  if (!isFinite(ip) || !isFinite(op) || !isFinite(fr) || fr <= 0 || op <= ip) {
    return 0;
  }
  return (op - ip) / fr;
}

/** The progress (0...1) of `frame` in an animation of `totalFrames` frames. */
export function CYLCompatibleLOTProgressOfFrame(frame: number, totalFrames: number): number {
  const last = totalFrames - 1;
  if (!isFinite(frame) || last <= 0) {
    return 0;
  }
  return Math.min(1, Math.max(0, frame / last));
}

/** A deep copy of JSON data. */
export function CYLCompatibleLOTCopyData(data: Object): Object {
  return JSON.parse(JSON.stringify(data)) as Object;
}

function nodeName(node: Record<string, Object>): string | null {
  const name: Object | undefined = node['nm'];
  return typeof name === 'string' ? name as string : null;
}

function nodeType(node: Record<string, Object>): string | null {
  const type: Object | undefined = node['ty'];
  return typeof type === 'string' ? type as string : null;
}

function arrayField(node: Record<string, Object>, key: string): Record<string, Object>[] {
  const value: Object | undefined = node[key];
  return Array.isArray(value) ? value as Record<string, Object>[] : [];
}

/** The keypath children of a node: a composition's layers, a precomp's asset layers, a shape layer's or group's shapes. */
function children(node: Record<string, Object>, root: Record<string, Object>): Record<string, Object>[] {
  if (node === root) {
    return arrayField(node, 'layers');
  }
  const refId: Object | undefined = node['refId'];
  if (typeof refId === 'number' || typeof refId === 'string') {
    const asset = arrayField(root, 'assets').find((a: Record<string, Object>) => a['id'] === refId);
    if (asset !== undefined) {
      return arrayField(asset, 'layers');
    }
  }
  if (Array.isArray(node['shapes'])) {
    return arrayField(node, 'shapes');
  }
  return arrayField(node, 'it');
}

/** Whether a keypath component (a name, "*" or "**") matches a name. */
function componentMatches(component: string, name: string | null): boolean {
  return component === '*' || (name !== null && component === name);
}

/** Fills ("fl"), strokes ("st") and their gradient-free colors answer the property name "Color". */
function isColorNode(node: Record<string, Object>): boolean {
  const type = nodeType(node);
  return (type === 'fl' || type === 'st') && typeof node['c'] === 'object';
}

function visit(node: Record<string, Object>, root: Record<string, Object>, components: string[], index: number,
  found: Set<Record<string, Object>>, depth: number): void {
  if (depth > 64) {
    return;
  }
  const component = components[index];
  if (index === components.length - 1) {
    // The last component is the property: "Color" (or "*") of a fill or stroke.
    if (node !== root && isColorNode(node) && (component === 'Color' || component === '*')) {
      found.add(node);
    }
  }
  if (component === '**') {
    // Zero levels, then one or more.
    if (index + 1 < components.length) {
      visit(node, root, components, index + 1, found, depth + 1);
    }
    children(node, root).forEach((child: Record<string, Object>) => {
      visit(child, root, components, index, found, depth + 1);
    });
    return;
  }
  if (index === components.length - 1) {
    return;
  }
  children(node, root).forEach((child: Record<string, Object>) => {
    if (componentMatches(component, nodeName(child))) {
      visit(child, root, components, index + 1, found, depth + 1);
    }
  });
}

/** The fills and strokes whose color a lottie-ios keypath string ("Icon.**.Color", "*.Fill 1.Color") names. */
export function CYLCompatibleLOTColorNodes(data: Object, keypath: string): Record<string, Object>[] {
  const components = keypath.split('.').filter((c: string) => c.length > 0);
  if (components.length === 0 || typeof data !== 'object' || data === null) {
    return [];
  }
  const root = data as Record<string, Object>;
  const found = new Set<Record<string, Object>>();
  visit(root, root, components, 0, found, 0);
  return Array.from(found);
}

/**
 * Sets the color (channels 0...1) of every fill and stroke `keypath` names, as a static value (lottie-ios
 * ColorValueProvider); returns how many were set.
 */
export function CYLCompatibleLOTSetColor(data: Object, keypath: string, red: number, green: number, blue: number,
  alpha: number): number {
  const nodes = CYLCompatibleLOTColorNodes(data, keypath);
  nodes.forEach((node: Record<string, Object>) => {
    const value: Record<string, Object> = {};
    value['a'] = 0;
    value['k'] = [red, green, blue, alpha];
    node['c'] = value;
  });
  return nodes.length;
}

/** The static color (channels 0...1) of a fill or stroke node, or null when it is animated. */
export function CYLCompatibleLOTStaticColor(node: Record<string, Object>): number[] | null {
  const color: Object | undefined = node['c'];
  if (typeof color !== 'object' || color === null) {
    return null;
  }
  const property = color as Record<string, Object>;
  const k: Object | undefined = property['k'];
  if (property['a'] === 1 || !Array.isArray(k)) {
    return null;
  }
  return k as number[];
}
