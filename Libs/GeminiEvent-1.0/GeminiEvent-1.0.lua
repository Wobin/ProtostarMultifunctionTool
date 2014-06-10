--- Gemini:Event-1.0 provides event registration and secure dispatching.
-- All dispatching is done using **CallbackHandler-1.0**. GeminiEvent is a simple wrapper around
-- CallbackHandler, and dispatches all game events or addon message to the registrees.
--
-- **Gemini:Event-1.0** can be embeded into your addon, either explicitly by calling GeminiEvent:Embed(MyAddon) or by 
-- specifying it as an embeded library in your AceAddon. All functions will be available on your addon object
-- and can be accessed directly, without having to explicitly call GeminiEvent itself.\\
-- It is recommended to embed GeminiEvent, otherwise you'll have to specify a custom `self` on all calls you
-- make into GeminiEvent.
-- @class file
-- @name Gemini:Event-1.0
local MAJOR, MINOR = "Gemini:Event-1.0", 1
-- Get a reference to the package information if any
local APkg = Apollo.GetPackage(MAJOR)
-- If there was an older version loaded we need to see if this is newer
if APkg and (APkg.nVersion or 0) >= MINOR then
	return -- no upgrade needed
end
-- Set a reference to the actual package or create an empty table
local GeminiEvent = APkg and APkg.tPackage or {}
local kStrEventPrefx = "_EVT_"

-- Lua APIs
local pairs = pairs

GeminiEvent.embeds = GeminiEvent.embeds or {} -- what objects embed this lib
local CallbackHandler = Apollo.GetPackage("Gemini:CallbackHandler-1.0").tPackage

function BuildDispatcher(strEventName)
	local funcStr = "return (function (self, ...) self:Fire('" .. strEventName .. "', ...) end)"

	-- Convert this string into a function
	local loadedFunc = loadstring(funcStr)
	-- Since this function actually returns the function we want, we return the function that the function we made made ... clear no?
	return loadedFunc()
end

-- APIs and registry for Apollo events, using CallbackHandler lib
GeminiEvent.events = CallbackHandler:New(GeminiEvent, 
	"RegisterEvent", "UnregisterEvent", "UnregisterAllEvents")
GeminiEvent.SendEvent = Event_FireGenericEvent

function GeminiEvent.events:OnUsed(target, eventName)
	local strHandler = kStrEventPrefx .. eventName
	self[strHandler] = BuildDispatcher(eventName)
	Apollo.RegisterEventHandler(eventName, strHandler, self)
end

function GeminiEvent.events:OnUnused(target, eventName)
	Apollo.RemoveEventHandler(eventName, self)
	local strHandler = kStrEventPrefx .. eventName
	self[strHandler] = nil
end

-- APIs and registry for IPC messages, using CallbackHandler lib
GeminiEvent.messages = CallbackHandler:New(GeminiEvent, 
	"RegisterMessage", "UnregisterMessage", "UnregisterAllMessages"
)
GeminiEvent.SendMessage = GeminiEvent.messages.Fire

--- embedding and embed handling
local mixins = {
	"RegisterEvent", "UnregisterEvent",
	"RegisterMessage", "UnregisterMessage",
	"SendEvent", "SendMessage",
	"UnregisterAllEvents", "UnregisterAllMessages",
}

--- Register for a Blizzard Event.
-- The callback will be called with the optional `arg` as the first argument (if supplied), and the event name as the second (or first, if no arg was supplied)
-- Any arguments to the event will be passed on after that.
-- @name GeminiEvent:RegisterEvent
-- @class function
-- @paramsig event[, callback [, arg]]
-- @param event The event to register for
-- @param callback The callback function to call when the event is triggered (funcref or method, defaults to a method with the event name)
-- @param arg An optional argument to pass to the callback function

--- Unregister an event.
-- @name GeminiEvent:UnregisterEvent
-- @class function
-- @paramsig event
-- @param event The event to unregister

--- Register for a custom GeminiEvent-internal message.
-- The callback will be called with the optional `arg` as the first argument (if supplied), and the event name as the second (or first, if no arg was supplied)
-- Any arguments to the event will be passed on after that.
-- @name GeminiEvent:RegisterMessage
-- @class function
-- @paramsig message[, callback [, arg]]
-- @param message The message to register for
-- @param callback The callback function to call when the message is triggered (funcref or method, defaults to a method with the event name)
-- @param arg An optional argument to pass to the callback function

--- Unregister a message
-- @name GeminiEvent:UnregisterMessage
-- @class function
-- @paramsig message
-- @param message The message to unregister

--- Send a message over the Gemini:Event-1.0 internal message system to other addons registered for this message.
-- @name GeminiEvent:SendMessage
-- @class function
-- @paramsig message, ...
-- @param message The message to send
-- @param ... Any arguments to the message


-- Embeds GeminiEvent into the target object making the functions from the mixins list available on target:..
-- @param target target object to embed GeminiEvent in
function GeminiEvent:Embed(target)
	for k, v in pairs(mixins) do
		target[v] = self[v]
	end
	self.embeds[target] = true
	return target
end

-- GeminiEvent:OnEmbedDisable( target )
-- target (object) - target object that is being disabled
--
-- Unregister all events messages etc when the target disables.
-- this method should be called by the target manually or by an addon framework
function GeminiEvent:OnEmbedDisable(target)
	target:UnregisterAllEvents()
	target:UnregisterAllMessages()
end

--- Finally: upgrade our old embeds
for target, v in pairs(GeminiEvent.embeds) do
	GeminiEvent:Embed(target)
end

-- Initialization routines
function GeminiEvent:OnLoad()

end

function GeminiEvent:OnDependencyError(strDep, strError)
	error(MAJOR .. " couldn't load " .. strDep .. ". Fatal error: " .. strError)
	return false
end

Apollo.RegisterPackage(GeminiEvent, MAJOR, MINOR, {"Gemini:CallbackHandler-1.0"})
