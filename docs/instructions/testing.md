# Testing scenario (`testing`)

Full text of the `testing` rules (verification, shared emulators, screenshots), moved verbatim from `instructions.md` and `AGENTS.md` on 2026-11-22 (owner's
rule: instruction files by tag, at most 200 lines each). Summaries: [instructions.md](../../instructions.md) and
[AGENTS.md](../../AGENTS.md), heading "Tag: Testing scenario". English only.

## Shared emulators: restart a hung emulator

Several sessions share the Android emulator (`emulator-5556`) and the HarmonyOS emulator (`127.0.0.1:5555`).

- **An emulator that stays hung** (adb / hdc commands time out, the package manager does not answer, the screen does
  not respond) stays hung until it is restarted. **Tell the other sessions first** (`SendMessage`: "taking
  emulator-5556, restarting it"), **then restart it** from the command line. Do not ask the owner whether to restart.
- **An emulator that does not open** (it does not boot, or it is not listed by `adb devices` / `hdc list targets`):
  restarting is the first strategy, before any other fix.
- **How to restart** (Android): `adb -s emulator-5556 emu kill`, wait for `qemu-system-x86_64` to exit, then a cold
  boot: `emulator -avd <name> -port 5556 -no-snapshot-load -no-boot-anim`, and wait for
  `getprop sys.boot_completed` to be `1`. HarmonyOS: close the emulator (`hdc kill`, or end `Emulator.exe` for that
  device only), then start it again with `Emulator -hvd "<device>" ...` (skill `cyl-harmonyos-setup`).
- Restart only the hung emulator; leave the other platform's emulator running.
- **When done, tell the other sessions** ("done, emulator-5556 is free") and stop anything that might hang it again
  (for example a loop of `adb shell dumpsys` checks).

## Screenshots of local builds and CI/CD

These rules cover every screenshot: local simulator or device runs and CI/CD artifacts.

- **When to take them: at key moments.** A key moment is when a `TODO` or a "Linux" note in the docs can be removed,
  when a pull request is ready to merge, or when you judge that the result meets the expectation with no bug and no
  open issue.
- **Show the key detail, not the whole screen.** Crop to the part that proves the point (the refresh header, the
  footer, the badge); take the full screen only when the whole layout is the point.
- **Stitch several details into one image** in a portrait (vertical) sheet, in this order of preference (the owner's
  rule of 2026-11-18, second update, which replaces the same morning's "two columns first"):
  1. one column with several rows, stacked top to bottom;
  2. two columns with several rows, only when the one-column image would be taller than one screen of a common phone
     (19.5:9: height above about 2.17 times the width at phone width);
  3. a single horizontal row, the last resort, with at most three images per row.
  Every stitched image has a header and a footer; see "Header and footer on stitched screenshots" below.
- **Store every screenshot in `docs/`.** Put the image in `docs/assets/` (or the `assets/` folder next to the document)
  and embed it in the document it belongs to; create a document when none fits. Commit the images to the repository;
  never leave them only in a temporary folder or a CI artifact.
- **Update the README when the result meets the expectation.** Put the latest images in the matching README section
  (create the section when there is none), and label each image or group with:
  - the platform: iOS, Android, Flutter, React Native, HarmonyOS or mini program;
  - the environment: the operating system version, the simulator or emulator (device and version), and the platform
    SDK version (iOS SDK / Xcode, Android SDK, Flutter, React Native, HarmonyOS SDK, mini program base library);
  - this repository's version, or the commit with its link;
  - the time the screenshot was taken.
- **Use clear original images**: the simulator's or device's full-resolution capture, cropped but not scaled down or
  recompressed until it blurs.

### Header and footer on stitched screenshots

The owner's rule (2026-11-18). Reference image, which shows the style (the header and the panel captions) but has no
footer yet: `docs/assets/screenshot-style-reference-ios27.2-iphone17pro-xcode27.2-cyltabbarcontroller-dcbfdec6-20261118.png`.

- **Layout.** A portrait sheet: one column with several rows first; two columns with several rows when one column
  would be taller than one phone screen (height above about 2.17 times the width); one row last (see above). Plain
  white background, the same margin around every panel, panels in the order of the test (left to right, then top to
  bottom).
- **A header and a footer on every stitched image.** Both are bands of their own above and below the panels. They never
  overlap, cover or touch any screenshot pixel; nothing is drawn on a screenshot (no labels, arrows or boxes inside
  it). Leave a gap between a band and the panels.
- **Everything in English**, in bold text of one high-contrast color (the reference uses red), large enough to read on
  a phone without zooming.
- **The header holds the key facts**, on one or two lines, in this order, separated by commas:
  1. the platform and the device: "iOS 27.2, iPhone 17 Pro sim" (the simulator or emulator OS version and device; "real
     device" for a phone);
  2. the IDE and its version, for example "Xcode 27.2", "DevEco Studio 6.0.1", "Android Studio 2026.1", "WeChat DevTools 1.06";
  3. the host operating system and its version: "macOS 27.3", "Windows 11 24H2";
  4. the libraries under test and their commits: "CYLTabBarController dcbfdec6 (ef1d0313)";
  5. this repository's branch and commit: "feat/android-refresh-port-followup 579018c";
  6. the date: "2026-11-18";
  7. then, ending the header with a full stop, the test purpose in a few words: "Rive tags at rest (no play)".
- **A caption above each panel**, in its own band (never over the image), naming the step and, when measured, the
  result: "launch, no play", "11 s later, 0 changed pixels", "after Retry", "dark mode".
- **The footer holds the outcome**: the verdict (pass / fail), the measured values, how they were measured (for
  example a pixel diff of two captures 11 s apart), the launch arguments or command, and the file names of the
  original captures in `docs/assets/`.
- **Originals stay too.** Commit the uncropped original captures next to the stitched image in `docs/assets/`, named
  with the platform, OS, device, commit and date. Crop the panels, never scale them down or recompress them until they
  blur.

### Enforcement: every screenshot passes the checker

The owner's rule (2026-11-18), after a screenshot was committed without the header and footer 26 seconds after the rule
above landed (this session pulled the rule in the same command as its commit and never read it; the earlier sheets had
no tool and no check behind them). From now on a screenshot that breaks the rule cannot be committed or merged:

1. **Make every stitched image with the tool.** `python3 scripts/screenshot_sheet.py sheet.json` writes the portrait
   sheet in the order above (one column first, two columns only when one column is taller than 2.17 times its width),
   the bold English header with the seven facts, a caption band above each panel and the footer, all outside the
   panels, and records them in the PNG ("cyl-screenshot-sheet"). A sheet made by another tool (CYLTabBarController's
   `scripts/stitch-screenshots.py`) needs a sidecar `<sheet>.sheet.json` with the same record (header, captions,
   footer, originals).
2. **Name the originals** `<platform>-...-<commit>-<yyyymmdd>.<png|jpg|jpeg>` (platform: ios, android, harmonyos,
   wechat-miniprogram, flutter, react-native), commit them in `docs/assets/`, and list them in the sheet. A single
   screenshot used as evidence is a one-panel sheet too, never a bare capture.
3. **Run the checker before every commit that adds or changes an image:** `python3 scripts/check_screenshots.py`. Both
   scripts need Pillow (`python3 -m pip install pillow`, or a venv where the system Python refuses it). It
   fails on any image in `docs/assets/` that is neither a sheet with a complete record nor an original one uses. It is
   a local check: CI does not run it (removed from the `Docs navigation` job at the owner's request, 2026-11-18), so
   run it yourself before every commit that adds or changes an image.
4. **Never add to `docs/assets/screenshot-legacy.txt`.** It lists the images committed before the rule; replace an
   old image by a conforming sheet instead (keep the old file only while another repository links it).
5. **Re-read the rules a pull changed** (see "Re-read the rules a pull changes") before taking,
   stitching or committing a screenshot: the screenshot rules changed three times on 2026-11-18.

## AGENTS.md: Screenshots: enforced

- **Screenshots are enforced:** every stitched image is made with `python3 scripts/screenshot_sheet.py` (portrait, one
  column first, bold English header / captions / footer outside the panels, recorded in the PNG; another tool adds a
  `<sheet>.sheet.json` sidecar), originals are named `<platform>-...-<commit>-<yyyymmdd>`, and
  `python3 scripts/check_screenshots.py` must pass before every commit that adds an image (a local check; CI does not run it). Never add to
  `docs/assets/screenshot-legacy.txt`. After every pull, read the rule changes it brought
  (`git diff ORIG_HEAD HEAD -- instructions.md AGENTS.md .agents/skills`) before committing; never pull and commit in
  one command. See `instructions.md`, "Enforcement: every screenshot passes the checker" and "Re-read the rules a pull
  changes".

## AGENTS.md: SKILLS

- WeChat DevTools Skills (<https://developers.weixin.qq.com/miniprogram/dev/devtools/Skills.html>): run `wechatide`
  (WeChat DevTools 2.02.2607032 or later) to print the skill folder and install it for the agent (Claude Code:
  a link at `~/.claude/skills/wechatide-skill`). Use it to build, run and screenshot the mini program in
  `CrossPlatform/wechat-miniprogram-cylplaceholder`; authorize the client once with `wechatide auth -c <client>`
  while logged in to DevTools. Status and remaining work: `docs/WeChat-MiniProgram.md`.

## AGENTS.md: Project and verification

- Screenshots (local and CI/CD): take them at key moments (a `TODO` or "Linux" note can go, a pull request can be
  merged, or the result meets the expectation with no bug); crop to the key detail; stitch several details in a portrait
  sheet: one column with several rows first, two columns with several rows only when one column would be taller than
  one phone screen (height above about 2.17 times the width), a single row last (at most three per row); every
  stitched image has an English header (platform and device, simulator OS, IDE version, host OS, library and repository
  commits, date, test purpose), a caption band above each panel and a footer (verdict, measured values, method,
  original file names), none of them overlapping the screenshots (`instructions.md`, "Header and footer on stitched
  screenshots"); store every image in `docs/` (embedded
  in the fitting document, committed); when the result is right, update the README section with the platform, the
  OS / simulator / SDK versions, the commit and the time; use clear original images. See "Screenshots of local
  builds and CI/CD" in `instructions.md`.
