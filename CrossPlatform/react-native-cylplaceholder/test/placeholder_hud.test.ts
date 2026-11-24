import assert from 'node:assert/strict';
import test from 'node:test';
import { CYLPlaceholderComponent } from '../src/placeholder/components.ts';
import { CYLPlaceholderHUDBase, type CYLPlaceholderHUDBackend } from '../src/hud/hudBase.ts';

function mockBackend() {
  const calls: Array<[string, Record<string, unknown> | undefined]> = [];
  let listener: ((action: string) => void) | undefined;
  let listeners = 0;
  const backend: CYLPlaceholderHUDBackend = {
    call: (method, args) => void calls.push([method, args]),
    onAction: (fn) => {
      listener = fn;
      listeners++;
      return () => {
        listener = undefined;
      };
    },
  };
  return { backend, calls, tap: (name: string) => listener?.(name), listening: () => listener !== undefined, subscriptions: () => listeners };
}

test('components build the configuration dictionary the native stack reads, without undefined keys', () => {
  assert.deepEqual(CYLPlaceholderComponent.icon({ style: 'error', title: 'Failed', animationLoops: true, animationSpeed: 2, size: [96, 96] }), {
    type: 'icon', style: 'error', title: 'Failed', animationLoops: true, animationSpeed: 2, size: [96, 96],
  });
  assert.deepEqual(CYLPlaceholderComponent.icon({ title: undefined }), { type: 'icon' });
  assert.deepEqual(CYLPlaceholderComponent.hint('Check the network'), { type: 'hint', title: 'Check the network' });
  assert.deepEqual(CYLPlaceholderComponent.button('Retry', 'retry', { buttonStyle: 'capsule' }), {
    type: 'button', title: 'Retry', action: 'retry', buttonStyle: 'capsule',
  });
  assert.deepEqual(CYLPlaceholderComponent.separator('or', { spacingBefore: 8 }), { type: 'separator', title: 'or', spacingBefore: 8 });
});

test('the HUD forwards each method with the names and arguments of CYLPlaceholderHUDBridge', () => {
  const { backend, calls } = mockBackend();
  const hud = new CYLPlaceholderHUDBase(backend);
  hud.show();
  hud.showWithStatus('Please wait');
  hud.showProgress(0.5, 'Uploading');
  hud.setStatus('Almost');
  hud.showInfoWithStatus('Info');
  hud.showSuccessWithStatus('Done');
  hud.showErrorWithStatus('Failed');
  hud.popActivity();
  hud.dismiss();
  assert.deepEqual(calls, [
    ['show', undefined],
    ['showWithStatus', { status: 'Please wait' }],
    ['showProgress', { progress: 0.5, status: 'Uploading' }],
    ['setStatus', { status: 'Almost' }],
    ['showInfoWithStatus', { status: 'Info' }],
    ['showSuccessWithStatus', { status: 'Done' }],
    ['showErrorWithStatus', { status: 'Failed' }],
    ['popActivity', undefined],
    ['dismiss', undefined],
  ]);
});

test('showComponents names each action component-<index> and runs the function when the native HUD reports the name', () => {
  const { backend, calls, tap, subscriptions } = mockBackend();
  const hud = new CYLPlaceholderHUDBase(backend);
  let ok = 0;
  hud.showComponents([{ type: 'hint', title: 'Hello' }, { type: 'button', title: 'OK', action: () => ok++ }]);
  assert.deepEqual(calls[0], ['showComponents', { components: [{ type: 'hint', title: 'Hello' }, { type: 'button', title: 'OK', action: 'component-1' }] }]);
  tap('component-0');
  assert.equal(ok, 0);
  tap('component-1');
  assert.equal(ok, 1);
  hud.showComponents([{ type: 'button', title: 'Again', action: () => (ok += 10) }]);
  tap('component-1');
  assert.equal(ok, 1);
  tap('component-0');
  assert.equal(ok, 11);
  assert.equal(subscriptions(), 1);
});

test('dismissWithDelay passes the delay in seconds and calls the completion afterwards; dispose stops listening', async () => {
  const { backend, calls, listening } = mockBackend();
  const hud = new CYLPlaceholderHUDBase(backend);
  let done = false;
  hud.dismissWithDelay(0.01, () => (done = true));
  assert.deepEqual(calls[0], ['dismissWithDelay', { delay: 0.01 }]);
  assert.equal(done, false);
  await new Promise((resolve) => setTimeout(resolve, 40));
  assert.equal(done, true);
  hud.showComponents([{ type: 'hint', title: 'x' }]);
  assert.equal(listening(), true);
  hud.dispose();
  assert.equal(listening(), false);
});
