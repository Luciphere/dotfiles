#!/usr/bin/env bash

BAT1="/org/freedesktop/UPower/devices/battery_BAT1"
BAT0="/org/freedesktop/UPower/devices/battery_BAT0"

get_info() {
  upower -i "$1"
}

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

if [ "$STATE" = "charging" ]; then ICON=""; fi

echo "$ICON $PERCENT ($LABEL)"
