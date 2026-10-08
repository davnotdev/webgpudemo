#!/usr/bin/env bash

set -e

# PROJECT_DIR=
# BUILDTYPE=<debug|release>
# GODOT_EDITOR=<path to the godot editor binary>
# OUTPUT_DIR=

case $BUILDTYPE in
    debug)
        export GODOT_EXPORT_FLAG="--export-debug"
        ;;
    release)
        export GODOT_EXPORT_FLAG="--export-release"
        ;;
    *)
        echo "Error: unsupported build type: $BUILDTYPE"
        exit 1
        ;;
esac

if [ ! -f "$PROJECT_DIR/project.godot" ]; then
    echo "Error: bad project dir: $PROJECT_DIR"
    exit 1
fi

if [ ! -x "$GODOT_EDITOR" ]; then
    echo "Error: bad godot editor: $GODOT_EDITOR"
    exit 1
fi

GODOT_HOME=$(mktemp -d)
trap 'rm -rf "$GODOT_HOME"' EXIT
export XDG_CONFIG_HOME="$GODOT_HOME/config"
export XDG_DATA_HOME="$GODOT_HOME/data"
export XDG_CACHE_HOME="$GODOT_HOME/cache"

mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR=$(realpath "$OUTPUT_DIR")

"$GODOT_EDITOR" --headless --path "$PROJECT_DIR" --import
"$GODOT_EDITOR" --headless --path "$PROJECT_DIR" $GODOT_EXPORT_FLAG "WebGPU" "$OUTPUT_DIR/index.html"

if [ ! -f "$OUTPUT_DIR/index.html" ]; then
    echo "Error: export produced no output: $PROJECT_DIR"
    exit 1
fi
