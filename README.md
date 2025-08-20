# VanillaSwirl
**An unmodded multi-world Minecraft server framework**

## About
**_VanillaSwirl_** is a server framework for _Minecraft: Java Edition_ that
facilitates hosting multiple Minecraft servers (referred to here as "worlds")
simultaneously. It also includes a datapack featuring a custom dialog menu that
can teleport players between these worlds.

## Installation
1. Download the repository to your host machine:
```sh
$ git clone https://github.com/reidst/VanillaSwirl.git
$ cd VanillaSwirl
```
2. Install a Minecraft `server.jar`:
```sh
$ wget -O common/server.jar <some URL>
```
> Note: because players can move between worlds without restarting their client,
every world's server version must be compatible with a common client version. In
almost every case, this means using a common server version.

3. Agree to the [Minecraft EULA](https://aka.ms/MinecraftEULA):
```sh
echo 'eula=true' > common/eula.txt
```
4. Write your hostname to the `hostname.txt` file (this is the same address you
would enter into the `Server Address` field in Minecraft's multiplayer menu):
```sh
$ echo 'myserverdomainname.net' > hostname.txt
```
5. Configure your worlds. See [Configuration](#configuration) below.
6. Build your worlds, generating a separate server in the `servers/` directory
for each world template:
```sh
$ scripts/generate.sh
```

From here, worlds can be started, stopped, and backed up in bulk using the
provided scripts (`scripts/(start,stop,backup).sh`). Note that worlds cannot be
re-generated, started, or backed up if worlds are already running.

## Configuration
- Files common to all worlds (e.g., `eula.txt`) go in the `common/` directory.
- For each world you want to serve, create a unique subdirectory within the
`templates/` directory. Files in a template subdirectory will be unique to a
world and will overwrite common files upon server generation (with the exception
of `server.properties` files, for which the template version will append the
common version). An empty template subdirectory is valid, merely describing a
world with no unique settings.
- Files in a template ending in `.mcfunction` will be converted into a datapack
local to the world. `load.mcfunction` and `tick.mcfunction` files will be added
to the respective `#minecraft:load` and `#minecraft:tick` function tags.
- Templates are sorted lexicographically with the first template getting the
default server port (25565) and subsequent templates getting subsequent ports.
- Template names are expected to take the form `<prefix>_<name>`. The prefix and
the following underscore are used to sort templates and are removed during
generation. All names must be unique and written in snake case. For example, the
templates `0_hub`, `1_creative_sandbox`, and `2_hardcore` would generate worlds
named Hub (running on port 25565), Creative Sandbox (25566), and Hardcore
(25567).

### Necessary common configuration
The following files are required by each world and therefore come preinstalled
under `common/`:
- `run.sh` calls the java runtime and decides parameters such as memory
limitations.
- `server.properties` with the fields `accepts-transfers=true` and
`function-permission-level=3` enables the builtin datapack to warp players
between worlds.

## Running
Each world is run within a `screen` session: a world created from
`templates/0_hub` would be run within a screen session named
`<pid>.vanillaswirl.hub`, and its console could be accessed via
`screen -r vanillaswirl.hub`. However, if you wish to run console commands, you
most likely want to run them across all worlds simultaneously; you can do so via
`scripts/global_command.sh`. For example, the following usage:
```sh
$ scripts/global_command.sh 'kick AnnoyingPerson'
```
would run the `/kick AnnoyingPerson` command on all worlds. If you wish to run a
command on a single world, do so via:
```sh
$ screen -S vanillaswirl.<world_name> -X stuff 'kick AnnoyingPerson^M'
```

## Notes
This project was made in a few afternoons by a stubborn Minecrafter who wanted
to host a small server network and refused to install server-side mods. That is
to say, this is a personal project with personal goals. Don't expect me to
respond to issues or pull requests with any urgency (but if you wish to fork the
project and continue it yourself, please feel free to do so).
