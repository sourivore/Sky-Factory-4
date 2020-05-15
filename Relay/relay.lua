local _component = require("_component")
local _event = require("_event")
local _logic = require("_logic")

local REACTOR = "REACTOR"
local POWER = "POWER"
local MSG_GET_STATUS = "GET_STATUS"
local MSG_POST_STATUS = "POST_STATUS"
local MSG_SHUTDOWN_POWER = "SHUTDOWN_POWER"
local MSG_ACTIVATE_POWER = "ACTIVATE_POWER"
local MAX_ITERATION = 10
local DELAY_ITERATION = 10

local remoteComputers = {REACTOR, POWER}
local remoteComputersInfos = {}

_component.init(remoteComputers, remoteComputersInfos, true)

local getMsgSuccess = function(message)
  return function()
    print("Réussite de l'envoi : "..message)
  end
end

local getMsgFailure = function(message)
  return function()
    print("Echec de l'envoi : "..message)
  end
end

local reactorAddress = remoteComputersInfos[REACTOR].address
local reactorPort = remoteComputersInfos[REACTOR].port
local powerAddress = remoteComputersInfos[POWER].address
local powerPort = remoteComputersInfos[POWER].port

local listenModemMessage = function(...)
  if _logic.case(powerPort, MSG_GET_STATUS) then
    print("Envoi du message "..MSG_GET_STATUS.." sur le port "..powerPort.."...")
    _event.sendTimeout(reactorAddress, reactorPort, MSG_GET_STATUS,
                        getMsgSuccess(MSG_GET_STATUS), getMsgFailure(MSG_GET_STATUS),
                        DELAY_ITERATION, MAX_ITERATION)
  elseif _logic.case(powerPort, MSG_ACTIVATE_POWER) then
    print("Envoi du message "..MSG_GET_STATUS.." sur le port "..powerPort.."...")
    _event.sendTimeout(reactorAddress, reactorPort, MSG_ACTIVATE_POWER,
                        getMsgSuccess(MSG_ACTIVATE_POWER), getMsgFailure(MSG_ACTIVATE_POWER),
                        DELAY_ITERATION, MAX_ITERATION)
  elseif _logic.case(powerPort, MSG_SHUTDOWN_POWER) then
    print("Envoi du message "..MSG_SHUTDOWN_POWER.." sur le port "..powerPort.."...")
    _event.sendTimeout(reactorAddress, reactorPort, MSG_SHUTDOWN_POWER,
                        getMsgSuccess(MSG_SHUTDOWN_POWER), getMsgFailure(MSG_SHUTDOWN_POWER),
                        DELAY_ITERATION, MAX_ITERATION)
  elseif _logic.case(reactorPort, MSG_POST_STATUS) then
    print("Envoi du message "..MSG_POST_STATUS.." sur le port "..reactorPort.."...")
    _event.sendTimeout(powerAddress, powerPort, MSG_POST_STATUS,
                        getMsgSuccess(MSG_POST_STATUS), getMsgFailure(MSG_POST_STATUS),
                        DELAY_ITERATION, MAX_ITERATION, ...)
  end
end

_event.listenModemMessage(listenModemMessage)

while not _component.isClosed() do
  os.sleep(1)
end
os.execute("refresh")