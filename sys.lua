--[[
    https://pastebin.com/4rqZqTpv
    System utils such as logging
]]--

local sys = {}

function sys.clearOutLog()
	-- Clear Old Log
	if fs.exists("/turtleLog") then
		print("Removing old turtleLog")
		fs.delete("/turtleLog")
	end
end

function sys.log()
	-- Print that outputs to stdout and file
	print("[" .. os.time() .. "]" .. text)
	local file = fs.open("/turtleLog", "a")
	file.writeLine("[" .. os.time() .. "]" .. text)
	file.close()
end

return sys