---
name: cyl-harmonyos-a11y-l10n
description: HarmonyOS accessibility (screen readers, visual assistance) and localization rules for CrossPlatform/harmonyos-cylplaceholder, and how UI tests locate controls through them.
---

# HarmonyOS accessibility and localization

Use this skill for any change to the HarmonyOS library or example (`CrossPlatform/harmonyos-cylplaceholder`) and for
every HarmonyOS UI test. The rule is in `instructions.md`, "HarmonyOS accessibility and localization"; status and
score are in `docs/HarmonyOS.md` ("Full-marks standard").

## The rule

All HarmonyOS code of this project supports visual assistance and blind users (screen readers such as ScreenReader /
TalkBack-style navigation, large text, high contrast) and internationalization / localization. If you find code that
does not, add the support first, before anything else in the task.

## Accessibility checklist (ArkUI)

- **Every tappable element** has a role and a label: `.accessibilityRole(AccessibilityRoleType.BUTTON)` (or the
  fitting role) and visible text or `.accessibilityText(...)` with a localized string. Glyph or icon-only buttons
  always have `.accessibilityText`.
- **Rows** that act as one control: `.accessibilityGroup(true)` so title and detail read as one element.
- **Decorative images and animations** (arrows, frames, spinners, illustration animations next to their text):
  `.accessibilityLevel('no')`; a container whose content is read elsewhere: `'no-hide-descendants'`.
- **What is not shown is not read**: hidden or auto-hidden controls use `.accessibilityLevel('no-hide-descendants')`.
- **State**: selected items use `.accessibilitySelected(...)` and say "Selected" (localized); adjustable controls
  (sliders) describe their value (`.accessibilityDescription("1.5x")`).
- **Library views** follow iOS VoiceOver behavior: the placeholder (`CYLPlaceholderView`: `accessibilityLabel`,
  `accessibilityHint`, `accessibilityIdentifier`), the status bar (one group, a button when tappable), the HUD and
  the refresh controls (state + time as one element, decorative icons hidden, the auto footer's label a button).
- Use `.id(...)` for stable test hooks, but never instead of a label.

## Localization checklist

- **No hard-coded user-visible or spoken text.** Library texts come from `CYLPlaceholderLocalization`; example texts
  from `t('Key')` (`common/L10n.ets`, generated `common/ExampleStrings.ets`, seven languages: en, zh-Hans, zh-Hant,
  ja, ko, ru, uk); playback control texts from `common/Playback.ets`; tab bar texts (Selected, Plus button, Close,
  Play / Stop, Badges) from `common/TabBarStrings.ets`, copied from CYLTabBarController's string table by
  `node scripts/import-tabbar-strings.js` (only the keys this project uses; re-run it to refresh).
- New example texts go to the shared example strings (mini program `utils/strings/<lang>.js`, then
  `node scripts/import-example-strings.js`), in all seven languages.
- Check: `node scripts/harmony-l10n-check.js` (every `t('...')` key exists in every language).

## UI tests locate controls through accessibility and localization

In automated UI tests (`entry/src/ohosTest`, Hypium + UiTest; run with `scripts/emulator-check.sh uitest`):

1. **Find controls by what assistive technology reads first**: `ON.description(label)` (the accessibility label),
   then `ON.text(label)` (the localized visible text), trying the label in every language the example supports, so
   the test passes whatever the device language is and fails when a label is missing.
2. **Use component ids only as the fallback** (`ON.id('tab-scenarios')`).
3. **Trigger taps and complex flows** (several steps in a row, such as open a tab, open a row, Play all, Loop on,
   Play all again, back) through those label lookups; take a screenshot per step.

See `entry/src/ohosTest/ets/test/ExampleUi.test.ets` (`find(driver, labels, fallbackId)`).

## Verify

```sh
cd CrossPlatform/harmonyos-cylplaceholder
scripts/build.sh test                 # HAP, HAR, ohosTest HAP, unit tests
node ../../scripts/harmony-l10n-check.js
scripts/emulator-check.sh uitest      # on an emulator: the UI tests and their screenshots
```
