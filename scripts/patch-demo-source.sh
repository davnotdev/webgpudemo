#!/usr/bin/env bash

set -e

# Applies `source/patches/<demo>/*.patch` to a checked out demo repository.
# DEMO_DIR=<demo repository root>

if [ ! -d "$DEMO_DIR" ]; then
    echo "Error: bad demo dir: $DEMO_DIR"
    exit 1
fi

PATCHES="$(dirname "$(realpath "$0")")/../source/patches/$(basename "$(realpath "$DEMO_DIR")")"

for patch in "$PATCHES"/*.patch; do
    [ -f "$patch" ] || continue
    if git -C "$DEMO_DIR" apply --reverse --check "$patch" 2> /dev/null; then
        echo "already applied: $(basename "$patch")"
    else
        git -C "$DEMO_DIR" apply "$patch"
        echo "applied: $(basename "$patch")"
    fi
done
