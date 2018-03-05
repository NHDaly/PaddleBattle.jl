BINARY="$1"
CERT="$2"
function sign_all_unsigned() {
  all_success=0
  for l in "$BINARY"/Contents/MacOS/*; do
    codesign --display --extract-certificates $l  ||  (codesign -s "$2" $l ; all_success=-1)
  done
  # Stop if all are signed.
  $(return $all_success) && exit
}

# Repeat this a few times in order to allow for dependency chains.
for x in 1..10; do
  sign_all_unsigned
done

