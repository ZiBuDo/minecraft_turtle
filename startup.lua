--[[
    https://pastebin.com/RM6PJHQ5
    Command: pastebin get RM6PJHQ5 startup
             startup
    Installer <call this startup>

    On boot 
    1) Self Update
        - Install Utils
        - Update directive
    2) Run Home
    3) Resume

    Install things based on config file "<file>" and run after home
    If no config then dont run aynthing
]]--
local utils = {}
-- utils["chunkLoader"] = ""
utils["loot"] = "meF1m5tQ"
utils["minerals"] = "4pdXNEJk"
utils["metadata"] = "hJjQW9we"
utils["status"] = "Jdi1z66j"
utils["directions"] = "rZCBaHQY"
utils["utils"] = "Trsh048i"
utils["home"] = "qDWsjxMc"
utils["sys"] = "4rqZqTpv"

local directives = {}
directives["miner"] = "3V9bKEbv"
directives["dungeon"] = "irRH1pk6"

local programName, newProgramName = "startup", "startup_new"
local running = shell.getRunningProgram()
print("Running " .. running)
if running ~= newProgramName then
    print("Updating Startup Script")
    shell.run("pastebin", "get", "RM6PJHQ5", "startup_new")
    shell.execute("startup_new")
else
    -- actually run script since in new
    -- Clear Old Startup
    if fs.exists("/" .. programName) then
        print("Removing old startup")
        fs.delete("/" .. programName)
    end
    -- copy new to startup
    fs.move("/" .. newProgramName, "/" .. programName)

    print("Installing Utils")

    for key, value in pairs(utils) do
        print("Installing Util " .. key)
        if fs.exists("/" .. key) then
            print("Removing old " .. key)
            fs.delete("/" .. key)
        end
        shell.run("pastebin", "get", value, key)
	end

    -- configuration file read
    local directive
    if fs.exists("/config") then
        local configFile = fs.open("/config")
        directive = configFile.readLine()
        configFile.close()
    end

    if directive ~= nil then
        -- Install Directive
        print("Installing Directive " .. directive)
        if fs.exists("/" .. directive) then
            print("Removing old " .. directive)
            fs.delete("/" .. directive)
        end
        shell.run("pastebin", "get", directives[directives], directives)
    end

    -- Run Home
    print("Ensuring turtle is home")
    shell.execute("home")

    -- Run config

    print("Resuming Directive")
    if directive ~= nil then
        shell.execute(directive)
    else
        print("No directive found in config file")
    end
end