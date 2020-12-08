--[[
	Loot from mobs
]]--

local metadata = require("metadata")

local mod = {}

local loot = {}
loot["minecraft:ender_pearl[0]"] = true
loot["minecraft:ender_eye[0]"] = true
loot["actuallyadditions:item_solidified_experience[0]"] = true
loot["minecraft:string[0]"] = true
loot["minecraft:bone[0]"] = true
loot["minecraft:arrow[0]"] = true
loot["minecraft:slime_ball[0]"] = true
loot["minecraft:name_tag[0]"] = true
loot["minecraft:gunpowder[0]"] = true
loot["quark:diamond_heart[0]"] = true
loot["minecraft:skull[0]"] = true
loot["minecraft:emerald[0]"] = true
loot["minecraft:iron_ingot[0]"] = true
loot["minecraft:gold_ingot[0]"] = true
loot["minecraft:diamond[0]"] = true

-- check if a inv spot is a resource
function mod.isLoot(detail)
	for key, value in pairs(loot) do
		if metadata.detailToBlockString(detail) == key and value then
			 return true
		end
	end
	return false
end

mod.loot = loot

return mod