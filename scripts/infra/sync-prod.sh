#!/usr/bin/env bash

set -e

cd "$(dirname "$(realpath "$0")")/../.."

sudo rsync -av builds/ /app/webgpudemo/
