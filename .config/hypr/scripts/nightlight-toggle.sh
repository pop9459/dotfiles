#!/usr/bin/env bash
# Toggle the hyprsunset blue light filter on/off.
state="${XDG_RUNTIME_DIR:-/tmp}/nightlight-on"

if [ -e "$state" ]; then
    hyprctl hyprsunset identity
    rm -f "$state"
    notify-send "Night light" "Off"
else
    hyprctl hyprsunset temperature 3500
    touch "$state"
    notify-send "Night light" "On (3500K)"
fi
