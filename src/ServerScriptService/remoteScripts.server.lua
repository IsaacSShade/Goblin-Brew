local interactableFunctions = require(game.ServerScriptService.interactableFunctions)
local plantFunctions = require(game.ServerScriptService.plantFunctions)
local buildFunctions = require(game.ServerScriptService.buildFunctions)

game.ReplicatedStorage.RemoteEvents.drop.OnServerEvent:Connect(function(player, model, character)
	interactableFunctions.Drop(model, character)
end)

game.ReplicatedStorage.RemoteEvents.plant.OnServerEvent:Connect(function(player, model)
	plantFunctions.Plant(model)
end)

game.ReplicatedStorage.RemoteEvents.createGhost.OnServerEvent:Connect(function(player, buildingName, oldBuilding)
	buildFunctions.Create_Ghost_Building(player, buildingName, oldBuilding)
end)

game.ReplicatedStorage.RemoteEvents.build.OnServerEvent:Connect(function(player, buildingName)
	buildFunctions.Trigger_Build(buildingName)
end)

game.ReplicatedStorage.RemoteEvents.delete.OnServerEvent:Connect(function(player, building)
	buildFunctions.Delete_Build(player, building)
end)