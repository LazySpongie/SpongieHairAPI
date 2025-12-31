require "TimedActions/ISBaseTimedAction";
require "XpSystem/ISUI/ISCharacterScreen";
require "TimedActions/ISCutHair";
require "TimedActions/ISWearClothing";
require "TimedActions/ISClothingExtraAction";
require "SpongieHairAPI";

local ContextMenu_CutHairFor = string.gsub(getText("ContextMenu_CutHairFor"),"%%1","")
local ContextMenu_TieHair    = string.gsub(getText("ContextMenu_TieHair")   ,"%%1","")


local function predicateRazor(item)
	if item:isBroken() then return false end
	return item:hasTag("Razor") or item:getType() == "Razor"
end

local function predicateScissors(item)
	if item:isBroken() then return false end
	return item:hasTag("Scissors") or item:getType() == "Scissors"
end
local function predicateNotBroken(item)
	return not item:isBroken()
end
local function compareHairStyle(a, b)
	if a:getName() == "Bald" then return true end
	if b:getName() == "Bald" then return false end
	local nameA = getText("IGUI_Hair_" .. a:getName())
	local nameB = getText("IGUI_Hair_" .. b:getName())
	return not string.sort(nameA, nameB)
end


function ISCharacterScreen:hairMenu(button)
	local player = self.char;
	local context = ISContextMenu.get(self.char:getPlayerNum(), button:getAbsoluteX(), button:getAbsoluteY() + button:getHeight());
	local playerInv = player:getInventory()
	
	-- hair
	local currentHairStyle = getHairStylesInstance():FindMaleStyle(player:getHumanVisual():getHairModel())
	local hairStyles = getHairStylesInstance():getAllMaleStyles();
	if player:isFemale() then
		currentHairStyle = getHairStylesInstance():FindFemaleStyle(player:getHumanVisual():getHairModel())
		hairStyles = getHairStylesInstance():getAllFemaleStyles();
	end
	local hairList = {}
	for i=1,hairStyles:size() do
		table.insert(hairList, hairStyles:get(i-1))
	end
	table.sort(hairList, compareHairStyle)
	-- if we have hair long enough to trim it
	if currentHairStyle and currentHairStyle:getLevel() > 0 then
--		local option = context:addOption(getText("IGUI_char_HairStyle"))
--		local hairMenu = context:getNew(context)
--		context:addSubMenu(option, hairMenu)
		local hairMenu = context
		
		if isDebugEnabled() then
			if player:isFemale() then
				hairMenu:addOption("[DEBUG] Grow Long2", player, ISCharacterScreen.onCutHair, "Long2", 10);
			else
				hairMenu:addOption("[DEBUG] Grow Fabian", player, ISCharacterScreen.onCutHair, "Fabian", 10);
			end
		end
		
		-- if we have an attached hair model but non nonAttachedHair reference, we get one
		if currentHairStyle:isAttachedHair() and not player:getVisual():getNonAttachedHair() then
			-- get the growReference of our current level, it'll become our nonAttachedHair, so if we decide to detach our hair (from a pony tail for ex.) we'll go back to this growReference
			for _,hairStyle in ipairs(hairList) do
				if hairStyle:getLevel() == currentHairStyle:getLevel() and hairStyle:isGrowReference() then
					player:getVisual():setNonAttachedHair(hairStyle:getName());
				end
			end
		end
		
		-- untie hair
		if player:getVisual():getNonAttachedHair() then
			hairMenu:addOption(getText("ContextMenu_UntieHair"), player, ISCharacterScreen.onCutHair, player:getVisual():getNonAttachedHair(), 100);
		end
		
		if not player:getVisual():getNonAttachedHair() then
			-- add attached hair
			for _,hairStyle in ipairs(hairList) do
				if hairStyle:getLevel() <= currentHairStyle:getLevel() and hairStyle:getName() ~= currentHairStyle:getName() and hairStyle:isAttachedHair() and hairStyle:getName() ~= "" then
					hairMenu:addOption(getText("ContextMenu_TieHair", getText("IGUI_Hair_" .. hairStyle:getName())), player, ISCharacterScreen.onCutHair, hairStyle:getName(), 100);
				end
			end

			local hairList2 = {}
			-- add all "under level" we can find, any level 2 hair can be cut into a level 1
			for _,hairStyle in ipairs(hairList) do
				if not hairStyle:isAttachedHair() and not hairStyle:isNoChoose() and hairStyle:getLevel() <= currentHairStyle:getLevel() and hairStyle:getName() ~= "" then
					table.insert(hairList2, hairStyle)
				end
			end
			table.sort(hairList2, compareHairStyle)
			
			for _,hairStyle in ipairs(hairList2) do
				if hairStyle:getName() == "Bald" then
					local option = hairMenu:addOption(getText("ContextMenu_CutHairFor", getText("IGUI_Hair_" .. hairStyle:getName())), player, ISCharacterScreen.onCutHair, hairStyle:getName(), 300);
					option.name = getText("ContextMenu_ShaveHair");
					if not player:getInventory():containsEvalRecurse(predicateRazor) and not player:getInventory():containsEvalRecurse(predicateScissors) then
						self:addTooltip(option, getText("Tooltip_requireRazorOrScissors"));
					end
					
				-- Replace hardcoded mohawk
				elseif SpongieHairAPI.GelledHairList[hairStyle:getName()] ~= nil then
					option = hairMenu:addOption(getText("ContextMenu_GelHairFor", getText("IGUI_Hair_" .. hairStyle:getName())), player, ISCharacterScreen.onCutHair, hairStyle:getName(), 300);
					if not player:getInventory():containsTypeRecurse("Hairgel") then
						self:addTooltip(option, getText("Tooltip_requireHairGel"));
					end
					
				else
					local option = hairMenu:addOption(getText("ContextMenu_CutHairFor", getText("IGUI_Hair_" .. hairStyle:getName())), player, ISCharacterScreen.onCutHair, hairStyle:getName(), 300);
					if not player:getInventory():containsTagEvalRecurse("Scissors", predicateNotBroken) then
						self:addTooltip(option, getText("Tooltip_RequireScissors"));
					end
				end
			end
		end
	else
