local component = require("component")
local reactor = component.nc_fission_reactor

if reactor.isProcessing() then
	print("Arrêt du réacteur")
	reactor.deactivate()
else
    print("Le réacteur est déjà arrêté")
end