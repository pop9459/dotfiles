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
    # Try to find the correct socket path
    SOCKET_PATH=""
    if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        if [ -S "/run/user/$(id -u)/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" ]; then
            SOCKET_PATH="/run/user/$(id -u)/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
        elif [ -S "/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" ]; then
            SOCKET_PATH="/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
        fi
    fi
    
    if [ -z "$SOCKET_PATH" ]; then
        echo "Error: Could not find Hyprland socket" >&2
        exit 1
    fi
    
    socat -u UNIX-CONNECT:"$SOCKET_PATH" - | while read -r line; do
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
