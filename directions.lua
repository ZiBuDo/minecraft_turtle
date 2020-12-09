--[[
	forward (+) back (-)
	right (+) left (-)
	up (+) down (-)
	direction facing
]]--

local sys, inventory, metadata = require("sys"), require("inventory"), require("metadata")
local directions = {}

-- direction can be facing forward, facing right, facing left or facing backward and manipulates what forward means
local direction = "forward"

local forwards, rights, ups = 0, 0, 0

local chestDirection, refuelDirection = "down", "up"

function directions.setChestDirection(dir)
	chestDirection = dir
end

function directions.setRefuelDirection(dir)
	refuelDirection = dir
end

function directions.getDistance()
	return math.abs(forwards) + math.abs(rights) + math.abs(ups)
end

function directions.setPosition(fs, rs, us, facing)
	forwards = fs
	rights = rs
	ups = us
	direction = facing
end

function directions.pickUpFromFile(fileName)
	if not fs.exists("/" .. fileName) then
		return
	end
	local file = fs.open("/" .. fileName, "r")
	local forwards = file.readLine()
	local rights = file.readLine()
	local ups = file.readLine()
	local facing = file.readLine()
	sys.log("Location picked up from " .. fileName .. ": " .. tostring(forwards) .. ", " .. tostring(rights) .. ", " .. tostring(ups) .. ", " .. facing)
	directions.setPosition(forwards, rights, ups, facing)
	file.close()
end

function directions.getForwards()
	return forwards
end

function directions.getRights()
	return rights
end

function directions.getUps()
	return ups
end

function directions.getDirectionFacing()
	return direction
end

function directions.getFacingInt(facing)
	if facing == "forward" then
		return 0
	elseif facing == "right" then
		return 1
	elseif facing == "backward" then
		return 2
	elseif facing == "left" then
		return 3
	end
end

function directions.setFacing(facing)
	-- diff of facing to current facing
	local turns = directions.getFacingInt(facing) - directions.getFacingInt(direction)
	if turns == 0 then
		return
	elseif turns < 0 then
		for i = 1, -turns do
			directions.turnLeft()
		end
	else
		for i = 1, turns do
			directions.turnRight()
		end
	end
end

function directions.turnAround()
	directions.turnLeft()
	directions.turnLeft()
end

function directions.suck(direction, noCheck)
	local suck
	if not direction then
		suck = turtle.suck
	elseif direction == "up" then
		suck = turtle.suckUp
	elseif direction == "down" then
		suck = turtle.suckDown
	end
	local sucked = false
	while suck() do 
		sucked = true
	end
	if not noCheck and sucked then
		if not inventory.hasSpace() then
			directions.loop()
		end
	end
	return sucked
end

function directions.dig(direction, noCheck)
	local dig
	if not direction then
		dig = turtle.dig
	elseif direction == "up" then
		dig = turtle.digUp
	elseif direction == "down" then
		dig = turtle.digDown
	end
	local dug = false
	while dig() do 
		dug = true
	end
	if not noCheck and dug then
		if not inventory.hasSpace() then
			directions.loop()
		end
	end
	return dug
end

function directions.recordPosition(fileName, fileHandle)
	local file = fs.open("/" .. fileName, "w")
    file.writeLine(tostring(forwards))
    file.writeLine(tostring(rights))
	file.writeLine(tostring(ups))
	file.writeLine(direction)
	file.close()
end

local directionFile

function directions.recordDirections()
	directions.recordPosition("position")
end

function directions.turnRight()
	if direction == "forward" then
		direction = "right"
	elseif direction == "backward" then
		direction = "left"
	elseif direction == "right" then
		direction = "backward"
	else
		direction = "forward"
	end
	turtle.turnRight()
	directions.recordDirections()
end

function directions.turnLeft()
	if direction == "forward" then
		direction = "left"
	elseif direction == "backward" then
		direction = "right"
	elseif direction == "right" then
		direction = "forward"
	else
		direction = "backward"
	end
	turtle.turnLeft()
	directions.recordDirections()
end

function calculateForwardsMovement()
    if direction == "forward" then
		forwards = forwards + 1
	elseif direction == "backward" then
		forwards = forwards - 1
	elseif direction == "right" then
		rights = rights + 1
	else
		rights = rights - 1
	end
	directions.recordDirections()
end

