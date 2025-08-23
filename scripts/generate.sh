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
	clean_name=${template_name#*_}
	port="$(grep -sh '^server-port=' $template/server.properties | tail -1 | cut -d'=' -f 2)"
	for other_template in templates/*/; do
		other_template=${other_template%/}
		if [ $template == $other_template ]; then continue; fi
		other_template_name=${other_template#*/}
		other_clean_name=${other_template_name#*_}
		if [ $clean_name == $other_clean_name ]; then
			echo "VanillaSwirl Error: templates $template_name and $other_template_name have the same underlying name."
			exit 1
		fi
		if ! grep -sq '^server-port=' $other_template/server.properties; then continue; fi
		other_port=$(grep -h '^server-port=' $other_template/server.properties | tail -1 | cut -d'=' -f 2)
		if [ "$port" == "$other_port" ]; then
			echo "VanillaSwirl Error: templates $template_name and $other_template_name have the same port."
			exit 1
		fi
	done
	if ! ls servers/*/ >/dev/null 2>&1; then continue; fi
	for server in servers/*/; do
		server=${server%/}
		server_name=${server#*/}
		if [ "$clean_name" == "$server_name" ]; then
			echo "VanillaSwirl Error: a server named $server_name already exists."
			exit 1
		fi
		other_port=$(grep -h '^server-port=' $server/server.properties | tail -1 | cut -d'=' -f 2)
		if [ "$port" == "$other_port" ]; then
			echo "VanillaSwirl Error: port $port (requested by template $template_name) is already in use by $server_name."
			exit 1
		fi
	done
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
for template_name in templates/*/; do
	template_name=${template_name%/}
	clean_name=${template_name#*/}
	clean_name=${template_name#*_}
	mkdir servers/$clean_name
	cp -r common/* servers/$clean_name/
	if ls $template_name/* >/dev/null 2>&1; then
		for template_file in $template_name/*; do
			if [ "${template_file##*/}" == "server.properties" ]; then
				echo >> servers/$clean_name/server.properties
				cat $template_file >> servers/$clean_name/server.properties
			else
				cp -r $template_file servers/$clean_name/
			fi
			rm -r $template_file
		done
	fi
	rmdir $template_name
	chmod u+x servers/$clean_name/run.sh
	if ! grep -q '^server-port=[0-9]$' servers/$clean_name/server.properties; then
		port=25565
		while grep -q "^server-port=$port\$" servers/*/server.properties; do
			((port++))
		done
		echo -e "\nserver-port=$port" >> servers/$clean_name/server.properties
	fi
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
scripts/update_datapack.sh
if screen -ls | grep -q '\.vanillaswirl\.'; then
	for server in servers/*/; do
		server=${server%/}
		name=${server#*/}
		if ! screen -ls | grep -q '\.vanillaswirl\.'"${name}[[:space:]]"; then
			cd $root/$server
			screen -S ".vanillaswirl.$name" -d -m ./run.sh
		fi
	done
fi
