#!/usr/bin/env bash
if ! ls templates/*/ >/dev/null 2>&1; then
	echo "VanillaSwirl Error: template directory empty."
	exit 1
fi
if [ ! -f "hostname.txt" ] || [ -z "$(cat hostname.txt)" ]; then
	echo "VanillaSwirl Error: missing or empty hostname.txt file."
	exit 1
fi
for template in templates/*/; do
	template=${template%/}
	template_name=${template#*/}
	port="$(grep -sh '^server-port=' $template/server.properties | tail -1 | cut -d'=' -f 2)"
	if [ -n "$port" ]; then
		for other in templates/*/; do
			other=${other%/}
			other_name=${other#*/}
			if [ "$template" == "$other" ]; then continue; fi
			if grep -sq "^server-port=$port\$" $other/server.properties; then
				echo "VanillaSwirl Error: templates $template_name and $other_name both request port $port."
				exit 1
			fi
		done
	fi
	if ls worlds/*/ >/dev/null 2>&1; then
		for world in worlds/*/; do
			world=${world%/}
			world_name=${world#*/}
			if [ "$template_name" == "$world_name" ]; then
				echo "VanillaSwirl Error: a world named $world_name already exists."
				exit 1
			fi
			if [ -n "$port" ] && grep -q "^server-port=$port\$" $world/server.properties; then
				echo "VanillaSwirl Error: port $port (requested by template $template_name) is already in use by $world_name."
				exit 1
			fi
		done
	fi
done
if [ ! -x common/run.sh ]; then
	for template in templates/*/; do
		template=${template%/}
		if [ ! -x $template/run.sh ]; then
			echo "VanillaSwirl Error: template ${template#*/} has no executable run.sh (and no common run.sh exists)."
			exit 1
		fi
	done
fi

root=$(pwd)
for template in templates/*/; do
	template=${template%/}
	template_name=${template#*/}
	mkdir worlds/$template_name
	cp -r common/* worlds/$template_name/
	if ls $template/* >/dev/null 2>&1; then
		for template_file in $template/*; do
			if [ "${template_file##*/}" == "server.properties" ]; then
				echo >> worlds/$template_name/server.properties
				cat $template_file >> worlds/$template_name/server.properties
			else
				cp -r $template_file worlds/$template_name/
			fi
			rm -r $template_file
		done
	fi
	rmdir $template
	chmod u+x worlds/$template_name/run.sh
	if ! grep -q '^server-port=[0-9]' worlds/$template_name/server.properties; then
		port=25565
		while grep -q "^server-port=$port\$" {worlds,templates}/*/server.properties; do
			((port++))
		done
		echo -e "\nserver-port=$port" >> worlds/$template_name/server.properties
	fi
	echo -e "\naccepts-transfers=true" >> worlds/$template_name/server.properties
	function_permission_level=$(grep -h '^function-permission-level=' worlds/$template_name/server.properties | tail -1 | cut -d'=' -f 2)
	function_permission_level=${function_permission_level:-2}
	if ((function_permission_level < 3)); then
		echo -e "\nfunction-permission-level=3" >> worlds/$template_name/server.properties
	fi
	if grep -q '^server-port=25565' worlds/$template_name/server.properties; then
		if ! grep -q '^motd=' worlds/$template_name/server.properties; then
			echo -e "\nmotd=A VanillaSwirl Minecraft Server" >> worlds/$template_name/server.properties
		fi
	fi
	if ls worlds/$template_name/*.mcfunction >/dev/null 2>&1; then
		level_name=$(grep '^level-name=' worlds/$template_name/server.properties | tail -1)
		level_name=${level_name#*=}
		level_name=${level_name:-world}
		mkdir -p worlds/$template_name/$level_name/datapacks/vanillaswirl_local
		cp datapack/pack.mcmeta worlds/$template_name/$level_name/datapacks/vanillaswirl_local/
		cd worlds/$template_name/$level_name
		mkdir -p datapacks/vanillaswirl_local/data/vanillaswirl_local/function
		mkdir -p datapacks/vanillaswirl_local/data/minecraft/tags/function
		mv ../*.mcfunction datapacks/vanillaswirl_local/data/vanillaswirl_local/function/
		cd datapacks/vanillaswirl_local/data/minecraft/tags/function
		echo '{"values":["vanillaswirl_local:load"]}' > load.json
		echo '{"values":["vanillaswirl_local:tick"]}' > tick.json
		cd $root
	fi
done
scripts/update_datapack.sh
if screen -ls | grep -q '\.vanillaswirl\.'; then
	for world in worlds/*/; do
		world=${world%/}
		name=${world#*/}
		if ! screen -ls | grep -q '\.vanillaswirl\.'"${name}[[:space:]]"; then
			cd $root/$world
			screen -S ".vanillaswirl.$name" -d -m ./run.sh
		fi
	done
fi
