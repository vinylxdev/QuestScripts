#!/usr/bin/env bash
set -euo pipefail

if (( $# < 1 || $# > 2 )); then
    printf 'Usage: %s on|off [IP:port]\n' "$0" >&2
    exit 2
fi

case "$1" in
    on) action='com.oculus.vrpowermanager.automation_disable' ;;
    off) action='com.oculus.vrpowermanager.prox_close' ;;
    *)
        printf 'Usage: %s on|off [IP:port]\n' "$0" >&2
        exit 2
        ;;
esac

target=${2-}
if (( $# == 2 )) && [[ ! "$target" =~ ^[^[:space:]]+:[0-9]+$ ]]; then
    printf 'Wireless target must be IP:port, for example 192.168.1.50:5555.\n' >&2
    exit 2
fi

if ! command -v adb >/dev/null 2>&1; then
    printf 'ADB is missing. Install Android SDK Platform Tools and try again.\n' >&2
    exit 1
fi

# Use USB by default, or connect to and select the requested wireless headset.
adb_args=(-d)
if [[ -n "$target" ]]; then
    if ! adb connect "$target"; then
        printf 'Could not connect to %s. Enable wireless ADB over USB first and check the headset IP and network.\n' "$target" >&2
        exit 1
    fi
    adb_args=(-s "$target")
fi

if ! adb "${adb_args[@]}" shell am broadcast -a "$action"; then
    printf '\nCould not set the proximity sensor to %s.\n' "$1" >&2
    if [[ -n "$target" ]]; then
        printf 'Enable wireless ADB over USB first, check the headset IP, and make sure the PC and headset are on the same local network.\n' >&2
        printf 'Accept any debugging authorization prompt in the headset.\n' >&2
    else
        printf 'Connect your headset over USB, enable Developer Mode, and accept "Allow USB debugging" in the headset.\n' >&2
        printf 'If multiple USB ADB devices are connected, disconnect the others and retry.\n' >&2
    fi
    exit 1
fi

printf '\nProximity sensor %s request sent.\n' "$1"
if [[ "$1" == off ]]; then
    printf 'Change is not permanent and this script will need to be run again after headset reboot.\n'
fi
