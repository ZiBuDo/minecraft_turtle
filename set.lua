--[[
    write config file of type of directive and run startup
]]--

local directives = { "miner", "dungeon" }

print("Which Type of bot to install")
for key, value in pairs(directives) do
    print(tostring(key) .. ") " .. value)
end
print("Press a #")

local _, char
while true do
    _, char = os.pullEvent("char")
    if directives[tonumber(char)] then
        break
    else
        error()
    end
end

local directive = directives[tonumber(char)]
print("Installing directive " .. directive)
local configFile = fs.open("/config", "w")
configFile.writeLine(directive)
configFile.close()

shell.execute("startup")
