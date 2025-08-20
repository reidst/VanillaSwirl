scoreboard players reset @a[scores={server.rejoin=1..}] server.warp
scoreboard players reset @a server.rejoin

execute as @a[scores={server.warp=1..}] at @s run function server:warp

scoreboard players reset @a server.warp
scoreboard players enable @a server.warp
