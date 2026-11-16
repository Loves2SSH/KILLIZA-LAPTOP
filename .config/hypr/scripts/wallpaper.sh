#!/bin/bash
# Start the daemon if it isn't running
pgrep -x awww-daemon >/dev/null || awww-daemon &

# Wait until the daemon is ready (up to ~5 seconds)
for i in $(seq 1 25); do
  awww query >/dev/null 2>&1 && break
  sleep 0.2
done

awww img "$HOME/Pictures/Wallpaper/desktopcp.gif" --transition-type none
