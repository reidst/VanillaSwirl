# VanillaSwirl
**An unmodded multi-world Minecraft server framework**

## Table of Contents
- [About](#about)
- [Installation](#installation)
- [Usage](#usage)
    - [`generate.sh`](#generatesh)
    - [`start.sh`](#startsh)
    - [`stop.sh [time]`](#stopsh-time)
    - [`add.sh <path>`](#addsh-path)
    - [`remove.sh <world>`](#removesh-world)
    - [`backup.sh [name]`](#backupsh-name)
    - [`global_command.sh <command>`](#global_commandsh-command)
- [Templates](#templates)
    - [Appended files](#appended-files)
    - [`.mcfunction` files](#mcfunction-files)
    - [Necessary common configuration](#necessary-common-configuration)
- [Datapacks](#datapacks)
- [Notes](#notes)

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
2. Install a Minecraft server jarfile:
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
would enter into the "Server Address" field in Minecraft's multiplayer menu):
```sh
$ echo 'myserverdomainname.net' > hostname.txt
```
5. Create a world template for each world you wish to host (see
[Templates](#templates) for details), then generate them:
```sh
$ scripts/generate.sh
```
6. If you have existing servers you wish to add to VanillaSwirl, you can do so:
```sh
$ scripts/add.sh <old server path>
```
7. Run VanillaSwirl:
```sh
$ scripts/start.sh
```
Worlds can be stopped, backed up, or removed using the provided scripts; see
[Usage](#usage).

## Usage
VanillaSwirl is controlled through scripts in the `scripts/` directory.

### `generate.sh`
Convert each world template into a physical server. This script does not run
under any of the following conditions:
- there are no templates to generate
- `hostname.txt` is missing or empty
- multiple templates request the same port
- a template requests the same port as an existing world
- a template has the same name as an existing world
- not all worlds would have an executable `run.sh` file

Each template generates an individual Minecraft server with the same name living
in the `servers/` subdirectory.

If a port is not specified (i.e., the `server-port` field of the template's
`server.properties` file is missing), the lowest available port starting at
25565 is assigned. Templates are generated in lexicographical order, so a
template named `b` without a specified port would receive a port after a
template named `a` without a specified port. This is really only relevant for
port 25565, to which players joining a VanillaSwirl server will be sent each
time they join the server (unless players explicitly specify a different port).

### `start.sh`
Start each world as a server running in its own screen session. This script does
not run under any of the following conditions:
- VanillaSwirl is already running
- worlds have not yet been generated

Screen session names take the form `<pid>.vanillaswirl.<world_name>`, and the
sessions automatically end once the contained `run.sh` process ends. If you wish
to run a console command in a world, use the following:
```sh
# to run a command without seeing the output:
$ screen -S vanillaswirl.<world_name> -X stuff '<your_command>^M'
# to run a command interactively:
$ screen -r vanillaswirl.<world_name>
$ <your_command>
# press Ctrl-a Ctrl-d to detach the screen
```
If you wish to run a command on every world simultaneously, see
[global_command.sh](#global_commandsh).

### `stop.sh [time]`
Send a warning message to all worlds, wait some time, then stop them. This
script does not run under any of the following conditions:
- a time argument is given that is not a nonnegative integer
- VanillaSwirl is not running

The `time` argument is optional, defaulting to 30 seconds.

### `add.sh <path>`
Add an existing Minecraft server as a VanillaSwirl world. This script does not
run under any of the following conditions:
- a path argument that is a valid directory is not given
- the server has the same name as an existing world
- the server does not contain all of the following:
    - `server.jar`
    - an executable `run.sh`
    - an agreement to the Minecraft EULA
- the server runs on the same port as an existing world

The server given will be moved into the `servers/` directory, assigned a port if
one is not declared, and modified to be compatible with the VanillaSwirl
datapack (see the `server.properties` fields in
[Necessary common configuration](#necessary-common-configuration)). The datapack
is then regenerated and reloaded on all worlds.

### `remove.sh <world>`
Remove a world. This script does not run under any of the following conditions:
- VanillaSwirl is running
- a world argument that is the name of a `servers/` subdirectory is not given

The world is moved to the `removed/` directory; deletion of the world must be
done manually.

### `backup.sh [name]`
Create a backup of each world. This script does not run under any of the
following conditions:
- VanillaSwirl is running
- worlds have not yet been generated

The `name` field is optional, defaulting to `yyyy-mm-dd_HH-MM-SS.tar.gz`. For
each world named `<server_name>`, there will be a corresponding
`backups/<server_name>/` subdirectory that holds the backups for that world.

### `global_command.sh <command>`
Send a console command to all worlds. This script does not run under any of the
following conditions:
- a command argument is not provided
- VanillaSwirl is not running

## Templates
For each world you want to serve, create a unique subdirectory within the
`templates/` directory. Files in a template subdirectory will be unique to the
world generated by that template. Template subdirectories are allowed to be
empty, in which case a world would be generated with no unique files.

Files that should be common to all worlds (e.g., `eula.txt` and `server.jar`) go
in the `common/` directory. Each world generated will have a copy of these
files. If a file within a template subdirectory has the same name as a common
file, the template file will overwrite the common one (with exceptions; see
[Appended files](#appended-files)).

### Appended files
If both a common and a template `server.properties` exist, the fields in the
template file will be appended to those from the common file. This allows for a
per-field, rather than a per-file, override system. 

For example, if the field `pvp=false` exists in a common file and `pvp=true`
exists in a template file, the end result will be a world in which `pvp=true` is
applied.

### `.mcfunction` files
Minecraft function files in a configuration directory will generate a datapack;
see [Template datapacks](#template-datapacks) for more information.

### Necessary common configuration
Each world is required to have all of the following:
- an executable `run.sh` that starts the world's `server.jar` and sets the JVM's
and Minecraft server's flags.
- an `eula.txt` with the field `eula=true`. The Minecraft server will not start
without, so VanillaSwirl also requires it. For legal reasons, VanillaSwirl does
not provide it automatically.
- a `server.properties` with the fields `accepts-transfers=true` and
`function-permission-level=3`. This cannot be overridden; VanillaSwirl ensures
these fields are set.

## Datapacks
### Builtin datapack
The datapack provided by VanillaSwirl enables players to warp between worlds via
the vanilla `/transfer` command. It can be triggered from a custom dialog menu
named "Warp Menu," which can be found in the pause menu or by pressing the quick
actions button in-game (defaults to <kbd>G</kbd>). The datapack is accessible
from each world as `file/vanillaswirl` and operates under the `vanillaswirl`
namespace.

### Template datapacks
If `.mcfunction` files are provided as world configuration files, they are
compiled to another datapack, accessible from each world as
`file/vanillaswirl_local` and operating under the `vanillaswirl_local`
namespace. This datapack will add the `vanillaswirl_local:load` and
`vanillaswirl_local:tick` functions to the respective `#minecraft:local` and
`#minecraft:tick` function tags.

## Notes
This project was made by a stubborn Minecrafter who wanted to host a small
server network and refused to install server-side mods. That is to say, this is
a personal project with personal goals. Don't expect me to respond to issues or
pull requests with any urgency (but if you wish to fork the project and continue
it yourself, please feel free to do so).
