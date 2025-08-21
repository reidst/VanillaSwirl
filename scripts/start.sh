#!/usr/bin/env bash
if screen -ls | grep -q '\.vanillaswirl\.'; then
    echo "VanillaSwirl Error: servers are already running."
    exit 1
fi
if ! ls servers/*/ >/dev/null 2>&1; then
    echo "VanillaSwirl Error: there are no servers to start."
    exit 1
fi
root=$(pwd)
for server in servers/*; do
    cd $root/$server
    screen -S vanillaswirl.${server#*/} -d -m ./run.sh
done
