local event = require("event")

local _event = {}

_event.removeListeners = function(key)
	for k,v in pairs(event.handlers) do
		if v.key == key then
			event.ignore(v.key, v.callback)
		end
	end
end

return _event