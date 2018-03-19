#!/bin/bash

APP_NAME="PowerPong"
jl_main="pongmain"
certificate="Nathan Daly"

julia ~/src/build-jl-app-bundle/build_app.jl -v \
 -R assets -L "libs/*" --icns icns.icns \
 --certificate "$certificate" --entitlements "./entitlements.entitlements" \
 --app_version=0.2 "$jl_main.jl" "$APP_NAME"
