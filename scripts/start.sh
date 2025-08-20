#!/usr/bin/env bash
if scripts/are_servers_running.sh; then
    echo "VanillaSwirl Error: servers are already running."
    exit 1
fi
if [ -z "$(ls -A servers/*)" ]; then
    echo "VanillaSwirl Error: there are no servers to start."
    exit 1
fi
root=$(pwd)
for server in servers/*; do
    name=${server#*/}
    if screen -ls vanillaswirl.$name >/dev/null; then continue; fi
    cd $root/$server
    screen -S vanillaswirl.$name -d -m ./run.sh
done
