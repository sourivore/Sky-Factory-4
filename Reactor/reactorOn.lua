local component = require("component")
local reactor = component.nc_fission_reactor

if not reactor.isProcessing() then
	print("Démarrage du réacteur")
	reactor.activate()
else
    print("Le réacteur est déjà démarré")
end