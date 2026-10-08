#!/usr/bin/env bash

set -e

# PROJECT_DIR=
# BUILDTYPE=<debug|release>
# TEMPLATE=

case $BUILDTYPE in
    debug)
        export TEMPLATE_DEBUG="$TEMPLATE"
        export TEMPLATE_RELEASE=""
        ;;
    release)
        export TEMPLATE_DEBUG=""
        export TEMPLATE_RELEASE="$TEMPLATE"
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

if [ ! -f "$TEMPLATE" ]; then
    echo "Error: bad template: $TEMPLATE"
    exit 1
fi

[ -n "$TEMPLATE_DEBUG" ] && export TEMPLATE_DEBUG=$(realpath "$TEMPLATE_DEBUG")
[ -n "$TEMPLATE_RELEASE" ] && export TEMPLATE_RELEASE=$(realpath "$TEMPLATE_RELEASE")

PRESETS="$PROJECT_DIR/export_presets.cfg"
PROJECT="$PROJECT_DIR/project.godot"
touch "$PRESETS"

INDEX=$(awk '
    /^\[preset\.[0-9]+\]$/ { section = $0; gsub(/[^0-9]/, "", section); count++ }
    /^name="WebGPU"$/ && section != "" { found = section }
    /^\[/ && !/^\[preset\.[0-9]+\]$/ { section = "" }
    END { print (found != "" ? found : count + 0) }
' "$PRESETS")

awk -v index_="$INDEX" '
    /^\[/ { skip = ($0 == "[preset." index_ "]" || $0 == "[preset." index_ ".options]") }
    skip { next }
    /^$/ { blanks++; next }
    { for (; blanks > 0; blanks--) print ""; print }
' "$PRESETS" > "$PRESETS.tmp"

[ -s "$PRESETS.tmp" ] && echo >> "$PRESETS.tmp"
cat >> "$PRESETS.tmp" <<EOF
[preset.$INDEX]

name="WebGPU"
platform="Web"
runnable=false
dedicated_server=false
custom_features=""
export_filter="all_resources"
include_filter=""
exclude_filter=""
export_path=""
encryption_include_filters=""
encryption_exclude_filters=""
seed=0
encrypt_pck=false
encrypt_directory=false
script_export_mode=2

[preset.$INDEX.options]

custom_template/debug="$TEMPLATE_DEBUG"
custom_template/release="$TEMPLATE_RELEASE"
variant/extensions_support=false
variant/thread_support=false
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=false
html/export_icon=true
html/custom_html_shell=""
html/head_include=""
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
html/experimental_virtual_keyboard=false
progressive_web_app/enabled=false
EOF
mv "$PRESETS.tmp" "$PRESETS"

awk -v method="forward_plus" '
    /^renderer\/rendering_method\.web=/ { next }
    { print }
    $0 == "[rendering]" { print "renderer/rendering_method.web=\"" method "\""; found = 1 }
    END { if (!found) { print ""; print "[rendering]"; print ""; print "renderer/rendering_method.web=\"" method "\"" } }
' "$PROJECT" > "$PROJECT.tmp"
mv "$PROJECT.tmp" "$PROJECT"
