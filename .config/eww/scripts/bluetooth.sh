#!/bin/bash

set -euo pipefail

has_bluetoothctl() {
  command -v bluetoothctl >/dev/null 2>&1
}

is_powered() {
  bluetoothctl show 2>/dev/null | grep -q "Powered: yes"
}

first_connected_name() {
  bluetoothctl devices Connected 2>/dev/null | sed -n '1s/^Device [^ ]* //p'
}

connected_count() {
  bluetoothctl devices Connected 2>/dev/null | grep -c '^Device ' || true
}

emit_state() {
  local available="true"
  local powered="false"
  local connected="false"
  local count=0
  local name=""
  local icon_off="󰂲"
  local icon_on=""
  local icon_connected="󰂱"
  local label="${icon_off} N/A"

  if ! has_bluetoothctl; then
    available="false"
  elif ! bluetoothctl show >/dev/null 2>&1; then
    available="false"
  else
    if is_powered; then
      powered="true"
      count=$(connected_count)

      if [ "$count" -gt 0 ]; then
        connected="true"
        name=$(first_connected_name)
        if [ "$count" -gt 1 ]; then
          label="${icon_connected} ${count} devices"
        elif [ -n "$name" ]; then
          label="${icon_connected} ${name}"
        else
          label="${icon_connected} connected"
        fi
      else
        label="${icon_on} on"
      fi
    else
      label="${icon_off} off"
    fi
  fi

  jq -cn \
    --argjson available "$available" \
    --argjson powered "$powered" \
    --argjson connected "$connected" \
    --argjson count "$count" \
    --arg name "$name" \
    --arg label "$label" \
    '{available:$available, powered:$powered, connected:$connected, count:$count, name:$name, label:$label}'
}

toggle_power() {
  if ! has_bluetoothctl; then
    exit 1
  fi

  if is_powered; then
    bluetoothctl power off >/dev/null 2>&1 || true
  else
    bluetoothctl power on >/dev/null 2>&1 || true
  fi

  emit_state
}

case "${1:-status}" in
  status)
    emit_state
    ;;
  toggle)
    toggle_power
    ;;
  *)
    emit_state
    ;;
esac
