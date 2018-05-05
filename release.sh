# Load the read/writeable dmg with manually set Finder settings.
cp ./dmg/Paddle-Battle-rw.dmg ./builddir/Paddle-Battle-rw-tmp.dmg
# Resize the .dmg to fit the app (plus a 50MB buffer for leeway):
hdiutil resize -size "$(julia -E "M=1; $(du -hs builddir/Paddle\ Battle.app  | awk '{print $1}') + 50")m"  ./builddir/Paddle-Battle-rw-tmp.dmg
hdiutil attach ./builddir/Paddle-Battle-rw-tmp.dmg

# Replace the existing .app so that the position/size of the icon in Finder is preserved.
stat /Volumes/Paddle\ Battle/Paddle\ Battle.app || exit 1
rm -rf /Volumes/Paddle\ Battle/Paddle\ Battle.app    # Remove current contents of app (in case you've removed/renamed files)
CpMac -r ./builddir/Paddle\ Battle.app  /Volumes/Paddle\ Battle/   # Replace .app with new contents (Must use CpMac -- it copies and preserves codesign!)

hdiutil detach $(hdiutil info | grep '/Volumes/Paddle Battle' | awk '{print $1}')

# "Save" the modified r/w .dmg to a read-only, compressed .dmg
hdiutil convert -format UDZO -o ./builddir/Paddle-Battle-rw-converted.out.dmg  ./builddir/Paddle-Battle-rw-tmp.dmg
mv ./builddir/Paddle-Battle-rw-converted.out.dmg ./builddir/Paddle-Battle.dmg

# Sign it
CpMac builddir/Paddle-Battle.dmg builddir/Paddle-Battle-unsigned.dmg  # CpMac to preserve codesign
codesign -s "Developer ID Application: nhdalyMadeThis, LLC" builddir/Paddle-Battle.dmg 


