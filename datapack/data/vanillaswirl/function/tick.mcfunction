scoreboard players reset @a[scores={vanillaswirl.rejoin=1..}] vanillaswirl.warp
scoreboard players reset @a vanillaswirl.rejoin

execute as @a[scores={vanillaswirl.warp=1..}] at @s run function vanillaswirl:warp

scoreboard players reset @a vanillaswirl.warp
scoreboard players enable @a vanillaswirl.warp
