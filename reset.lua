--[[
    Reset the bot and re run start up
]]--

local directive
    if fs.exists("/config") then
        local configFile = fs.open("/config")
        directive = configFile.readLine()
        configFile.close()
    end

print("Are you sure you wish to reset this " .. directive .. "bot?")
while true do
    local _, char = os.pullEvent("char")
    if char:lower() == "n" then
        error()
    elseif char:lower() == "y" then
        break
    end
end

local ls = fs.list("/")
for key, value in pairs(ls) do
    if not fs.isDir(value) and value ~= "startup" then
        fs.delete(value)
    end
end

shell.execute("startup")