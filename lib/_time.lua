local _time = {}

_time.secondsToTime = function(seconds, precision)
	local precision = precision or 1
	local nbJ = math.floor(seconds / 60 / 60 / 24)
  	seconds = seconds - nbJ * 60 * 60 * 24
  	local nbH = math.floor(seconds / 60 / 60)
  	seconds = seconds - nbH * 60 * 60
  	local nbMin = math.floor(seconds / 60)
  	seconds = seconds - nbMin * 60
  	local nbS = math.floor(seconds)
  	seconds = seconds - nbS
  	local nbMs = math.floor(1000 * seconds)
	seconds = seconds - nbMs / 1000
  	local nbMus = math.floor(1000 * 1000 * seconds)

  	local txtJ, txtH, txtMin, txtS, txtMs, txtMus

  	local txtTime = {}

  	if nbJ > 0 then table.insert(txtTime, nbJ.."j") end
  	if nbH > 0 and precision >= -2 then table.insert(txtTime, nbH.."h") end
  	if nbMin > 0 and precision >= -1 then table.insert(txtTime, nbMin.."min") end
  	if nbS > 0 and precision >= 0 then table.insert(txtTime, nbS.."s") end
  	if nbMs > 0 and precision >= 1 then table.insert(txtTime, nbMs.."ms") end
  	if nbMus > 0 and precision >= 2 then table.insert(txtTime, nbMus.."µs") end
	
	txtTime = {table.unpack(txtTime, 1, precision)}

  	return table.concat(txtTime, " ")
end

return _time