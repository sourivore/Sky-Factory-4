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

_table.remove = function(tableValues, value)
	for index, tableValue in pairs(tableValues) do
		if equals(tableValue, value) then
			table.remove(tableValues, index)
		end
	end
end

return _table