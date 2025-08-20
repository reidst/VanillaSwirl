# VanillaSwirl
**An unmodded multi-world Minecraft server framework**

## About
`VanillaSwirl` is a Minecraft server framework that facilitates hosting multiple
Minecraft servers simultaneously. It also includes a datapack featuring a
custom dialog menu that can teleport players between these servers.

## Installation
1. Download the repository to your server:
```sh
$ git clone https://github.com/reidst/VanillaSwirl.git
$ cd VanillaSwirl
```
2. Configure your servers. See [Configuration](#configuration) below.
3. Write your hostname to the `hostname` file (this is the same address you
would enter into the `Server Address` field in Minecraft's multiplayer menu).
For instance, if your server has the domain name `mycoolmcserver.net`, then run:
```sh
$ echo "mycoolmcserver.net" > hostname.txt
```
4. Build the server:
```sh
$ scripts/generate.sh
```
This converts each template subdirectory into a real server under the `servers/`
directory. Server generation can fail if a template subdirectory would overwrite
an existing server, or if two templates' names collide with one another
(ignoring the sorting prefix).

5. From here, servers can be started, stopped, and backed up in bulk using the
provided scripts (`scripts/(start,stop,backup).sh`).

## Configuration
- Files common to all servers (e.g., `eula.txt`) go in the `common/` directory.
- For each world you want to serve, create a unique subdirectory within the
`templates/` directory. Files in a template subdirectory will be unique to a
world and will overwrite common files upon server generation (with the exception
of `server.properties` files, for which the template version will append the
common version). An empty template subdirectory is valid, merely describing a
world with no unique settings.
- Templates are sorted lexicographically with the first template getting the
default server port (25565) and subsequent templates getting subsequent ports.
Ordering can be controlled by prefixing template subdirectory names with a
string followed by an underscore (e.g., `0_hub`, `1_survival`, `2_skywars`,
etc.).

## Running
Each server is run within a `screen` session. For example, a server created from
`templates/0_hub` would be run within a screen session named `minecraft.hub`,
and its console could be accessed via `screen -r minecraft.hub`. However, if you
wish to run console commands, you most likely want to run them globally; you can
do so via `scripts/global_command.sh`. For example, the following usage:
```sh
$ scripts/global_command.sh "kick AnnoyingPerson"
```
would run the `/kick AnnoyingPerson` command on all servers.

## Notes
This project was made in a few afternoons by a stubborn Minecrafter who wanted
to host a small server network and refused to install server-side mods. That is
to say, this is a personal project with personal goals. Don't expect me to
respond to issues or pull requests with any urgency (but if you wish to fork the
project and continue it yourself, please feel free to do so).
