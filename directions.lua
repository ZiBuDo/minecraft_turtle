--[[
	https://pastebin.com/rZCBaHQY
	forward (+) back (-)
	right (+) left (-)
	up (+) down (-)
]]--

local status, sys = require("status"), require("sys")

local directions = {}

-- direction can be facing forward, facing right, facing left or facing backwards and manipulates what forward means
local direction = "forward"

local forwards, rights, ups = 0, 0, 0

function directions.pickUpPosition(forwards, rights, ups)
	forwards = forwards
	rights = rights
	ups = ups
end

function directions.pickUpFromFile()
	if not fs.exists("/directions") then
		return
	end
	local file = fs.open("/directions", "r")
	local forwards = file.readLine()
	local rights = file.readLine()
	local lefts = file.readLine()
	pickUpPosition(forwards, rights, lefts)
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

function directions.turnAround()
	directions.turnLeft()
	directions.turnLeft()
end

function directions.suck(direction)
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
	if sucked then
		utils.hasSpace()
	end
end

function directions.recordPosition(file)
	local file = fs.open("/" .. file, "w")
    file.writeLine(tostring(forwards))
    file.writeLine(tostring(rights))
    file.writeLine(tostring(ups))
	file.close()
end

function directions.recordDirections()
	directions.recordPosition("directions", forwards, rights, ups)
end

-- records N as a head before branching to be used before branching while facing forward
function directions.recordFacing(direction)
	local file = fs.open("/looking", "w")
	file.writeLine(tostring(distance))
	file.close()
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
	directions.recordFacing(direction)
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
	directions.recordFacing(direction)
end

function directions.faceForward()
	local file = fs.open("/looking", "r")
	local facing = file.readLine()
	file.close()
	direction = facing
	-- face forward
	if direction == "backward" then
		directions.turnLeft()
		directions.turnLeft()
	elseif direction == "left" then
		directions.turnRight()
	elseif direction == "right" then
		directions.turnLeft()
	end
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

function calculateBackwardsMovement()
    if direction == "forward" then
		forwards = forwards - 1
	elseif direction == "backward" then
		forwards = forwards + 1
	elseif direction == "right" then
		rights = rights - 1
	else
		rights = rights + 1
	end
	directions.recordDirections()
end

function directions.forward(dig, attack, suck, force, breakCondition)
	local moved = turtle.forward()
    while (status.getOk() or force) and not moved do
        if dig == true then
            while turtle.dig() do end
        end
        if attack == true then
            while turtle.attack() do end
		end
		if suck == true then
			directions.suck()
		end
		if breakCondition and breakCondition() then
			break
		end
		moved = turtle.forward()
	end
	if moved then
		status.isOk()
		calculateForwardsMovement()
	end
end

function directions.backward(dig, attack, suck, force, breakCondition)
	--face forward effectively and go then face back
	directions.turnLeft()
	directions.turnLeft()
	directions.forward(dig, attack, suck, force, breakCondition)
	calculateBackwardsMovement()
	directions.turnLeft()
	directions.turnLeft()
end

function directions.up(dig, attack, suck, force, breakCondition)
	local moved = turtle.up()
	while (status.getOk() or force) and not moved do
		if dig == true then
            while turtle.digUp() do end
        end
        if attack == true then
            while turtle.attackUp() do end
		end
		if suck == true then
			directions.suck("up")
		end
		if breakCondition and breakCondition() then
			break
		end
		moved = turtle.up()
	end
	if moved then
		status.isOk()
		ups = ups + 1
		directions.recordDirections()
	end
end

function directions.down(dig, attack, suck, force, breakCondition)
	local moved = turtle.down()
	while (status.getOk() or force) and not moved do
		if dig == true then
            while turtle.digDown() do end
        end
        if attack == true then
            while turtle.attackDown() do end
		end
		if suck == true then
			directions.suck("down")
		end
		if breakCondition and breakCondition() then
			break
		end
		moved = turtle.down()
	end
	if moved then
		status.isOk()
		ups = ups - 1
		directions.recordDirections()
	end
end

function directions.left(dig, attack, suck, force, breakCondition)
	directions.turnLeft()
	directions.forward(dig, attack, suck, force, breakCondition)
	directions.turnRight()
end

function directions.right(dig, attack, suck, force, breakCondition)
	directions.turnRight()
	directions.forward(dig, attack, suck, force, breakCondition)
	directions.turnLeft()
end

function directions.goHome()
	utils.refuel()
	-- face forward
	directions.faceForward()
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
end

-- recursive method for checking surroundings + status entry point for actions based on strip pattern
-- sub routine should return to original block facing same direction
-- no is okay check outside specifics in block routine (space size w/o context)
function directions.check(blockRoutine)
	if not ok then return end
	--forward
	blockRoutine()
	if not ok then return end
	directions.turnLeft()
	--left
	blockRoutine()
	directions.turnRight()
	if not ok then return end
	directions.turnRight()
	--right
	blockRoutine()
	directions.turnLeft()
	if not ok then return end
	--up
	blockRoutine("up")
	if not ok then return end
	--down
	blockRoutine("down")
	if not ok then return end
end


return directions