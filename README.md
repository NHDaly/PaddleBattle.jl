# Paddle Battle -- a simple game written in Julia.

A simple pong-clone built in [`julia`](https://github.com/JuliaLang/julia) using
the [`SDL2`](https://www.libsdl.org/) library.

This repo is an example of building a complete game, distributed as a `.app`,
written entirely in Julia! This game uses the
[`SDL2.jl`](https://github.com/jonathanBieler/SDL2.jl) package, which provides
julia bindings for `SDL2`, for its graphics and keyboard/mouse input.

The game can be compiled into a complete, ready-for-release distributable via
the build script (`./build.sh`). It simply invokes `build_app.jl` from
[NHDaly/build-jl-app-bundle](https://github.com/NHDaly/build-jl-app-bundle) to
compile and bundle a macOS application from the julia code.


# License
This project is licensed under the terms of the MIT license.

Please do go ahead and copy it, modify it, remix it, and sell your creation!
