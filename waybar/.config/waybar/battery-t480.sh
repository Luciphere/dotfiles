#!/usr/bin/env bash

BAT1="/org/freedesktop/UPower/devices/battery_BAT1"
BAT0="/org/freedesktop/UPower/devices/battery_BAT0"

get_info() {
  upower -i "$1"
}

HAS_BAT1=$(get_info "$BAT1" 2>/dev/null | grep -c "state:" || true)

if [ "$HAS_BAT1" -gt 0 ]; then
  # T480: dual battery — show whichever is discharging, prefer BAT1 otherwise
  if get_info "$BAT1" 2>/dev/null | grep -q "state:\s*discharging"; then
    BAT="$BAT1"
    LABEL="BAT1"
  elif get_info "$BAT0" 2>/dev/null | grep -q "state:\s*discharging"; then
    BAT="$BAT0"
    LABEL="BAT0"
  else
    BAT="$BAT1"
    LABEL="BAT1"
  fi
else
  # Single battery (e.g. X220)
  BAT="$BAT0"
  LABEL=""
fi

INFO=$(get_info "$BAT")

PERCENT=$(echo "$INFO" | awk '/percentage/ {print $2}')
STATE=$(echo "$INFO" | awk '/state/ {print $2}')

ICON=""
P=${PERCENT%\%}

if [ "$P" -le 10 ]; then
  ICON=""
elif [ "$P" -le 25 ]; then
  ICON=""
elif [ "$P" -le 50 ]; then
  ICON=""
elif [ "$P" -le 75 ]; then
  ICON=""
fi

if [ "$STATE" = "charging" ]; then ICON="󰂄"; fi
if [ "$STATE" = "fully-charged" ]; then ICON=""; PERCENT="100%"; fi

if [ -n "$LABEL" ]; then
  echo "$ICON $PERCENT ($LABEL)"
else
  echo "$ICON $PERCENT"
fi
