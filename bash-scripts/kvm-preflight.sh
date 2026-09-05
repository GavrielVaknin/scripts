#!/usr/bin/env  bash
#kvm-preflight.sh - check whether this Ubuntu host can run KVM guests.
# Read-only: makes no changes. Exit 0 = ready, 1 = blocking problem, 2 = bad usage.

set -euo pipefail
