
if getActivatedMods():contains("\\improvedhairmenubuild42") then return end

local function predicateRazor(item)
	if item:isBroken() then return false end
	return item:hasTag(ItemTag.RAZOR) or item:getType() == "Razor"
end

local function predicateScissors(item)
	if item:isBroken() then return false end
	return item:hasTag(ItemTag.SCISSORS) or item:getType() == "Scissors"
end
local function predicateHairGel(item)
	return item:getType() == "Hairgel"
end
local function predicateHairSpray(item)
	return item:getType() == "Hairspray2"
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

			local hasScissors = player:getInventory():containsEvalRecurse(predicateScissors)
			local hasRazor = player:getInventory():containsEvalRecurse(predicateRazor)
			local hasHairGel = player:getInventory():containsEvalRecurse(predicateHairGel)
			local hasHairSpray = player:getInventory():containsEvalRecurse(predicateHairSpray)

			local SpongieHairAPI = require("SpongieHairAPI")
			for _,hairStyle in ipairs(hairList2) do
				local hair = hairStyle:getName()

				local option = hairMenu:addOption(getText("ContextMenu_CutHairFor", getText("IGUI_Hair_" .. hair)), player, ISCharacterScreen.onCutHair, hair, 300);
				if hair == "Bald" then
					option.name = getText("ContextMenu_ShaveHair");
					if not hasRazor and not hasScissors then
						self:addTooltip(option, getText("Tooltip_requireRazorOrScissors"));
					end
				else
					local hairGel = SpongieHairAPI:GetHairGel(hair)
					local hairSpray = SpongieHairAPI:GetHairSpray(hair)
					
					if hairGel and hairSpray then
						-- print(hairStyle:getName() .. " REQUIRES HAIR GEL OR HAIR SPRAY")
						option.name = getText("ContextMenu_GelHairFor", getText("IGUI_Hair_" .. hair))
						if not hasHairGel and not hasHairSpray  then
							self:addTooltip(option, getText("Tooltip_requireHairGelOrHairSpray"));
						end
					elseif hairGel then
						-- print(hairStyle:getName() .. " REQUIRES HAIR GEL")
						option.name = getText("ContextMenu_GelHairFor", getText("IGUI_Hair_" .. hair))
						if not hasHairGel then
							self:addTooltip(option, getText("Tooltip_requireHairGel"));
						end
					elseif hairSpray then
						-- print(hairStyle:getName() .. " REQUIRES HAIR SPRAY")
						option.name = getText("ContextMenu_GelHairFor", getText("IGUI_Hair_" .. hair))
						if not hasHairSpray then
							self:addTooltip(option, getText("Tooltip_requireHairSpray"));
						end

					elseif not hasScissors then
						self:addTooltip(option, getText("Tooltip_RequireScissors"));
					end
				end
			end
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
