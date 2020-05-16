local _component = require("_component")
local _event = require("_event")
local _logic = require("_logic")

local remoteComputers = {"REACTOR", "POWER"}
local remoteComputersInfos = {}

_component.init(remoteComputers, remoteComputersInfos, true)

local getStatusSuccess = function()
  print("Réussite de l'envoi GET STATUS")
end

local getStatusFailure = function()
  print("Echec de l'envoi GET STATUS")
end

local postStatusSuccess = function()
  print("Réussite de l'envoi POST STATUS")
end

local postStatusFailure = function()
  print("Echec de l'envoi POST STATUS")
end

local reactorAddress = remoteComputersInfos["REACTOR"].address
local reactorPort = remoteComputersInfos["REACTOR"].port
local powerAddress = remoteComputersInfos["POWER"].address
local powerPort = remoteComputersInfos["POWER"].port

local listenModemMessage = function(...)
  if _logic.case(powerPort, "GET_STATUS") then
    print(powerPort.." - GET STATUS")
    _event.sendTimeout(reactorAddress, reactorPort, "GET_STATUS", getStatusSuccess, getStatusFailure, 5, 10)
  elseif _logic.case(powerPort, "ACTIVATE_REACTOR") then
    print(powerPort.." - ACTIVATE REACTOR")
    _event.sendTimeout(reactorAddress, reactorPort, "ACTIVATE_REACTOR", nil, nil, 5, 10)
  elseif _logic.case(powerPort, "DESACTIVATE_REACTOR") then
    print(powerPort.." - DESACTIVATE REACTOR")
    _event.sendTimeout(reactorAddress, reactorPort, "DESACTIVATE_REACTOR", nil, nil, 5, 10)
  elseif _logic.case(reactorPort, "POST_STATUS") then
    print(reactorPort.." - POST STATUS")
    _event.sendTimeout(powerAddress, powerPort, "POST_STATUS", postStatusSuccess, postStatusFailure, 1, 3, ...)
  elseif _logic.case(powerPort, "GET_STATUS_ERROR") then
    print(powerPort.." - GET STATUS ERROR")
    _event.sendTimeout(reactorAddress, reactorPort, "GET_STATUS_ERROR", nil, nil, 5, 10, ...)
  elseif _logic.case(powerPort, "ACTIVATE_REACTOR_ERROR") then
    print(powerPort.." - ACTIVATE REACTOR ERROR")
    _event.sendTimeout(reactorAddress, reactorPort, "ACTIVATE_REACTOR_ERROR", nil, nil, 5, 10, ...)
  elseif _logic.case(powerPort, "DESACTIVATE_REACTOR_ERROR") then
    print(powerPort.." - DESACTIVATE REACTOR ERROR")
    _event.sendTimeout(reactorAddress, reactorPort, "DESACTIVATE_REACTOR_ERROR", nil, nil, 5, 10, ...)
  end
end

_event.listenModemMessage(listenModemMessage)

while not _component.isClosed() do
  os.sleep(1)
end
os.execute("refresh")