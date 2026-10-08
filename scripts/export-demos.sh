#!/usr/bin/env bash

set -e

# Usage: export-demos.sh <project dir>...
# BUILDTYPE=<debug|release>
# TEMPLATE=<path to godot.web.template_*.wasm32.nothreads.zip>
# GODOT_EDITOR=<path to the godot editor binary>
# OUTPUT_DIR=
# LOG_DIR=
# JOBS=<parallel exports, defaults to nproc>
# TIMEOUT=<per project timeout, defaults to 30m>

if [ $# -eq 0 ]; then
    echo "Error: no projects given"
    exit 1
fi

for var in BUILDTYPE TEMPLATE GODOT_EDITOR OUTPUT_DIR LOG_DIR; do
    if [ -z "${!var}" ]; then
        echo "Error: $var is not set"
        exit 1
    fi
done

mkdir -p "$OUTPUT_DIR" "$LOG_DIR"
export SCRIPTS=$(dirname "$(realpath "$0")")
export TEMPLATE=$(realpath "$TEMPLATE")
export GODOT_EDITOR=$(realpath "$GODOT_EDITOR")
export OUTPUT_DIR=$(realpath "$OUTPUT_DIR")
export LOG_DIR=$(realpath "$LOG_DIR")
export TIMEOUT=${TIMEOUT:-30m}
export BUILDTYPE
: > "$LOG_DIR/failed"

export_one() {
    local dir=$1
    local log="$LOG_DIR/${dir//\//_}.log"

    if PROJECT_DIR="$dir" bash "$SCRIPTS/patch-demo-msaa.sh" > "$log" 2>&1 &&
        PROJECT_DIR="$dir" bash "$SCRIPTS/patch-demo-exports.sh" >> "$log" 2>&1 &&
        PROJECT_DIR="$dir" OUTPUT_DIR="$OUTPUT_DIR/$dir" timeout --kill-after=1m "$TIMEOUT" \
            bash "$SCRIPTS/export-project.sh" >> "$log" 2>&1; then
        echo "ok: $dir"
    else
        echo "failed: $dir"
        echo "$dir" >> "$LOG_DIR/failed"
    fi
}
export -f export_one

printf '%s\0' "$@" | xargs -0 -P "${JOBS:-$(nproc)}" -I{} bash -c 'export_one "$1"' _ {}

if [ -s "$LOG_DIR/failed" ]; then
    while read -r dir; do
        echo "===== $dir"
        tail -n 50 "$LOG_DIR/${dir//\//_}.log"
    done < "$LOG_DIR/failed"
    echo "Error: $(wc -l < "$LOG_DIR/failed") of $# projects failed"
    exit 1
fi
