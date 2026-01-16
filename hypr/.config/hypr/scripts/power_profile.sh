#!/usr/bin/env bash

op1="●  Performance"
op2="◐  Balanced"
op3="○  Power Saver"

options="$op1\n$op2\n$op3"

valgt=$(echo -e "$options" | rofi -dmenu -i -p "Profil" \
  -theme-str "window { width: 250px; border: 2px; border-radius: 12px; border-color: #585b70; background-color: #1e1e2e; } \
                listview { lines: 3; scrollbar: false; } \
                element { padding: 8px; border-radius: 8px; } \
                element selected { background-color: #313244; text-color: #cdd6f4; } \
                inputbar { enabled: false; }")

case "$valgt" in
*"Performance"*) powerprofilesctl set performance ;;
*"Balanced"*) powerprofilesctl set balanced ;;
*"Power Saver"*) powerprofilesctl set power-saver ;;
esac
