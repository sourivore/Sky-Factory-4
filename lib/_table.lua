local _table = {}

_table.equals = function(table1, table2)
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

return _table