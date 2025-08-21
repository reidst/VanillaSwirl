#!/usr/bin/env bash
if [ -z "$1" ]; then
    echo "VanillaSwirl Error: a command argument is required."
    exit 1
fi
if ! screen -ls | grep -q '\.vanillaswirl\.'; then
    echo "VanillaSwirl Error: no servers are currently running."
    exit 1
fi
for session in /var/run/screen/S-$USER/*; do
    if [[ "$session" =~ \.vanillaswirl\. ]]; then
        screen -S ${session##*/} -X stuff "$1"'^M'
    fi
done
