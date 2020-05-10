local packages = require("package")
local f = assert (io.popen ("ls /usr/lib"))

for line in f:lines() do
    packages.loaded[string.gsub(line, ".lua", "")] = nil
	print("Uncached "..line)
end
   
f:close()