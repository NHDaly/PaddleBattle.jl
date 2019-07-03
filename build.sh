#!/bin/bash

APPNAME="Paddle Battle"
jl_main="src/main"
dist_certificate="Developer ID Application: nhdalyMadeThis, LLC"  # outside App Store
appstore_certificate="3rd Party Mac Developer Application: nhdalyMadeThis, LLC"  # outside App Store

# Build for distribution
julia ~/.julia/v0.6/ApplicationBuilder/build_app.jl -v \
 -R assets -L "libs/*"  --icns "icns.icns" \
 --bundle-identifier "com.nhdalyMadeThis.Paddle-Battle" \
 --certificate "$dist_certificate" --entitlements "./entitlements.entitlements" \
 --app-version=1.0.4 "$jl_main.jl" "$APPNAME"
