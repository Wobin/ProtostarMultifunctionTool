
local MAJOR,MINOR = "Wob:LibSort-1.0", 3
-- Get a reference to the package information if any
local APkg = Apollo.GetPackage(MAJOR)
-- If there was an older version loaded we need to see if this is newer
if APkg and (APkg.nVersion or 0) >= MINOR then
	return -- no upgrade needed
end
-- Set a reference to the actual package or create an empty table
local LibSort = APkg and APkg.tPackage or {}

local glog

function LibSort:OnLoad()
local GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage
glog = GeminiLogging:GetLogger({
        level = GeminiLogging.DEBUG,
        pattern = "%d %n %c %l - %m",
        appender = "GeminiConsole"
  	})
end

local function removeSpaces(name)
	return name:gsub(" ","")
end

local function makePrefix(name)
	return removeSpaces(name) .. "_"
end

LibSort.FirstInChain = {}

LibSort.RegisteredCallbacks = {}
LibSort.AddonOrder = {}
LibSort.DefaultOrdersLow = {}
LibSort.DefaultOrdersHigh = {}
LibSort.TiebreakerChain = {}

function LibSort:Comparer(addonName, itemA, itemB)
	if self.FirstInChain[addonName] then
		return self:ProcessOrderFunction(addonName, self.FirstInChain[addonName], self.TiebreakerChain[addonName][self.FirstInChain[addonName].key], itemA, itemB)
	end
end

function LibSort:ReOrderKeys(addonName)
	local first 
	local previous
	if self.DefaultOrdersLow[addonName] then
		for _, name in ipairs(self.DefaultOrdersLow[addonName]) do
			local data = self.RegisteredCallbacks[addonName][name] 
			if data then -- we skip the ones we haven't registered yet
				first, previous = self:SetKeyOrder(addonName, first, previous, data)
			end
		end
	end	
	if self.DefaultOrdersHigh[addonName] then
		for _, name in ipairs(self.DefaultOrdersHigh[addonName]) do
			local data = self.RegisteredCallbacks[addonName][name] 
			if data then -- we skip the ones we haven't registered yet
				first, previous = self:SetKeyOrder(addonName, first, previous, data)
			end
		end
	end					
end

function LibSort:SetKeyOrder(addonName, first, previous, data)
	if not first then 
		first = true 
		self.FirstInChain[addonName] = data
		self.TiebreakerChain[addonName] = {}
	else
		if previous then
			self.TiebreakerChain[addonName][previous] = data
		end
	end	
	return first, data.key
end


function LibSort:ProcessOrderFunction(addonName, data, tiebreaker, itemA, itemB)
	if itemA == itemB then
		return 0
	end
	if itemA and itemB == nil then
		return -1
	end
	if itemA == nil and itemB then
		return 1
	end
	

	local response = data.func(itemA, itemB)
	if response == 0 and self.TiebreakerChain[addonName][data.key] then		
		return self:ProcessOrderFunction(addonName, tiebreaker, self.TiebreakerChain[addonName][tiebreaker.key], itemA, itemB)
	else
		return response
	end
end

--------- API ---------

function LibSort:Unregister(addonName, name)
	if not name then 
		self.RegisteredCallbacks[addonName] = nil
		self.DefaultOrdersHigh[addonName] = nil
		self.DefaultOrdersLow[addonName] = nil
		return
	end

	if self.RegisteredCallbacks[addonName] then
		self.RegisteredCallbacks[addonName][name] = nil
	end
end

function LibSort:Register(addonName, name, desc, key, func)
	if not self.RegisteredCallbacks[addonName] then self.RegisteredCallbacks[addonName] = {} table.insert(self.AddonOrder, addonName) end
	self.RegisteredCallbacks[addonName][name] = {key = makePrefix(addonName)..key, func = func, desc = desc, name = name}
	if not self.DefaultOrdersHigh[addonName] then self.DefaultOrdersHigh[addonName] = {} end
	table.insert(self.DefaultOrdersHigh[addonName], name)
	self:ReOrderKeys(addonName)
end

function LibSort:RegisterDefaultOrder(addonName, keyTableLow, keyTableHigh)
	self.DefaultOrdersHigh[addonName] = keyTableHigh
	self.DefaultOrdersLow[addonName] = keyTableLow
	self:ReOrderKeys(addonName)
end

Apollo.RegisterPackage(LibSort, MAJOR, MINOR, {})