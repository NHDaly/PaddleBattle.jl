#!/bin/bash

APPNAME="Paddle Battle"
jl_main="main"
dist_certificate="Developer ID Application: nhdalyMadeThis, LLC"  # outside App Store

# Build for distribution
julia ~/src/build-jl-app-bundle/build_app.jl -v \
 -R assets -L "libs/*" --bundle_identifier "com.nhdalyMadeThis.Paddle-Battle" --icns "icns.icns" \
 --certificate "$dist_certificate" --entitlements "./entitlements.entitlements" \
 --app_version=1.0 "$jl_main.jl" "$APPNAME"
