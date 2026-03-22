#!/bin/bash

# Get list of workspaces and format for eww
get_workspaces() {
    local active_workspace=$(hyprctl activeworkspace -j | jq -r '.id')
    local workspaces=$(hyprctl workspaces -j | jq -r '.[].id' | sort -n)
    
    echo -n "["
    
    local first=true
    for ws in $workspaces; do
        if [ "$first" = true ]; then
            first=false
        else
            echo -n ","
        fi
        
        if [ "$ws" -eq "$active_workspace" ]; then
            echo -n "{\"id\":$ws,\"active\":true}"
        else
            echo -n "{\"id\":$ws,\"active\":false}"
        fi
    done
    
    echo "]"
}

# Monitor workspace changes
if [ "$1" = "listen" ]; then
    # Output initial state
    get_workspaces
    
    # Listen for workspace events
    socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
        case "$line" in
            workspace*|destroyworkspace*|createworkspace*)
                get_workspaces
                ;;
        esac
    done
else
    # Just output current state
    get_workspaces
fi
