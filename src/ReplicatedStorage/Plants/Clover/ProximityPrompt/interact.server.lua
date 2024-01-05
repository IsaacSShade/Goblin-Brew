local model = script.Parent.Parent
local interactableFunctions = require(game.ServerScriptService.interactableFunctions)

script.Parent.Triggered:Connect(function(player)
	local character = game.Workspace:FindFirstChild(player.Name)
	interactableFunctions.Pick_Up(model, character)
end)