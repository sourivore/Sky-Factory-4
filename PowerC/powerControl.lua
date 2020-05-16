local component = require("component")
local _component = require("_component")
local _logic = require("_logic")
local _event = require("_event")
local gpu = component.gpu

local remoteComputers = {"RELAY"}
local remoteComputersInfos = {}

_component.init(remoteComputers, remoteComputersInfos, true)

local relayAddress = remoteComputersInfos["RELAY"].address
local relayPort = remoteComputersInfos["RELAY"].port

local reactorStatus = true

local listenModemMessage = function(...)
  local payload = {...}
  if _logic.case(relayPort, "POST_STATUS") then
    print(relayPort.." - POST STATUS")
    print("Statut récupéré : "..tostring(payload[1]))
    reactorStatus = payload[1]
  elseif _logic.caseIn(
    {relayPort, "GET_STATUS_ERROR"},
    {relayPort, "ACTIVATE_REACTOR_ERROR"},
    {relayPort, "DESACTIVATE_REACTOR_ERROR"}) then
      print(relayPort.." - ".._logic.getTest()[2])
      print("ERREUR : "..payload[1])
  end
end

_event.listenModemMessage(listenModemMessage)

local changeReactorStatus = function(type)
   print("Change status", type)
  _event.sendTimeout(relayAddress, relayPort, type, nil, nil, 1, 3)
end

local getStatusFailure = function()
  print("Echec de l'envoi GET STATUS")
end

local getStatusSuccess = function()
  print("Réussite de l'envoi GET STATUS")
end

_event.sendTimeout(relayAddress, relayPort, "GET_STATUS", getStatusSuccess, getStatusFailure, 1, 3)

local level = 0
local direction

while not _component.isClosed() do
  gpu.set(30, 1, "LEVEL : "..level.." ")
  if reactorStatus then
    direction = 1
  else
    direction = -1
  end
  level = level + math.random(20) * direction
  if level >= 100 and reactorStatus then
    reactorStatus = false
    changeReactorStatus("DESACTIVATE_REACTOR")
  end
  if level <= 0 and not reactorStatus then
    reactorStatus = true
    changeReactorStatus("ACTIVATE_REACTOR")
  end
  os.sleep(1)
end
os.execute("refresh")