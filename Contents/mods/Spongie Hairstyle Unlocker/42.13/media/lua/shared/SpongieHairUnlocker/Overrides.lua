require "TimedActions/ISCutHair";
require "TimedActions/ISWearClothing";


---@diagnostic disable-next-line: duplicate-set-field
function ISCutHair:complete()
	local newHairStyle = getHairStylesInstance():FindMaleStyle(self.hairStyle)
	if self.character:isFemale() then
		newHairStyle = getHairStylesInstance():FindFemaleStyle(self.hairStyle)
	end

	if newHairStyle:getName():contains("Bald")then
		self.character:getHumanVisual():setHairColor(self.character:getHumanVisual():getNaturalHairColor())
	end

	local resetHairGrowingTime = true

	-- if we're attaching our hair we need to set the non attached model, or if we untie, we reset our model
	if newHairStyle:isAttachedHair() and not self.character:getHumanVisual():getNonAttachedHair() then
		self.character:getHumanVisual():setNonAttachedHair(self.character:getHumanVisual():getHairModel());
		resetHairGrowingTime = false
	end
	if self.character:getHumanVisual():getNonAttachedHair() and not newHairStyle:isAttachedHair() then
		self.character:getHumanVisual():setNonAttachedHair(nil);
		resetHairGrowingTime = false
	end
	self.character:getHumanVisual():setHairModel(self.hairStyle)
	self.character:resetModel()

	--if we dont check this then hair growth will be reset when switching to and from tied hairs
	if resetHairGrowingTime then
		self.character:resetHairGrowingTime();
	end

	
	local SpongieHairAPI = require("SpongieHairUnlocker/SpongieHairAPI")
	
	local hair = newHairStyle:getName()
	local usedHairgel = false
	if SpongieHairAPI:NeedHairGel(hair) then
		local hairgel = self.character:getInventory():getItemFromType("Hairgel", true, true)
		if hairgel then
			hairgel:UseAndSync()
			usedHairgel = true
		end
	end
	if SpongieHairAPI:NeedHairSpray(hair) and not usedHairgel then
		local hairspray = self.character:getInventory():getItemFromType("Hairspray2", true, true)
		if hairspray then
			hairspray:UseAndSync();
		end
	end
	sendHumanVisual(self.character)
	return true
end

---@diagnostic disable-next-line: duplicate-set-field
function ISWearClothing:complete()
	if self:isAlreadyEquipped(self.item) then
		return false;
	end

	-- kludge for knapsack sprayers
	if self.item:hasTag(ItemTag.REPLACE_PRIMARY) then
		if self.character:getPrimaryHandItem() then
			self.character:removeFromHands(self.character:getPrimaryHandItem())
		end
		self.character:setPrimaryHandItem(self.item)
	end
	
	if (instanceof(self.item, "InventoryContainer") or self.item:hasTag(ItemTag.WEARABLE)) and self.item:canBeEquipped() ~= "" then
		self.character:removeFromHands(self.item);
		self.character:setWornItem(self.item:canBeEquipped(), self.item);

	elseif self.item:getCategory() == "Clothing" or self.item:getCategory() == "AlarmClock" then

		if self.item:getBodyLocation() ~= "" then
			self.character:setWornItem(self.item:getBodyLocation(), self.item);
			
			local SpongieHairAPI = require("SpongieHairUnlocker/SpongieHairAPI")
			local flatHair = SpongieHairAPI:GetFlatHair(self.character:getHumanVisual():getHairModel())

			-- print("CHECKING IF HAIR SHOULD BE FLATTENED")
			-- print(self.character:getHumanVisual():getHairModel())
			-- print(flatHair)

			--flatten hair (we only flat if the item is not a bandage or bandana)
			if flatHair then
				if (self.item:getBodyLocation() == ItemBodyLocation.HAT or self.item:getBodyLocation() == ItemBodyLocation.FULL_HAT) and not self.item:getName():contains("Band") and not self.item:getName():contains("Visor")  then
					self.character:getHumanVisual():setHairModel(flatHair);
					self.character:resetModel();
				end
			end
		end
	end
	return true;
end

