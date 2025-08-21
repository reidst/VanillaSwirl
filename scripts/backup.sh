#!/usr/bin/env bash
if screen -ls | grep -q '\.vanillaswirl\.'; then
    echo "VanillaSwirl Error: cannot backup when servers are running."
    exit 1
fi
if [ -z "$(ls -A servers)" ]; then exit; fi
backup_name="${1:-$(date +%Y-%m-%d_%H-%M-%S)}"
for server in servers/*; do
    name=${server#*/}
    mkdir -p backups/$name
    tar -czf backups/$name/$backup_name.tar.gz -C $server .
    find backups/$name -type f -mtime +14 -delete
done
