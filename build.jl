using ApplicationBuilder

# TODO: Switch to using default libraries, instead of custom modified ones
# using SimpleDirectMediaLayer
# SDL2 = SimpleDirectMediaLayer

APPNAME="Paddle Battle"
jl_main="src/PaddleBattle.jl"
dist_certificate="Developer ID Application: nhdalyMadeThis, LLC"  # outside App Store
appstore_certificate="3rd Party Mac Developer Application: nhdalyMadeThis, LLC"  # outside App Store

build_app_bundle(jl_main, appname=APPNAME, verbose=true,
                 libraries=["libs/*"], resources=["assets"],
                 snoopfile="main.jl",
                 icns_file="icns.icns", bundle_identifier="com.nhdalyMadeThis.Paddle-Battle",
                 #certificate=dist_certificate, entitlements_file="./entitlements.entitlements",
                 app_version="1.1.0",
                 )
