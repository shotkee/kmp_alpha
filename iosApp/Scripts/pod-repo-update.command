#!/bin/sh

pod repo update

osascript -e 'display notification "Repo update complete" with title "CocoaPods"'
osascript -e 'beep 3'
