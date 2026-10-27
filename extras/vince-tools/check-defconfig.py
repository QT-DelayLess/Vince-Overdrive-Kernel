#!/usr/bin/env python3
"""Inspect selected options in the Vince kernel defconfig (read-only)."""

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONFIG_DIRS = [ROOT / "arch/arm64/configs", ROOT / "arch/arm/configs"]
KEYS = [
    "CONFIG_CPU_FREQ",
    "CONFIG_CPU_FREQ_GOV_INTERACTIVE",
    "CONFIG_CPU_FREQ_GOV_SCHEDUTIL",
    "CONFIG_CPU_FREQ_GOV_PERFORMANCE",
    "CONFIG_CPU_BOOST",
    "CONFIG_SCHED_WALT",
    "CONFIG_THERMAL",
    "CONFIG_HZ",
]


def find_config():
    for folder in CONFIG_DIRS:
        if folder.is_dir():
            files = sorted(folder.rglob("*vince*defconfig"))
            if files:
                return files[0]
    return None


def main():
    path = find_config()
    if path is None:
        print("Vince defconfig not found. Run this script inside the forked kernel repository.")
        return 1

    settings = {}
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if line.startswith("CONFIG_") and "=" in line:
            key, value = line.split("=", 1)
            settings[key] = value
        elif line.startswith("# CONFIG_") and line.endswith(" is not set"):
            settings[line[2:].split(" is not set")[0]] = "n"

    print(f"Defconfig: {path.relative_to(ROOT)}")
    print("Selected settings (read-only):")
    for key in KEYS:
        print(f"  {key} = {settings.get(key, '(not explicitly set)')}")
    print("Note: final compiled .config may differ after Kconfig resolution.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
