-----------------------------------------------------------------------------------------------
-- Client Lua Script for ProtostarMultifunctionTool
-- Copyright (c) Wobin. All rights reserved
--
--
-- Then Amnon hated her exceedingly; so that the first time a thunk is forced, we will turn it 
-- into an evaluated thunk
--             A reading from the Book of Markov - Chapter 30 Verses 5-14 
--                      Structure and Interpretation of Computer Programs - King James Version
--                                                                  http://tinyurl.com/p8vb3me
-----------------------------------------------------------------------------------------------
 
require "Window"
 
local GatheringTypes = {}
local GatheringNames = {}
local ValidGatheringNames = {}

-----------------------------------------------------------------------------------------------
-- ProtostarMultifunctionTool Module Definition
-----------------------------------------------------------------------------------------------

PSTool = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:NewAddon("Protostar Multifunction Tool", false, {}, "Gemini:Hook-1.0", "Gemini:Event-1.0") 
local GeminiGUI, glog

function PSTool:OnInitialize()
	local GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage
  	glog = GeminiLogging:GetLogger({
        level = GeminiLogging.DEBUG,
        pattern = "%d %n %c %l - %m",
        appender = "GeminiConsole"
  	})	
end

local harvestType, harvestLevel, currentTimer

function PSTool:SpellCastFailed(name, messageType, castResult, targetUnit, sourceUnit, message)	
	if targetUnit ~= sourceUnit then return end
	if castResult ~= Spell.CodeEnumCastResult.Prereq_TargetCast then return end
	if not GameLib.GetTargetUnit():CanBeHarvestedBy(GameLib.GetPlayerUnit()) then return end
	harvestType, harvestLevel = GameLib.GetTargetUnit():GetHarvestRequiredTradeskillName(), GameLib.GetTargetUnit():GetHarvestRequiredTradeskillTier()	
	if not ValidGatheringNames[harvestType] then return end
	local tool = self:GetEquippedTool(GameLib.GetPlayerUnit():GetEquippedItems())
	if not tool or GatheringTypes[tool:GetItemCategory()] ~= harvestType then		

		-- Lets get the correct tool for the job
		local inv = GameLib.GetPlayerUnit():GetInventoryItems()		
		local slot
		for i=1, #inv do
			
			if GatheringTypes[inv[i].itemInBag:GetItemCategory()] == harvestType then
				slot = inv[i].nBagSlot;
				break
			end			
		end
		
		GameLib.EquipBagItem(slot + 1)
	end
end


function PSTool:GetEquippedTool(equippedItems)	
	for i,v in ipairs(equippedItems) do		
		if v:GetSlot() == 6 then
			return v 
		end
	end
	return nil 
end

function PSTool:OnEnable()

	GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage	
	self:RegisterEvent("SpellCastFailed")
	
	ValidGatheringNames = {
		[CraftingLib.GetTradeskillInfo(15).strName] = true,
		[CraftingLib.GetTradeskillInfo(18).strName] = true,
		[CraftingLib.GetTradeskillInfo(13).strName] = true,
	}

	GatheringNames = { 
		["Survivalist"] = 	CraftingLib.GetTradeskillInfo(15).strName,
		["Relic Hunter"] = 	CraftingLib.GetTradeskillInfo(18).strName,
		["Mining"] = 		CraftingLib.GetTradeskillInfo(13).strName,
	}

	GatheringTypes = {
		[116] = CraftingLib.GetTradeskillInfo(15).strName, -- Survivalist
		[117] = CraftingLib.GetTradeskillInfo(18).strName, -- Relic Hunter
		[106] = CraftingLib.GetTradeskillInfo(13).strName, -- Mining
	}
end
