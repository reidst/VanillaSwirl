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
	for name in templates/*/; do
		local clean_name=${name%/}
		clean_name=${clean_name#*/}
		clean_name=${clean_name#*_}
		templates+=($clean_name)
		(( len++ ))
	done
	for (( i=0; i<len; i++ )); do
		for (( j=0; j<len; j++ )); do
			if (( i == j )); then continue; fi
			if [ "${templates[$i]}" == "${templates[$j]}" ]; then
				echo "VanillaSwirl Error: there is more than one template named (${templates[$i]})."
				exit 1
			fi
		done
	done
}
function detect_missing_run {
	if [ -f common/run.sh ]; then return; fi
	for template_name in templates/*/; do
		template_name=${template_name%/}
		if [ ! -d $template_name ]; then continue; fi
		if [ ! -f $template_name/run.sh ]; then
			echo "VanillaSwirl Error: the template ${template_name#*/} has no run.sh (and no common run.sh exists)."
			exit 1
		fi
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
function generate_local_datapack (
	cd $1
	mkdir -p datapacks/server_local/data/server_local/function
	mkdir -p datapacks/server_local/data/minecraft/tags/function
	cp datapacks/server/pack.mcmeta datapacks/server_local/
	mv ../*.mcfunction datapacks/server_local/data/server_local/function/
	cd datapacks/server_local/data/minecraft/tags/function
	echo '{"values":["server_local:load"]}' > load.json
	echo '{"values":["server_local:tick"]}' > tick.json
)

if ls servers/*/ >/dev/null 2>&1; then
	echo "VanillaSwirl Error: servers have already been generated."
	exit 1
fi
if ! ls templates/*/ >/dev/null 2>&1; then
	echo "VanillaSwirl Error: template directory empty."
	exit 1
fi
if [ ! -f "hostname.txt" ] || [ -z "$(cat hostname.txt)" ]; then
	echo "VanillaSwirl Error: missing or empty hostname.txt file."
	exit 1
fi
detect_duplicates
detect_missing_run

port=25565
warp_buttons=()
for template_name in templates/*/; do
	template_name=${template_name%/}
	clean_name=${template_name#*/}
	clean_name=${template_name#*_}
	if [ ! -d $template_name ]; then continue; fi
	mkdir servers/$clean_name
	cp -r common/* servers/$clean_name/
	if ls -A "$template_name/*" >/dev/null 2>&1; then
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
for server in servers/*/; do
	server=${server%/}
	world_name=$(grep '^level-name=' $server/server.properties | tail -1)
	world_name=${world_name#*=}
	mkdir -p $server/$world_name/datapacks
	cp -r datapack.tmp $server/$world_name/datapacks/server
	if [ -f "$server/load.mcfunction" ] || [ -f "$server/tick.mcfunction" ]; then
		generate_local_datapack $server/$world_name
	fi
done
rm -r datapack.tmp
