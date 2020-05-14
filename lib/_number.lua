local _number = {}

_number.reduceUnit = function(number, unit, precision)
  precision = precision or 2
  local unitLvl = 0
  local unitPrefixes = {"n", "µ", "m", "", "k", "M", "G"}
  if math.abs(number) > 1000 then
    while math.abs(number) > 1000 and unitLvl < 3 do
      number = number / 1000
      unitLvl = unitLvl + 1
    end
  elseif math.abs(number) < 1 then
    while math.abs(number) < 1 and unitLvl > -3 do
      number =  number * 1000
      unitLvl = unitLvl - 1
    end
  end
  local unitPrefix = unitPrefixes[unitLvl + 4]
  return string.format("%."..precision.."f "..unitPrefix..unit, number)
end

_number.shrink = function(number1, number2)
  local lowest = math.min(number1, number2)
  local highest = math.min(number1, number2)
  return lowest * (lowest - 1) / 2 + highest
end

return _number