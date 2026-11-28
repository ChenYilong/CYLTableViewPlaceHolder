<#
.SYNOPSIS
  Frees RAM on a Windows development machine by stopping dev tools, idle emulators and heavy background apps.
  Documentation: docs/Free-RAM.md (Windows section).

.DESCRIPTION
  Stops: WeChat devtools, DevEco Studio (+ HarmonyOS emulator, hdc, hvigor), Android Studio, Gradle/Kotlin daemons,
  Android emulators that no session is using, watchman, Obsidian, Chrome, Edge, opencode, minimax, bionic,
  TextExpander, and closes every File Explorer window (explorer.exe itself is NOT killed).
  It never stops claude / Claude Code, git, or unrelated node/java processes: node and java are matched by command line.

  Run it ONLY when no session is debugging on an emulator. Use -KeepEmulator for an emulator a session is using.

.PARAMETER DryRun         List what would be stopped; stop nothing.
.PARAMETER KeepEmulator   Serials (for example emulator-5556) that stay running. All other Android emulators are stopped.
.PARAMETER Restart        Serial:AvdName pairs to boot after the cleanup, for example emulator-5556:Medium_Phone_API_37.0.
                          A restarted emulator is set to light mode (uimode night no).
.PARAMETER Dim            Try to set the built-in display brightness to this percent (default: leave unchanged).
                          Only laptop panels support it; external monitors return "Not supported" (use the monitor buttons).
.PARAMETER SkipBrowsers   Keep Chrome and Edge running.
.PARAMETER KeepGradle     Keep Gradle/Kotlin java daemons (use while a build is running; stop idle ones with `gradlew --stop`-like tools by hand).

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts/free-ram-windows.ps1 -DryRun
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File scripts/free-ram-windows.ps1 -Restart emulator-5556:Medium_Phone_API_37.0 -Dim 1
#>
[CmdletBinding()]
param(
  [switch]$DryRun,
  [string[]]$KeepEmulator = @(),
  [string[]]$Restart = @(),
  [int]$Dim = -1,
  [switch]$SkipBrowsers,
  [switch]$KeepGradle
)

