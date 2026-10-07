#!/usr/bin/env bash

set -e

# GODOT_SOURCE=
# PLATFORM=<linuxbsd|windows>
# BUILDTYPE=<debug|release>

case $PLATFORM in
    windows)
        export CMAKE_PLATFORM_FLAGS="-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded -DABSL_MSVC_STATIC_RUNTIME=ON -DCMAKE_POLICY_DEFAULT_CMP0141=NEW -DCMAKE_MSVC_DEBUG_INFORMATION_FORMAT=Embedded"
        # mingw
        # export CMAKE_PLATFORM_FLAGS="-DCMAKE_TOOLCHAIN_FILE=$(dirname "$(realpath "$0")")/mingw-w64-x86_64.cmake"
        ;;
    linuxbsd)
        export CMAKE_PLATFORM_FLAGS=""
        ;;
    *)
        echo "Error: unsupported platform: $PLATFORM"
        exit 1
        ;;
esac

case $BUILDTYPE in
    debug)
        export CMAKE_BUILD_TYPE=Debug
        ;;
    release)
        export CMAKE_BUILD_TYPE=Release
        ;;
    *)
        echo "Error: unsupported build type: $BUILDTYPE"
        exit 1
        ;;
esac

if [ "$PLATFORM" = windows ] && [ "$BUILDTYPE" = debug ]; then
    export CMAKE_BUILD_TYPE=RelWithDebInfo
    export CMAKE_PLATFORM_FLAGS="$CMAKE_PLATFORM_FLAGS -DDAWN_ALWAYS_ASSERT=ON"
fi

if [ ! -d "$GODOT_SOURCE" ]; then
    echo "Error: bad source dir: $GODOT_SOURCE"
    exit 1
fi

cmake -S . -B out/$PLATFORM/$BUILDTYPE/Vendor -G Ninja \
    -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
    -DDAWN_ENABLE_INSTALL=ON \
    -DDAWN_FETCH_DEPENDENCIES=ON \
    -DDAWN_BUILD_SAMPLES=OFF \
    -DDAWN_BUILD_TESTS=OFF \
    -DDAWN_USE_GLFW=OFF \
    -DDAWN_SUPPORTS_CXX_MODULES=OFF \
    -DTINT_BUILD_TESTS=OFF \
    $CMAKE_PLATFORM_FLAGS
cmake --build out/$PLATFORM/$BUILDTYPE/Vendor
cmake --install out/$PLATFORM/$BUILDTYPE/Vendor --prefix "$GODOT_SOURCE/thirdparty/dawn/"

