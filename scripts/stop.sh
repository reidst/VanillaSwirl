#!/usr/bin/env bash
timer=${1:-0}
if ! [ "$timer" -ge 0 ] 2>/dev/null; then
    echo "VanillaSwirl Error: stop requires a nonnegative integer timer."
    exit 1
fi
if ! screen -ls | grep -q '\.vanillaswirl\.'; then
    echo "VanillaSwirl Error: there are no worlds to stop."
    exit 1
fi
if ((timer > 0)); then
    scripts/global_command.sh "say The server will be shutting down in $timer seconds."
    sleep $timer
fi
scripts/global_command.sh "stop"
while screen -ls | grep -q '\.vanillaswirl\.'; do
    sleep 1
done