function directions.forward(dig, attack, suck, noCheckInv)
	if attack == true then
		while turtle.attack() do end
	end
	if suck == true then
		directions.suck(nil, noCheckInv)
	end
	local moved = turtle.forward()
	local unstuck = false
    while not moved do
        if dig == true then
			unstuck = directions.dig(nil, noCheckInv)
		end
		if attack == true then
			while turtle.attack() do unstuck = true end
		end
		if suck == true then
			directions.suck(nil, noCheckInv)
		end
		moved = turtle.forward()
		if not moved and not unstuck then
			break
		end
	end
	if moved then
		calculateForwardsMovement()
		if not directions.checkStatus() then
			directions.loop()
		end
	end
	return moved
end

function directions.backward(dig, attack, suck, noCheckInv)
	--face forward effectively and go then face back
	directions.turnLeft()
	directions.turnLeft()
	local result = directions.forward(dig, attack, suck, noCheckInv)
	directions.turnLeft()
	directions.turnLeft()
	return result
end

function directions.up(dig, attack, suck, noCheckInv)
	if attack == true then
		while turtle.attackUp() do end
	end
	if suck == true then
		directions.suck("up", noCheckInv)
	end
	local moved = turtle.up()
	local unstuck = false
	while not moved do
		if dig == true then
            unstuck = directions.dig("up", noCheckInv)
        end
        if attack == true then
            while turtle.attackUp() do unstuck = true end
		end
		if suck == true then
			directions.suck("up", noCheckInv)
		end
		moved = turtle.up()
		if not moved and not unstuck then
			break
		end
	end
	if moved then
		ups = ups + 1
		directions.recordDirections()
		if not directions.checkStatus() then
			directions.loop()
		end
	end
	return moved
end

function directions.down(dig, attack, suck, noCheckInv)
	if attack == true then
		while turtle.attackDown() do end
	end
	if suck == true then
		directions.suck("down", noCheckInv)
	end
	local moved = turtle.down()
	local unstuck = false
	while not moved do
		if dig == true then
            unstuck = directions.dig("down", noCheckInv)
        end
        if attack == true then
            while turtle.attackDown() do unstuck = true end
		end
		if suck == true then
			directions.suck("down", noCheckInv)
		end
		moved = turtle.down()
		if not moved and not unstuck then
			break
		end
	end
	if moved then
		ups = ups - 1
		directions.recordDirections()
		if not directions.checkStatus() then
			directions.loop()
		end
	end
	return moved
end

function directions.left(dig, attack, suck, noCheckInv)
	directions.turnLeft()
	local result = directions.forward(dig, attack, suck, noCheckInv)
	directions.turnRight()
	return result
end

function directions.right(dig, attack, suck, noCheckInv)
	directions.turnRight()
	local result = directions.forward(dig, attack, suck, noCheckInv)
	directions.turnLeft()
	return result
end

function directions.goToPosition(fs, rs, us, facing)
	sys.log("Going To Position: " .. tostring(fs) .. ", " .. tostring(rs) .. ", " .. tostring(us) .. ", " .. facing)
	-- face forward
	directions.setFacing("forward")
	-- reduce and follow
	-- up + down
	local vertical = directions.getUps() - us
	if vertical > 0 then
		-- go down
		for i = 1, vertical do
			down(true, true, false, true)
		end
	elseif vertical < 0 then
		-- go up
		for i = 1, -vertical do
			up(true, true, false, true)
		end
	end
	-- left + right
	local horizontal = directions.getRights() - rs
	if horizontal > 0 then
		-- go right
		for i = 1, horizontal do
			directions.left(true, true, false)
		end
	elseif horizontal < 0 then
		-- go left
		for i = 1, -horizontal do
			directions.right(true, true, false)
		end
	end
	-- foward + back
	local dist = directions.getForwards() - fs
	if dist > 0 then
		-- go backward
		for i = 1, dist do
			directions.backward(true, true, false)
		end
	elseif dist < 0 then
		-- go forward
		for i = 1, -dist do
			directions.forward(true, true, false)
		end
	end
	directions.setFacing(facing)
end

function directions.goHome()
	directions.goToPosition(0,0,0,"forward")
end

-- recursive method for checking surroundings + status entry point for actions based on strip pattern
-- sub routine should return to original block facing same direction
-- no is okay check outside specifics in block routine (space size w/o context)
function directions.check(blockRoutine)
	--forward
	blockRoutine()
	directions.turnLeft()
	--left
	blockRoutine()
	directions.turnAround()
	--right
	blockRoutine()
	directions.turnLeft()
	--up
	blockRoutine("up")
	--down
	blockRoutine("down")
end


-- check fuel and refuel if possible
function directions.fuelCheck()
	inventory.refuel()
	-- check to home
	if (directions.getDistance() + inventory.getFuelSafetyThreshold()) > findMaxFuelLevel()  then
		sys.log("[fuelCheck]: Fuel Reserves Depleted!  Initiating return!")
		return false
	end
	return true
