local component = require("component")
local event = require("event")
local term = require("term")
local computer = require "computer"
local _event = require("_event")
local _gpu = require("_gpu")
local _number = require("_number")
local _time = require("_time")
local _text = require("_text")
local _component = require("_component")
local gpu = component.gpu
local powerCell = component.energy_device
local modem = component.modem
gpu.setResolution(48,16)

local MIN_ENERGY_PERCENT = 10
local MAX_ENERGY_PERCENT = 90
local COMMUNICATION_PORT = 22356
local MSG_TYPE_ACTIVATION = "MSG_TYPE_ACTIVATION"
local SHUTDOWN_POWER = "SHUTDOWN_POWER"
local ACTIVATE_POWER = "ACTIVATE_POWER"
local MAX_ITERATION = 10
local MSG_ERROR = "ERROR"
local MSG_OK = "OK"
local C_BLACK, C_WHITE, C_OK, C_KO, C_INFO, C_INFO2 = 0x000000, 0xffffff, 0x22af4b, 0xee2524, 0x0f89ca, 0xf9df30
local resX, resY = gpu.getResolution()
local reactorActivated = true
local state = {close = false}

_event.removeListeners("modem_message")
_event.removeListeners("touch")

if not modem.isOpen(COMMUNICATION_PORT) then
    modem.open(COMMUNICATION_PORT)
end

local filterMessageTypeActivation = function(name, _, _, _, _, type, ... )
	return name == "modem_message" and type == MSG_TYPE_ACTIVATION
end

local controlPower =  function(action, msgKO)
	modem.broadcast(COMMUNICATION_PORT, MSG_TYPE_ACTIVATION, action)
	local msg, _reactorActivated
	for iteration = 0, MAX_ITERATION do
		_, _, _, _, _, _, msg, _reactorActivated = event.pullFiltered(10, filterMessageTypeActivation)
		if reactorActivated ~= _reactorActivated then
			reactorActivated = _reactorActivated
			_gpu.setAll(-12, 2,
			{
				{"Reactor = "}, 
				{reactorActivated, {"OK", C_OK}, {"KO", C_KO}}
			}, 12, C_WHITE, C_BLACK)
		end
		if msg == MSG_OK then
			return
		elseif msg == MSG_ERROR then
			_gpu.set(1, 0, _text.alignCenter(msgKO, resX), 0, C_KO)
			return
		end
	end
	_gpu.set(1, 0, _text.alignCenter("Aucune réponse de l'ordinateur distant", resX), 0, C_KO)
end

local shutdownPower = function()
	controlPower(SHUTDOWN_POWER, "Le réacteur n'a pas pu être arrêté")
end

local activatePower = function()
	controlPower(ACTIVATE_POWER, "Le réacteur n'a pas pu être démarré")
end

term.clear()

shutdownPower()

local lastTime = computer.uptime()
local lastEnergy = powerCell.getEnergyStored()

_component.closeBtn(state)

while not state.close do
	local maxEnergy = powerCell.getMaxEnergyStored()
	local currentEnergy = powerCell.getEnergyStored()
	local energyPercent =_component.bargraphH(2, 4, -1, 3, currentEnergy , maxEnergy)
	local production = (currentEnergy - lastEnergy) / (computer.uptime() - lastTime - 0.05) / 20
	local secRemaining = - currentEnergy / production / 20

	_gpu.setAll(2, 8,
		{
			{_text.alignRight("Max", 18).." = "}, 
			{_number.reduceUnit(maxEnergy, "RF", 2), C_INFO}
		}, 0, C_WHITE, C_BLACK)
	_gpu.setAll(2, 9,
		{
			{_text.alignRight("RF", 18).." = "}, 
			{_number.reduceUnit(currentEnergy, "RF", 2), C_INFO}
		}, 0, C_WHITE, C_BLACK)
	_gpu.setAll(2, 10,
		{
			{_text.alignRight("Production", 18).." = "}, 
			{_number.reduceUnit(production, "RF/t"), C_INFO}
		}, 0, C_WHITE, C_BLACK)
	_gpu.setAll(2, 11,
		{
			{_text.alignRight("Secondes restantes", 18).." = "}, 
			{production < 0, 
				{_time.secondsToTime(-currentEnergy / production / 20, 2), C_INFO}, 
				{_time.secondsToTime((maxEnergy - currentEnergy) / production / 20, 2), C_INFO}
			},
			{production < 0, 
				{" ↓", C_KO}, 
				{" ↑", C_OK}
			}
		}, 0, C_WHITE, C_BLACK)

	lastTime = computer.uptime()
	lastEnergy = powerCell.getEnergyStored()
	if energyPercent > MAX_ENERGY_PERCENT and reactorActivated then
		shutdownPower()
	elseif energyPercent < MIN_ENERGY_PERCENT and not reactorActivated then
		activatePower()
	end
	_gpu.setAll(2, 2,
		{
			{"Percent = "}, 
			{string.format("%.2f", energyPercent).." %", C_INFO2}
		}, 18, C_WHITE, C_BLACK)
	os.sleep(1)
end
os.execute("refresh")