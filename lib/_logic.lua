local _table = require("_table")

local _logic = {}

local test

_logic.switch = function(...)
  test = {...}
end

_logic.case = function(...)
  return _table.equals(test, {...})
end

return _logic