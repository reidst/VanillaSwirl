summon marker ~ ~ ~ {Tags:["vanillaswirl.warpmarker"]}
execute \
    store result entity @n[tag=vanillaswirl.warpmarker] Air short 1 \
    run scoreboard players get @s vanillaswirl.warp
function vanillaswirl:transfer with entity @n[tag=vanillaswirl.warpmarker]
kill @n[tag=vanillaswirl.warpmarker]
