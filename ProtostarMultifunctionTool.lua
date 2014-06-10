-----------------------------------------------------------------------------------------------
-- Client Lua Script for ProtostarMultifunctionTool
-- Copyright (c) NCsoft. All rights reserved
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
                            Name = "ToEquipBag", 
                            Overlapped = true, 
                            IgnoreMouse = true, 
                            Picture = true, 
                            Events = {
                                GenerateTooltip = "OnGenerateTooltip",
                            },
                        },
                    },
                }

local GatheringTypes = {
	[116] = "Survivalist",
	[117] = "Relic",
	[106] = "Mining"
}

-----------------------------------------------------------------------------------------------
-- ProtostarMultifunctionTool Module Definition
-----------------------------------------------------------------------------------------------

PSTool = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:NewAddon("Protostar Multifunction Tool", 
											false, {"Gemini:GUI-1.0"}, "Gemini:Hook-1.0", "Gemini:Event-1.0") 
local GeminiGUI 
local glog 
local player 

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

end
 
local lastX, lastY 

function PSTool:MouseDown(name, eMouseButton, nLastRelativeMouseX, nLastRelativeMouseY, bDoubleClick, bStopPropagation)
	if eMouseButton ~= 1 then return end
	lastX = nLastRelativeMouseX
	lastY = nLastRelativeMouseY
end

function PSTool:TargetChanged(name, unit)	
	if not unit:CanBeHarvestedBy(player) then return end
	local harvestType, harvestLevel = unit:GetHarvestRequiredTradeskillName(), unit:GetHarvestRequiredTradeskillTier()
	local tool = self:GetEquippedTool(player:GetEquippedItems())
	glog:debug("tool is " .. tool)
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
	GeminiGUI:Create(tEquipmentSetFormDef):GetInstance()
	player = GameLib.GetPlayerUnit()
end