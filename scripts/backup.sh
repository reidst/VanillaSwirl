#!/usr/bin/env bash
if screen -ls | grep -q '\.vanillaswirl\.'; then
    echo "VanillaSwirl Error: cannot backup while running."
    exit 1
fi
if ! ls servers/*/ >/dev/null 2>&1; then
    echo "VanillaSwirl Error: there are no worlds to backup."
    exit 1
fi
backup_name="${1:-$(date +%Y-%m-%d_%H-%M-%S)}"
for server in servers/*/; do
    server_name=${server%/}
    server_name=${server_name#*/}
    mkdir -p backups/$server_name
    tar -czf backups/$server_name/$backup_name.tar.gz -C $server .
    find backups/$server_name -type f -mtime +14 -delete
done
