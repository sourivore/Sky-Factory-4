local event = require("event")
local _component = require("_component")
local _logic = require("_logic")
local _event = require("_event")

local remoteComputers = {"RELAY"}
local remoteComputersInfos = {}

_component.init(remoteComputers, remoteComputersInfos, true)

local relayAddress = remoteComputersInfos["RELAY"].address
local relayPort = remoteComputersInfos["RELAY"].port

local reactorStatus = true

local postStatusSuccess = function()
  print("Réussite de l'envoi POST STATUS")
end

local postStatusFailure = function()
  print("Echec de l'envoi POST STATUS")
end

local postStatus = function()
  _event.sendTimeout(relayAddress, relayPort, "POST_STATUS", postStatusSuccess, postStatusFailure, 1, 3, reactorStatus)
end

local listenModemMessage = function()
  if _logic.case(relayPort, "GET_STATUS") then
    print(relayPort.." - GET STATUS")
    postStatus()
  elseif _logic.case(relayPort, "ACTIVATE_REACTOR") then
    print(relayPort.." - ACTIVATE REACTOR")
    if not reactorStatus then
      reactorStatus = true
      postStatus()
    end
  elseif _logic.case(relayPort, "DESACTIVATE_REACTOR") then
    print(relayPort.." - DESACTIVATE REACTOR")
    if reactorStatus then
      reactorStatus = false
      postStatus()
    end
  end
end

_event.listenModemMessage(listenModemMessage)

event.listen("touch",
  function()
    reactorStatus = not reactorStatus
    postStatus()
  end
)

while not _component.isClosed() do
  os.sleep(1)
end
os.execute("refresh")