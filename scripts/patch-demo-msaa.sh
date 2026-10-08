#!/usr/bin/env bash

# NOTE: This is a temp patch for before msaa is implemented.

set -e

# PROJECT_DIR=

if [ ! -f "$PROJECT_DIR/project.godot" ]; then
    echo "Error: bad project dir: $PROJECT_DIR"
    exit 1
fi

sed -E -i '/^anti_aliasing\/quality\/msaa_(2d|3d)(\.[a-z_]+)?=/d' "$PROJECT_DIR/project.godot"

find "$PROJECT_DIR" -path "$PROJECT_DIR/.godot" -prune -o \( -name '*.tscn' -o -name '*.tres' \) -print0 |
    xargs -0 -r sed -E -i '/^msaa_(2d|3d) = /d'
