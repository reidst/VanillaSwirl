#!/usr/bin/env bash
if screen -ls | grep -q '\.vanillaswirl\.'; then
    echo "VanillaSwirl Error: already running."
    exit 1
fi
if ! ls worlds/*/ >/dev/null 2>&1; then
    echo "VanillaSwirl Error: there are no worlds to start."
    exit 1
fi
root=$(pwd)
for world in worlds/*/; do
    world=${world%/}
    cd $root/$world
    screen -S vanillaswirl.${world#*/} -d -m ./run.sh
done
