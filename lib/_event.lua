local component = require("component")
local event = require("event")
local modem = component.modem
local _event = {}

local signalReturnStatus = {}
local signalReturnIds = {}
local signalReturnAttempts = {}

local signalReturnCancel = function(key)
  if signalReturnIds[key] then
    event.cancel(signalReturnIds[key])
  end
  signalReturnStatus[key] = false
  signalReturnAttempts[key] = 0
end

local signalReturnCall = function(address, port, key, callbackSuccess, callbackFailure, maxAttempts, type, ...)
  if signalReturnStatus[key] then
    signalReturnCancel(key, signalReturnStatus)
    callbackSuccess()
  else
    if signalReturnAttempts[key] < maxAttempts then
      modem.send(address, port, key, type, ...)
      signalReturnAttempts[key] = signalReturnAttempts[key] + 1
    else
      signalReturnCancel(key, signalReturnStatus)
      callbackFailure()
    end
  end
end

local signalReturn = function(address, port, key, callbackSuccess, callbackFailure, maxAttempts, type, ...)
  local payload = ...
  return function()
    signalReturnCall(address, port, key, callbackSuccess, callbackFailure, maxAttempts, type, payload)
  end
end

_event.returnSignalCheck = function(key)
  signalReturnStatus[key] = true
end

_event.removeListeners = function(key)
  for _,v in pairs(event.handlers) do
    if v.key == key then
      event.ignore(v.key, v.callback)
    end
  end
end

_event.sendTimeout = function(address,
                              port,
                              key,
                              callbackSuccess,
                              callbackFailure,
                              callReturns,
                              delay,
                              maxAttempts,
                              type,
                              ...)
  table.insert(callReturns, {port, type})
  signalReturnCancel(key, signalReturnStatus)
  signalReturnCall(address, port, key, callbackSuccess, callbackFailure, maxAttempts, type, ...)
  signalReturnIds[key] = event.timer(
	  delay,
	  signalReturn(address, port, key, callbackSuccess, callbackFailure, maxAttempts, type, ...),
	  math.huge)
end

return _event