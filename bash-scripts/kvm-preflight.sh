#!/usr/bin/env  bash
#kvm-preflight.sh - check whether this Ubuntu host can run KVM guests.
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
    