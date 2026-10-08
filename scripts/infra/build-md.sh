#!/usr/bin/env bash

set -e

# Usage: build-md.sh <source.md> <destination.html>

sed "s/{{commit}}/$(tr -d '[:space:]' < "$(dirname "$(realpath "$0")")/../../source/GODOT_COMMIT")/g" "$1" |
    pandoc -f gfm -t html -s --metadata pagetitle="WebGPU Demos" -o "$2"
