--[[
	Originally Sourced from:
	http://www.computercraft.info/forums2/index.php?/topic/19777-kings-branch-mining-script/
	Slot 1: Bucket
	Slot 16: Fuel

	chest for fuel above
	chest for loot below
]]--
 
local inventory, sys, directive, metadata = require("inventory"), require("sys"), require("directive"), require("metadata")
local directions, minerals = require("directions"), require("minerals")

local args, bucket, branchSize = { ... }, 1, 15

local lavaRefuel = true

if turtle.getItemCount(bucket) ~= 1 then
	sys.log("No bucket in slot " .. tostring(bucket) .. " continuing without lava refuel option")
	lavaRefuel = false
else
	-- set inv start to 2 if bucket exists
	inventory.setInvStart(2)
end

-- refuel with lava
function refuelLava(direction)
	local place
	if not direction then
		place = turtle.place
	elseif direction:lower() == "down" then
		place = turtle.placeDown
	elseif direction:lower() == "up" then
		place = turtle.placeUp
	end
	turtle.select(bucket)
	place()
	if place() and turtle.refuel() then
		turtle.select(bucket)
		sys.log("[refuelLava]: Refueled using lava source!")
	end
	turtle.select(inventory.getInvStart())
end

-- recursive method for vein mining
function mineOre(direction, block)
	local veinLength = 0 --local vein branch
	local fwd, rev
	if not direction then
		fwd = directions.forward
		rev = directions.backward
	elseif direction:lower() == "down" then
		fwd = directions.down
		rev = directions.up
	elseif direction:lower() == "up" then
		fwd = directions.up
		rev = directions.down
	end
	if minerals.hasSpaceToHarvest(block) then
		sys.log("[mineOre]: Attempting to mine Ore! "  .. metadata.blockToString(block))
		turtle.select(inventory.getInvStart())
		fwd(true, true, false)
		sys.log("[mineOre]: Dug ore!")
		veinLength = veinLength + 1
		directions.check(blockRoutine) -- finish vein and leave un touched non main vein ores alone
	else
		sys.log("[mineOre]: No Space to Harvest This Ore! " .. metadata.blockToString(block))
	end
	-- return out of vein
	while veinLength > 0 do
		rev(true, true, false)
		veinLength = veinLength - 1
	end
end

-- vein direction routine
function blockRoutine(direction)
	-- inspect block in direction, based on type do action
	-- ensure original location + direction are maintained at end of routine
	-- cases: lava, chest, ore, ignore
	local exists, block = metadata.inspect(direction)
	if not exists then
		return
	elseif minerals.isLava(block) and lavaRefuel then 
		refuelLava(direction)
	elseif metadata.isChest(block) then
		return -- todo
	elseif minerals.isMineral(block) then
		mineOre(direction, block)
	end
end

-- branch size
function fork()
	for i = 1, branchSize do
		directions.forward(true, true, false)
		directions.check(blockRoutine) -- check for veins
	end
	sys.log("[branch]: Returning!")
	-- 180 turn back
	directions.turnAround()
	for i = 1, branchSize do
		directions.forward(true, true, false)
	end
	sys.log("[branch]: Returned!")
end

local distance = 0
function main()
	-- go to 3 for branching
	if distance == 0 then
		while directions.forward(false, true, false) do 
			distance = distance + 1
		end
	end
	for i = 1, 3 do
		directions.forward(true, true, false)
		distance = distance + 1
		-- check around
		directions.check(blockRoutine)
	end
	directions.turnLeft()
	sys.log("[main]: Initiating branch Left!")
	fork() -- spits back backwards
	sys.log("[main]: Initiating branch Right!")
	fork()
	-- face forward
	directions.turnRight()
	directions.goToPosition(distance, 0, 0, "forward")
end


inventory.setKeepInventory(minerals.isResource)
directive.run("miner", main)