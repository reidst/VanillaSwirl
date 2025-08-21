#!/usr/bin/env bash
timer=${1:-30}
if ! [ "$timer" -ge 0 ] 2>/dev/null; then
    echo "VanillaSwirl Error: stop requires a nonnegative integer timer."
    exit 1
fi
if ! screen -ls | grep -q '\.vanillaswirl\.'; then
    echo "VanillaSwirl Error: no servers are currently running."
    exit 1
fi
scripts/global_command.sh "say The server will be shutting down in $timer seconds."
sleep $timer
scripts/global_command.sh "stop"
