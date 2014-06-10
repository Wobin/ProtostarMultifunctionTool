GeminiEvent
===========

Wildstar Library - Provides event &amp; message registration/dispatching.

GeminiEvent-1.0 provides event registration and secure dispatching.
All dispatching is done using CallbackHandler-1.0. GeminiEvent is a simple wrapper around CallbackHandler, and dispatches all game events or addon message to the registrees.

**GeminiEvent-1.0** can be embeded into your addon, either explicitly by calling GeminiEvent:Embed(MyAddon) or by specifying it as an embeded library in your GeminiAddon. All functions will be available on your addon object and can be accessed directly, without having to explicitly call GeminiEvent itself.
It is recommended to embed GeminiEvent, otherwise you'll have to specify a custom `self` on all calls you make into GeminiEvent.



##GeminiEvent:RegisterEvent(event[, callback [, arg]])
Register for a Apollo Event. 
The callback will be called with the optional `arg` as the first argument (if supplied), and the event name as the second (or first, if no arg was supplied) Any arguments to the event will be passed on after that.

###Parameters

**event**

		The event to register for
**callback**

		The callback function to call when the event is triggered (funcref or method, defaults to a method with the event name)
**arg**

		An optional argument to pass to the callback function


##GeminiEvent:RegisterMessage(message[, callback [, arg]])
Register for a custom GeminiEvent-internal message. 
The callback will be called with the optional `arg` as the first argument (if supplied), and the event name as the second (or first, if no arg was supplied) Any arguments to the event will be passed on after that.

###Parameters

**message**

		The message to register for
**callback**

		The callback function to call when the message is triggered (funcref or method, defaults to a method with the event name)
**arg**

		An optional argument to pass to the callback function


##GeminiEvent:SendMessage(message, ...)
Send a message over the GeminiEvent-1.0 internal message system to other addons registered for this message.

###Parameters

**message**

		The message to send
**...**

		Any arguments to the message


##GeminiEvent:SendEvent(event, ...)
Send a message over the Apollo event system to other addons registered for this message.

###Parameters

**event**

		The event to send
**...**

		Any arguments to the message


##GeminiEvent:UnregisterEvent(event)
Unregister an event.

###Parameters

**event**

		The event to unregister


##GeminiEvent:UnregisterMessage(message)
Unregister a message

###Parameters

**message**

		The message to unregister


##GeminiEvent:UnregisterAllEvents(message)
Unregister all events


##GeminiEvent:UnregisterAllMessage(message)
Unregister all messages

