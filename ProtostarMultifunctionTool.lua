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
 
 local tEquipmentSetFormDef =   {
                    AnchorOffsets = { -20, -20, 20, 20 },
                    AnchorPoints = "CENTER",
                    RelativeToClient = true, 
                    BGColor = "UI_WindowBGDefault", 
                    TextColor = "UI_WindowTextDefault", 
                    Name = "BagContainer", 
                    Pixies = {
                        { AnchorPoints = "FILL", Sprite = "BK3:UI_BK3_Holo_InsetFramed_Darker", BGColor = "white", TextColor = "black", },
                    },
                    Children = {
                        {
                            AnchorOffsets = { 2, 2, -2, -2 },
                            AnchorPoints = "FILL",
                            Class = "BagWindow", 
                            RelativeToClient = true, 
                            Sprite = "CRB_UIKitSprites:spr_baseframe", 
                            SquareSize = 100, 
                            BoxesPerRow = 1, 
                            SwallowMouseClicks = true, 
                            IgnoreTooltipDelay = true, 
                            NewQuestOverlaySprite = "BK3:UI_BK3_Holo_Framing_3_Blocker", 
                            Name = "GatheringTool", 
                            Overlapped = true, 
                            IgnoreMouse = true, 
                            Picture = true, 
                            Events = {
                             --   GenerateTooltip = "OnGenerateTooltip",           
                                MouseButtonUp = "MouseUpClear"                   
                            },
                        },
                    },
                }

local GatheringTypes = {
	[116] = "Survivalist",
	[117] = "Relic Hunter",
	[106] = "Mining"
}

-----------------------------------------------------------------------------------------------
-- ProtostarMultifunctionTool Module Definition
-----------------------------------------------------------------------------------------------

PSTool = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:NewAddon("Protostar Multifunction Tool", 
											false, {}, "Gemini:Hook-1.0", "Gemini:Event-1.0", "Gemini:Timer-1.0") 
local GeminiGUI, glog, LibSort, bag, bagWindow 

function PSTool:OnInitialize()
	GeminiGUI = Apollo.GetPackage("Gemini:GUI-1.0").tPackage
	self:RegisterEvent("MouseButtonDown", function(...) self:MouseDown(...) end)
	self:RegisterEvent("TargetUnitChanged", function(...) self:TargetChanged(...) end)


	local GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage
  	glog = GeminiLogging:GetLogger({
        level = GeminiLogging.DEBUG,
        pattern = "%d %n %c %l - %m",
        appender = "GeminiConsole"
  	})

	LibSort = Apollo.GetPackage("Wob:LibSort-1.0").tPackage
	
	self.LibSort = LibSort

	LibSort:Register("PSMFT - Survivalist", "Category", "Sort by Specific Survivalist Category", "SurvivalistCategory", function(...) return PSTool:SortCategory(116, ...) end)
	LibSort:Register("PSMFT - Survivalist", "Level", "Sort by Level", "Level", function(...) return PSTool:SortLevel(...) end)
	LibSort:Register("PSMFT - Relic Hunter", "Category", "Sort by Specific Relic Hunter Category", "RelicHunterCategory", function(...) return PSTool:SortCategory(117, ...) end)
	LibSort:Register("PSMFT - Relic Hunter", "Level", "Sort by Level", "Level", function(...) return PSTool:SortLevel(...) end)
	LibSort:Register("PSMFT - Mining", "Category", "Sort by Specific Mining Category", "MiningCategory", function(...) return PSTool:SortCategory(106, ...) end)
	LibSort:Register("PSMFT - Mining", "Level", "Sort by Level", "Level", function(...) return PSTool:SortLevel(...) end)
end
 
function PSTool:SortCategory(cat, a, b)
	local catA, catB = a:GetItemCategory(), b:GetItemCategory()
	
	if catA == catB then return 0 end
	if catA == cat then return -1 end
	if catB == cat then return 1 end
	return 0
end

function PSTool:SortLevel(a, b)	
	local la, lb = a:GetRequiredLevel(), b:GetRequiredLevel()
	if la == lb then return 0 end
	if la < lb then return -1 end
	return 1
end
--[[
function PSTool:OnGenerateTooltip(wndControl, wndHandler, tType, item)
	if wndControl ~= wndHandler then return end
	wndControl:SetTooltipDoc(nil)
	if item ~= nil then
		local itemEquipped = item:GetEquippedItemForItemType()
		Tooltip.GetItemTooltipForm(self, wndControl, item, {bPrimary = true, bSelling = false, itemCompare = itemEquipped})
	end
end
--]]

local lastX, lastY 

function PSTool:MouseDown(name, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation)
	if eMouseButton ~= 1 then return end
	lastX = nLastRelativeMouseX
	lastY = nLastRelativeMouseY
end

function PSTool:MouseUpClear(wndControl, wndHandler, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation)
	if eMouseButton == 1 then
		bag:Show(false)
	end
end

function PSTool:TargetChanged(name, unit)
	if bag:IsShown() then bag:Show(false) end
	if not unit then return end
	if not unit:CanBeHarvestedBy(GameLib.GetPlayerUnit()) then return end
	local harvestType, harvestLevel = unit:GetHarvestRequiredTradeskillName(), unit:GetHarvestRequiredTradeskillTier()
	local tool = self:GetEquippedTool(GameLib.GetPlayerUnit():GetEquippedItems())
	if not tool or GatheringTypes[tool:GetItemCategory()] ~= harvestType then
		-- Lets get the correct tool for the job
		bagWindow:SetSort(true)
		bagWindow:SetItemSortComparer(function(...) return LibSort:Comparer("PSMFT - " .. harvestType, ...) end)
		bag:Show(true)
		-- Move it to the cursor
		bag:SetAnchorPoints(0,0,0,0)	
		bag:SetAnchorOffsets(lastX - 20, lastY - 20, (lastX + 20), (lastY + 20))	
		-- And hide it after a second
		self:ScheduleTimer(function() bag:Show(false) end, 1)	
	end
end

function PSTool:HideBag()	
	bag:Show(false)
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
	bag = GeminiGUI:Create(tEquipmentSetFormDef):GetInstance(PSTool)	
	bagWindow = bag:FindChild("GatheringTool")
	bag:Show(false)
end