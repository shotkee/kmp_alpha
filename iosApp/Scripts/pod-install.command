#!/bin/sh

cd "$(dirname "$0")"
pod install --verbose

osascript -e 'display notification "Install complete" with title "CocoaPods"'
osascript -e 'beep 3'
