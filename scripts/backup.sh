#!/usr/bin/env bash
if scripts/are_servers_running; then
    echo "VanillaSwirl Error: cannot backup when servers are running."
    exit 1
fi
if [ -z "$(ls -A servers)" ]; then exit; fi
for server in servers/*; do
    name=${server#*/}
    mkdir -p backups/$name
    date=$(date +%Y-%m-%d_%H-%M-%S)
    tar -czf backups/$name/$date.tar.gz -C $server .
    find backups/$name -type f -mtime +14 -delete
done
