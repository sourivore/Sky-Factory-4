local component = require("component")
local event = require("event")
local term = require("term")
local _event = require("_event")
local _gpu = require("_gpu")
local _text = require("_text")
local _component = require("_component")
local gpu = component.gpu
local modem = component.modem
local reactor = component.nc_fission_reactor

local COMMUNICATION_PORT = 22356
local MSG_TYPE_ACTIVATION = "MSG_TYPE_ACTIVATION"
local MSG_SHUTDOWN_POWER = "SHUTDOWN_POWER"
local MSG_ACTIVATE_POWER = "ACTIVATE_POWER"
local MSG_ERROR = "ERROR"
local MSG_OK = "OK"
local C_BLACK, C_WHITE, C_OK, C_KO, C_INFO2 = 0x000000, 0xffffff, 0x22af4b, 0xee2524, 0xf9df30
local resX, resY = gpu.getResolution()
local state = {close = false}

_event.removeListeners("modem_message")
_event.removeListeners("touch")
term.clear()

if not modem.isOpen(COMMUNICATION_PORT) then
	modem.open(COMMUNICATION_PORT)
end

local onMessageReceived = function(type, msg)
	if not type == MSG_TYPE_ACTIVATION then
		return
	end
	if not reactor.isComplete() then
		_gpu.set(1, 0,
			_text.alignCenter(os.date("[%X] Le réacteur a essayé de démarrer un réacteur incomplet"), resX), 0, C_KO)
		modem.broadcast(COMMUNICATION_PORT, MSG_TYPE_ACTIVATION, MSG_ERROR)
	elseif msg == MSG_SHUTDOWN_POWER then
		--SHUTDOWN REACTOR
		if reactor.isProcessing() then
			_gpu.set(1, 0, _text.alignCenter(os.date("[%X] Arrêt du réacteur"), resX), 0, C_INFO2)
			reactor.deactivate()
		else
			_gpu.set(1, 0, _text.alignCenter(os.date("[%X] Le réacteur est déjà arrêté"), resX), 0, C_KO)
		end
		modem.broadcast(COMMUNICATION_PORT, MSG_TYPE_ACTIVATION, MSG_OK, reactor.isProcessing())
	elseif msg == MSG_ACTIVATE_POWER then
		--ACTIVATE POWER
		if reactor.isProcessing() then
			_gpu.set(1, 0, _text.alignCenter(os.date("[%X] Le réacteur est déjà démarré"), resX), 0, C_KO)
		else
			_gpu.set(1, 0, _text.alignCenter(os.date("[%X] Démarrage du réacteur"), resX), 0, C_INFO2)
			reactor.activate()
		end
		modem.broadcast(COMMUNICATION_PORT, MSG_TYPE_ACTIVATION, MSG_OK, reactor.isProcessing())
	end
end

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
		else
			reactor.activate()
			drawPowerBtn(C_KO)
		end
	end
end


event.listen("modem_message",
	function(_, _, _, _, _, type, msg)
		onMessageReceived(type, msg)
	end
)

event.listen("touch", onChangeActivation)

_component.closeBtn(state)

_gpu.set(2,2, reactor.getFissionFuelName(), 12, C_INFO2)

local cPower
if reactor.isProcessing() then
	cPower = C_KO
else
	cPower = C_OK
end

drawPowerBtn(cPower)

while not state.close do
	_gpu.setIf(reactor.isProcessing(), -7, 2, {"ALLUMÉ", C_OK}, {"ÉTEINT", C_KO}, 0, C_WHITE, C_BLACK)
	_component.bargraphH(2, 4, -1, 1, reactor.getEnergyStored(), reactor.getMaxEnergyStored())
	os.sleep(1)
end
os.execute("refresh")