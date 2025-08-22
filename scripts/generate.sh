#!/usr/bin/env bash
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
root=$(pwd)
for template_name in templates/*/; do
	template_name=${template_name%/}
	clean_name=${template_name#*/}
	clean_name=${template_name#*_}
	if [ ! -d $template_name ]; then continue; fi
	mkdir servers/$clean_name
	cp -r common/* servers/$clean_name/
	if ls -A $template_name/* >/dev/null 2>&1; then
		for template_file in $template_name/*; do
			if [ "${template_file##*/}" == "server.properties" ]; then
				printf '\n' >> servers/$clean_name/server.properties
				cat $template_file >> servers/$clean_name/server.properties
			else
				cp -r $template_file servers/$clean_name/
			fi
		done
	fi
	chmod u+x servers/$clean_name/run.sh
	printf '\nserver-port=%s' "${port}" >> servers/$clean_name/server.properties
	sed -i '/^[[:space:]]*$/d' servers/$clean_name/server.properties
	(( port++ ))
	if ls servers/$clean_name/*.mcfunction >/dev/null 2>&1; then
		world_name=$(grep '^level-name=' servers/$clean_name/server.properties | tail -1)
		world_name=${world_name#*=}
		world_name=${world_name:-world}
		mkdir -p servers/$clean_name/$world_name/datapacks/vanillaswirl_local
		cp datapack/pack.mcmeta servers/$clean_name/$world_name/datapacks/vanillaswirl_local/
		cd servers/$clean_name/$world_name
		mkdir -p datapacks/vanillaswirl_local/data/vanillaswirl_local/function
		mkdir -p datapacks/vanillaswirl_local/data/minecraft/tags/function
		mv ../*.mcfunction datapacks/vanillaswirl_local/data/vanillaswirl_local/function/
		cd datapacks/vanillaswirl_local/data/minecraft/tags/function
		echo '{"values":["vanillaswirl_local:load"]}' > load.json
		echo '{"values":["vanillaswirl_local:tick"]}' > tick.json
		cd $root
	fi
done
