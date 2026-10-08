#!/usr/bin/env bash

set -e

# Fetches and builds Godot and its dependencies into local/.
# Extra arguments are passed to scons.
#
# TODO: Allow building with MinGW and basic cross compiling.
#
# PLATFORM=<linuxbsd|windows|web>
# BUILDTYPE=<debug|release>
# BACKEND=<wgpu-desktop|dawn-desktop|emdawnwebgpu>
# RUSTUP_TOOLCHAIN=<defaults to 1.91>
# RUST_NIGHTLY=<defaults to nightly-2026-10-01>
# FORCE=<1 to rebuild a finished build>

case $PLATFORM in
    linuxbsd|windows|web)
        ;;
    *)
        echo "Error: unsupported platform: $PLATFORM"
        exit 1
        ;;
esac

case $BUILDTYPE in
    debug|release)
        ;;
    *)
        echo "Error: unsupported build type: $BUILDTYPE"
        exit 1
        ;;
esac

case $PLATFORM/$BACKEND in
    linuxbsd/wgpu-desktop|windows/wgpu-desktop)
        export BACKEND_DEP=wgpu-native
        ;;
    linuxbsd/dawn-desktop|windows/dawn-desktop)
        export BACKEND_DEP=dawn
        ;;
    web/emdawnwebgpu)
        export BACKEND_DEP=""
        ;;
    *)
        echo "Error: backend $BACKEND is not supported on platform: $PLATFORM"
        exit 1
        ;;
esac

export PLATFORM BUILDTYPE BACKEND
export RUSTUP_TOOLCHAIN=${RUSTUP_TOOLCHAIN:-1.91}
export RUST_NIGHTLY=${RUST_NIGHTLY:-nightly-2026-10-01}

check_sha() {
    if ! [[ $2 =~ ^[0-9a-f]{40}$ ]]; then
        echo "Error: bad $1 commit: $2" >&2
        exit 1
    fi
}

ROOT=$(realpath "$(dirname "$(realpath "$0")")/..")
SCRIPTS="$ROOT/scripts"
SOURCES="$ROOT/local/sources"
GODOT_COMMIT=$(tr -d '[:space:]' < "$ROOT/source/GODOT_COMMIT")
check_sha godot "$GODOT_COMMIT"
BUILD="$ROOT/local/godot-$PLATFORM-$BUILDTYPE-$BACKEND-${GODOT_COMMIT:0:10}"
GODOT="$BUILD/godot"

if [ -f "$BUILD/.done" ] && [ "$FORCE" != 1 ]; then
    echo "Warning: $BUILD already exists, set FORCE=1 to rebuild it"
    exit 0
fi
rm -f "$BUILD/.done"

fetch() {
    local dir=$1 url=$2 sha=$3
    if [ "$(git -C "$dir" rev-parse HEAD 2>/dev/null)" = "$sha" ]; then
        return
    fi
    echo "fetching: $url $sha"
    mkdir -p "$dir"
    git -C "$dir" init -q
    git -C "$dir" fetch -q --depth 1 "$url" "$sha"
    git -C "$dir" checkout -q --force FETCH_HEAD
    if [ -f "$dir/.gitmodules" ] && [ "$4" = submodules ]; then
        git -C "$dir" submodule update -q --init --recursive --depth 1
    fi
}

fetch "$GODOT" https://github.com/davnotdev/godot "$GODOT_COMMIT"

resolve() {
    local sha
    sha=$(tr -d '[:space:]' < "$GODOT/thirdparty/$4/TAG" 2>/dev/null) || true
    if [ -z "$sha" ]; then
        echo "Warning: no thirdparty/$4/TAG, using $3 of $2" >&2
        sha=$(git ls-remote "$2" "$3" | cut -f1)
    fi
    check_sha "$1" "$sha"
    echo "$sha"
}

build_dep() {
    local dep=$1 url=$2 ref=$3 out=$4
    local sha
    sha=$(resolve "$dep" "$url" "$ref" "$out")
    echo "$dep: $sha"

    if [ "$dep" = dawn ]; then
        fetch "$SOURCES/$dep" "$url" "$sha"
    else
        fetch "$SOURCES/$dep" "$url" "$sha" submodules
    fi
    mkdir -p "$GODOT/thirdparty/$out"
    (cd "$SOURCES/$dep" && GODOT_SOURCE="$GODOT" bash "$SCRIPTS/build-$dep.sh")
}

build_dep naga https://github.com/davnotdev/naga-native refs/heads/naga-patches-wgpu-29 naga-native
build_dep spirv-webgpu-transform https://github.com/davnotdev/spirv-webgpu-transform HEAD spirv-webgpu-transform
case $BACKEND_DEP in
    wgpu-native)
        build_dep wgpu-native https://github.com/davnotdev/wgpu-native refs/heads/godot-webgpu wgpu
        ;;
    dawn)
        build_dep dawn https://dawn.googlesource.com/dawn refs/heads/main dawn
        ;;
esac

(cd "$GODOT" && bash "$SCRIPTS/build-godot.sh" "$@")

touch "$BUILD/.done"
echo "built: $GODOT/bin"
