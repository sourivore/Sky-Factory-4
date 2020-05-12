local _array = require("_array")

local _logic = {}

local test

_logic.switch = function(...)
  test = {...}
end

_logic.case = function(...)
  return _array.equals(test, {...})
end

return _logic