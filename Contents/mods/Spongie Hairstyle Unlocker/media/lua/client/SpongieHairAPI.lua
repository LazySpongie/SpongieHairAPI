-- Lets you give hairstyles the same functionality as the vanilla mohawks, since they are currently hardcoded.

--Create tables
SpongieHairAPI = {};
SpongieHairAPI.GelledHairList = {};


function SpongieHairAPI:SetHairAsGelled(gelledHairName, entry)
	SpongieHairAPI.GelledHairList[gelledHairName] = entry;
end

--Setup vanilla hair
SpongieHairAPI:SetHairAsGelled("MohawkFan", {flatHair = "MohawkFlat",});
SpongieHairAPI:SetHairAsGelled("MohawkSpike", {flatHair = "MohawkFlat",});
SpongieHairAPI:SetHairAsGelled("MohawkShort", {flatHair = "MohawkFlat",});
SpongieHairAPI:SetHairAsGelled("GreasedBack", {flatHair = "",});
SpongieHairAPI:SetHairAsGelled("Buffont", {flatHair = "",});
SpongieHairAPI:SetHairAsGelled("Spike", {flatHair = "",});
SpongieHairAPI:SetHairAsGelled("LibertySpikes", {flatHair = "",});
