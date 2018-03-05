#!/bin/sh

APP_NAME="PowerPong"
jl_main="pongmain"
certificate="Nathan Daly"

julia ~/src/build-jl-app-bundle/build_app.jl -v -R assets -L "libs/*" --icns icns.icns --app_version=0.2 "$jl_main.jl" "$APP_NAME"

./sign-application.sh "builddir/$APP_NAME.app" "$certificate"

codesign --entitlements ./entitlements.entitlements -fs "$certificate" "builddir/$APP_NAME.app/Contents/MacOS/$jl_main"
