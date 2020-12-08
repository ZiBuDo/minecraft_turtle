--[[
	forward (+) back (-)
	right (+) left (-)
	up (+) down (-)
	direction facing
]]--

local sys, inventory = require("sys"), require("inventory")
local directions = {}

-- direction can be facing forward, facing right, facing left or facing backwards and manipulates what forward means
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

function directions.pickUpFromFile(file)
	if not fs.exists("/" .. file) then
		return
	end
	local file = fs.open("/" .. file, "r")
	local forwards = file.readLine()
	local rights = file.readLine()
	local lefts = file.readLine()
	local facing = file.readLine()
	directions.setPosition(forwards, rights, lefts, facing)
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

function direction.setFacing(facing)
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
end

function directions.recordPosition(file)
	local file = fs.open("/" .. file, "w")
    file.writeLine(tostring(forwards))
    file.writeLine(tostring(rights))
	file.writeLine(tostring(ups))
	file.writeLine(direction)
	file.close()
end

function directions.recordDirections()
	directions.recordPosition("directions")
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

function directions.forward(dig, attack, suck)
	local moved = turtle.forward()
    while not moved do
        if dig == true then
            while turtle.dig() do end
        end
        if attack == true then
            while turtle.attack() do end
		end
		if suck == true then
			directions.suck()
		end
		moved = turtle.forward()
	end
	if moved then
		calculateForwardsMovement()
		if not directions.checkStatus() then
			directions.loop()
		end
	end
	return moved
end

function directions.backward(dig, attack, suck)
	--face forward effectively and go then face back
	directions.turnLeft()
	directions.turnLeft()
	local result = directions.forward(dig, attack, suck)
	directions.turnLeft()
	directions.turnLeft()
	return result
end

function directions.up(dig, attack, suck)
	local moved = turtle.up()
	while not moved do
		if dig == true then
            while turtle.digUp() do end
        end
        if attack == true then
            while turtle.attackUp() do end
		end
		if suck == true then
			directions.suck("up")
		end
		moved = turtle.up()
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

function directions.down(dig, attack, suck)
	local moved = turtle.down()
	while not moved do
		if dig == true then
            while turtle.digDown() do end
        end
        if attack == true then
            while turtle.attackDown() do end
		end
		if suck == true then
			directions.suck("down")
		end
		moved = turtle.down()
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

function directions.left(dig, attack, suck)
	directions.turnLeft()
	local result = directions.forward(dig, attack, suck)
	directions.turnRight()
	return result
end

function directions.right(dig, attack, suck)
	directions.turnRight()
	local result = directions.forward(dig, attack, suck)
	directions.turnLeft()
	return result
end

function directions.goToPosition(fowards, ups, downs, facing)
	-- face forward
	directions.setFacing("forward")
	-- reduce and follow
	-- up + down
	local vertical = directions.getUps()
	sys.log("vertical: " .. tostring(vertical))
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
	local horizontal = directions.getRights()
	sys.log("horizontal: " .. tostring(horizontal))
	if horizontal > 0 then
		-- go right
		for i = 1, horizontal do
			left(true, true, false, true)
		end
	elseif horizontal < 0 then
		-- go left
		for i = 1, -horizontal do
			right(true, true, false, true)
		end
	end
	-- foward + back
	local dist = directions.getForwards()
	sys.log("distance: " .. tostring(dist))
	if dist > 0 then
		-- go backwards
		for i = 1, dist do
			backward(true, true, false, true)
		end
	elseif dist < 0 then
		-- go forwards
		for i = 1, -dist do
			forward(true, true, false, true)
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
	-- at top
	local count = turtle.getItemCount(fuel)
	turtle.select(fuel)
	suck(turtle.getItemSpace(fuel))
	if turtle.getItemCount(fuel) > count then
		sys.log("Refueled at home")
	end
	directions.setFacing("forward")
	turtle.select(inventory.getInvStart())
end

-- drop off method
function directions.dropOffInventory()
	local drop
	if direction == "up" then
		drop = turtle.dropUp
	elseif direction == "down" then
		drop = turtle.dropDown
	else
		directions.setFacing(refuelDirection)
		drop = turtle.drop
	end
	local space = true
	-- at bottom
	for i = invStart, invEnd do
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

return directions