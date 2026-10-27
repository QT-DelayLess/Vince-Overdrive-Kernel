# Redmi 5 Plus (vince) read-only ADB diagnostic report.
# Runs in Windows PowerShell 5.1+ or PowerShell 7+.
# Requires adb in PATH and a single authorized Android device.

# Continue on inaccessible sysfs nodes; report 'n/a' instead of aborting.
$ErrorActionPreference = 'Continue'

if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    Write-Error 'adb was not found. Install Android Platform Tools and add adb to PATH.'
    exit 1
}

$connected = @(& adb devices | Select-Object -Skip 1 | Where-Object { $_ -match '\sdevice\s*$' })
if ($connected.Count -ne 1) {
    Write-Error "Expected one authorized ADB device; found $($connected.Count). Check USB debugging and authorization."
    exit 1
}

function Read-Property([string]$name) {
    $result = & adb shell getprop $name 2>$null
    return ($result | Out-String).Trim()
}

function Read-SysFile([string]$path) {
    # This tool reads information only; it does not write to sysfs.
    $result = & adb shell cat $path 2>$null
    if ($LASTEXITCODE -ne 0) { return 'n/a' }
    $value = ($result | Out-String).Trim()
    if (-not $value) { return 'n/a' }
    return $value
}

function To-MHz([string]$khz) {
    if ($khz -match '^\d+$') { return ('{0:N0} MHz' -f ([int64]$khz / 1000)) }
    return $khz
}

$device = Read-Property 'ro.product.device'
$model = Read-Property 'ro.product.model'
$android = Read-Property 'ro.build.version.release'
$kernel = (& adb shell uname -r | Out-String).Trim()

Write-Output '=== Redmi 5 Plus / Vince Diagnostics ==='
Write-Output "Device codename : $device"
Write-Output "Model           : $model"
Write-Output "Android version : $android"
Write-Output "Kernel version  : $kernel"
if ($device -ne 'vince') {
    Write-Warning 'Device codename is not vince. Results may still be useful, but hardware differs.'
}

Write-Output ''
Write-Output 'CPU frequency and governors (reported per core, if exposed by ROM):'
for ($cpu = 0; $cpu -lt 8; $cpu++) {
    $base = "/sys/devices/system/cpu/cpu$cpu/cpufreq"
    $current = Read-SysFile "$base/scaling_cur_freq"
    $min = Read-SysFile "$base/scaling_min_freq"
    $max = Read-SysFile "$base/scaling_max_freq"
    $governor = Read-SysFile "$base/scaling_governor"
    Write-Output ("CPU{0}: {1} | min {2} | max {3} | governor {4}" -f $cpu, (To-MHz $current), (To-MHz $min), (To-MHz $max), $governor)
}
Write-Output ''
Write-Output 'Read-only report completed. No frequency, voltage or kernel setting was modified.'
