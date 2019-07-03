# Paddle Battle -- a simple game written in Julia.

A simple pong clone built in [`julia`](https://github.com/JuliaLang/julia) using
the [`SDL2`](https://www.libsdl.org/) library.

This repo is an example of building a complete game, compiled and distributed as
a `.app`, written entirely in Julia! This game uses the
[`https://github.com/jonathanBieler/SimpleDirectMediaLayer.jl`](https://github.com/jonathanBieler/SimpleDirectMediaLayer.jl)
package, which provides julia bindings for `SDL2`, for its graphics and keyboard/mouse input.

The game can be compiled into a complete, ready-for-release distributable via
the build script (`./build.sh`). It simply invokes `build_app.jl` from
[NHDaly/build-jl-app-bundle](https://github.com/NHDaly/build-jl-app-bundle) to
compile and bundle a macOS application from the julia code.

Building the game in Julia was lots of fun! Not least, live-editing code in Juno is
really nice:
![Paddle-Battle-Juno-live-editing.gif](https://raw.githubusercontent.com/NHDaly/nhdalyMadeThis.website/master/assets/images/Paddle-Battle-Juno-live-editing.gif)

## Install

You can download the game for Mac here:
<br>~https://nhdalyMadeThis.website~
<br>EDIT: oops sadly I let this domain name expire, and now it's hundreds of dollars to buy it back! 😭 So I'll have to get a new website I guess. 😢

You can download the game from the Releases tab on this github repo:
<br>https://github.com/NHDaly/PaddleBattle.jl/releases/latest

## License
This project is licensed under the terms of the MIT license.

Please do go ahead and copy it, modify it, remix it, and sell your creation!