end

-- refuel method
function directions.refuelAtHome()
	local suck
	if refuelDirection == "up" then
		suck = turtle.suckUp
	elseif refuelDirection == "down" then
		suck = turtle.suckDown
	else
		-- face direction and suck
		directions.setFacing(refuelDirection)
		suck = turtle.suck
	end
	local exists, block = metadata.inspect(refuelDirection)
	if not metadata.isChest(block) then
		sys.log("Chest is not in refuel spot, closing routine")
		error()
	end
	-- at top
	local count = turtle.getItemCount(inventory.getFuelSlot())
	turtle.select(inventory.getFuelSlot())
	suck(turtle.getItemSpace(inventory.getFuelSlot()))
	if turtle.getItemCount(inventory.getFuelSlot()) > count then
		sys.log("Refueled at home")
	end
	directions.setFacing("forward")
	turtle.select(inventory.getInvStart())
end

-- drop off method
function directions.dropOffInventory()
	sys.log("Dropping off haul into chest @ " .. chestDirection)
	local drop
	if chestDirection == "up" then
		drop = turtle.dropUp
	elseif chestDirection == "down" then
		drop = turtle.dropDown
	else
		directions.setFacing(chestDirection)
		drop = turtle.drop
	end
	local exists, block = metadata.inspect(refuelDirection)
	if not metadata.isChest(block) then
		sys.log("Chest is not in inventory drop off spot, closing routine")
		error()
	end
	local space = true
	-- at bottom
	for i = inventory.getInvStart(), inventory.getInvEnd() do
		if turtle.getItemCount(i) > 0 then
			turtle.select(i)
			if not drop() then
				space = false
			end
		end
	end
	directions.setFacing("forward")
	return space
end

function directions.checkStatus()
	local fueledUp = inventory.refuel()
	if not fueledUp then
		return false
	end
	return true
end

function directions.atHomeRoutine()
	directions.refuelAtHome()
	local spaceAtHome = true
	if inventory.isGatherer() then
		spaceAtHome = directions.dropOffInventory()
	end
	local status = directions.checkStatus()
	if not status or not spaceAtHome then
		sys.log("Going home, status is not sufficient to continue.")
		directions.goHome()
		sys.log("Ending Routine")
		error()
	end
end

function directions.loop()
	-- save position
	local fs, rs, us, facing = forwards, rights, ups, direction
	-- go home
	directions.goHome()
	-- run home routine
	directions.atHomeRoutine()
	-- go back to saved position
	directions.goToPosition(fs, rs, us, facing)
end

function directions.placeAndInspectLadder()
	-- move forward until ladder is placeable
	turtle.select(inventory.getLadderSlot())
	local movement = 0
	while not turtle.place() do 
		directions.forward(true, true, false, true)
		directions.backward(true, true, false, true)
	end
	local cardinal = metadata.getLadderFacing(metadata.inspect())
	turtle.dig()
	turtle.select(inventory.getInvStart())
	return cardinal
end

function directions.getDirectionFromCardinal(cardinal)
	if cardinal == "north" then
		return "south"
	elseif cardinal == "south" then
		return "north"
	elseif cardinal == "east" then
		return "west"
	elseif cardinal == "west" then
		return "east"
	end
end

function directions.getCardinalInt(cardinal)
	if cardinal == "north" then
		return 0
	elseif cardinal == "east" then
		return 1
	elseif cardinal == "south" then
		return 2
	elseif cardinal == "west" then
		return 3
	end
end

-- find forward and set in file
function directions.recordForward()
	local file = fs.open("/forward", "w")
	file.writeLine(directions.getDirectionFromCardinal(directions.placeAndInspectLadder()))
	file.close()
end

function directions.getForward()
	if not fs.exists("/forward") then
		return false
	end
	local file = fs.open("/forward", "r")
	local cardinal = file.readLine()
	file.close()
	return cardinal
end

-- place ladder and get opposite facing to find direction facing
function directions.orientate()
	local forward = directions.getForward()
	if not forward then
		direction = "forward"
		directions.recordDirections()
		return
	end
	local current = directions.getDirectionFromCardinal(directions.placeAndInspectLadder())
	-- diff of facing to current facing to face forward
	local turns = directions.getCardinalInt(forward) - directions.getCardinalInt(current)
	if turns == 0 then
		return
	elseif turns < 0 then
		for i = 1, -turns do
			turtle.turnLeft()
		end
	else
		for i = 1, turns do
			turtle.turnRight()
		end
	end
	direction = "forward"
	directions.recordDirections()
end

return directions