--		local option = context:addOption(getText("IGUI_char_HairStyle"))
--		local hairMenu = context:getNew(context)
--		context:addSubMenu(option, hairMenu)
		local hairMenu = context
		
		if isDebugEnabled() then
			if player:isFemale() then
				hairMenu:addOption("[DEBUG] Grow Long2", player, ISCharacterScreen.onCutHair, "Long2", 10);
			else
				hairMenu:addOption("[DEBUG] Grow Fabian", player, ISCharacterScreen.onCutHair, "Fabian", 10);
			end
		end
	end

	if JoypadState.players[self.playerNum+1] and context.numOptions > 0 then
		context.origin = self
		context.mouseOver = 1
		setJoypadFocus(self.playerNum, context)
	end
end

function ISCutHair:perform()
	if self.item then
		self.item:setJobDelta(0.0);
	end
	local newHairStyle = getHairStylesInstance():FindMaleStyle(self.hairStyle)
	if self.character:isFemale() then
		newHairStyle = getHairStylesInstance():FindFemaleStyle(self.hairStyle)
	end

	if newHairStyle:getName():contains("Bald") then
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
	self.character:getHumanVisual():setHairModel(self.hairStyle);
	self.character:resetModel();

	--if we dont check this then hair growth will be reset when switching to and from tied hairs
	if resetHairGrowingTime then
		self.character:resetHairGrowingTime();
	end
	
		-- Replace hardcoded mohawk
	if (SpongieHairAPI.GelledHairList[newHairStyle:getName()] ~= nil) then
		local hairgel = self.character:getInventory():getItemFromType("Hairgel", true, true);
		if hairgel then
			hairgel:Use();
		end
	end
	triggerEvent("OnClothingUpdated", self.character)

    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

function ISWearClothing:perform()
    self.item:setJobDelta(0.0);

	if self:isAlreadyEquipped(self.item) then
		ISBaseTimedAction.perform(self);
		return
	end

    self.item:getContainer():setDrawDirty(true);

	if instanceof(self.item, "InventoryContainer") and self.item:canBeEquipped() ~= "" then

		self.character:removeFromHands(self.item);
		self.character:setWornItem(self.item:canBeEquipped(), self.item);
		getPlayerInventory(self.character:getPlayerNum()):refreshBackpacks();

	elseif self.item:getCategory() == "Clothing" then

		if self.item:getBodyLocation() ~= "" then
			self.character:setWornItem(self.item:getBodyLocation(), self.item);

			local gelledHair = SpongieHairAPI.GelledHairList[self.character:getHumanVisual():getHairModel()]
			-- Replace hardcoded mohawk
			if gelledHair ~= nil then

				--flatten the hair
				
				--for some reason this doesnt work on mohawks??
				--it works correctly but something that runs after this code just sets the hair back to mohawkflat anyway
				--this literally shouldnt be possible

				if gelledHair.flatHair ~= "" and self.item:getBodyLocation():contains("Hat") and not self.item:getName():contains("Band") then
					self.character:getHumanVisual():setHairModel(gelledHair.flatHair);
					self.character:resetModel();
				end

			end
			
		end
	end
	-- sendClothing(self.character, self.item:getBodyLocation(), self.item)
	triggerEvent("OnClothingUpdated", self.character)
--~ 	self.character:SetClothing(self.item:getBodyLocation(), self.item:getSpriteName(), self.item:getPalette());
    -- needed to remove from queue / start next.
	ISBaseTimedAction.perform(self);
end

function ISClothingExtraAction:perform()
	self.item:setJobDelta(0.0);
	local playerObj = self.character
	playerObj:removeFromHands(self.item)
	playerObj:removeWornItem(self.item)
	playerObj:getInventory():Remove(self.item)
	local newItem = self:createItem(self.item, self.extra)
	playerObj:getInventory():AddItem(newItem)
	if newItem:IsInventoryContainer() and newItem:canBeEquipped() ~= "" then
		playerObj:setWornItem(newItem:canBeEquipped(), newItem)
		getPlayerInventory(self.character:getPlayerNum()):refreshBackpacks();
	elseif newItem:IsClothing() then
		playerObj:setWornItem(newItem:getBodyLocation(), newItem)
		
			local gelledHair = SpongieHairAPI.GelledHairList[self.character:getHumanVisual():getHairModel()]
			-- Replace hardcoded mohawk
			if gelledHair ~= nil then
				--flatten the hair
				if gelledHair.flatHair ~= "" and newItem:getBodyLocation():contains("Hat") and not newItem:getName():contains("Band") then
					self.character:getHumanVisual():setHairModel(gelledHair.flatHair);
					self.character:resetModel()
				end

			end
	end
	-- sendClothing(self.character, self.item:getBodyLocation(), self.item)
	triggerEvent("OnClothingUpdated", playerObj)

	ISBaseTimedAction.perform(self)
end

