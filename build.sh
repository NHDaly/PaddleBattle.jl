#!/bin/bash

APPNAME="Paddle Battle"
jl_main="main"
certificate="Developer ID Application: nhdalyMadeThis, LLC"  # outside App Store

julia ~/src/build-jl-app-bundle/build_app.jl -v \
 -R assets -L "libs/*" --bundle_identifier "com.nhdalyMadeThis.paddlebattle" --icns "icns.icns" \
 --certificate "$certificate" --entitlements "./entitlements.entitlements" \
 --app_version=0.2 "$jl_main.jl" "$APPNAME"
