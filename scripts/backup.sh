#!/usr/bin/env bash
if screen -ls | grep -q '\.vanillaswirl\.'; then
    echo "VanillaSwirl Error: cannot backup while running."
    exit 1
fi
if ! ls worlds/*/ >/dev/null 2>&1; then
    echo "VanillaSwirl Error: there are no worlds to backup."
    exit 1
fi
backup_name="${1:-$(date +%Y-%m-%d_%H-%M-%S)}"
for world in worlds/*/; do
    world_name=${world%/}
    world_name=${world_name#*/}
    mkdir -p backups/$world_name
    tar -czf backups/$world_name/$backup_name.tar.gz -C $world .
    find backups/$world_name -type f -mtime +14 -delete
done
