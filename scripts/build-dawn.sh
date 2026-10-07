#!/usr/bin/env bash

set -e

# GODOT_SOURCE=
# PLATFORM=<linuxbsd|windows>
# BUILDTYPE=<debug|release>

case $PLATFORM in
    windows)
        ;;
    linuxbsd)
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

if [ ! -d "$GODOT_SOURCE" ]; then
    echo "Error: bad source dir: $GODOT_SOURCE"
    exit 1
fi

cmake -S . -B out/$BUILDTYPE/Vendor -G Ninja \
    -DCMAKE_BUILD_TYPE=$CMAKE_BUILD_TYPE \
    -DDAWN_ENABLE_INSTALL=ON
cmake --build out/$BUILDTYPE/Vendor
cmake --install out/$BUILDTYPE/Vendor --prefix "$GODOT_SOURCE/thirdparty/dawn/"

