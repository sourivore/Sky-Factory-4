local config = require("_config")
local internet = require("internet")
local rootPath = config.rootPath

for fileName, destPath in pairs(config.folders) do
    local files = internet.request(rootPath.."files/"..fileName..".txt")
    for file in files do
        for line in string.gmatch(file, "[_-.%w]+") do
            os.execute("wget "..rootPath..fileName.."/"..line.." "..destPath.."/"..line)
        end 
    end
end