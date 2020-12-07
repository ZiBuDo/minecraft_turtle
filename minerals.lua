--[[
	https://pastebin.com/4pdXNEJk
	Minerals Metadata
]]--

local metadata, utils = require("metadata"), require("utils")

local minerals = {}

local blocks = {}
-- modname:ore[metadata] = modname:ore (item detail)
blocks["minecraft:gold_ore[0]"] = "minecraft:gold_ore[0]"
blocks["minecraft:iron_ore[0]"] = "minecraft:iron_ore[0]"
blocks["minecraft:coal_ore[0]"] = "minecraft:coal[0]"
blocks["minecraft:lapis_ore[0]"] = "minecraft:dye[4]"
blocks["minecraft:diamond_ore[0]"] = "minecraft:diamond[0]"
blocks["minecraft:redstone_ore[0]"] = "minecraft:redstone[0]"
blocks["minecraft:emerald_ore[0]"] = "minecraft:emerald[0]"
blocks["ic2:resource[1]"] = "ic2:resource[1]" -- copper
blocks["ic2:resource[2]"] = "ic2:resource[2]" -- lead
blocks["ic2:resource[3]"] = "ic2:resource[3]" -- tin
blocks["ic2:resource[4]"] = "ic2:resource[4]" -- uranium
blocks["forestry:resources[0]"] = "forestry:apatite[0]"
blocks["forestry:resources[1]"] = "forestry:resources[1]" -- copper
blocks["forestry:resources[2]"] = "forestry:resources[2]" -- tin
blocks["biomesoplenty:gem_ore[0]"] = "biomesoplenty:gem[0]" -- ender amethyst
blocks["biomesoplenty:gem_ore[1]"] = "biomesoplenty:gem[1]" -- ruby
blocks["biomesoplenty:gem_ore[2]"] = "biomesoplenty:gem[2]" -- peridot
blocks["biomesoplenty:gem_ore[3]"] = "biomesoplenty:gem[3]" -- topaz
blocks["biomesoplenty:gem_ore[4]"] = "biomesoplenty:gem[4]" -- tanzanite
blocks["biomesoplenty:gem_ore[5]"] = "biomesoplenty:gem[5]" -- malachite
blocks["biomesoplenty:gem_ore[6]"] = "biomesoplenty:gem[6]" -- sapphire
blocks["biomesoplenty:gem_ore[7]"] = "biomesoplenty:gem[7]" -- amber
blocks["atum:gold_ore[0]"] = "atum:gold_ore[0]"
blocks["atum:iron_ore[0]"] = "atum:iron_ore[0]"
blocks["atum:coal_ore[0]"] = "minecraft:coal[0]"
blocks["atum:lapis_ore[0]"] = "minecraft:dye[4]"
blocks["atum:diamond_ore[0]"] = "minecraft:diamond[0]"
blocks["atum:redstone_ore[0]"] = "minecraft:redstone[0]"
blocks["atum:emerald_ore[0]"] = "minecraft:emerald[0]"
blocks["atum:bone_ore[0]"] = "atum:dusty_bone[0]"
blocks["thaumcraft:ore_cinnabar[0]"] = "thaumcraft:ore_cinnabar[0]"
blocks["thaumcraft:ore_quartz[0]"] = "minecraft:quartz[0]"
blocks["thaumcraft:ore_amber[0]"] = "thaumcraft:amber[0]"
blocks["actuallyadditions:block_misc[3]"] = "actuallyadditions:block_misc[3]" -- dark quartz
blocks["astralsorcery:blockcustomore[0]"] = "astralsorcery:blockcustomore[0]" -- rock crystal
blocks["astralsorcery:blockcustomore[1]"] = "astralsorcery:blockcustomore[1]" -- star metal

minerals.blocks = blocks

-- block to harvested resource type
function minerals.getBlockResource(block)
	local mineral = minerals[metadata.blockToString(block)]
	if mineral then
		return mineral
	end
	return nil
end

-- is mineral
function minerals.isMineral(block)
	local mineral = blocks[metadata.blockToString(block)]
	if mineral then
		return true
	end
	return false
end


-- check if a inv spot is a resource
function minerals.isResource(detail)
	for key, value in pairs(minerals) do
		if detail.name == value then
			 return true
		end
	end
	return false
end

-- check if lava to refuel
function minerals.isLava(block)
	local name = metadata.blockToString(block)
	if name == "minecraft:flowing_lava[0]" then
		return true
	end
	return false
end

-- check if chest to suck
function minerals.isChest(block)
	local name = metadata.blockToString(block)
	if name == "minecraft:chest[0]" then
		return true
	end
	return false
end

-- method that takes in block and determines if there is space to harvest it
-- iterate through inv and check if resource count is < space for it anywhere
function minerals.hasSpaceToHarvest(block, recurse)
	local resource = minerals.getBlockResource(block)
	-- if inv full then check stacks
	for i = utils.getInvStart(), utils.getInvEnd() do
		if turtle.getItemCount(i) == 0 then
			return true
		end
		if turtle.getItemCount(i) > 0 and 
			resource == metadata.detailToBlockString(turtle.getItemDetail(i)) and 
			turtle.getItemCount(i) < turtle.getItemSpace(i) then
			return true
		end
	end
	if recurse then 
		return false
	end
	-- dump and try again
	utils.dumpWaste()
	return minerals.hasSpaceToHarvest(block, true)
end

return blocks