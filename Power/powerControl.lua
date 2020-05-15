local component = require("component")
local computer = require "computer"
local _event = require("_event")
local _gpu = require("_gpu")
local _number = require("_number")
local _time = require("_time")
local _text = require("_text")
local _component = require("_component")
local _logic = require("_logic")
local gpu = component.gpu
local powerCell = component.energy_device
gpu.setResolution(48,16)

local MIN_ENERGY_PERCENT = 10
local MAX_ENERGY_PERCENT = 90
local MAX_ITERATION = 10
local DELAY_ITERATION = 10
-- local MSG_ERROR = "ERROR"
local MSG_SHUTDOWN_POWER = "SHUTDOWN_POWER"
local MSG_ACTIVATE_POWER = "ACTIVATE_POWER"
local MSG_GET_STATUS = "GET_STATUS"
local MSG_POST_STATUS = "POST_STATUS"
local RELAY = "RELAY"
local C_BLACK, C_WHITE, C_OK, C_KO, C_INFO, C_INFO2 = 0x000000, 0xffffff, 0x22af4b, 0xee2524, 0x0f89ca, 0xf9df30
local resX, _ = gpu.getResolution()
local reactorActivated = true
local remoteComputers = {RELAY}
local remoteComputersInfos = {}

_component.init(remoteComputers, remoteComputersInfos, true)

local relayAddress = remoteComputersInfos[RELAY].address
local relayPort = remoteComputersInfos[RELAY].port

local listenModemMessage = function(...)
	local payload = {...}
	if _logic.case(relayPort, MSG_POST_STATUS) then
		reactorActivated = payload[1]
		_gpu.setAll(-12, 2,
			{
				{"Reactor = "},
				{reactorActivated, {"OK", C_OK}, {"KO", C_KO}}
			}, 12, C_WHITE, C_BLACK)
	end
end

local getStatusFailure = function()
	_gpu.set(1, 0, _text.alignCenter("Aucune réponse de l'ordinateur distant", resX), 0, C_KO)
end

local changeReactorStatus = function(type)
   _event.sendTimeout(relayAddress, relayPort, type, nil, nil, DELAY_ITERATION, MAX_ITERATION)
 end

_event.listenModemMessage(listenModemMessage)

_event.sendTimeout(relayAddress, relayPort, MSG_GET_STATUS, nil, getStatusFailure, DELAY_ITERATION, MAX_ITERATION)

-- _gpu.set(1, 0, _text.alignCenter(msgKO, resX), 0, C_KO)
-- _gpu.set(1, 0, _text.alignCenter("Tentative "..iteration.." échouée. Nouvelle tentative...", resX), 0, C_KO)
-- controlPower(SHUTDOWN_POWER, "Le réacteur n'a pas pu être arrêté")
-- controlPower(ACTIVATE_POWER, "Le réacteur n'a pas pu être démarré")

local lastTime = computer.uptime()
local lastEnergy = powerCell.getEnergyStored()

while not _component.isClosed() do
	local maxEnergy = powerCell.getMaxEnergyStored()
	local currentEnergy = powerCell.getEnergyStored()
	local energyPercent =_component.bargraphH(2, 4, -1, 3, currentEnergy , maxEnergy)
	local production = (currentEnergy - lastEnergy) / (computer.uptime() - lastTime - 0.05) / 20

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
		changeReactorStatus(MSG_SHUTDOWN_POWER)
	elseif energyPercent < MIN_ENERGY_PERCENT and not reactorActivated then
		changeReactorStatus(MSG_ACTIVATE_POWER)
	end
	_gpu.setAll(2, 2,
		{
			{"Percent = "},
			{string.format("%.2f", energyPercent).." %", C_INFO2}
		}, 18, C_WHITE, C_BLACK)
	os.sleep(1)
end
os.execute("refresh")