#!/usr/bin/env bash

set -e

# Installs the dependencies of `sync-github.sh`.

sudo apt-get update
sudo apt-get install -y git gh unzip pandoc

