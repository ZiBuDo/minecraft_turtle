--[[
    https://pastebin.com/Jdi1z66j
    Get Status of Bot
]]--

local utils = reuqire("utils")
--local chunks = require("chunkLoader")

local ok = true

local status = {}

-- method to determine if fueled or any other status checks
function status.isOk()
	if not ok then
		return false
	end
	-- fuel
    if not utils.fuelCheck() then
       ok = false 
    end
    --if not chunks.timeCheck() then
    --    ok = false 
    -- end
	return ok
end

function status.getOk()
	return ok
end

function status.reset()
	ok = true
end

function status.setOk(bool)
    ok = bool
end

return status