--[[
	Return to home
]]--

local directions, sys = require("directions"), require("sys")

sys.log("Going Home No Matter What!")
directions.pickUpFromFile("position")
directions.goHome()
sys.log("Made It Home!")