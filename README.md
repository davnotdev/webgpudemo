# Godot WebGPU Demo CI

Convenient Github Action workflows and scripts for building and hosting Godot binaries, web templates, and web exports with experimental WebGPU support from [`davnotdev/godot@webgpu`](https://github.com/davnotdev/godot/tree/webgpu).

Checkout releases for access to pre-built downloads. 
The code featured is highly work in progress and experimental.
Run at your own risk.

This repository builds the following targets:

- `linuxbsd-debug-wgpu-desktop`, `linuxbsd-release-wgpu-desktop`, 
- `linuxbsd-debug-dawn-desktop`, `linuxbsd-release-dawn-desktop`
- `windows-debug-wgpu-desktop`, `windows-release-wgpu-desktop`
- `windows-debug-dawn-desktop`, `windows-release-dawn-desktop`
- `web-debug-emdawnwebgpu-mobile`, `web-release-emdawnwebgpu-mobile`
- `web-debug-emdawnwebgpu-forward_plus`, `web-release-emdawnwebgpu-forward_plus`

This repository exports the following demos:

- [`godot-demo-projects`](https://github.com/godotengine/godot-demo-projects)

You can access exported demos at [https://webgpudemo.davnot.dev](https://webgpudemo.davnot.dev).

## Running Locally

Here is the gist of how you would run a build yourself.

> Unfortunately, we currently do not have script support for mingw cross compilation.
> However, you could do that yourself with mingw and wgpu-desktop only.

### Install Dependencies for Linux

```sh
sudo apt-get install -y git python3 scons clang llvm lld

# For Linux Build
sudo apt-get install -y build-essential pkg-config libx11-dev libxcursor-dev libxinerama-dev \
    libgl1-mesa-dev libglu1-mesa-dev libasound2-dev libpulse-dev libudev-dev libxi-dev \
    libxrandr-dev libwayland-dev

# For dawn builds
sudo apt-get install -y cmake ninja-build libx11-xcb-dev mesa-common-dev
```

You will need to setup [Rust](https://rustup.rs/) and install the nightly toolchain.

```sh
rustup toolchain install nightly --component rust-src
```

For web builds, you will need to install emscripten

```sh
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh
cd ..
```

### Install Dependencies for Windows

Windows builds use MSVC and must be built natively on Windows.
Install MSVC, then from PowerShell:

```powershell
winget install Git.Git
winget install Python.Python.3.12
winget install Rustlang.Rustup
winget install Kitware.CMake
winget install Ninja-build.Ninja
py -m pip install scons
```

CMake and Ninja are only needed for dawn builds.
Make sure Python's `Scripts` directory is on your `PATH` so that `scons` can be found.

Builds must run from Git Bash inside an MSVC environment.

### Fetching Sources and Compiling 

```sh
PLATFORM=<linuxbsd|windows|web> \
BUILDTYPE=<debug|release> \
BACKEND=<wgpu-desktop|dawn-desktop|emdawnwebgpu> \
# CAUTION: Mixing different rustc's can cause link errors. 
# You should set these to whatever toolchain you have installed
RUSTUP_TOOLCHAIN=<pinned to source/RUSTUP_TOOLCHAIN>> \
RUST_NIGHTLY=<pinned to source/RUSTUP_NIGHTLY> \
# Web only
RENDERING_METHOD=<mobile|forward_plus> \
# ---
bash scripts/build-local.sh
```

## Things to Note

- Run with `--rendering-driver webgpu`
- Web demos have only been tested on Linux
- Windows builds have limited testing (only tested on wine)
- The driver requires increased WebGPU limits, on my system that means running with `VK_LOADER_DRIVERS_DISABLE=amd_icd64.json chromium --enable-unsafe-webgpu --enable-features=Vulkan` (Use RADV)
- As a note, chromium often prefers the system's iGPU which may cause problems.
- Not all demos run or run smoothly (WIP)
- Using Dawn causes for 3d scenes causes large frame drops during buffer sweeps (WIP)
- The current driver does not include global illumination or MSAA support (WIP)

> DISCLAIMER: The Github workflows are written using LLMs.
> The scripts in this repository are made for reading, but I do not recommend you use or read these workflows.
> After all, Github Actions was not made for mortals.

