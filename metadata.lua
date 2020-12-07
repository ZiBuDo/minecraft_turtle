--[[
	https://pastebin.com/hJjQW9we
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

return metadata
