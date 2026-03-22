#!/bin/bash

DESKTOP_DIRS=(
  "$HOME/.local/share/applications"
  "/usr/local/share/applications"
  "/usr/share/applications"
)

ICON_DIRS=(
  "$HOME/.local/share/icons"
  "/usr/share/icons"
  "/usr/share/pixmaps"
)

get_socket_path() {
  local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

  if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && [ -S "$runtime_dir/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" ]; then
    echo "$runtime_dir/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    return 0
  fi

  if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && [ -S "/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" ]; then
    echo "/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
    return 0
  fi

  return 1
}

get_active_window_json() {
  hyprctl activewindow -j 2>/dev/null || echo '{}'
}

find_desktop_file() {
  local app_class="$1"
  local dir=""
  local file=""

  if [ -z "$app_class" ]; then
    return 1
  fi

  for dir in "${DESKTOP_DIRS[@]}"; do
    [ -d "$dir" ] || continue
    file=$(grep -Ril --include='*.desktop' "^StartupWMClass=${app_class}$" "$dir" 2>/dev/null | head -n1)
    if [ -n "$file" ]; then
      echo "$file"
      return 0
    fi
  done

  for dir in "${DESKTOP_DIRS[@]}"; do
    [ -d "$dir" ] || continue
    file=$(find "$dir" -type f -iname "*${app_class}*.desktop" 2>/dev/null | head -n1)
    if [ -n "$file" ]; then
      echo "$file"
      return 0
    fi
  done

  return 1
}

extract_icon_name() {
  local desktop_file="$1"
  grep -m1 '^Icon=' "$desktop_file" 2>/dev/null | cut -d'=' -f2-
}

resolve_icon_path() {
  local icon_name="$1"
  local base_name=""
  local dir=""
  local found=""

  if [ -z "$icon_name" ]; then
    return 1
  fi

  if [ -f "$icon_name" ]; then
    echo "$icon_name"
    return 0
  fi

  base_name="$icon_name"
  base_name="${base_name%.png}"
  base_name="${base_name%.svg}"
  base_name="${base_name%.xpm}"

  for dir in "${ICON_DIRS[@]}"; do
    [ -d "$dir" ] || continue

    if [ -f "$dir/$base_name.png" ]; then
      echo "$dir/$base_name.png"
      return 0
    fi
    if [ -f "$dir/$base_name.svg" ]; then
      echo "$dir/$base_name.svg"
      return 0
    fi
    if [ -f "$dir/$base_name.xpm" ]; then
      echo "$dir/$base_name.xpm"
      return 0
    fi
  done

  for dir in "${ICON_DIRS[@]}"; do
    [ -d "$dir" ] || continue

    found=$(find "$dir" -type f \( -iname "$base_name.png" -o -iname "$base_name.svg" -o -iname "$base_name.xpm" -o -iname "$base_name-symbolic.svg" \) 2>/dev/null | head -n1)
    if [ -n "$found" ]; then
      echo "$found"
      return 0
    fi
  done

  return 1
}

emit_state() {
  local active_json=""
  local app_class=""
  local app_title=""
  local app_name=""
  local focused="false"
  local desktop_file=""
  local icon_name=""
  local icon_path=""
  local resolved_icon=""

  active_json=$(get_active_window_json)

  app_class=$(jq -r '.class // empty' <<< "$active_json")
  app_title=$(jq -r '.title // empty' <<< "$active_json")

  if [ -n "$app_class" ] || [ -n "$app_title" ]; then
    focused="true"
    app_name="$app_class"
    if [ -z "$app_name" ]; then
      app_name="$app_title"
    fi
  fi

  desktop_file=$(find_desktop_file "$app_class" || true)
  if [ -n "$desktop_file" ]; then
    icon_name=$(extract_icon_name "$desktop_file")
  fi

  if [ -z "$icon_name" ] && [ -n "$app_class" ]; then
    icon_name="$app_class"
  fi

  resolved_icon=$(resolve_icon_path "$icon_name" || true)
  if [ -n "$resolved_icon" ]; then
    icon_path="$resolved_icon"
  fi

  jq -cn --arg name "$app_name" --arg icon "$icon_path" --argjson focused "$focused" '{name:$name, icon:$icon, focused:$focused}'
}

listen_updates() {
  local socket_path=""

  socket_path=$(get_socket_path) || exit 1

  emit_state
  socat -u UNIX-CONNECT:"$socket_path" - | while read -r line; do
    case "$line" in
      activewindow*|activewindowv2*|openwindow*|closewindow*|movewindow*|windowtitle*|workspace*|focusedmon*)
        emit_state
        ;;
    esac
  done
}

if [ "$1" = "listen" ]; then
  listen_updates
else
  emit_state
fi
