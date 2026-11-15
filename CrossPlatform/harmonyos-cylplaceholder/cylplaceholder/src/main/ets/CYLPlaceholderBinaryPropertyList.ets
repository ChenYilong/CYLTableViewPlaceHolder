// Reads binary property lists ("bplist00"), which iOS reads as configuration files like XML ones
// (NSPropertyListSerialization). Values map as the XML reader maps them: dict -> Record, array -> Array, string,
// integer and real -> number, true / false -> boolean, date -> ISO 8601 string, data -> base64 string.
import { util } from '@kit.ArkTS';

/** The 2001-01-01T00:00:00Z reference date of property-list dates, in ms since 1970. */
const REFERENCE_DATE_MS: number = 978307200000;

class BinaryPropertyListReader {
  private view: DataView;
  private bytes: Uint8Array;
  private offsets: number[] = [];
  private refSize: number = 1;
  private depth: number = 0;

  constructor(bytes: Uint8Array) {
    this.bytes = bytes;
    this.view = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
  }

  read(): Object {
    const n = this.bytes.length;
    if (n < 40 || CYLBinaryPropertyListIsBinary(this.bytes) === false) {
      throw new Error('The binary property list is too short or has no bplist00 header.');
    }
    const trailer = n - 32;
    const offsetSize = this.bytes[trailer + 6];
    this.refSize = this.bytes[trailer + 7];
    const count = this.uint(trailer + 8, 8);
    const top = this.uint(trailer + 16, 8);
    const tableOffset = this.uint(trailer + 24, 8);
    if (offsetSize < 1 || offsetSize > 8 || this.refSize < 1 || this.refSize > 8 || count < 1 ||
      tableOffset + count * offsetSize > trailer || top >= count) {
      throw new Error('The binary property list trailer is invalid.');
    }
    for (let i = 0; i < count; i++) {
      this.offsets.push(this.uint(tableOffset + i * offsetSize, offsetSize));
    }
    return this.object(top);
  }

  /** A big-endian unsigned integer of `size` bytes (up to 8; exact up to 2^53). */
  private uint(at: number, size: number): number {
    if (at < 0 || at + size > this.bytes.length) {
      throw new Error('The binary property list is truncated.');
    }
    let value = 0;
    for (let i = 0; i < size; i++) {
      value = value * 256 + this.bytes[at + i];
    }
    return value;
  }

  /** An object's length: the low nibble, or the integer object that follows when it is 0xF. */
  private length(at: number): number[] {
    const low = this.bytes[at] & 0x0F;
    if (low !== 0x0F) {
      return [low, at + 1];
    }
    const marker = this.bytes[at + 1];
    if ((marker & 0xF0) !== 0x10) {
      throw new Error('The binary property list has an invalid length.');
    }
    const size = 1 << (marker & 0x0F);
    return [this.uint(at + 2, size), at + 2 + size];
  }

  private object(ref: number): Object {
    if (ref < 0 || ref >= this.offsets.length) {
      throw new Error('The binary property list has an invalid object reference.');
    }
    this.depth++;
    if (this.depth > 512) {
      throw new Error('The binary property list nests too deeply.');
    }
    try {
      return this.objectAt(this.offsets[ref]);
    } finally {
      this.depth--;
    }
  }

  private objectAt(at: number): Object {
    if (at >= this.bytes.length) {
      throw new Error('The binary property list is truncated.');
    }
    const marker = this.bytes[at];
    const kind = marker & 0xF0;
    const low = marker & 0x0F;
    switch (kind) {
      case 0x00:
        if (marker === 0x08) {
          return false;
        }
        if (marker === 0x09) {
          return true;
        }
        throw new Error('The binary property list has an unsupported null or fill value.');
      case 0x10: {
        const size = 1 << low;
        if (size === 8) {
          // 8-byte integers are signed.
          return Number(this.view.getBigInt64(at + 1));
        }
        return this.uint(at + 1, size);
      }
      case 0x20:
        return low === 2 ? this.view.getFloat32(at + 1) : this.view.getFloat64(at + 1);
      case 0x30:
        return new Date(REFERENCE_DATE_MS + this.view.getFloat64(at + 1) * 1000).toISOString();
      case 0x40: {
        const l = this.length(at);
        const data = this.bytes.subarray(l[1], l[1] + l[0]);
        return new util.Base64Helper().encodeToStringSync(data);
      }
      case 0x50: {
        const l = this.length(at);
        let text = '';
        for (let i = 0; i < l[0]; i++) {
          text += String.fromCharCode(this.bytes[l[1] + i]);
        }
        return text;
      }
      case 0x60: {
        const l = this.length(at);
        const units: number[] = [];
        for (let i = 0; i < l[0]; i++) {
          units.push(this.view.getUint16(l[1] + i * 2));
        }
        let text = '';
        for (let i = 0; i < units.length; i += 4096) {
          text += String.fromCharCode(...units.slice(i, i + 4096));
        }
        return text;
      }
      case 0x80:
        return this.uint(at + 1, low + 1);
      case 0xA0: {
        const l = this.length(at);
        const list: Object[] = [];
        for (let i = 0; i < l[0]; i++) {
          list.push(this.object(this.uint(l[1] + i * this.refSize, this.refSize)));
        }
        return list;
      }
      case 0xD0: {
        const l = this.length(at);
        const map: Record<string, Object> = {};
        for (let i = 0; i < l[0]; i++) {
          const key = this.object(this.uint(l[1] + i * this.refSize, this.refSize));
          const value = this.object(this.uint(l[1] + (l[0] + i) * this.refSize, this.refSize));
          if (typeof key !== 'string') {
            throw new Error('The binary property list has a dictionary key that is not a string.');
          }
          map[key as string] = value;
        }
        return map;
      }
      default:
        throw new Error('The binary property list has an unsupported object type.');
    }
  }
}

/** Whether the bytes start with "bplist00". */
export function CYLBinaryPropertyListIsBinary(bytes: Uint8Array): boolean {
  const header = 'bplist00';
  if (bytes.length < header.length) {
    return false;
  }
  for (let i = 0; i < header.length; i++) {
    if (bytes[i] !== header.charCodeAt(i)) {
      return false;
    }
  }
  return true;
}

/** The root object of a binary property list; throws an Error with the reason when it is invalid. */
export function CYLBinaryPropertyListParse(bytes: Uint8Array): Object {
  return new BinaryPropertyListReader(bytes).read();
}

/** UTF-8 bytes as text: util.TextDecoder when the runtime has it, else a plain decoder (host unit tests). */
export function CYLPlaceholderDecodeUTF8(bytes: Uint8Array): string {
  try {
    return util.TextDecoder.create('utf-8').decodeToString(bytes);
  } catch (e) {
    let text = '';
    let i = 0;
    while (i < bytes.length) {
      const b = bytes[i];
      let code = b;
      let extra = 0;
      if (b >= 0xF0) {
        code = b & 0x07;
        extra = 3;
      } else if (b >= 0xE0) {
        code = b & 0x0F;
        extra = 2;
      } else if (b >= 0xC0) {
        code = b & 0x1F;
        extra = 1;
      }
      for (let k = 1; k <= extra && i + k < bytes.length; k++) {
        code = (code << 6) | (bytes[i + k] & 0x3F);
      }
      text += String.fromCodePoint(code);
      i += extra + 1;
    }
    return text;
  }
}
