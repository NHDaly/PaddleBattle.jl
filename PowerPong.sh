#!/bin/bash

# Haha apparently the script must be 28 bytes to execute.....
# So this is some padding!

logfile="~/.PowerPong.log"
exec > $logfile 2>&1

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/..

MacOS/julia -e 'include("Resources/scripts/pongmain.jl"); julia_main([""])'
