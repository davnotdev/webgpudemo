# Godot WebGPU Demos

Godot WebGPU demo exports for build commit: `{{commit}}`.

Browse the latest exports of WebGPU demos [here](./latest).

## 

Notes about compatibility:

- Run at your own risk (GPU crashes are possible on unstable browsers).
- Running on Linux, you may need `--enable-unsafe-webgpu --enable-features=Vulkan` and to enable a different set of drivers.
- Running on Windows, some demos [need this bug fix](https://dawn.googlesource.com/dawn/+/db1e07651072206acba2b2ea1ab15d22f54c23de), available in Chrome 157.0.8082.0+. 
- Firefox and safari do not work currently.
- If the Forward+ renderer fails to initialize, your browser may have lower limits, try the Mobile renderer.

Below, you will find a matrix of tested demos.
If you find an issue or correction with the matrix, [open an issue](https://github.com/davnotdev/webgpudemo).

## Demo Testing Matrix

> TODO: I haven't filled all these out yet. 

{{testing}}
