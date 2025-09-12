#!/bin/sh

echo "Pod name:"
read POD_NAME

cd "$(dirname "$0")"
pod update --verbose $POD_NAME

osascript -e 'display notification "Install complete" with title "CocoaPods"'
osascript -e 'beep 3'
