local config = require("_config")
local internet = require("internet")
local rootPath = config.rootPath

for fileName, destPath in pairs(config.folders) do
    local files = internet.request(rootPath..fileName..".txt")
    for file in files do
        print("LINE", file)
    end
end