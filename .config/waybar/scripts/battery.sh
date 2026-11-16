#!/bin/bash
# ── battery.sh ─────────────────────────────────────────────
# Description: Shows battery % with ASCII bar + dynamic tooltip
# Usage: Waybar `custom/battery` every 10s
# Dependencies: upower
# ───────────────────────────────────────────────────────────

bat_path=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
[ -z "$bat_path" ] && exit 1
bat_name=$(basename "$bat_path")

capacity=$(cat "$bat_path/capacity")
status=$(cat "$bat_path/status")

# Time estimate from upower
info=$(upower -i "/org/freedesktop/UPower/devices/battery_$bat_name")
time_to_empty=$(echo "$info" | awk -F: '/time to empty/ {print $2}' | xargs)
time_to_full=$(echo "$info" | awk -F: '/time to full/ {print $2}' | xargs)

# Icons
charging_icons=(󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅)
default_icons=(󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)

index=$((capacity / 10))
[ "$index" -ge 10 ] && index=9

if [[ "$status" == "Charging" ]]; then
  icon=${charging_icons[$index]}
elif [[ "$status" == "Full" ]]; then
  icon="󰂅"
else
  icon=${default_icons[$index]}
fi

# ASCII bar (clamped to 0-10 blocks)
filled=$((capacity / 10))
[ "$filled" -gt 10 ] && filled=10
empty=$((10 - filled))
bar=""
pad=""
for ((i = 0; i < filled; i++)); do bar+="█"; done
for ((i = 0; i < empty; i++)); do pad+="░"; done
ascii_bar="[$bar$pad]"

# Color thresholds
if [ "$capacity" -lt 20 ]; then
  fg="#bf616a" # red
elif [ "$capacity" -lt 55 ]; then
  fg="#ccff00" # lime
else
  fg="#ccff00" # lime
fi

# Tooltip text
tooltip="Battery: $capacity% ($status)"
if [ "$status" = "Discharging" ] && [ -n "$time_to_empty" ]; then
  tooltip="$tooltip\nTime left: $time_to_empty"
elif [ "$status" = "Charging" ] && [ -n "$time_to_full" ]; then
  tooltip="$tooltip\nTime to full: $time_to_full"
fi

# JSON output
echo "{\"text\":\"<span foreground='$fg'>$icon $ascii_bar $capacity%</span>\",\"tooltip\":\"$tooltip\"}"
