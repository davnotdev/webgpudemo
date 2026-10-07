#!/usr/bin/env bash

set -e

# GODOT_SOURCE=
# PLATFORM=<linuxbsd|windows>
# BUILDTYPE=<debug|release>

case $PLATFORM in
    windows)
        export TARGET_TRIPLE=x86_64-pc-windows-gnu
        export BUILD_DIR=target/x86_64-pc-windows-gnu/
        ;;
    linuxbsd)
        export TARGET_TRIPLE=x86_64-unknown-linux-gnu
        export BUILD_DIR=target/x86_64-unknown-linux-gnu/
        ;;
    *)
        echo "Error: unsupported platform: $PLATFORM"
        exit 1
        ;;
esac

case $BUILDTYPE in
    debug)
        export CARGO_BUILD_FLAGS=""
        ;;
    release)
        export CARGO_BUILD_FLAGS="--release"
        ;;
    *)
        echo "Error: unsupported build type: $BUILDTYPE"
        exit 1
        ;;
esac

if [ ! -d "$GODOT_SOURCE" ]; then
    echo "Error: bad source dir: $GODOT_SOURCE"
    exit 1
fi

cargo b --target $TARGET_TRIPLE $CARGO_BUILD_FLAGS
cp "$BUILD_DIR/$BUILDTYPE/libnaga_native.a" "$GODOT_SOURCE/thirdparty/naga-native/"
