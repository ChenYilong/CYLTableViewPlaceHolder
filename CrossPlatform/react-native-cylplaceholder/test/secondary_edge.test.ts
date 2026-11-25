import assert from 'node:assert/strict';
import { test } from 'node:test';
import { cylSecondaryEdge } from '../src/refresh/index.ts';

test('the footer edge of a native event is read from nativeEvent', () => {
  assert.equal(cylSecondaryEdge({ nativeEvent: { edge: 'footer' } }), 'footer');
  assert.equal(cylSecondaryEdge({ nativeEvent: { edge: 'header' } }), 'header');
});

test('a missing, empty or unknown edge is the header (Android sends none)', () => {
  assert.equal(cylSecondaryEdge(undefined), 'header');
  assert.equal(cylSecondaryEdge(null), 'header');
  assert.equal(cylSecondaryEdge({}), 'header');
  assert.equal(cylSecondaryEdge({ nativeEvent: {} }), 'header');
  assert.equal(cylSecondaryEdge({ nativeEvent: { edge: 'side' } }), 'header');
});
