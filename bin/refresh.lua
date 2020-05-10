local component = require("component")
local term = require("term")
local _event = require("_event")
local gpu = component.gpu

_event.removeListeners("modem_message")
_event.removeListeners("touch")
gpu.setBackground(0x000000)
gpu.setForeground(0xffffff)
gpu.setResolution(gpu.maxResolution())
term.clear()