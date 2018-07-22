using ApplicationBuilder; using BuildApp

using SimpleDirectMediaLayer
SDL2 = SimpleDirectMediaLayer
build_app_bundle("main.jl", appname="Paddle Battle", libraries=[SDL2.libSDL2, SDL2.libSDL2_tt
f, SDL2.libSDL2_mixer], resources=["assets"])
