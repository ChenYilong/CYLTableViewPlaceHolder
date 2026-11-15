// The HarmonyOS counterpart of the iOS configuration readers (`-initWithConfiguration:`, `-initWithContentsOfURL:`,
// `-initWithItemContentsOfURL:`, `cyl_applyStatusConfiguration...`), translated from android/placeholder's
// CYLPlaceholderConfiguration.kt (keys and error messages as there) and the mini program's cyl_configuration.js (the
// XML property list reader). A configuration is a JSON object, or an XML property list on a ".plist" path.
import { fileIo } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { CYLPlaceholderLocalization } from './CYLPlaceholderLocalization';
import { CYLPlaceholderComponent, CYLPlaceholderScenarioCatalog } from './CYLPlaceholderScenario';
import { CYLPlaceholderTapHighlightStyle } from './CYLPlaceholderViewTypes';

/** Receives the reason a configuration was refused (the iOS `error:` out parameter). */
export type CYLPlaceholderConfigurationErrorHandler = (message: string) => void;

/** "WifiOff" -> "wifi_off", "CYLPlaceholderStatusNetworkUnavailable" -> "cyl_placeholder_status_network_unavailable". */
function snake(name: string): string {
  return name.replace(new RegExp('([a-z0-9])([A-Z])', 'g'), '$1_$2')
    .replace(new RegExp('([A-Z])([A-Z][a-z])', 'g'), '$1_$2').toLowerCase();
}

function isRecord(value: Object | undefined | null): boolean {
  return value !== undefined && value !== null && typeof value === 'object' && !Array.isArray(value);
}

function decodeEntities(s: string): string {
  return s.replace(new RegExp('&lt;', 'g'), '<').replace(new RegExp('&gt;', 'g'), '>')
    .replace(new RegExp('&quot;', 'g'), '"').replace(new RegExp('&apos;', 'g'), '\'')
    .replace(new RegExp('&amp;', 'g'), '&');
}

/** A refusal while reading a property list (caught by parsePropertyList). */
class PlistError extends Error {
}

/** Reads an XML property list token by token. */
class PlistReader {
  private tokens: string[];
  private i: number = 0;

  constructor(text: string) {
    const cleaned = text.replace(new RegExp('<\\?xml[^>]*\\?>|<!DOCTYPE[^>]*>|<!--[\\s\\S]*?-->', 'g'), '');
    const found = cleaned.match(new RegExp('<[^>]+>|[^<]+', 'g'));
    this.tokens = found !== null ? found.map((t: string) => t) : [];
  }

  next(): string | null {
    while (this.i < this.tokens.length && !this.tokens[this.i].startsWith('<')) {
      this.i++;
    }
    return this.i < this.tokens.length ? this.tokens[this.i++] : null;
  }

  textUntil(close: string): string {
    let s = '';
    while (this.i < this.tokens.length && this.tokens[this.i] !== close) {
      s += this.tokens[this.i++];
    }
    this.i++;
    return decodeEntities(s);
  }

  value(tag: string | null): Object {
    if (tag === null) {
      throw new PlistError('The property list is not complete.');
    }
    const empty = tag.match(new RegExp('^<(\\w+)\\s*/>$'));
    if (empty !== null) {
      const name = empty[1];
      if (name === 'true') {
        return true;
      }
      if (name === 'false') {
        return false;
      }
      if (name === 'string') {
        return '';
      }
      if (name === 'dict') {
        const d: Record<string, Object> = {};
        return d;
      }
      if (name === 'array') {
        const a: Object[] = [];
        return a;
      }
      throw new PlistError('Unsupported property list element <' + name + '/>.');
    }
    const open = tag.match(new RegExp('^<(\\w+)'));
    const name = open !== null ? open[1] : '';
    if (name === 'string' || name === 'date' || name === 'data') {
      return this.textUntil('</' + name + '>');
    }
    if (name === 'integer') {
      return parseInt(this.textUntil('</integer>'), 10);
    }
    if (name === 'real') {
      return parseFloat(this.textUntil('</real>'));
    }
    if (name === 'array') {
      const list: Object[] = [];
      for (let t = this.next(); t !== '</array>'; t = this.next()) {
        if (t === null) {
          throw new PlistError('The property list is not complete.');
        }
        list.push(this.value(t));
      }
      return list;
    }
    if (name === 'dict') {
      const dict: Record<string, Object> = {};
      for (let t = this.next(); t !== '</dict>'; t = this.next()) {
        if (t !== '<key>') {
          throw new PlistError('A property list dictionary needs <key> before each value.');
        }
        const key = this.textUntil('</key>');
        dict[key] = this.value(this.next());
      }
      return dict;
    }
    throw new PlistError('Unsupported property list element ' + tag + '.');
  }
}

