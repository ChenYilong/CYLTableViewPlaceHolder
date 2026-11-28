import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  CYLPlaceholderItemKey,
  CYLPlaceholderStyle,
  CYLPlaceholderStyles,
  cylPlaceholderItemAttributes,
  cylPlaceholderValuesFromAttributes,
} from '../src/placeholder/attributes.ts';

test('the styles keep the Flutter order, so an index means the same style on every platform', () => {
  assert.equal(CYLPlaceholderStyles.length, 20);
  assert.equal(CYLPlaceholderStyles[0], 'empty');
  assert.equal(CYLPlaceholderStyles[2], 'error');
  assert.equal(CYLPlaceholderStyles[19], 'locked');
});

test('an item dictionary with the iOS keys is read: style by name or index, size, colors', () => {
  const values = cylPlaceholderValuesFromAttributes({
    [CYLPlaceholderItemKey.style]: 3,
    [CYLPlaceholderItemKey.title]: 'Offline',
    [CYLPlaceholderItemKey.message]: 'Try again',
    [CYLPlaceholderItemKey.animationURL]: 'a.riv',
    [CYLPlaceholderItemKey.animationSize]: [80, 60],
    [CYLPlaceholderItemKey.titleColor]: '#336699',
    [CYLPlaceholderItemKey.iconColor]: '80336699',
    [CYLPlaceholderItemKey.backgroundColor]: 0xff102030,
  });
  assert.equal(values.style, 'wifiOff');
  assert.equal(values.title, 'Offline');
  assert.equal(values.message, 'Try again');
  assert.equal(values.animationFile, 'a.riv');
  assert.deepEqual(values.animationSize, { width: 80, height: 60 });
  assert.equal(values.titleColor, 'rgba(51, 102, 153, 1)');
  assert.equal(values.iconColor, `rgba(51, 102, 153, ${0x80 / 255})`);
  assert.equal(values.backgroundColor, 'rgba(16, 32, 48, 1)');
  assert.equal(cylPlaceholderValuesFromAttributes({ [CYLPlaceholderItemKey.style]: 'blocked' }).style, 'blocked');
});

test('invalid values fall back to the defaults', () => {
  const values = cylPlaceholderValuesFromAttributes({
    [CYLPlaceholderItemKey.style]: 99,
    [CYLPlaceholderItemKey.animationSize]: [1],
    [CYLPlaceholderItemKey.titleColor]: 'red',
  });
  assert.equal(values.style, CYLPlaceholderStyle.empty);
  assert.deepEqual(values.animationSize, { width: 120, height: 120 });
  assert.equal(values.titleColor, undefined);
  assert.equal(values.title, undefined);
});

test('itemAttributes is the inverse of reading, with the style as a name', () => {
  const attributes = cylPlaceholderItemAttributes({ style: 'error', title: 'Failed', animationFile: 'x.json' });
  assert.deepEqual(attributes, {
    CYLPlaceholderItemStyle: 'error',
    CYLTabBarItemTitle: 'Failed',
    CYLTabBarAnimationURL: 'x.json',
  });
  assert.equal(cylPlaceholderValuesFromAttributes(attributes).style, 'error');
});
