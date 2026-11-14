#!/bin/bash
# usage: run.sh <script.py> [app args]
# Runs the debug binary under Xvfb, drives it with the script (see
# drive.py for click/drag/key/shot) and reports the app's exit status.
# Screenshots go to $TRACELASER_SHOTS (default /tmp/tracelaser-visual).
# The splash screen is skipped unless TRACELASER_NO_SPLASH=0.
set -e
cd "$(dirname "$0")/../.."
export DISPLAY=:99
export TRACELASER_SHOTS="${TRACELASER_SHOTS:-/tmp/tracelaser-visual}"
mkdir -p "$TRACELASER_SHOTS/config"
LOG="$TRACELASER_SHOTS/app.log"
# Interface size 100 %: on Linux one interface point per pixel on this
# unscaled screen (the size the scripts' coordinates are taken at). TraceLaser saves its preferences
# as they change, so each run starts from the defaults (the layout the
# coordinates are taken at) unless TRACELASER_KEEP_SETTINGS=1 keeps what
# the last run left.
python3 - "$TRACELASER_SHOTS/config/settings.json" "${TRACELASER_KEEP_SETTINGS:-0}" <<'PY'
import json, sys
s = {}
if sys.argv[2] == "1":
    try:
        s = json.load(open(sys.argv[1]))
    except (OSError, ValueError):
        s = {}
s["ui_size"] = 1.0
# No first-start update question and no network check in automation.
s.setdefault("update_check_asked", True)
s.setdefault("check_updates", False)
json.dump(s, open(sys.argv[1], "w"), indent=2)
PY
Xvfb :99 -screen 0 1600x1000x24 >/dev/null 2>&1 & XPID=$!
sleep 1
SCRIPT=$1; shift
(WINIT_UNIX_BACKEND=x11 TRACELASER_NO_SPLASH="${TRACELASER_NO_SPLASH:-1}" TRACELASER_CONFIG_DIR="$TRACELASER_SHOTS/config" LIBGL_ALWAYS_SOFTWARE=1 ./target/debug/tracelaser "$@" >"$LOG" 2>&1; echo "APP EXIT $?" >> "$LOG") &
sleep 6
python3 "$(dirname "$0")/drive.py" "$SCRIPT" || true
sleep 1
grep "APP EXIT" "$LOG" || echo "app still running"
grep -i "panic" "$LOG" && echo "PANIC in log" || true
pkill -x tracelaser 2>/dev/null || true; sleep 0.5; kill $XPID 2>/dev/null || true
