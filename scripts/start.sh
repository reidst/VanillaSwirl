#!/usr/bin/env bash
if screen -ls | grep -q '\.vanillaswirl\.'; then
    echo "VanillaSwirl Error: already running."
    exit 1
fi
if ! ls servers/*/ >/dev/null 2>&1; then
    echo "VanillaSwirl Error: there are no worlds to start."
    exit 1
fi
root=$(pwd)
for server in servers/*/; do
    server=${server%/}
    cd $root/$server
    screen -S vanillaswirl.${server#*/} -d -m ./run.sh
done
