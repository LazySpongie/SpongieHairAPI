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
	

	-- reduce hairgel or hairspray
	if SpongieHairAPI.HairGelOrHairSprayList[newHairStyle:getName()] == true then
		local hairgel = self.character:getInventory():getItemFromType("Hairgel", true, true) or self.character:getInventory():getItemFromType("Hairspray2", true, true) or self.character:getInventory():getFirstTagRecurse("DoHairdo");
		if hairgel then
			hairgel:UseAndSync();
		end
	end
	-- reduce hairspray
	if SpongieHairAPI.HairSprayList[newHairStyle:getName()] == true then
		local hairspray = self.character:getInventory():getItemFromType("Hairspray2", true, true)
		if hairspray then
			hairspray:UseAndSync();
		end
	end
	-- reduce hairgel
	if SpongieHairAPI.HairGelList[newHairStyle:getName()] == true then
		local hairgel = self.character:getInventory():getItemFromType("Hairgel", true, true) or self.character:getInventory():getFirstTagRecurse("SlickHair")
		if hairgel then
			hairgel:UseAndSync();
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
	if self.item:hasTag("ReplacePrimary") then
		if self.character:getPrimaryHandItem() then
			self.character:removeFromHands(self.character:getPrimaryHandItem())
		end
		self.character:setPrimaryHandItem(self.item)
	end

	if (instanceof(self.item, "InventoryContainer") or self.item:hasTag("Wearable")) and self.item:canBeEquipped() ~= "" then
		self.character:removeFromHands(self.item);
		self.character:setWornItem(self.item:canBeEquipped(), self.item);

	elseif self.item:getCategory() == "Clothing" then

		if self.item:getBodyLocation() ~= "" then
			self.character:setWornItem(self.item:getBodyLocation(), self.item);
            
			-- Replace hardcoded mohawk

			--for some reason this doesnt work on mohawks??
			--it works correctly but something that runs after this code just sets mohawks back to mohawkflat anyway
			--this literally shouldnt be possible lmao

			local flatHair = SpongieHairAPI.FlatHairList[self.character:getHumanVisual():getHairModel()]
			print("CHECKING IF HAIR SHOULD BE FLATTENED")
			print(self.character:getHumanVisual():getHairModel())
			print(flatHair)

			--flatten hair (we only flat if the item is not a bandage or bandana)
			if flatHair then
                if self.item:getBodyLocation():contains("Hat") and not self.item:getName():contains("Band") and not self.item:getName():contains("Visor") then
                    self.character:getHumanVisual():setHairModel(flatHair)
                    self.character:resetModel()
                    -- sendHumanVisual(self.character)
                    
                    print("FLATTENING HAIR NOW")
                end
			end

		end

	end
	return true;
end

