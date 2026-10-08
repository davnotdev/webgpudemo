# Godot WebGPU Demo CI

Convenient Github Action workflows and scripts for building and hosting Godot binaries, web templates, and web exports with experimental WebGPU support from [`davnotdev/godot@webgpu`](https://github.com/davnotdev/godot/tree/webgpu).

Checkout releases for access to pre-built downloads. 
The code featured is highly work in progress and experimental.
Run at your own risk.

This repository builds the following targets:

- `linuxbsd-debug-wgpu-desktop`
- `linuxbsd-release-wgpu-desktop`
- `linuxbsd-debug-dawn-desktop`
- `linuxbsd-release-dawn-desktop`
- `windows-debug-wgpu-desktop`
- `windows-release-wgpu-desktop`
- `windows-debug-dawn-desktop`
- `windows-release-dawn-desktop`
- `web-debug-emdawnwebgpu`
- `web-release-emdawnwebgpu`

This repository exports the following demos:

- [`godot-demo-projects`](https://github.com/godotengine/godot-demo-projects)

You can access exported demos at [https://webgpudemo.davnot.dev](https://webgpudemo.davnot.dev).

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

