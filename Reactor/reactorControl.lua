local component = require("component")
local event = require("event")
local _logic = require("_logic")
local _event = require("_event")
local _gpu = require("_gpu")
local _text = require("_text")
local _component = require("_component")
local gpu = component.gpu
local reactor = component.nc_fission_reactor

local MSG_GET_STATUS = "MSG_GET_STATUS"
local MSG_POST_STATUS = "MSG_POST_STATUS"
local MSG_SHUTDOWN_POWER = "SHUTDOWN_POWER"
local MSG_ACTIVATE_POWER = "ACTIVATE_POWER"
-- local MSG_ERROR = "ERROR"
local RELAY = "RELAY"
local C_BLACK, C_WHITE, C_OK, C_KO, C_INFO2 = 0x000000, 0xffffff, 0x22af4b, 0xee2524, 0xf9df30
local resX, resY = gpu.getResolution()

local remoteComputers = {RELAY}
local remoteComputersInfos = {}

_component.init(remoteComputers, remoteComputersInfos, true)

local relayAddress = remoteComputersInfos[RELAY].address
local relayPort = remoteComputersInfos[RELAY].port

local postStatusFailure = function()
	_gpu.set(1, 0, _text.alignCenter("Aucune réponse de l'ordinateur distant", resX), 0, C_KO)
end

local postStatus = function()
	_event.sendTimeout(relayAddress, relayPort, MSG_POST_STATUS, nil, postStatusFailure, 1, 3, reactor.isProcessing())
end

local listenModemMessage = function()
	if _logic.case(relayPort, MSG_GET_STATUS) then
	  postStatus()
	elseif _logic.case(relayPort, MSG_ACTIVATE_POWER) then
		if not reactor.isComplete() then
			_gpu.set(1, 0,
				_text.alignCenter(os.date("[%X] Le réacteur a essayé de démarrer un réacteur incomplet"), resX), 0, C_KO)
		elseif not reactor.isProcessing() then
			_gpu.set(1, 0, _text.alignCenter(os.date("[%X] Démarrage du réacteur"), resX), 0, C_INFO2)
			reactor.activate()
			postStatus()
		else
			_gpu.set(1, 0, _text.alignCenter(os.date("[%X] Le réacteur est déjà démarré"), resX), 0, C_KO)
		end
	elseif _logic.case(relayPort, MSG_SHUTDOWN_POWER) then
		if not reactor.isComplete() then
			_gpu.set(1, 0,
				_text.alignCenter(os.date("[%X] Le réacteur a essayé d'arrêter un réacteur incomplet"), resX), 0, C_KO)
		elseif reactor.isProcessing() then
			_gpu.set(1, 0, _text.alignCenter(os.date("[%X] Arrêt du réacteur"), resX), 0, C_INFO2)
			reactor.deactivate()
			postStatus()
		else
			_gpu.set(1, 0, _text.alignCenter(os.date("[%X] Le réacteur est déjà arrêté"), resX), 0, C_KO)
		end
	end
  end

_event.listenModemMessage(listenModemMessage)

local drawPowerBtn = function(cPower)
	_gpu.draw(-16, -9, {cPower}, {
		{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0},
		{1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1},
		{1, 1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1, 1},
		{1, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1},
		{1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1},
		{1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1},
		{1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1},
		{1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1},
		{0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0}
	})
end

local onChangeActivation = function(_, _, x, y)
	if x >= resX - 16 and x <= resX - 1 and y >= resY - 9 and y <= resY - 1 then
		if reactor.isProcessing() then
			reactor.deactivate()
			drawPowerBtn(C_OK)
			postStatus()
		else
			reactor.activate()
			drawPowerBtn(C_KO)
			postStatus()
		end
	end
end

event.listen("touch", onChangeActivation)

_gpu.set(2,2, reactor.getFissionFuelName(), 12, C_INFO2)

local cPower
if reactor.isProcessing() then
	cPower = C_KO
else
	cPower = C_OK
end

drawPowerBtn(cPower)

while not _component.isClosed() do
	_gpu.setIf(reactor.isProcessing(), -7, 2, {"ALLUMÉ", C_OK}, {"ÉTEINT", C_KO}, 0, C_WHITE, C_BLACK)
	_component.bargraphH(2, 4, -1, 1, reactor.getEnergyStored(), reactor.getMaxEnergyStored())
	os.sleep(1)
end
os.execute("refresh")