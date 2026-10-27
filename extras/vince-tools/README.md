# Redmi 5 Plus (vince) — Diagnostic Extras

Small, **read-only** helpers for experimenting with Android kernel configurations and collecting basic device information.

This directory is an independent addition to the original [Genom Project vince 4.9 kernel source](https://github.com/Genom-Project/android_kernel_xiaomi_vince-4.9). It does **not** modify the kernel, provide a boot image, or claim Android ROM compatibility.

## 1. Collect live CPU information (Windows)

Requirements: Android Platform Tools (`adb`), PowerShell 5.1+ and USB debugging authorized on **one** Android device.

From the root of this kernel repository:

```powershell
adb devices
powershell -ExecutionPolicy Bypass -File .\extras\vince-tools\vince-diagnostics.ps1
```

The script prints the device codename, Android/kernel versions, and available CPU frequency/governor readings. Some ROMs restrict access to sysfs, so an `n/a` reading does not necessarily indicate a failure.

**Privacy:** Review any diagnostic output before sharing it publicly. No files are uploaded or transmitted by this script.

## 2. Inspect kernel config options (Python)

Run from the repo root (Python 3.8+):

```bash
python extras/vince-tools/check-defconfig.py
```

The script looks for a `*vince*defconfig` under `arch/arm64/configs` or `arch/arm/configs` and prints several CPU frequency, scheduler and thermal-related settings. If multiple files exist, it selects the first alphabetical match. This is a quick source inspection, not a build-time config validator.

## Scope

- No flashing or root access.
- No voltage, clock or governor changes.
- No claim of higher FPS, lower temperatures, or improved battery life.

**Upstream credits:** [Genom Project](https://github.com/Genom-Project/android_kernel_xiaomi_vince-4.9) and all original kernel contributors. Existing upstream licensing remains unchanged; additions are supplied as supplementary scripts and documentation.
