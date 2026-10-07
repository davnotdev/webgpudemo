#!/usr/bin/env bash

set -e

# GODOT_SOURCE=
# PLATFORM=<linuxbsd|windows|web>
# BUILDTYPE=<debug|release>

case $PLATFORM in
    windows)
        export TARGET_TRIPLE=x86_64-pc-windows-gnu
        export BUILD_DIR=target/x86_64-pc-windows-gnu/
        export CARGO_WEB_BUILD_FLAGS=""
        export CARGO_TOOLCHAIN=""
        ;;
    linuxbsd)
        export TARGET_TRIPLE=x86_64-unknown-linux-gnu
        export BUILD_DIR=target/x86_64-unknown-linux-gnu/
        export CARGO_WEB_BUILD_FLAGS=""
        export CARGO_TOOLCHAIN=""
        ;;
    web)
        export TARGET_TRIPLE=wasm32-unknown-emscripten
        export BUILD_DIR=target/wasm32-unknown-emscripten
        export RUSTFLAGS="$RUSTFLAGS -C panic=abort"
        export CARGO_WEB_BUILD_FLAGS="-Zbuild-std=panic_abort,core,alloc,std"
        export CARGO_TOOLCHAIN="+nightly"
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

cd ffi/
cargo $CARGO_TOOLCHAIN b --target $TARGET_TRIPLE $CARGO_BUILD_FLAGS $CARGO_WEB_BUILD_FLAGS
cd ..
cp "$BUILD_DIR/$BUILDTYPE/libspirv_webgpu_transform_ffi.a" "$GODOT_SOURCE/thirdparty/spirv-webgpu-transform/"
