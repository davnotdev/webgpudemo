#!/usr/bin/env bash

set -e

# PLATFORM=<linuxbsd|windows|web>
# BUILDTYPE=<debug|release>
# BACKEND=<wgpu-desktop|dawn-desktop|emdawnwebgpu>
# RENDERING_METHOD=<mobile|forward_plus, web only, optional>

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

export SCONS_DEBUG_SYMBOLS=yes

if [ "$WEB_BUILD" = 1 ]; then
    export SCONS_PLATFORM_FLAGS="$SCONS_PLATFORM_FLAGS target=template_$BUILDTYPE"
    if [ "$BUILDTYPE" = release ]; then
        export SCONS_DEBUG_SYMBOLS=no
    fi
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

if [ "$WEB_BUILD" = 0 ] && [ -n "$RENDERING_METHOD" ]; then
    echo "Warning: ignoring RENDERING_METHOD=$RENDERING_METHOD on platform: $PLATFORM"
    RENDERING_METHOD=""
fi

case $RENDERING_METHOD in
    "")
        export SCONS_RENDERING_METHOD_FLAG=""
        ;;
    mobile|forward_plus)
        export SCONS_RENDERING_METHOD_FLAG="webgpu_force_rendering_method=$RENDERING_METHOD"
        ;;
    *)
        echo "Error: unsupported rendering method: $RENDERING_METHOD"
        exit 1
        ;;
esac

# For personal builds I recommend:
#   - `linker=mold`, but note the license.
#   - `builtin_*=no` to potentially save on compile time.

scons --max-drift=1 \
    optimize=$SCONS_OPTIMIZE \
    debug_symbols=$SCONS_DEBUG_SYMBOLS \
    compiledb=yes \
    webgpu=yes \
    $SCONS_BACKEND_FLAG \
    $SCONS_RENDERING_METHOD_FLAG \
    $SCONS_PLATFORM_FLAGS \
    "$@"

if [ "$PLATFORM" = windows ] && [ "$BACKEND" = dawn-desktop ]; then
    cp thirdparty/dawn/bin/*.dll bin/
elif [ "$PLATFORM" = windows ]; then
    DXC_DIRS=("/c/Program Files (x86)/Windows Kits/10/bin/"*/x64)
    DXC_DIR=$(printf '%s\n' "${DXC_DIRS[@]}" | sort -V | tail -n 1)
    if [ ! -f "$DXC_DIR/dxcompiler.dll" ] || [ ! -f "$DXC_DIR/dxil.dll" ]; then
        echo "Error: no dxcompiler.dll and dxil.dll in the Windows SDK"
        exit 1
    fi
    cp "$DXC_DIR/dxcompiler.dll" "$DXC_DIR/dxil.dll" bin/
fi
