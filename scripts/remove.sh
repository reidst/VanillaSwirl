#!/usr/bin/env bash
if screen -ls | grep -q '\.vanillaswirl\.'; then
    echo "VanillaSwirl Error: cannot remove servers while servers are running."
    exit 1
fi
if [ -z $1 ] || [ ! -d servers/$1 ]; then
    echo "VanillaSwirl Error: a server name argument is required."
    exit 1
fi
mkdir -p removed
mv servers/$1 removed/
scripts/update_datapack.sh
