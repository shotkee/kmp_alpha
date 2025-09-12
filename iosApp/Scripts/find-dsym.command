echo "dSYM UUID:"
read DSYM_UUID

IFS=$'\n' FOUND_PATHS=( $(mdfind "com_apple_xcode_dsym_uuids == $DSYM_UUID") )
FOUND_PATH=${FOUND_PATHS[0]}

if [ -n "$FOUND_PATH" ];
then
  open "$FOUND_PATH/dSYMs"
  osascript -e 'tell application "Terminal" to close first window' & exit
else
  echo "Not found"
fi
