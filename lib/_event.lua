local component = require("component")
local event = require("event")
local _table = require("_table")
local _logic = require("_logic")
local modem = component.modem
local _event = {}

local callReturns = {}
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

local signalReturnCall = function(address, port, key, callbackSuccess, callbackFailure, maxAttempts, ...)
  if signalReturnStatus[key] then
    signalReturnCancel(key, signalReturnStatus)
    if callbackSuccess then callbackSuccess() end
  else
    if signalReturnAttempts[key] < maxAttempts then
      modem.send(address, port, key, ...)
      signalReturnAttempts[key] = signalReturnAttempts[key] + 1
    else
      signalReturnCancel(key, signalReturnStatus)
      if callbackFailure then callbackFailure() end
    end
  end
end

local signalReturn = function(address, port, key, callbackSuccess, callbackFailure, maxAttempts, ...)
  local payload = ...
  return function()
    signalReturnCall(address, port, key, callbackSuccess, callbackFailure, maxAttempts, payload)
  end
end

local filterReturn = function(tableTest, tableCheck)
  local result = tableTest[1] == tableCheck[1]
          and tableTest[2] == tableCheck[2].."_RETURN"
          and #tableTest == #tableCheck
  return result
end

local getCallReturn = function(port, type)
  _logic.switch(port, type)
  return _logic.caseFilter(filterReturn, callReturns)[1]
end

local returnSignalCheck = function(callReturn)
  signalReturnStatus[callReturn[2]] = true
  _table.remove(callReturns, callReturn)
end

_event.listenModemMessage = function(eventFunction)
  event.listen("modem_message",
    function(_, _, from, port, _, type, ...)
      _event.processCallReturn(from, port, type)

      _logic.switch(port, type)

      eventFunction(...)

    end
  )
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
                              delay,
                              maxAttempts,
                              ...)
  table.insert(callReturns, {port, key})
  signalReturnCancel(key, signalReturnStatus)
  signalReturnCall(address, port, key, callbackSuccess, callbackFailure, maxAttempts, ...)
  signalReturnIds[key] = event.timer(
	  delay,
	  signalReturn(address, port, key, callbackSuccess, callbackFailure, maxAttempts, ...),
	  math.huge)
end

_event.processCallReturn = function(from, port, type)
  local callReturn = getCallReturn(port, type)
  if callReturn then
    returnSignalCheck(callReturn)
  else
    modem.send(from, port, type.."_RETURN")
  end
end

return _event