--[[
	Chunk loader information
]]--

local metadata = require("metadata")

-- fuel in hours
local chunkFuelResource = {}
chunkFuelResource["railcraft:dust[0]"] = 2
chunkFuelResource["minecraft:ender_pearl[0]"] = 4
chunkFuelResource["railcraft:dust[6]"] = 8
chunkFuelResource["railcraft:dust[7]"] = 12

local chunkLoaderA, chunkerLoaderB, chunkFuel, timeExpiration, timerId, epochStart = 13, 14, 15, nil, nil, 0

local chunkLoading = true

if turtle.getItemCount(chunkLoader) ~= 2 then
	print("No chunk loaders found " .. tostring(chunkLoader) .. " please place 2 fueled chunk loaders in slot to use chunk loading")
	chunkLoading = false
	invEnd = 14
	-- eject if any <at home>
	turtle.select(chunkLoader)
	turtle.dropDown()
	turtle.select(chunkFuel)
	turtle.dropDown()
	turtle.select(invStart)
else
	if turtle.getItemCount(chunkFuel) < 2 then
		print("Need at least 2 chunk fuel in " .. tostring(chunkFuel))
		chunkLoading = false
		invEnd = 14
		-- eject if any <at home>
		turtle.select(chunkFuel)
		turtle.dropDown()
		turtle.select(invStart)
	else
		-- calculate time to die
		local hours = chunkFuelResource[metadata.detailToBlockString(turtle.getItemDetail(chunkFuel))]
		local ttd = fs.open("/ttd", "w")
		local seconds = hours * 60 * 60
		ttd.writeLine(tostring(hours * 60 * 60)) -- write seconds
		file.close()
		timeExpiration = seconds
		epochStart = math.floor(os.epoch("utc") / 1000)
		 -- need timer that takes distance ~ 1 second per 3 movement
		 -- check every minute
		timerId = os.startTimer(60)
	end
end


-- chunk loading = 3x3 so 3 x 16 = 48 l + r and f + back assuming on edges
-- up to 32 spaces either direction 
-- place A - move up 32 space - place B - go back get A -- go back to B -- continue
-- write to chunks files <chunkA, chunkB> line, instructions on how to get to A and get to B
-- home directive should return to chunks, then start heading home using chunking methodology as described above
-- chunk B = directions from pos to chunk B
-- chunk A = direction from chunk B to chunk A
-- home = chunkA to home
-- home = if no chunkA or chunkB file then just follow home if it exists
-- chunk A = chunk closest to home
-- chunk B = chunk furthest from home
function hopChunkLoaders(forward, backward)
	-- assume direction of facing forward

end


-- chunk loading time check
function timeCheck()
	if not chunkLoading then
		return
	end
	local _, tid = os.pullEvent("timer")
	if timerId == tid then
		-- check if time is out if not restart timer (10 minute safety threshold)
		local epochCurr = math.floor(os.epoch("utc") / 1000)
		if epochStart + timeExpiration + 600 > epochCurr then
			print("[timeCheck]: Times out!  Returning to base!")
			ok = false
		else
			timerId = os.startTimer(60)
		end
	end
end

