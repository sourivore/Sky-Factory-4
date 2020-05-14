
local component = require("component")
local _config = require("_config")
local modem = component.modem

local _computer = {}

local INIT_PORT = 1

local getComputerType = function()
    return _config.computerType
end

local getPort = function()
    return _config.port
end

_computer.getComputerType = getComputerType

_computer.getPort = getPort

_computer.askAddress = function()
    modem.broadcast(INIT_PORT, "ASK_ADDRESS")
end

_computer.sendAddress = function()
    modem.broadcast(INIT_PORT, "SEND_ADDRESS", getComputerType(), getPort())
end

return _computer