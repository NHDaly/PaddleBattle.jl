#!/bin/bash

APPNAME="Paddle Battle"
jl_main="main"
dist_certificate="Developer ID Application: nhdalyMadeThis, LLC"  # outside App Store
appstore_certificate="3rd Party Mac Developer Application: nhdalyMadeThis, LLC"  # outside App Store

# Build for distribution
julia ~/src/build-jl-app-bundle/build_app.jl -v \
 -R assets -L "libs/*"  --icns "icns.icns" \
 --bundle_identifier "com.nhdalyMadeThis.Paddle-Battle" \
 --certificate "$dist_certificate" --entitlements "./entitlements.entitlements" \
 --app_version=1.0.2 "$jl_main.jl" "$APPNAME"
