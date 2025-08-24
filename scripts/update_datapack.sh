#!/usr/bin/env bash
function snake_to_title_case {
    local name="$1"
    for letter in {a..z}; do
        upper=${letter^}
        name=${name/#$letter/$upper}
        name=${name//_$letter/_$upper}
    done
    echo "${name//_/' '}"
}

if ! ls worlds/*/ >/dev/null 2>&1; then exit; fi
if [ ! -f hostname.txt ] || [ -z "$(cat hostname.txt)" ]; then
    echo "VanillaSwirl Error: missing or empty hostname.txt file."
    exit 1
fi
actions=''
for world in worlds/*/; do
    world=${world%/}
    world_name=${world#*/}
    world_display_name="$(snake_to_title_case $world_name)"
    port="$(grep -sh '^server-port=' $world/server.properties | tail -1 | cut -d'=' -f 2)"
    if [ -z "$port" ]; then
        echo "VanillaSwirl Error: unable to update datapacks because the world $world_name has no port."
        exit 1
    fi
    if [ -n "$actions" ]; then
        actions+=','
    fi
    actions+="{\"label\":\"Warp to ${world_display_name}\",\"action\":{\"type\":\"run_command\",\"command\":\"trigger vanillaswirl.warp set $port\"}}"
done
for world in worlds/*/; do
    level_name="$(grep -sh '^level-name=' $world/server.properties | tail -1 | cut -d'=' -f 2)"
    level_name=${level_name:-world}
    datapack_path=$world/$level_name/datapacks/vanillaswirl
    mkdir -p $datapack_path
    rm -r $datapack_path 2>/dev/null
    cp -r datapack/ $datapack_path
    sed -i 's/\[\]/\['"$actions"'\]/' $datapack_path/data/vanillaswirl/dialog/warp_menu.json
    sed -i "s/localhost/$(cat hostname.txt)/" $datapack_path/data/vanillaswirl/function/transfer.mcfunction
done
if screen -ls | grep -q '\.vanillaswirl\.'; then
    scripts/global_command.sh reload
fi