/** The configuration readers shared by the stack view, the placeholder view, the status bar and the page status. */
export class CYLPlaceholderConfiguration {
  /** Calls onError with message (when there is one) and returns null. */
  static fail(onError: CYLPlaceholderConfigurationErrorHandler | null, message: string): null {
    if (onError !== null) {
      onError(message);
    }
    return null;
  }

  /** A JSON object, or null (the reason to onError) when the text is not one. */
  static parseJSON(text: string, onError: CYLPlaceholderConfigurationErrorHandler | null = null):
    Record<string, Object> | null {
    let parsed: Object | null = null;
    try {
      parsed = JSON.parse(text) as Object;
    } catch (e) {
      parsed = null;
    }
    if (parsed === null || !isRecord(parsed)) {
      return CYLPlaceholderConfiguration.fail(onError, 'The configuration file is not a JSON object.');
    }
    return parsed as Record<string, Object>;
  }

  /**
   * An XML property list (dict, array, string, integer, real, true, false, date and data as strings); null, with the
   * reason, for a binary or invalid one.
   */
  static parsePropertyList(text: string, onError: CYLPlaceholderConfigurationErrorHandler | null = null):
    Object | null {
    if (text.startsWith('bplist')) {
      return CYLPlaceholderConfiguration.fail(onError, 'A binary property list is not supported; save it as XML.');
    }
    try {
      const reader = new PlistReader(text);
      let root = reader.next();
      if (root !== null && root.startsWith('<plist')) {
        root = reader.next();
      }
      return reader.value(root);
    } catch (e) {
      return CYLPlaceholderConfiguration.fail(onError, (e as Error).message);
    }
  }

  /** The dictionary in a configuration text: a property list when fileName ends with ".plist", else JSON. */
  static parseText(text: string, fileName: string, onError: CYLPlaceholderConfigurationErrorHandler | null = null):
    Record<string, Object> | null {
    if (fileName.toLowerCase().endsWith('.plist')) {
      const value = CYLPlaceholderConfiguration.parsePropertyList(text, onError);
      if (value === null) {
        return null;
      }
      if (!isRecord(value)) {
        return CYLPlaceholderConfiguration.fail(onError, 'The property list is not a dictionary.');
      }
      return value as Record<string, Object>;
    }
    return CYLPlaceholderConfiguration.parseJSON(text, onError);
  }

  /**
   * Reads the configuration in a local ".json" or ".plist" file (the iOS file URL): a sandbox path
   * ("/data/storage/el2/base/files/a.json", or a "file://" URI). Null, with the reason, when it cannot be read.
   */
  static readFile(path: string, onError: CYLPlaceholderConfigurationErrorHandler | null = null):
    Record<string, Object> | null {
    const plain = path.startsWith('file://') ? path.substring('file://'.length) : path;
    let text = '';
    try {
      const file = fileIo.openSync(plain, fileIo.OpenMode.READ_ONLY);
      try {
        const size = fileIo.statSync(file.fd).size;
        const buffer = new ArrayBuffer(size);
        fileIo.readSync(file.fd, buffer);
        text = util.TextDecoder.create('utf-8').decodeToString(new Uint8Array(buffer));
      } finally {
        fileIo.closeSync(file);
      }
    } catch (e) {
      return CYLPlaceholderConfiguration.fail(onError, 'The configuration file cannot be read: ' + (e as Error).message);
    }
    return CYLPlaceholderConfiguration.parseText(text, plain, onError);
  }

