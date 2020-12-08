--[[
	Return to home
]]--

local directions, utils = require("/directions"), require("/inventory")

utils.log("Going Home No Matter What!")
directions.pickUpFromFile("directions")
directions.goHome()
utils.log("Made It Home!")