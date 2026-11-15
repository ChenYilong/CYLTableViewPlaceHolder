---
name: cyl-harmonyos-setup
description: Prepare DevEco Studio and the HarmonyOS emulator for CrossPlatform/harmonyos-cylplaceholder - IDE setup, emulator prerequisites, and the China region setting in country.region.xml that the emulator needs.
---

# HarmonyOS IDE and emulator setup

Use this skill before building, running or screenshotting the HarmonyOS port
(`CrossPlatform/harmonyos-cylplaceholder`), and whenever DevEco Studio's Device Manager shows no emulator images,
refuses to download one, or the emulator will not start. The project rules are in `instructions.md`, "HarmonyOS";
the status and score are in `docs/HarmonyOS.md`.

## 1. IDE preparation

- Install **DevEco Studio 6.0.1.251** (it bundles hvigor, ohpm, Node and the emulator) and the **HarmonyOS SDK
  6.0.1.112 (API 21)**. On Windows the SDK lives in `%LOCALAPPDATA%\Huawei\Sdk`, emulator images in
  `%LOCALAPPDATA%\Huawei\Sdk\system-image`, and deployed emulators in `%LOCALAPPDATA%\Huawei\Emulator\deployed`.
- Sign in to a **Huawei developer account** in DevEco Studio (needed for emulator images and automatic signing).
- Open `CrossPlatform/harmonyos-cylplaceholder`, run ohpm install, and set up automatic signing (File > Project
  Structure > Signing Configs) for the example HAP `entry`. Never commit signing material.
- hvigor refuses non-ASCII project paths (this checkout sits under `文档`), so build with
  `CrossPlatform/harmonyos-cylplaceholder/scripts/build.sh`, which mirrors the project to an ASCII directory.

## 2. Emulator prerequisites

All of these must hold, or Device Manager lists nothing or the emulator fails to boot:

1. **Region set to China** in DevEco Studio's `country.region.xml` (section 3). Outside the China region the
   emulator is not offered, even when the machine is physically elsewhere (for example New Zealand).
2. **Hardware virtualization on:** VT-x / AMD-V enabled in the BIOS / UEFI.
3. **Windows features on:** Hyper-V and Windows Hypervisor Platform (Control Panel > Turn Windows features on or
   off), then reboot. Check in PowerShell: `(Get-CimInstance Win32_ComputerSystem).HypervisorPresent` must be
   `True` (`VirtualizationFirmwareEnabled` reads `False` once a hypervisor is running; that is normal).
4. **Resources:** 16 GB RAM or more recommended, and several GB of free disk space for an image on the SDK drive.
5. **A listed device type:** `compatibleSdkVersion` stays at 5.1.0(18) so Device Manager offers phone emulator
   images; do not raise it without checking the Device Manager list.
6. **Signed in** to the Huawei account, with the HarmonyOS 6.0.1 phone image downloaded in Device Manager.

## 3. Region: set `country.region.xml` to China

The region file is in DevEco Studio's options folder:

- Windows: `%APPDATA%\Huawei\DevEcoStudio6.0\options\country.region.xml`
- macOS: `~/Library/Application Support/Huawei/DevEcoStudio6.0/options/country.region.xml`

Steps:

1. Quit DevEco Studio (it rewrites the file on exit).
2. Back up the current file (for example `country.region.xml.bak-NZ` when the region was New Zealand).
3. Change the region to China (`CN`):

   ```xml
   <application>
       <component name="CountryRegionSetting">
           <countryregion name="CN"/>
       </component>
   </application>
   ```

4. **Make sure the region file now says China:** it must contain `<countryregion name="CN"/>`. Check before
   restarting DevEco Studio:

   ```sh
   grep -n 'countryregion name="CN"' "$APPDATA/Huawei/DevEcoStudio6.0/options/country.region.xml"
   ```

   ```powershell
   Select-String -Path "$env:APPDATA\Huawei\DevEcoStudio6.0\options\country.region.xml" -Pattern 'countryregion name="CN"'
   ```

   No match means the change did not stick: repeat with DevEco Studio closed.
5. Start DevEco Studio, open Device Manager, and download / start the HarmonyOS 6.0.1 phone emulator.

The region is first chosen in the IDE at first launch; editing the file is the reliable fix once the IDE has picked
another region (NZ on the owner's machine).

## 4. After setup

- Build with `scripts/build.sh`, install the `entry` HAP on the emulator, and follow `instructions.md`
  ("Screenshots of local builds and CI/CD") when recording results.
- Record emulator results in `docs/HarmonyOS.md`; pages verified only by compiling say "no emulator".
