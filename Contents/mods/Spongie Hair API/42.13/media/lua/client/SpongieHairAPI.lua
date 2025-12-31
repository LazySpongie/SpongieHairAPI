-- Lets you give hairstyles the same functionality as the vanilla mohawks, since they are currently hardcoded.

SpongieHairAPI = {};
SpongieHairAPI.HairGelList = {};
SpongieHairAPI.HairSprayList = {};
SpongieHairAPI.HairGelOrHairSprayList = {};
SpongieHairAPI.FlatHairList = {};


function SpongieHairAPI:RequireHairGel(hair, flatHair)
	SpongieHairAPI.HairGelList[hair] = true
	-- if flatHair == nil then return end 
	SpongieHairAPI.FlatHairList[hair] = flatHair
end
function SpongieHairAPI:RequireHairSpray(hair, flatHair)
	SpongieHairAPI.HairSprayList[hair] = true
	-- if flatHair == nil then return end 
	SpongieHairAPI.FlatHairList[hair] = flatHair
end
function SpongieHairAPI:RequireHairGelOrHairSpray(hair, flatHair)
	SpongieHairAPI.HairGelOrHairSprayList[hair] = true
	-- if flatHair == nil then return end 
	SpongieHairAPI.FlatHairList[hair] = flatHair
end


-- local cat = {name = "MohawkFan", FlatHair = "MohawkFlat", HairGel = true, HairSpray = true}
-- SpongieHairAPI:AddHair(cat)


--Setup vanilla hair
SpongieHairAPI:RequireHairGelOrHairSpray("MohawkFan")
SpongieHairAPI.FlatHairList["MohawkFan"] = "MohawkFlat"

SpongieHairAPI:RequireHairGelOrHairSpray("MohawkSpike")
SpongieHairAPI.FlatHairList["MohawkSpike"] = "MohawkFlat"

SpongieHairAPI:RequireHairGelOrHairSpray("MohawkShort")
SpongieHairAPI.FlatHairList["MohawkShort"] = "MohawkFlat"

SpongieHairAPI:RequireHairGelOrHairSpray("Spike")
SpongieHairAPI:RequireHairGelOrHairSpray("LibertySpikes")
SpongieHairAPI:RequireHairGel("GreasedBack")
SpongieHairAPI:RequireHairSpray("Buffont")
