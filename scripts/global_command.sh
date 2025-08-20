#!/usr/bin/env bash
for session in /var/run/screen/S-$USER/*; do
    if [[ "$session" =~ \.vanillaswirl\. ]]; then
        screen -S ${session##*/} -X stuff "$1"'^M'
    fi
done