  /**
   * A text from a configuration: the core string of the key in keyName ("CYLPlaceholderStatusNetworkUnavailable")
   * when there is one, else the literal in literalName (iOS `CYLScenarioConfiguredText`).
   */
  static configuredText(map: Record<string, Object>, literalName: string, keyName: string): string | null {
    const literalValue: Object | undefined = map[literalName];
    const keyValue: Object | undefined = map[keyName];
    const literal = typeof literalValue === 'string' ? literalValue as string : null;
    const key = typeof keyValue === 'string' ? keyValue as string : null;
    if (key !== null && key.length > 0) {
      const plain = snake(key).replace(new RegExp('^cyl_placeholder_'), '');
      const text = CYLPlaceholderLocalization.localizedStringForKey(plain, '\u0000');
      if (text !== '\u0000') {
        return text;
      }
      return literal !== null ? literal : key;
    }
    return literal;
  }

  /**
   * Applies the fields every component and override may set: "interactionEnabled", "highlightStyle",
   * "repeatCount", "spacingBefore", "accessibilityIdentifier" and, for an override, "action". false, with the reason,
   * when a value is invalid.
   */
  static applyComponentFields(component: CYLPlaceholderComponent, map: Record<string, Object>,
    onError: CYLPlaceholderConfigurationErrorHandler | null = null): boolean {
    const interaction: Object | undefined = map['interactionEnabled'];
    if (interaction !== undefined) {
      if (typeof interaction !== 'boolean') {
        CYLPlaceholderConfiguration.fail(onError, 'interactionEnabled must be a boolean.');
        return false;
      }
      component.interactionEnabled = interaction as boolean;
    }
    const highlight: Object | undefined = map['highlightStyle'];
    if (highlight !== undefined) {
      const index = ['dim', 'shrink', 'none'].indexOf(typeof highlight === 'string' ?
        (highlight as string).toLowerCase() : '');
      if (index < 0) {
        CYLPlaceholderConfiguration.fail(onError, 'highlightStyle must be dim, shrink or none.');
        return false;
      }
      component.tapHighlightStyle = [CYLPlaceholderTapHighlightStyle.Dim, CYLPlaceholderTapHighlightStyle.Shrink,
        CYLPlaceholderTapHighlightStyle.None][index];
    }
    const repeat: Object | undefined = map['repeatCount'];
    if (repeat !== undefined) {
      let count = -1;
      if (typeof repeat === 'string' && (repeat as string).toLowerCase() === 'loop') {
        count = 0;
      } else if (typeof repeat === 'string' && (repeat as string).toLowerCase() === 'once') {
        count = 1;
      } else if (typeof repeat === 'number' && Math.floor(repeat as number) === (repeat as number)) {
        count = repeat as number;
      }
      if (count < 0 || count > 10000) {
        CYLPlaceholderConfiguration.fail(onError, 'repeatCount must be 0 (loop) or more, "loop" or "once".');
        return false;
      }
      component.animationRepeatCount = count;
    }
    const spacing: Object | undefined = map['spacingBefore'];
    if (spacing !== undefined) {
      if (typeof spacing !== 'number' || !isFinite(spacing as number) || (spacing as number) < 0) {
        CYLPlaceholderConfiguration.fail(onError, 'spacingBefore must be a number of points.');
        return false;
      }
      component.spacingBefore = spacing as number;
    }
    const identifier: Object | undefined = map['accessibilityIdentifier'];
    if (identifier !== undefined) {
      if (typeof identifier !== 'string') {
        CYLPlaceholderConfiguration.fail(onError, 'accessibilityIdentifier must be a string.');
        return false;
      }
      component.accessibilityIdentifier = identifier as string;
    }
    const action: Object | undefined = map['action'];
    if (action !== undefined && map['type'] === undefined) {
      const name = typeof action === 'string' ? action as string : '';
      component.action = name.length > 0 ? CYLPlaceholderScenarioCatalog.actionNamed(name) : null;
    }
    return true;
  }

  /** Whether value is a dictionary (a JSON object), not an array. */
  static isDictionary(value: Object | undefined | null): boolean {
    return isRecord(value);
  }
}
