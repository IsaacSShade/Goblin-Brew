local building = script.Parent.Parent.Parent
local interactableFunctions = require(game.ServerScriptService.interactableFunctions)

script.Parent.Triggered:Connect(function(player)
	local character = game.Workspace:FindFirstChild(player.Name)
	interactableFunctions.Insert(character, building)
end)
