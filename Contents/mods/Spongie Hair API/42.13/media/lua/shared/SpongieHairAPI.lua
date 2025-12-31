-- Lets you give hairstyles the same functionality as the vanilla mohawks, since they are currently hardcoded.


local SpongieHairAPI = {}
SpongieHairAPI.Hairs = {}

function SpongieHairAPI:AddHair(hair)
	SpongieHairAPI.Hairs[hair.name] = hair
end

function SpongieHairAPI:GetFlatHair(hair)
	if not SpongieHairAPI.Hairs[hair] then return nil end
	return SpongieHairAPI.Hairs[hair].flatHair
end
function SpongieHairAPI:GetHairGel(hair)
	if not SpongieHairAPI.Hairs[hair] then return false end
	return SpongieHairAPI.Hairs[hair].hairGel
end
function SpongieHairAPI:GetHairSpray(hair)
	if not SpongieHairAPI.Hairs[hair] then return false end
	return SpongieHairAPI.Hairs[hair].hairSpray
end


local vanillahairs = {
	{name = "MohawkFan", flatHair = "MohawkFlat", hairGel = true, hairSpray = true},
	{name = "MohawkSpike", flatHair = "MohawkFlat", hairGel = true, hairSpray = true},
	{name = "MohawkShort", flatHair = "MohawkFlat", hairGel = true, hairSpray = true},

	{name = "Spike", flatHair = "", hairGel = true, hairSpray = true},
	{name = "LibertySpikes", flatHair = "", hairGel = true, hairSpray = true},
	{name = "GreasedBack", flatHair = "", hairGel = true, hairSpray = false},
	{name = "Buffont", flatHair = "", hairGel = false, hairSpray = true},
}

for i,v in ipairs(vanillahairs) do
	SpongieHairAPI:AddHair(v)
end

return SpongieHairAPI