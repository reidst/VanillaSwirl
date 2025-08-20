#!/usr/bin/env bash
function join_by {
	local IFS="$1"
	shift
	echo "$*"
}
function detect_duplicates {
	local templates=()
	local len=0
	local name i j
	for name in templates/*; do
		local clean_name=${name#*/}
		clean_name=${clean_name#*_}
		templates+=($clean_name)
		(( len++ ))
	done
	for (( i=0; i<len; i++ )); do
		for (( j=0; j<len; j++ )); do
			if (( i == j )); then continue; fi
			if [ "${templates[$i]}" == "${templates[$j]}" ]; then
				echo "VanillaSwirl Error: two templates have the same name (${templates[$i]})."
				exit 1
			fi
		done
	done
}

if [ -n "$(ls -A servers/)" ]; then
	echo "VanillaSwirl Error: servers have already been generated."
	exit 1
fi
if [ -z "$(ls -A templates/)" ]; then
	echo "VanillaSwirl Error: template directory empty."
	exit 1
fi
if [ ! -f "hostname.txt" ] || [ -z "$(cat hostname.txt)" ]; then
	echo "VanillaSwirl Error: missing or empty hostname.txt file."
	exit 1
fi
detect_duplicates
if scripts/are_servers_running.sh; then
	echo "VanillaSwirl Error: cannot generate new servers while old ones are running."
	exit 1
fi

port=25565
warp_buttons=()
for name in templates/*; do
	clean_name=${name#*/}
	clean_name=${name#*_}
	if [ ! -d $name ]; then continue; fi
	mkdir servers/$clean_name
	cp common/* servers/$clean_name/
	if [ -n "$(ls -A $name)" ]; then
		for file in $name/*; do
			if [ "${file##*/}" == "server.properties" ]; then
				cat $file >> servers/$clean_name/server.properties
			else
				cp $file servers/$clean_name/
			fi
		done
	fi
	echo "server-port=$port" >> servers/$clean_name/server.properties
	warp_buttons+=("{\"label\":\"Warp to ${clean_name^}\",\"action\":{\"type\":\"run_command\",\"command\":\"trigger server.warp set $port\"}}")
	(( port++ ))
done

cp -r datapack datapack.tmp
button_list=$(join_by ',' "${warp_buttons[@]}")
sed -i 's/\[\]/\['"$button_list"'\]/' datapack.tmp/data/server/dialog/warp_menu.json
server_hostname=$(cat hostname.txt)
sed -i "s/localhost/$server_hostname/" datapack.tmp/data/server/function/transfer.mcfunction
for server in servers/*; do
	mkdir -p $server/world/datapacks
	cp -r datapack.tmp $server/world/datapacks/server
done
rm -r datapack.tmp
