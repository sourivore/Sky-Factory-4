local _table = {}

local equals = function(table1, table2)
	if #table1 ~= #table2 then
		return false
	end
	for key1, value1 in pairs(table1) do
		if value1 ~= table2[key1] then
		return false
		end
	end
	return true
end

local reduce = function(reduceFunction, tableFull)
	local result = {}
	for _, value in pairs(tableFull) do
		table.insert(result, reduceFunction(value))
	end
	return result
end

_table.equals = equals

_table.check = function(checkFunction, tableTest, tableCheck)
	return checkFunction(tableTest, tableCheck)
end

_table.filter = function(filterFunction, tableTest, tablesCheck)
	local result = {}
	for _, tableCheck in pairs(tablesCheck) do
		if filterFunction(tableTest, tableCheck) then
			table.insert(result, tableCheck)
		end
	end
	return result
end

_table.reduce = reduce

_table.reduceProp = function(prop, tableFull)
	local reduceFunction = function(element)
		return element[prop]
	end
	return reduce(reduceFunction, tableFull)
end


_table.remove = function(tableValues, value)
	for index, tableValue in pairs(tableValues) do
		if tableValue == value or equals(tableValue, value) then
			table.remove(tableValues, index)
		end
	end
end

_table.contains = function(tableValues, value)
	for _, tableValue in pairs(tableValues) do
		if tableValue == value or equals(tableValue, value) then
			return true
		end
	end
	return false
end

_table.length = function (t)
    local count = 0
    for _, _ in pairs(t) do
        count = count + 1
    end
    return count
end

return _table