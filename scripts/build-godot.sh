#!/usr/bin/env bash

set -e

# PLATFORM=<linuxbsd|windows|web>
# BUILDTYPE=<debug|release>
# BACKEND=<wgpu-desktop|dawn-desktop|emdawnwebgpu>

case $PLATFORM in
    windows)
        export WEB_BUILD=0
        export SCONS_PLATFORM_FLAGS="platform=windows d3d12=no opengl3=no"
        # mingw
        # export SCONS_PLATFORM_FLAGS="platform=windows use_mingw=yes d3d12=no opengl3=no"
        ;;
    linuxbsd)
        export WEB_BUILD=0
        export SCONS_PLATFORM_FLAGS="platform=linuxbsd use_llvm=yes"
        ;;
    web)
        export WEB_BUILD=1
        export SCONS_PLATFORM_FLAGS="platform=web opengl3=no disable_xr=yes threads=no"
        ;;
    *)
        echo "Error: unsupported platform: $PLATFORM"
        exit 1
        ;;
esac

case $BUILDTYPE in
    debug)
        export SCONS_OPTIMIZE=debug
        ;;
    release)
        export SCONS_OPTIMIZE=speed_trace
        ;;
    *)
        echo "Error: unsupported build type: $BUILDTYPE"
        exit 1
        ;;
esac

if [ "$WEB_BUILD" = 1 ]; then
    export SCONS_PLATFORM_FLAGS="$SCONS_PLATFORM_FLAGS target=template_$BUILDTYPE"
fi

case $BACKEND in
    "")
        export SCONS_BACKEND_FLAG=""
        ;;
    wgpu-desktop|dawn-desktop)
        if [ "$WEB_BUILD" = 1 ]; then
            echo "Error: backend $BACKEND is not supported on platform: $PLATFORM"
            exit 1
        fi
        export SCONS_BACKEND_FLAG="webgpu_backend=$BACKEND"
        ;;
    emdawnwebgpu)
        if [ "$WEB_BUILD" = 0 ]; then
            echo "Error: backend $BACKEND is not supported on platform: $PLATFORM"
            exit 1
        fi
        export SCONS_BACKEND_FLAG="webgpu_backend=$BACKEND"
        ;;
    *)
        echo "Error: unsupported backend: $BACKEND"
        exit 1
        ;;
esac

# For personal builds I recommend:
#   - `linker=mold`, but note the license.
#   - `builtin_*=no` to potentially save on compile time.

scons --max-drift=1 \
    optimize=$SCONS_OPTIMIZE \
    debug_symbols=yes \
    compiledb=yes \
    webgpu=yes \
    $SCONS_BACKEND_FLAG \
    $SCONS_PLATFORM_FLAGS

