--[[
    Thread executor for a directive
]]--

local sys, directions = require("sys"), require("directions")

local directive = {}


-- string and method
function directive.run(name, thread)
    sys.clearOutLog()
    sys.log("Starting " .. name)
    os.setComputerLabel(name .. " " .. tostring(os.getComputerID()))
    directions.atHomeRoutine()
    while true do
        thread()
    end
end

return directive