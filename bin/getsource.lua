local config = require("_config")
local rootPath = config.rootPath

for id, folder in pairs(config.folders) do
    local handle = internet.request(rootPath..id)
    for line in handle do
        print("LINE", line)
    end
end