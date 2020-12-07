--[[
    https://pastebin.com/irRH1pk6
	Purpose is to go from start to end of wall and suck and attack back and forth
	
	chest behind it
	fuel below it
]]--

local utils, directions, loot, status = require("utils"), require("directions"), require("loot"), require("status")

local args = { ... }

function isEnd()
    local exists, block = turtle.inspect()
    return exists
end

function main()
	utils.setKeepInventory(loot.isLoot)
    -- slay, output to chest, reduce waste, finish when out of fuel or chest full
    while status.getOk() do
        directions.forward(false, true, true, false, isEnd) -- forward attack
        if not status.getOk() then break end
        directions.turnAround()
        directions.forward(false, true, true, false, isEnd) -- back attack
        directions.turnAround() -- face forward
        if not status.getOk() then break end
        directions.turnAround() -- if ok turn around and insert into chest
		utils.dropOffInventory()
		utils.refuelAtHome("up")
        directions.turnAround() -- turn back around
        if not status.getOk() then break end
    end
    directions.turnAround() -- turn around to get home
    directions.forward(false, true, true, true, isEnd) -- back attack
    utils.dropOffInventory()
    directions.turnAround() -- face forward
end


print("Slaaaaying!")
main()
print("Done Slaaaaying!")