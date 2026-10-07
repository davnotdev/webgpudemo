#!/usr/bin/env bash

set -e

# PLATFORM=<linuxbsd|windows>

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

