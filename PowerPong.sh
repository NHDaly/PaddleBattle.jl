#!/bin/bash

# Haha apparently the script must be 28 bytes to execute.....
# So this is some padding!

logfile="$HOME/NATHAN_PP.txt"
exec > $logfile 2>&1

echo "HI..."

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/../Resources

echo "Running..."
export JULIA_PKGDIR="$(pwd)/julia_pkgs/"
echo "PKGDIR: $JULIA_PKGDIR"

# Note --compilecache=no, needed to avoid precompilation. (Accidentally shipping precompiled )
../MacOS/julia --compilecache=no -E 'using Compat; Pkg.dir("Compat"); include("scripts/pongmain.jl"); julia_main([""])'
