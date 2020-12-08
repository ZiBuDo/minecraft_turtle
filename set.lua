--[[
    write config file of type of directive and run startup
]]--

local directives = { "miner", "dungeon" }

print("Which Type of bot to install")
for key, value in pairs(directives) do
    print(tostring(key) .. ") " .. value)
end
print("Press a #")

while true do
    local _, char = os.pullEvent("char")
    if directives[tonumber(char)] == "n" then
        break
    else
        error()
    end
end

local index = tonumber(char)

local directive = directives[index]
print("Installing directive " .. directive)
local configFile = fs.open("/config", "w")
configFile.writeLine(directive)
configFile.close()

shell.execute("startup")
