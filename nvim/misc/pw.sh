#!/bin/bash
pw="$(osascript -e 'Tell application "System Events" to display dialog "password:" default answer "" with hidden answer' -e 'text returned of result' 2>/dev/null)" && echo "$pw"
