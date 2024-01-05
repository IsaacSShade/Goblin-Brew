local interactableFunctions = require(game.ServerScriptService.interactableFunctions)

script.Parent.Touched:Connect(function(touchPart)
	print("TOUCHED | ", touchPart.Name)
	interactableFunctions.Catch_Potion(touchPart)
end)
