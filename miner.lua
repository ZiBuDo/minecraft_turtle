--[[
	https://pastebin.com/3V9bKEbv
	Originally Sourced from:
	http://www.computercraft.info/forums2/index.php?/topic/19777-kings-branch-mining-script/
	Slot 1: Bucket
	Slot 16: Fuel

	chest for fuel above
	chest for loot below
]]--
 
local utils, status = require("utils"), require("status")
local directions = require("directions")

local args, distance, branch, vein, bucket, branchSize = { ... }, 0, 0, 0, 1, 15

local lavaRefuel = true

utils.clearOutLog()

if turtle.getItemCount(bucket) ~= 1 then
	print("No bucket in slot " .. tostring(bucket) .. " continuing without lava refuel option")
	lavaRefuel = false
else
	-- set inv start to 2 if bucket exists
	utils.setInvStart(2)
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
		utils.log("[refuelLava]: Refueled using lava source!")
	end
	turtle.select(utils.getInvStart())
end

-- recursive method for vein mining
function mineOre(direction, block)
	local veinLength = 0 --local vein branch
	local fwd, rev, dig, attack
	if not direction then
		fwd = forward
		rev = backward
	elseif direction:lower() == "down" then
		fwd = down
		rev = up
	elseif direction:lower() == "up" then
		fwd = up
		rev = down
	end
	if hasSpaceToHarvest(block) then
		utils.log("[mineOre]: Attempting to mine Ore! "  .. blockToString(block))
		turtle.select(invStart)
		fwd()
		utils.log("[mineOre]: Dug ore!")
		vein = vein + 1
		veinLength = veinLength + 1
		status.isOk() -- moved so check ok
		check() -- finish vein and leave un touched non main vein ores alone
	else
		utils.log("[mineOre]: No Space to Harvest This Ore! " .. blockToString(block))
	end
	-- return out of vein
	while veinLength > 0 do
		rev()
		veinLength = veinLength - 1
	end
end

-- vein direction routine
function blockRoutine(direction)
	-- inspect block in direction, based on type do action
	-- ensure original location + direction are maintained at end of routine
	-- cases: lava, chest, ore, ignore
	local exists, block = inspect(direction)
	if not exists then
		return
	elseif isLava(block) and lavaRefuel then 
		refuelLava(direction)
	elseif isChest(block) then
		return -- todo
	elseif isMineral(block) then
		mineOre(direction, block)
	end
end

-- branch size
function fork()
	for i = 1, branchSize do
		if not isAbleToContinueMining() then break end
		forward()
		branch = branch + 1
		if not status.isOk() then break end 
		check() -- check for veins
		if not status.getOk() then break end
	end
	utils.log("[branch]: Returning!")
	-- 180 turn back
	turnLeft()
	turnLeft()
	for i = 1, branch do
		forward()
	end
	utils.log("[branch]: Returned!")
	branch = 0
end

-- check fuel and refuel if possible
function fuelCheck()
	turtle.select(bucket)
	turtle.refuel()
	local threshold = fuelSafetyThreshold + distance + branch + vein
	turtle.select(invStart)
end

-- method to determine if it has space
function isAbleToContinueMining()
	-- space
	hasSpace()
	return ok
end

-- main loop using scoped globals
function main()
	status.isOk() -- init status
	-- go until back to non branched area
	utils.log("[main]: Going Back to Work!")
	while moveForward() and status.isOk() do
		distance = distance + 1
	end
	utils.log("[main]: Made It Back to end of tunnel!")
	while ok do
		-- go to 3 for branching
		for i = 1, 3 do
			if not isAbleToContinueMining() then break end
			forward()
			distance = distance + 1
			if not status.isOk() then break end -- quit for loop
			-- check around
			check()
			if not status.getOk() then break end -- quit for loop
		end
		if not status.getOk() then break end -- don't branch come home
		recordReducedDirections()
		turnLeft()
		utils.log("[main]: Initiating branch Left!")
		fork()
		-- face forward
		turnLeft()
		recordReducedDirections()
		if not status.getOk() then break end --not ok, don't run second branch
		turnRight()
		utils.log("[main]: Initiating branch Right!")
		fork()
		-- face forward
		turnRight()
		recordReducedDirections()
		if not status.getOk() then break end
	end
	--not ok, return to base
	utils.log("[main]: Returning to base!")
	-- 180 back down the tunnel
	turnLeft()
	turnLeft()
	-- brute force home
	repeat
		forward()
		distance = distance - 1
		recordReducedDirections()
	until distance == 0
	turnLeft()
	turnLeft()
end

utils.log("Starting!")
main()
utils.log("Finished")