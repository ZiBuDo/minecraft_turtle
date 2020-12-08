--[[
	Return to home
]]--

local directions, sys = require("directions"), require("sys")

sys.log("Going Home No Matter What!")
directions.pickUpFromFile("directions")
directions.goHome()
sys.log("Made It Home!")