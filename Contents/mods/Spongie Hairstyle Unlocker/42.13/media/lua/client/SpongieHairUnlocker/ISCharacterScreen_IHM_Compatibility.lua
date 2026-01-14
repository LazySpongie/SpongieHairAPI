
if not getActivatedMods():contains("\\improvedhairmenubuild42") then return end

require 'Contents.mods.Spongie Hairstyle Unlocker.42.0.media.lua.client.ImprovedHairMenuCompatibility';

local ContextMenu_CutHairFor = string.gsub(getText("ContextMenu_CutHairFor"),"%%1","")
local ContextMenu_TieHair    = string.gsub(getText("ContextMenu_TieHair")   ,"%%1","")

-- Build 42.13+ uses ItemTag objects (not strings) for hasTag / containsTagEvalRecurse.

local function IHM_itemHasTag(item, tagObj, fallbackString)
	if not item or not item.hasTag then return false end

	if tagObj ~= nil then
		local ok, res = pcall(item.hasTag, item, tagObj)
		if ok then return res == true end
	end

	-- Back-compat: older builds (or other environments) may still accept strings
	if fallbackString ~= nil then
		local ok, res = pcall(item.hasTag, item, fallbackString)
		return ok and res == true
	end

	return false
end

local function predicateRazor(item)
	if item:isBroken() then return false end
	if item:getType() == "Razor" then return true end

	-- Prefer ItemTag constant (42.13+)
	local tagObj = (ItemTag and ItemTag.RAZOR) or nil
	return IHM_itemHasTag(item, tagObj, "Razor")
end

local function predicateScissors(item)
	if item:isBroken() then return false end
	if item:getType() == "Scissors" then return true end

	local tagObj = (ItemTag and ItemTag.SCISSORS) or nil
	return IHM_itemHasTag(item, tagObj, "Scissors")
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


-- Modified vanilla function to produce `hairInfo` instead of context menu options
function ISCharacterScreen:hairMenu(button)
	local player = self.char;
	local context = ISContextMenu.get(self.char:getPlayerNum(), button:getAbsoluteX(), button:getAbsoluteY() + button:getHeight());
	local playerInv = player:getInventory()
	
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
		local hairMenu = context

		local tie_options = {}
		local cut_options = {}
		
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
					table.insert(tie_options, {
						id = hairStyle:getName(),
						display = getText("IGUI_Hair_" .. hairStyle:getName()),
						getterName = "getHairModel",
						setterName = "setHairModel",
						selected = false,
						requirements = nil,
						actionTime = 100, 
					})
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
			
			local inv = player:getInventory()
			local hasRazor    = inv:containsEvalRecurse(predicateRazor)
			local hasScissors = inv:containsEvalRecurse(predicateScissors)
			local hasHairgel  = inv:containsTypeRecurse("Hairgel") or inv:containsTypeRecurse("HairGel")
			
			local SpongieHairAPI = require("SpongieHairUnlocker/SpongieHairAPI")
			for _,hairStyle in ipairs(hairList2) do
				local info = {
					id = hairStyle:getName(),
					display = getText("IGUI_Hair_" .. hairStyle:getName()),
					getterName = "getHairModel",
					setterName = "setHairModel",
					selected = false,
					requirements = {},
					actionTime = 300,
				}
				
				local hairGel = SpongieHairAPI:NeedHairGel(hairStyle:getName())
				local hairSpray = SpongieHairAPI:NeedHairSpray(hairStyle:getName())
				if hairStyle:getName() == "Bald" then
					info.requirements.razor = hasRazor
					info.requirements.scissors = hasScissors
				elseif hairGel then
					info.requirements.hairgel = hasHairgel
				elseif hairSpray then
					info.requirements.hairgel = hasHairgel
				else
					info.requirements.scissors = hasScissors
				end

				table.insert(cut_options, info)
			end
		end

		if #tie_options > 0 then
			hairMenu:addOption(ContextMenu_TieHair, self, self.ihm_open_hair_menu, tie_options, ContextMenu_TieHair, false)
		end
		if #cut_options > 0 then
			hairMenu:addOption(ContextMenu_CutHairFor, self, self.ihm_open_hair_menu, cut_options, ContextMenu_CutHairFor, false)
		end
	else
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
