local component = require("component")
local modem = component.modem

local _modem = {}

local openPort = function(port)
    if not modem.isOpen(port) then
        modem.open(port)
    end
end

local closePort = function(port)
    if modem.isOpen(port) then
        modem.close(port)
    end
end

_modem.openPort = openPort

_modem.closePort = closePort

_modem.openPorts = function(ports)
    for _, port in pairs(ports) do
        openPort(port)
    end
end

_modem.closePorts = function(ports)
    for _, port in pairs(ports) do
        closePort(port)
    end
end

return _modem