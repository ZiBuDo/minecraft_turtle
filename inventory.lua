--[[
	Inventory turtle methods
]]--

local sys = require("sys")

local inventory = {}

local fuelAmount, fuelSafetyThreshold, fuel, invStart, invEnd = nil, 256, 16, 1, 15

if turtle.getItemCount(fuel) == 0 then
	sys.log("No fuel found running on " .. tostring(turtle.getFuelLevel()))
end

local inventoryChecker

function inventory.getFuelSlot()
	return fuel
end

function inventory.getFuelSafetyThreshold()
	return fuelSafetyThreshold
end

function inventory.setKeepInventory(keep)
	inventoryChecker = keep
end

function inventory.checkInventory(detail)
	if inventoryChecker then
		return inventoryChecker(detail)
	end
	return true
end

function inventory.setInvStart(s)
	invStart = s
end

function inventory.setInvEnd(e)
	invEnd = e
end

function inventory.getInvStart()
	return invStart
end

function inventory.getInvEnd()
	return invEnd
end

-- method to reduce inv space
function inventory.reduceInventory()
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
function inventory.dumpWaste()
	-- dump trash
	for i = invStart, invEnd do
		if turtle.getItemCount(i) > 0 and not inventory.checkInventory(turtle.getItemDetail(i)) then
			turtle.select(i)
            turtle.drop()
		end
	end
	inventory.reduceInventory()
	turtle.select(1)
end

-- refuel method
function inventory.refuel()
	local currentLevel = turtle.getFuelLevel()
	if currentLevel < fuelSafetyThreshold then --check fuel
		sys.log("[fuelCheck]: Fuel Level Low! Attempting to Refuel")
		while turtle.getItemCount(fuel) > 0 and not (turtle.getFuelLevel() > fuelSafetyThreshold) do
			turtle.select(fuel)
			turtle.refuel(1)
		end
		if turtle.getFuelLevel() > fuelSafetyThreshold then
			sys.log("[fuelCheck]: Refuel Successful!")
		else
			sys.log("[fuelCheck]: Refuel Unsuccessful, Initiating return!")
			return false
		end
	end
end


-- function to find max amount of fuel needed to get home [fuel amount is fuel value of source]
function inventory.findMaxFuelLevel()
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

local gatherer = true

function inventory.setGatherer(bool)
	gatherer = bool
end

function inventory.isGatherer(bool)
	return gatherer
end


-- check if it has space to keep mining
function inventory.hasSpace()
	if not gatherer then
		return true
	end
	inventory.dumpWaste()
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

return inventory