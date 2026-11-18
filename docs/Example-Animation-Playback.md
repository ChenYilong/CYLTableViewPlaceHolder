# Animation playback controls in examples

<!-- bound-classes: none -->

<!-- docs-navigation:start -->

| 中文 | English |
| --- | --- |
| [Rule](#rule) | [Rule](#rule) |
| [Controls](#controls) | [Controls](#controls) |
| [Engines](#engines) | [Engines](#engines) |
| [Pages](#pages) | [Pages](#pages) |

<!-- docs-navigation:end -->

<!-- docs-binding:start -->

| 类 / Class | 头文件 / Header |
| --- | --- |
| 无 / none | — |

<!-- docs-binding:end -->

Written in English only, as the owner asked on 2026-11-13 (task in `docs/Task-Log.md`).

## Rule

Every example page that shows animations (placeholder animations, refresh icons, tab bar item animations, any
Lottie / Rive / PAG / GIF / frame animation) has three playback controls next to its one-shot "Play all":

1. **Play all** restarts every animation on the page from progress 0, every time it is tapped, also while they are
   playing or finished.
2. **Speed slider**: the playback rate, applied live to the animations that are playing and to the next ones.
3. **Loop switch**: on, the animations repeat; off, they play once and stop at their last frame. Applied live.

The three controls combine: for example 0.5x with the loop on plays every animation slowly forever; 2x with the loop
off plays each once, fast; Play all then restarts them all from 0 with the current speed and loop setting. Changing a
control never needs a restart of the page.

This applies to the examples of every layer: iOS (Swift examples), Android (Kotlin examples), React Native, Flutter,
mini programs and HarmonyOS. When an engine or the core cannot do it yet, change the core (a Swift naming macro or a
new core API; an Objective-C interface change follows the compatibility rules in `instructions.md`) instead of
hiding the control.

## Controls

| Control | Values | Default | Label (accessibility) |
| --- | --- | --- | --- |
| Play all | button | — | "Play all"; a button |
| Speed | 0.25x to 3x, steps of 0.25x; the current value shown next to it ("1x") | 1x | "Speed", value "1.5x"; adjustable (VoiceOver increment / decrement, TalkBack scroll actions) |
| Loop | switch | off for one-shot demos, on for spinners | "Loop", value on / off |

- The texts are localized in the example's own bundle (seven languages), never hard-coded.
- The page remembers the setting while it is open; leaving the page may reset it.
- Reduce Motion: the controls still work; an example that pauses animations for Reduce Motion says so next to Play all.
- Screenshots of the page show the controls with a non-default speed and the loop state visible.

## Engines

How each engine gets the three settings. "Core" means the library's own API should offer it, so examples do not
reach into the engine.

| Engine | Restart from 0 | Speed | Loop |
| --- | --- | --- | --- |
| Lottie (iOS `LottieAnimationView`, Android `LottieAnimationView`, lottie-web, lottie-react-native, Flutter `lottie`) | progress 0, then play | `animationSpeed` / `speed` | `loopMode` / `repeatCount` |
| Rive | reset the state machine or animation, then play | drive the time (`advance(delta * speed)`) where the runtime has no speed | the animation's loop mode, or restart on end |
| PAG | `progress = 0`, then play | drive the progress per frame where the view has no speed | `repeatCount` (0 = forever) |
| SVGA (Android and HarmonyOS done 2026-11-19: Animations tab and refresh example57; Android through the CYLAnimatedItem engine, HarmonyOS through the example's Canvas engine; iOS and the mini program TODO, see `docs/Task-Log.md` "SVGA animations") | `stepToFrame(0)`, then `startAnimation` | drive the frame per tick where the player has no speed | `loops` (0 = forever) |
| GIF / frame animations | frame 0 | scale the frame durations | `animationRepeatCount` / repeat count |
| System animations (`CAAnimation`, `ValueAnimator`, Flutter `AnimationController`) | remove and add again / `start()` from 0 / `forward(from: 0)` | `speed` on the layer / duration scale / duration | `repeatCount` / `repeat()` |

## Pages

TODO until each page has the three controls and a screenshot. The order follows the task order in `docs/Task-Log.md`
(after the Android port in progress).

| Page | Platform | Status |
| --- | --- | --- |
| Example-Scenarios "Animations" tab (`CYLAnimationListViewController.swift`) | iOS | TODO |
| Example-Scenarios Rive Home icon page (`CYLRiveRoomsViewController.swift`, house.riv, number input Rooms) | iOS | Done (2026-11-18): Rooms picker and slider (by hand), Loop switch (1.5 s, label follows); no speed control (a number input has no playback speed). Screenshot: `assets/rive-rooms-loop-ios.png` (iPhone 17 Pro simulator, iOS 27.0, Xcode 27.2) |
| Example-Scenarios "Refresh icons" page (Feed tab) | iOS | TODO |
| Refresh demo pages with animated headers (Lottie / Rive / PAG / GIF styles) | iOS | TODO |
| `android/merged` example, refresh styles and animations | Android | Animations tab detail page done (2026-11-18, `AnimationsPage.kt`): "Play all" from frame 0, speed slider 0.25–3× (12 steps, label follows), loop switch (on: for ever; off: once), all through the core (`CYLPlaceholderView.animationSpeed`, `animationRepeatCount`, play / stop), seven languages; checked on emulator-5556 with CYLPlaceholderCelebrate.json (loop on keeps playing, 3× changes every capture, loop off plays once and stops). Screenshot: `assets/android-17-api37-x86_64-emulator-playback-controls-5f3f774-20261118-sheet.png`. Refresh demo pages done (2026-11-19, `ab7d05f`, `RefreshExamplesPage.kt` example51–56, shared `PlaybackControls.kt`): Play all (the header refreshes again and the icons restart), speed and loop on the header's and footer's icons through the core (`CYLRefreshIconView.animationSpeed`, `loopsWhilePlaying`, `replayAnimation()`; image frames rebuilt with duration / speed); checked on emulator-5556. Screenshot: `assets/android-17-api37-x86_64-emulator-refresh-playback-controls-ab7d05f-20261119-sheet.png`. |
| CYLTabBarController "Animated icons" page (Lottie tab bar items: "Animation engine: CYLTabBarItemAnimationFactory is linked", "1x", "Play all"), for example the Android ClassifyMenu demo in the owner's 2026-11-13 screenshot | Android, iOS (CYLTabBarController's examples) | TODO: an example of a page this rule applies to; record it in that repository too |
| WeChat Mini Program example: scenario detail, animation detail and configuration pages (`CrossPlatform/wechat-miniprogram-cylplaceholder/example/miniprogram/pages/{scenario-detail,animation-detail,configuration}`, controls in `widgets/playback-controls`): "Play all" from frame 0, speed slider 0.25–3×, loop switch | mini program | Done for these pages (2026-11-17): Play all, loop and speed work live (speed fixed in CYLTabBarController PR #818, `2b09d007`; see MP2 / MP4 in `docs/WeChat-MiniProgram.md`). The refresh icon demo has them too (2026-11-17): `cyl-refresh` takes `icon-speed` / `icon-loop` and `playIconsFromStart()` (core), checked in the simulator ([screenshot](assets/wechat-miniprogram-refresh-icon-controls.jpg)). |
| HarmonyOS example, animation detail, scenario and refresh icon pages (`AnimationDetailPage.ets`, `ScenarioDetailPage.ets`, `RefreshIconDemoPage.ets` under `CrossPlatform/harmonyos-cylplaceholder/entry/src/main/ets/pages`, controls in `common/Playback.ets`): Play all from 0, speed slider 0.25–3x, loop switch, live; Lottie, PAG (driven progress) and GIF (scaled frame durations) | HarmonyOS | Done in code, 2026-11-16; Rive speed and the emulator screenshot TODO (`docs/HarmonyOS.md`, Q7 and Q13) |
| React Native and Flutter examples (CYLTabBarController `react-native-cyltabbar` and `flutter_cyltabbar`, Messages tab, Playback card) | cross-platform | Done (2026-11-18, Android emulator-5556, CYLTabBarController 4cb61807): Play all, speed (2.75×) and loop with Rive tab icons: icons keep playing with loop on and stop after one play with loop off (pixel diffs of the icons, badges excluded). Screenshots: `assets/android-17-api37-x86_64-emulator-playback-controls-5f3f774-20261118-sheet.png`, `assets/android-17-api37-x86_64-emulator-playback-controls-5f3f774-20261118-sheet.png`. Found: in Flutter, turning on "Rive tab icons" jumps back to the first tab (React Native stays on Messages); reported to the CYLTabBarController session. The search examples (`react-native-cylsearch`, `flutter_cylsearch`) show no animations: launch checked only. |
