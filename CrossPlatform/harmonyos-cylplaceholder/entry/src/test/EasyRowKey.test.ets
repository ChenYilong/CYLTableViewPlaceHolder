// Local (host) unit test of the key RefreshEasyPage's ForEach uses: a row whose text changes must get a new key, or the
// list keeps the old row (the scroll mode page's check mark stayed on Move).
import { describe, expect, it } from '@ohos/hypium';
import { easyRowKey } from '../main/ets/common/EasyRowKey';

export default function easyRowKeyTest() {
  describe('EasyRowKey', () => {
    it('changedTextChangesKey', 0, () => {
      expect(easyRowKey('scrollMode1', '拉伸') !== easyRowKey('scrollMode1', '✓ 拉伸')).assertTrue();
    });
    it('sameRowKeepsKey', 0, () => {
      expect(easyRowKey('r1', 'a')).assertEqual(easyRowKey('r1', 'a'));
    });
  });
}
