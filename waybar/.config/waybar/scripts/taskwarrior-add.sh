#!/bin/bash

echo "Enter task description (use +tag for tags):"
read -r description

echo "Enter due date (5min, 1h, tomorrow, 2025-12-25) or leave blank:"
read -r due_input

if [ -z "$description" ]; then
    echo "No description provided."
    read -n 1 -s -r -p "Press any key to continue..."
    exit 0
fi

# Build command
cmd="task add $description"

if [ -n "$due_input" ]; then
    # Convert relative times
    if [[ $due_input =~ ^[0-9]+min$ ]] || [[ $due_input =~ ^[0-9]+h$ ]] || [[ $due_input =~ ^[0-9]+d$ ]]; then
        due_input="now+$due_input"
    fi
    cmd="$cmd due:$due_input"
fi

# Execute with eval to properly parse tags and capture output
output=$(eval "$cmd" 2>&1)

# Show success message in terminal
echo ""
echo "✓ Task added successfully!"
if [ -n "$due_input" ]; then
    echo "  Due: $due_input"
fi
echo ""

# Send desktop notification with checkmark icon
notify-send "✓ Task Added" "$description" -i emblem-default

read -n 1 -s -r -p "Press any key to continue..."
