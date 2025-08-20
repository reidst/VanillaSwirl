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
function snake_to_title_case {
	local words
	IFS='_' read -a words <<< "$1"
	local len="${#words[@]}"
	for (( i=0; i<len; i++ )); do
		words[$i]=${words[$i]^}
	done
	local capitalized=$(join_by '_' "${words[@]}")
	printf '%s' "${capitalized//_/\ }"
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
for template_name in templates/*; do
	clean_name=${template_name#*/}
	clean_name=${template_name#*_}
	if [ ! -d $template_name ]; then continue; fi
	mkdir servers/$clean_name
	cp -r common/* servers/$clean_name/
	if [ -n "$(ls -A $template_name)" ]; then
		for template_file in $template_name/*; do
			if [ "${template_file##*/}" == "server.properties" ]; then
				printf '\n' >> servers/$clean_name/server.properties
				cat $template_file >> servers/$clean_name/server.properties
			else
				cp -r $template_file servers/$clean_name/
			fi
		done
	fi
	if ! grep -q '^level-name=' servers/$clean_name/server.properties; then
		printf '\nlevel-name=%s' "$clean_name" >> servers/$clean_name/server.properties
	fi
	printf '\nserver-port=%s' "${port}" >> servers/$clean_name/server.properties
	sed -i '/^[[:space:]]*$/d' servers/$clean_name/server.properties
	pretty_name=$(snake_to_title_case $clean_name)
	warp_buttons+=("{\"label\":\"Warp to ${pretty_name}\",\"action\":{\"type\":\"run_command\",\"command\":\"trigger server.warp set $port\"}}")
	(( port++ ))
done

cp -r datapack datapack.tmp
button_list=$(join_by ',' "${warp_buttons[@]}")
sed -i 's/\[\]/\['"$button_list"'\]/' datapack.tmp/data/server/dialog/warp_menu.json
server_hostname=$(cat hostname.txt)
sed -i "s/localhost/$server_hostname/" datapack.tmp/data/server/function/transfer.mcfunction
for server in servers/*; do
	world_name=$(grep '^level-name=' $server/server.properties | tail -1)
	world_name=${world_name#*=}
	mkdir -p $server/$world_name/datapacks
	cp -r datapack.tmp $server/$world_name/datapacks/server
done
rm -r datapack.tmp
