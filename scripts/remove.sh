#!/usr/bin/env bash
if screen -ls | grep -q '\.vanillaswirl\.'; then
    echo "VanillaSwirl Error: cannot remove servers while servers are running."
    exit 1
fi
if [ -z "$1" ]; then
    echo "VanillaSwirl Error: a server name argument is required."
    exit 1
fi
if [ ! -d "servers/$1" ]; then
    echo "VanillaSwirl Error: there is no server named $1."
    exit 1
fi
mv "servers/$1" removed/
scripts/update_datapack.sh
