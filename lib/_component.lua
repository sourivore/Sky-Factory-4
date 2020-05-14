local event = require("event")
local component = require("component")
local term = require("term")
local _gpu = require("_gpu")
local _text = require("_text")
local _event = require("_event")
local _table = require("_table")
local _computer = require("_computer")
local _modem = require("_modem")
local _number = require("_number")
local gpu = component.gpu
local modem = component.modem
local resX, resY = gpu.getResolution()

local INIT_PORT = 1

local _component = {}

local onTouch = function(state)
	return function(_, _, x, y)
		if x >= math.floor((resX-14)/2) + 1 and x <= math.floor((resX-14)/2) + 14 and y == resY- 2 then
			state.close = true
		end
	end
end

_component.init = function(remoteComputers, remoteComputersInfos)
	_event.removeListeners("modem_message")
	_event.removeListeners("touch")
	modem.close()
	term.clear()
	_modem.openPort(INIT_PORT)
	_computer.askAddress()
	event.listen("modem_message",
		function(_, _, from, port, _, type, ...)
			local payload = {...}
			local computerType = payload[1]
			local computerPort = payload[2]
			local selfComputerPort = _computer.getPort()
			local communicationPort = _number.shrink(computerPort, selfComputerPort)
			if port == INIT_PORT and type == "SEND_ADDRESS" and _table.contains(remoteComputers, computerType) then
				local remoteComputerInfo = {["address"] = from, ["port"] = communicationPort}
				remoteComputersInfos[computerType] = remoteComputerInfo
			elseif port == INIT_PORT and type == "ASK_ADDRESS" then
				_computer.sendAddress()
			end
		end
	)
	_computer.sendAddress()
end

_component.closeBtn = function(state)
	event.listen("touch", onTouch(state))
	_gpu.fillColor(math.floor((resX-14)/2) + 1, -2, 14, 1, 0x1ba39c)
	_gpu.set(math.floor((resX-14)/2) + 1, -2, _text.alignCenter("FERMER", 14), nil, 0xffffff, 0x1ba39c)
end

_component.bargraphH = function(x, y, width, height, current, maximum)
	local newWidth = width
	if width <= 0 then
        newWidth = resX + width - x + 1
    end
    local energyPercent = 100 * current / maximum
	_gpu.fillColor(x, y, newWidth, height, 0xffffff)
	if energyPercent > 0 then
		local green, blue = math.floor(255 * energyPercent / 100), 0
		local red = 255 - green
		local barColor = _gpu.rgbToHex(red, green, blue)
		local pixelCovered = newWidth * energyPercent / 100
		_gpu.fillColor(x,y, math.ceil(pixelCovered), height, barColor)
	end
	return energyPercent
end

return _component