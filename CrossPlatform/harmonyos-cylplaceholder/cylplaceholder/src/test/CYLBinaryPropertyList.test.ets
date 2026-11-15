// Unit tests for binary property lists ("bplist00") as configuration files, as iOS reads them.
import { describe, expect, it } from '@ohos/hypium';
import { CYLBinaryPropertyListIsBinary, CYLBinaryPropertyListParse } from '../main/ets/CYLPlaceholderBinaryPropertyList';
import { CYLPlaceholderConfiguration } from '../main/ets/CYLPlaceholderConfiguration';

// {title: "Hello", count: 3, ok: true, list: [1.5, "Café" (UTF-16), -2 (8-byte signed)]}, written by a bplist00 encoder.
const FIXTURE: number[] = [98, 112, 108, 105, 115, 116, 48, 48, 9, 85, 116, 105, 116, 108, 101, 85, 72, 101, 108, 108,
  111, 85, 99, 111, 117, 110, 116, 16, 3, 82, 111, 107, 84, 108, 105, 115, 116, 35, 63, 248, 0, 0, 0, 0, 0, 0, 100, 0,
  67, 0, 97, 0, 102, 0, 233, 19, 255, 255, 255, 255, 255, 255, 255, 254, 163, 7, 8, 9, 212, 1, 3, 5, 6, 2, 4, 0, 10, 8,
  9, 15, 21, 27, 29, 32, 37, 46, 55, 64, 68, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 12, 0, 0, 0, 0, 0, 0, 0, 11,
  0, 0, 0, 0, 0, 0, 0, 77];

export default function binaryPropertyListTest() {
  describe('CYLBinaryPropertyList', () => {
    it('readsEveryValueType', 0, () => {
      const root = CYLBinaryPropertyListParse(new Uint8Array(FIXTURE)) as Record<string, Object>;
      expect(root['title'] as string).assertEqual('Hello');
      expect(root['count'] as number).assertEqual(3);
      expect(root['ok'] as boolean).assertTrue();
      const list = root['list'] as Object[];
      expect(list.length).assertEqual(3);
      expect(list[0] as number).assertEqual(1.5);
      expect(list[1] as string).assertEqual('Café');
      expect(list[2] as number).assertEqual(-2);
    });

    it('detectsTheHeader', 0, () => {
      expect(CYLBinaryPropertyListIsBinary(new Uint8Array(FIXTURE))).assertTrue();
      expect(CYLBinaryPropertyListIsBinary(new Uint8Array([60, 63, 120, 109, 108]))).assertFalse();
    });

    it('configurationReadsBinaryPlistBytes', 0, () => {
      let error = '';
      const map = CYLPlaceholderConfiguration.parseData(new Uint8Array(FIXTURE), 'a.plist', (m: string) => error = m);
      expect(map !== null).assertTrue();
      expect((map as Record<string, Object>)['title'] as string).assertEqual('Hello');
      expect(error).assertEqual('');
    });

    it('rejectsATruncatedList', 0, () => {
      let error = '';
      const map = CYLPlaceholderConfiguration.parsePropertyListData(new Uint8Array(FIXTURE.slice(0, 60)),
        (m: string) => error = m);
      expect(map === null).assertTrue();
      expect(error.length > 0).assertTrue();
    });

    it('xmlBytesStillParse', 0, () => {
      const xml = '<?xml version="1.0"?><plist version="1.0"><dict><key>a</key><string>b</string></dict></plist>';
      const bytes = new Uint8Array(xml.length);
      for (let i = 0; i < xml.length; i++) {
        bytes[i] = xml.charCodeAt(i);
      }
      const map = CYLPlaceholderConfiguration.parseData(bytes, 'x.plist');
      expect((map as Record<string, Object>)['a'] as string).assertEqual('b');
    });
  });
}
