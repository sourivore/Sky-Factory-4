local _text = {}

_text.alignLeft = function(text, size)
	while #text < size do
		text = text.." "
	end
	return text
end

_text.alignCenter = function(text, size)
	local insertAfter = true
	while #text < size do
		if insertAfter then
			text = text.." "
		else
			text = " "..text
		end
		insertAfter = not insertAfter
	end
	return text
end

_text.alignRight = function(text, size)
	while #text < size do
		text = " "..text
	end
	return text
end

return _text