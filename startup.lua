--[[
    Command: wget https://raw.githubusercontent.com/ZiBuDo/minecraft_turtle/main/startup.lua startup
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

local url = "https://raw.githubusercontent.com/ZiBuDo/minecraft_turtle/main/"
local ext = ".lua"

function buildUrl(name)
    return url .. name .. ext
end

local utils = { "loot", "minerals", "metadata", "directions", "inventory", "home", "sys", "set", "reset", "directive" }

local directives = { "miner", "dungeon" }

local programName, newProgramName = "startup", "startup_new"
local running = shell.getRunningProgram()
print("Running " .. running)
if running ~= newProgramName then
    print("Updating Startup Script")
    shell.run("wget", buildUrl(programName), newProgramName)
    shell.execute(newProgramName)
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
        print("Installing Util " .. value)
        if fs.exists("/" .. value) then
            print("Removing old " .. value)
            fs.delete("/" .. value)
        end
        shell.run("wget", buildUrl(value), value)
	end

    -- configuration file read
    local directive
    if fs.exists("/config") then
        local configFile = fs.open("/config", "r")
        directive = configFile.readLine()
        configFile.close()
    end

    if directive then
        -- Install Directive
        print("Installing Directive " .. directive)
        if fs.exists("/" .. directive) then
            print("Removing old " .. directive)
            fs.delete("/" .. directive)
        end
        shell.run("wget", buildUrl(directive), directive)
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