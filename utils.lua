--[[
	https://pastebin.com/Trsh048i
	Utility turtle methods
]]--

local sys = require("sys")

local fuelAmount, fuelSafetyThreshold, fuel, invStart, invEnd = nil, 256, 16, 1, 12

if turtle.getItemCount(fuel) == 0 then
	sys.log("No fuel found running on " .. tostring(turtle.getFuelLevel()))
end

local inventoryChecker

function utils.setKeepInventory(keep)
	inventoryChecker = keep
end

function utils.checkInventory(detail)
	if inventoryChecker then
		return inventoryChecker(detail)
	end
	return true
end

local utils = {}

function utils.setInvStart(s)
	invStart = s
end

function utils.setInvEnd(e)
	invEnd = e
end

function utils.getInvStart(s)
	return invStart
end

function utils.getInvEnd(e)
	return invEnd
end

-- method to reduce inv space
function utils.reduceInventory()
	-- reduce inventory (i = inv,j = later slots)
	for i = invStart, invEnd do
		turtle.select(i)
		for j = i + 1, invEnd do
			if turtle.getItemCount(j) > 0 and turtle.compareTo(j) then
				turtle.select(j)
				turtle.transferTo(i) -- j to i
				turtle.select(i)
			end
		end
	end
end

-- method to drop all no keep
function utils.dumpWaste()
	-- dump trash
	for i = invStart, invEnd do
		if turtle.getItemCount(i) > 0 and not utils.checkInventory(turtle.getItemDetail(i)) then
			turtle.select(i)
            turtle.drop()
		end
	end
	utils.reduceInventory()
	turtle.select(1)
end

-- refuel method
function utils.refuel()
	local currentLevel = turtle.getFuelLevel()
	if currentLevel < fuelSafetyThreshold then --check fuel
		sys.log("[fuelCheck]: Fuel Level Low!")
		if turtle.getItemCount(fuel) > 0 then
			sys.log("[fuelCheck]: Refueling!")
			repeat
				turtle.select(fuel)
			until turtle.refuel(1) or turtle.getSelectedSlot() == fuel
			if turtle.getFuelLevel() > currentLevel then
				sys.log("[fuelCheck]: Refuel Successful!")
			else
				sys.log("[fuelCheck]: Refuel Unsuccessful, Initiating return!")
				return false
			end
		end
	end
end

-- check fuel and refuel if possible
function utils.fuelCheck(threshold)
	utils.refuel()
	-- check to home
	if threshold > findMaxFuelLevel()  then
		sys.log("[fuelCheck]: Fuel Reserves Depleted!  Initiating return!")
		return false
	end
	return true
end

-- refuel method
function utils.refuelAtHome(direction)
	local suck
	if not direction then
		suck = turtle.suck
	elseif direction == "up" then
		suck = turtle.suckUp
	elseif direction == "down" then
		suck = turtle.suckDown
	end
	-- at top
	local count = turtle.getItemCount(fuel)
	suck(turtle.getItemSpace(fuel))
	if turtle.getItemCount(fuel) > count then
		sys.log("Refueled at home")
	end
end

-- drop off method
function utils.dropOffInventory(direction)
	local drop
	if not direction then
		drop = turtle.drop
	elseif direction == "up" then
		drop = turtle.dropUp
	elseif direction == "down" then
		drop = turtle.dropDown
	end
	local space = true
	-- at bottom
	for i = invStart, invEnd then
		if turtle.getItemCount(i) > 0 then
			turtle.select(i)
			if not drop() then
				space = false
			end
		end
	end
	return space
end


-- function to find max amount of fuel needed to get home [fuel amount is fuel value of source]
function utils.findMaxFuelLevel()
	local level = turtle.getFuelLevel()
	if turtle.getItemCount(fuel) > 1 then
		if not fuelAmount then
			turtle.select(fuel)
			turtle.refuel(1)
			fuelAmount = turtle.getFuelLevel() - level
			sys.log("[findMaxFuelLevel]: Found fuelAmount: "..fuelAmount)
		end
		return turtle.getItemCount(fuel) * fuelAmount + turtle.getFuelLevel()
	else
		return turtle.getFuelLevel()
	end
end

-- check if it has space to keep mining
function utils.hasSpace()
	utils.dumpWaste()
	local space = false
	for i = invStart, invEnd do
		if turtle.getItemCount(i) == 0 then
			space = true
		end
	end
	if not space then
		sys.log("[hasSpace]: Out of space!")
		return false
	end
	return true
end

return utils


-- if out of fuel then go home and refuel
-- if out of space then go home and drop off