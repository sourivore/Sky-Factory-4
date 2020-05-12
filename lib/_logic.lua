local _table = require("_table")

local _logic = {}

local test

_logic.switch = function(...)
	test = {...}
end

_logic.case = function(...)
	return _table.equals(test, {...})
end

_logic.caseCheck = function(testFunction, ...)
	return _table.check(testFunction, test, {...})
end

_logic.caseFilter = function(filterFunction, ...)
	return _table.filter(filterFunction, test, {...})
end

return _logic