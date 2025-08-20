summon marker ~ ~ ~ {Tags:["server.warpmarker"]}
execute \
    store result entity @n[tag=server.warpmarker] Air short 1 \
    run scoreboard players get @s server.warp
function server:transfer with entity @n[tag=server.warpmarker]
kill @n[tag=server.warpmarker]
