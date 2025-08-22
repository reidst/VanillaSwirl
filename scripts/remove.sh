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
port=$(grep -sh '^server-port=' "servers/$1/server.properties" | tail -1 | cut -d'=' -f 2)
for server in servers/*/; do
    other_port=$(grep -sh '^server-port=' $server/server.properties | tail 1 | cut -d'=' -f 2)
    if ((port < other_port)); then
        sed -i 's/^server-port=[0-9]*$/server-port='"$((other_port - 1))/" $server/server.properties
    fi
done
mv "servers/$1" removed/
scripts/update_datapack.sh
