#!/usr/bin/env bash
if [ -z "$1" ] || [ ! -d "$1" ]; then
    echo "VanillaSwirl Error: a directory argument is required."
    exit 1
fi
server=${1%/}
server_name=${server##*/}
if [ -e servers/$server_name ]; then
    echo "VanillaSwirl Error: a world named $server_name already exists."
    exit 1
fi
if [ ! -f $server/server.jar ]; then
    echo "VanillaSwirl Error: the new world does not have a server.jar."
    exit 1
fi
if [ ! -x $server/run.sh ]; then
    echo "VanillaSwirl Error: the new world does not have an executable run.sh file."
    exit 1
fi
if ! grep -sq '^eula=true$' $server/eula.txt; then
    echo "VanillaSwirl Error: the new world does not agree to the Minecraft EULA."
    exit 1
fi
ports=($(grep -sh '^server-port=' servers/*/server.properties | cut -d'=' -f 2))
if ! grep -sq '^server-port=' $server/server.properties; then
    server_port=25565
    for port in "${ports[@]}"; do
        if ((server_port <= port)); then
            server_port=$((port + 1))
        fi
    done
else
    server_port=$(grep '^server-port=' $server/server.properties | tail -1 | cut -d'=' -f 2)
    for port in "${ports[@]}"; do
        if ((server_port == port)); then
            echo "VanillaSwirl Error: the new world has the same port as an existing world ($port)."
            exit 1
        fi
    done
fi
echo -e "\nserver-port=$server_port" >> $server/server.properties
echo "accepts-transfers=true" >> $server/server.properties
function_permission_level=$(grep -h '^function-permission-level=' $server/server.properties | tail -1 | cut -d'=' -f 2)
if [ -z $function_permission_level ] || ((function_permission_level < 3)); then
    echo "function-permission-level=3" >> $server/server.properties
fi
if grep -q '^server-port=25565$' $server/server.properties; then
    if ! grep -q '^motd=' $server/server.properties; then
        echo "motd=A VanillaSwirl Minecraft Server" >> $server/server.properties
    fi
fi
mv $server servers/
if screen -ls | grep -q '\.vanillaswirl\.'; then
    root=$(pwd)
    cd servers/$server_name
    screen -S vanillaswirl.$server_name -d -m ./run.sh
    cd $root
fi
scripts/update_datapack.sh
