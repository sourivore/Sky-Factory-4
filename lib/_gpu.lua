local component = require("component")
local gpu = component.gpu
local _gpu = {}

local charToHex = function(char)
	local result = ""
	if char == 10 then
		result = "A"
	elseif char == 11 then
		result = "B"
	elseif char == 12 then
		result = "C"
	elseif char == 13 then
		result = "D"
	elseif char == 14 then
		result = "E"
	elseif char == 15 then
		result = "F"
	else result = char
	end
	return result
end

local numberToHex = function(number)
	local firstCharNum = math.floor(number / 16)
	local secondCharNum = number - 16*firstCharNum 
	local firstChar = charToHex(firstCharNum)
	local secondChar = charToHex(secondCharNum)
	return firstChar..secondChar
end

local fill = function(x, y, width, height, char, bg, fg)
	local resX, resY = gpu.getResolution()
	local newX, newY, newWidth, newHeight = x, y, width, height
	if x <= 0 then
		newX = resX + x
	end
	if y <= 0 then
		newY = resY + y
	end
	if width <= 0 then
		newWidth = resX + width - x + 1
	end
	if height <= 0 then
		newHeight = resY + height - y + 1
	end
	if fg then
		gpu.setForeground(fg)
	end
	if bg then
		gpu.setBackground(bg)
    end
	gpu.fill(newX, newY, newWidth, newHeight, char)
end

local fillColor = function(x,y, width, height, bg)
	fill(x, y, width, height, " ", bg)
end

_gpu.rgbToHex = function(red, green, blue)
	return tonumber(numberToHex(red)..numberToHex(green)..numberToHex(blue), 16)
end

_gpu.fill = fill

_gpu.fillColor = function(x,y, width, height, bg)
	fillColor(x, y, width, height, bg)
end

_gpu.set = function(x, y, text, size, fg, bg)
	local fg = fg or 0xffffff
	local bg = bg or 0x000000
	local resX, resY = gpu.getResolution()
	local newX, newY = x, y
	if x <= 0 then
		newX = resX + x
	end
	if y <= 0 then
		newY = resY + y
	end
	if fg then
		gpu.setForeground(fg)
	end
	if bg then
		gpu.setBackground(bg)
    end
	if size then
		_gpu.fillColor(newX, newY, size, 1, bg)
    end
	gpu.set(newX, newY, tostring(text))
end

_gpu.setIf = function(condition, x, y, txtTrue, txtFalse, size, fg, bg)
	if fg then
		gpu.setForeground(fg)
	end
	if bg then
		gpu.setBackground(bg)
    end
	local txt
	if condition then
		txt = txtTrue
	else
		txt = txtFalse
	end
	_gpu.set(x, y, txt[1], size, txt[2], txt[3])
end

_gpu.setAll = function(x, y, texts, size, fg, bg)
	if fg then
		gpu.setForeground(fg)
	end
	if bg then
		gpu.setBackground(bg)
    end
	local currentX = x
	local currentSize = size
	for index, text in pairs(texts) do
		if type(text[1]) == "boolean" then
			if text[1] then
				text = text[2]
			else
				text = text[3]
			end
		end
		_gpu.set(currentX, y, text[1], currentSize, text[2], text[3])
		currentX = currentX + #text[1]
		currentSize = currentSize - #text[1]
	end
end

_gpu.draw = function (x, y, colors, pattern)
	for posY, line in pairs(pattern) do
		for posX, pixel in pairs(line) do
			if pixel > 0 then
				fillColor(x + posX - 1, y + posY - 1, 1, 1, colors[pixel])
			end
		end
	end
end

return _gpu