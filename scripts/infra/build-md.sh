#!/usr/bin/env bash

set -e

# Usage: build-md.sh <source.md> <destination.html>

SCRIPTS=$(dirname "$(realpath "$0")")

sed "s/{{commit}}/$(tr -d '[:space:]' < "$SCRIPTS/../../source/GODOT_COMMIT")/g" "$1" |
    python3 "$SCRIPTS/build-testing.py" |
    pandoc -f gfm -t html -s --metadata pagetitle="WebGPU Demos" \
        -V maxwidth=none -H "$SCRIPTS/index-header.html" -o "$2"
