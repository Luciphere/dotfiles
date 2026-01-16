#!/usr/bin/env bash

profile=$(powerprofilesctl get)

if [ "$profile" == "performance" ]; then
  echo '{"text": "●", "tooltip": "Performance"}'
elif [ "$profile" == "balanced" ]; then
  # Denne er garanteret 50/50
  echo '{"text": "◐", "tooltip": "Balanced"}'
else
  echo '{"text": "○", "tooltip": "Power Saver"}'
fi
