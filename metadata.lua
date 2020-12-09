--[[
	Get Information about the world
]]--

local metadata = {}

-- block data to string 
function metadata.blockToString(block)
	return block.name .. "[" .. block.metadata .. "]"
end

-- detail to block string
function metadata.detailToBlockString(detail)
    return detail.name .. "[" .. detail.damage .. "]"
end

-- inspect method returns block info
function metadata.inspect(direction)
	if not direction then
		return turtle.inspect()
	elseif direction:lower() == "down" then
		return turtle.inspectDown()
	elseif direction:lower() == "up" then
		return turtle.inspectUp()
	end
end

-- check if chest to suck
function metadata.isChest(block)
	local name = metadata.blockToString(block)
	if name == "minecraft:chest[0]" then
		return true
	end
	return false
end

function metadata.isLadder(detail)
	local name = metadata.detailToBlockString(detail)
	if name == "minecraft:ladder[0]" or 
		name == "minecraft:ladder[1]" or 
		name == "minecraft:ladder[2]" or 
		name == "minecraft:ladder[3]" or 
		name == "minecraft:ladder[4]" then
		return true
	end
	return false
end

function metadata.getLadderFacing(exists, block)
	return block.state.facing
end


return metadata