$ErrorActionPreference = 'Continue'
# `powershell -File` passes "a,b" as one string: split the list parameters on commas.
$KeepEmulator = @($KeepEmulator | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$Restart = @($Restart | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$sdk = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { Join-Path $env:LOCALAPPDATA 'Android\Sdk' }
$adb = Join-Path $sdk 'platform-tools\adb.exe'
$emulatorExe = Join-Path $sdk 'emulator\emulator.exe'

function Stop-Matching([string]$label, [scriptblock]$filter) {
  $found = @(Get-Process -ErrorAction SilentlyContinue | Where-Object $filter)
  if (-not $found) { return }
  foreach ($p in $found) {
    if ($DryRun) { "[dry-run] would stop $label : $($p.ProcessName) ($($p.Id))" }
    else { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue }
  }
  if (-not $DryRun) { "stopped $label ($($found.Count) process(es))" }
}

function Get-CommandLine([int]$id) {
  (Get-CimInstance Win32_Process -Filter "ProcessId=$id" -ErrorAction SilentlyContinue).CommandLine
}

# 1. Apps by name.
Stop-Matching 'WeChat devtools' { $_.ProcessName -match 'wechat|微信开发者工具|wechatdevtools' }
Stop-Matching 'DevEco Studio and the HarmonyOS emulator' { $_.ProcessName -match '^(devecostudio64|Emulator|hdc)$' }
Stop-Matching 'Android Studio' { $_.ProcessName -match '^studio(64)?$' }
Stop-Matching 'watchman' { $_.ProcessName -match 'watchman' }
Stop-Matching 'Obsidian' { $_.ProcessName -match '^obsidian$' }
Stop-Matching 'opencode / minimax / bionic / TextExpander' { $_.ProcessName -match 'opencode|minimax|bionic|textexpander' }
if (-not $SkipBrowsers) { Stop-Matching 'Chrome and Edge' { $_.ProcessName -match '^(chrome|msedge|msedgewebview2)$' } }

# 2. node and java: only the dev-tool daemons (matched by command line), never Claude Code or unrelated tools.
Stop-Matching 'DevEco/hvigor node' { $_.ProcessName -eq 'node' -and ((Get-CommandLine $_.Id) -match 'DevEco|hvigor|metro|react-native') }
if (-not $KeepGradle) { Stop-Matching 'Gradle/Kotlin/hvigor java daemons' { $_.ProcessName -eq 'java' -and ((Get-CommandLine $_.Id) -match 'gradle|kotlin|hvigor') } } else { 'kept Gradle/Kotlin daemons (-KeepGradle)'; Stop-Matching 'hvigor java daemons' { $_.ProcessName -eq 'java' -and ((Get-CommandLine $_.Id) -match 'hvigor') } }

# Metro bundler (react-native start): kill the listeners of its ports.
foreach ($port in 8081, 8097, 8099) {
  foreach ($c in @(Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue)) {
    if ($DryRun) { "[dry-run] would stop Metro listener on port $port (pid $($c.OwningProcess))" }
    else { Stop-Process -Id $c.OwningProcess -Force -ErrorAction SilentlyContinue; "stopped Metro listener on port $port" }
  }
}

# 3. Android emulators: stop every serial that is not in -KeepEmulator.
if (Test-Path $adb) {
  $serials = @(& $adb devices 2>$null | Select-String '^(emulator-\d+)\s+device' | ForEach-Object { $_.Matches[0].Groups[1].Value })
  foreach ($s in $serials) {
    if ($KeepEmulator -contains $s) { "kept $s (in -KeepEmulator)"; continue }
    if ($DryRun) { "[dry-run] would kill $s" } else { & $adb -s $s emu kill 2>$null | Out-Null; "killed $s" }
  }
  if (-not $DryRun) {
    Start-Sleep -Seconds 3
    # Leftovers of an emulator that did not exit (skipped when an emulator was kept).
    if ($KeepEmulator.Count -eq 0) { Stop-Matching 'emulator leftovers' { $_.ProcessName -match '^(emulator|emulator-crash-service|qemu-system-.*)$' }; & $adb kill-server 2>$null | Out-Null }
  }
}

# 4. Close every File Explorer window (the shell itself keeps running).
if ($DryRun) { "[dry-run] would close all File Explorer windows" }
else {
  try { $shell = New-Object -ComObject Shell.Application; foreach ($w in @($shell.Windows())) { try { $w.Quit() } catch {} }; "closed File Explorer windows" } catch {}
}

# 5. Optional: dim the built-in display (laptop panels only).
if ($Dim -ge 0 -and -not $DryRun) {
  try {
    Get-CimInstance -Namespace root/WMI -ClassName WmiMonitorBrightnessMethods -ErrorAction Stop |
      Invoke-CimMethod -MethodName WmiSetBrightness -Arguments @{ Timeout = 0; Brightness = [Math]::Max(0, [Math]::Min(100, $Dim)) } | Out-Null
    "brightness set to $Dim%"
  } catch { "brightness not changed: this display does not support software control (use the monitor buttons)" }
}

# 6. Restart the emulators this task needs, then wait for boot and force light mode.
foreach ($pair in $Restart) {
  $serial, $avd = $pair -split ':', 2
  if (-not $avd) { "skip '$pair': use serial:AvdName"; continue }
  if ($DryRun) { "[dry-run] would start $avd as $serial"; continue }
  $port = ($serial -replace 'emulator-', '')
  Start-Process -FilePath $emulatorExe -ArgumentList '-avd', $avd, '-port', $port, '-no-snapshot-load', '-no-boot-anim' -WindowStyle Minimized
  & $adb start-server 2>$null | Out-Null
  $booted = $false
  for ($i = 0; $i -lt 60; $i++) {
    Start-Sleep -Seconds 5
    if (((& $adb -s $serial shell getprop sys.boot_completed 2>$null) -join '').Trim() -eq '1') { $booted = $true; break }
  }
  if ($booted) { & $adb -s $serial shell cmd uimode night no | Out-Null; "$serial booted ($avd), light mode" } else { "$serial did not finish booting in 5 minutes" }
}

"Done. Tell the other sessions the emulators were restarted (see docs/Free-RAM.md)."
