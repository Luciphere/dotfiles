#!/usr/bin/env bash

# Definition af muligheder
op1="󰤄 Pause"
op2="󰍃 Log ud"
op3="󰑐 Genstart"
op4="󰐥 Sluk"

# Samlet liste til menuen
options="$op1\n$op2\n$op3\n$op4"

# Tæl antallet af linjer
num_options=$(echo -e "$options" | wc -l)

# Kør Rofi
valgt=$(echo -e "$options" | rofi -dmenu -i -p "System" \
  -theme-str "window { width: 250px; border: 2px; border-radius: 12px; border-color: #585b70; background-color: #1e1e2e; } \
                mainbox { children: [listview]; background-color: transparent; } \
                listview { lines: $num_options; scrollbar: false; fixed-height: true; padding: 10px; background-color: transparent; } \
                element { padding: 8px; border-radius: 8px; background-color: transparent; text-color: #cdd6f4; } \
                element selected { background-color: #45475a; text-color: #ffffff; }")

# Handling baseret på valg
case "$valgt" in
*"Pause"*)
  systemctl suspend
  ;;
*"Log ud"*)
  hyprctl dispatch exit
  ;;
*"Genstart"*)
  systemctl reboot
  ;;
*"Sluk"*)
  systemctl poweroff
  ;;
esac
