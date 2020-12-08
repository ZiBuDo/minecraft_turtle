--[[
	Purpose is to go from start to end of wall and suck and attack back and forth
	
	chest behind it
	fuel below it
]]--

local inventory, directions, loot, directive = require("/inventory"), require("/directions"), require("/loot"), require("/directive")

local args = { ... }

function isEnd()
    local exists, block = turtle.inspect()
    return exists
end

function main()
    while not isEnd() and directions.forward(false, true, true) do end -- forward attack
    directions.turnAround()
    while not isEnd() and directions.forward(false, true, true) do end -- forward attack
    directions.turnAround() -- face forward
end

directions.setChestDirection("backward")
directions.setRefuelDirection("down")
inventory.setKeepInventory(loot.isLoot)
directive.run("dungeon", main)