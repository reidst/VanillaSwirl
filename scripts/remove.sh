#!/usr/bin/env bash
if screen -ls | grep -q '\.vanillaswirl\.'; then
    echo "VanillaSwirl Error: cannot remove worlds while running."
    exit 1
fi
if [ -z "$1" ] || [ ! -d "servers/$1" ]; then
    echo "VanillaSwirl Error: a world name argument is required."
    exit 1
fi
mv "servers/$1" removed/
scripts/update_datapack.sh
