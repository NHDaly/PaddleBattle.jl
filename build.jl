APPNAME="PowerPong"

mkpath("builddir")
appDir="builddir/$APPNAME.app/Contents"

launcherDir="$appDir/MacOS"
scriptsDir="$appDir/Resources/scripts"

mkpath(launcherDir)
mkpath(scriptsDir)


julia_scripts = filter(r".*\.jl", readlines(`ls`))
run(`cp $julia_scripts $scriptsDir/`)
# Copy launch script -- note deleting the `.sh`
cp("$APPNAME.sh", "$launcherDir/$APPNAME", remove_destination=true)
run(`chmod +x "$launcherDir/$APPNAME"`)

cp("/usr/local/bin/julia", "$launcherDir/julia")
