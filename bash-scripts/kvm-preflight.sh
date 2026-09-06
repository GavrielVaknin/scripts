#!/usr/bin/env  bash
# kvm-preflight.sh - check whether this Ubuntu host can run KVM guests.
# Read-only: makes no changes. Exit 0 = ready, 1 = blocking problem, 2 = bad usage.

set -euo pipefail

readonly PACKAGES=(quemu-system-x86 libvirt-daemon-system libvirt-clients virtins)
readonly MIN_MEM_MB=2048
readonly MIN_DISK_GB=20
readonly IMAGE_DIR=/var/lib/libvirt/images

#USER is not exported under cron or plain `su`; ask the kernel as a fallback.
readonly USER_NAME=${USER:-$(id -un)}

fails=0
warns=0

if [[ -t 1 ]]; then
    readonly RED=$'\e[31m' YELLOW=$'\e[33m' GREEN=$'\e[32m' RESET=$'\e[0m'
else
    readonly RED='' YELLOW='' GREEN='' RESEST=''
fi

pass() { printf '%s[ OK ]%s %s\n' "$GREEN" "$RESET" "$1"; }
# $((n + 1)) not ((n++)): the latter returns the pre-increment value as its
# exit status, so the first warning would trip set -e and kill the script.
warn() { printf '%s[WARN]%s %s\n' "$YELLOW" "$RESEST" "$1"; warns=$((warns + 1)); }
fail() { printf '%s[FAIL]%s %s\n' "$RED" "$RESET" "$1"; fails=$((fails +1)); }

# Exact match against a space-padded list. grep -w is wrong here: it treats
# "-" as a word boundary, so "libvirt" would match inside "libvirt-qemu".
has_group() {
    [[ " $2 " == *" $1 "* ]]
}

