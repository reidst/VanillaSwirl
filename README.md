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
    - [Template names](#template-names)
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
7. Start the server:
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
- servers have already been generated
- no templates have been provided
- `hostname.txt` is missing or empty
- there are multiple templates with the same name (ignoring sorting prefixes)
- not all worlds would have an executable `run.sh` file

Physical servers exist as `servers/` subdirectories named after their
corresponding templates (with sorting prefixes removed; see
[Template names](#template-names)).

### `start.sh`
Start each world as a server running in its own screen session. This script does
not run under any of the following conditions:
- servers are already running
- servers have not yet been generated

Screen session names take the form `<pid>.vanillaswirl.<world_name>`, and the
sessions automatically end once the contained server process ends. If you wish
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
Send a warning message to all worlds, waits some time, then stops them. This
script does not run under any of the following conditions:
- a time argument is given that is not a nonnegative integer
- no servers are running

The `time` argument is optional, defaulting to 30 seconds.

### `add.sh <path>`
Add an existing Minecraft server as a VanillaSwirl world. This script does not
run under any of the following conditions:
- a path argument that is a valid directory is not given
- the new server has the same name as an existing server
- the new server does not contain all of the following:
    - `server.jar`
    - an executable `run.sh`
    - an agreement to the Minecraft EULA
- the new server runs on the same port as an existing server

The server given will be moved into the `servers/` directory, assigned a port if
one is not declared, and modified to be compatible with the VanillaSwirl
datapack (see
[Necessary common configuration](#necessary-common-configuration)). The datapack
is then regenerated and reloaded on all worlds.

### `remove.sh <world>`
Remove a world. This script does not run under any of the following conditions:
- servers are running
- a world argument that is the name of a `servers/` subdirectory is not given

The server that hosted the world is moved to the `removed/` subdirectory;
deletion of the world must be done manually.

### `backup.sh [name]`
Create a backup of each world. This script does not run under any of the
following conditions:
- servers are running
- servers have not yet been generated

The `name` field is optional, defaulting to `yyyy-mm-dd_HH-MM-SS.tar.gz`. For
each world named `<server_name>`, there will be a corresponding
`backups/<server_name>/` subdirectory that holds the backups for that world.

### `global_command.sh <command>`
Send a console command to all worlds. This script does not run under any of the
following conditions:
- a command argument is not provided
- no servers are running

## Templates
For each world you want to serve, create a unique subdirectory within the
`templates/` directory. Files in a template subdirectory will be unique to the
world generated by that template. Template subdirectories are allowed to be
empty, meaning a world will be generated with no unique files.

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

### Template names
Server ports are assigned by the lexicographical order of the template
subdirectory names. This means the first template is given the port 25565, the
next is given 25566, and so on.

To allow for greater control over the names of generated worlds, templates are
stripped of all characters up to and including the first underscore when being
generated into worlds. Therefore, template names are expected to take the form
`<prefix>_<name>`. No two templates may have the same `<name>`, even if their
`<prefix>`es do not match.

For example, the templates `0_hub`, `1_creative_sandbox`, and `2_hardcore` would
generate servers named `hub` (running on port 25565), `creative_sandbox`
(25566), and `hardcore` (25567). They would appear in the
[Warp Menu](#builtin-datapack) as "Hub", "Creative Sandbox", and "Hardcore."

### Necessary common configuration
The following files are required by each world and therefore come preinstalled
under `common/`:
- `run.sh` calls the java runtime and decides parameters such as memory
limitations. This can be modified or overridden on a per-world basis.
- `server.properties` with the fields `accepts-transfers=true` and
`function-permission-level=3` enables the builtin datapack to warp players
between worlds. Do not modify or override these fields.

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
This project was made in a few afternoons by a stubborn Minecrafter who wanted
to host a small server network and refused to install server-side mods. That is
to say, this is a personal project with personal goals. Don't expect me to
respond to issues or pull requests with any urgency (but if you wish to fork the
project and continue it yourself, please feel free to do so).
