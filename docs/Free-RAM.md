# Free RAM on a development machine

How a developer frees RAM by hand: stop idle dev tools, idle emulators and heavy background apps, then restart only the
emulator the current task needs. This page has one section per operating system.

- [Windows](#windows) (written)
- [macOS](#macos) (not written yet)

## Windows

Script: [`scripts/free-ram-windows.ps1`](../scripts/free-ram-windows.ps1)

### When to run it

Run it only when **no session is debugging on an emulator**. An emulator counts as active while any session installs,
runs or screenshots an app on it. Stopping an active emulator kills that session's test and its Gradle or hvigor build.
If one emulator is in use, keep it with `-KeepEmulator`.

### What it stops

| Group | Processes |
| --- | --- |
| WeChat mini program | WeChat devtools (all processes) |
| HarmonyOS | DevEco Studio, the HarmonyOS emulator, `hdc`, hvigor `node` and `java` daemons |
| Android | Android Studio, Gradle and Kotlin `java` daemons, every emulator not listed in `-KeepEmulator`, then the adb server |
| React Native | watchman, Metro `node`, and whatever listens on the Metro ports 8081, 8097 and 8099 |
| Apps | Obsidian, Chrome, Edge (and WebView2), opencode, minimax, bionic, TextExpander |
| Windows shell | closes every File Explorer window (`explorer.exe` is not killed) |

`node` and `java` are matched by command line (DevEco, hvigor, Metro, Gradle, Kotlin), so Claude Code, git and unrelated
programs keep running.

### Run it by hand

Open PowerShell in the repository root.

1. Preview first. This stops nothing and lists what would be stopped:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/free-ram-windows.ps1 -DryRun
   ```

2. Clean up and boot the emulator the task needs (serial `emulator-5556`, AVD `Medium_Phone_API_37.0`). The script waits
   for boot and sets light mode (`uimode night no`):

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts/free-ram-windows.ps1 -Restart emulator-5556:Medium_Phone_API_37.0
   ```

3. Tell the other sessions the emulators were restarted, so a session that was waiting can start its debugging again.

### Options

| Option | Meaning |
| --- | --- |
| `-DryRun` | List what would be stopped; stop nothing. |
| `-KeepEmulator emulator-5556,emulator-5558` | These serials stay running; every other emulator is stopped. |
| `-Restart serial:Avd[,serial:Avd]` | Boot these emulators after the cleanup. |
| `-Dim 1` | Set the built-in display brightness to 1 %. |
| `-SkipBrowsers` | Keep Chrome and Edge running. |
| `-KeepGradle` | Keep Gradle and Kotlin daemons, for example while a build is running (hvigor daemons are still stopped). |

### Notes

- **Brightness:** only laptop panels accept software brightness. An external monitor answers "Not supported"; dim it
  with the monitor buttons.
- **Emulator paths:** the script uses `ANDROID_HOME`, or `%LOCALAPPDATA%\Android\Sdk` when it is not set. Find AVD names
  with `emulator -list-avds`.
- **Emulator run rules:** stop the app and the emulator after every test; see
  [Testing, emulator run rules](instructions/testing.md).
- **Restart only what you need:** do not start `emulator-5558` or the HarmonyOS emulator unless the task uses it.

## macOS

Not written yet. A macOS developer adds a script `scripts/free-ram-macos.sh` and fills this section in the same format
(what it stops, how to run it, options).
