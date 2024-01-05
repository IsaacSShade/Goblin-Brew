local corridorFunctions = require(game.ServerScriptService.corridorFunctions)

script.Parent.Touched:Connect(function(object)
	corridorFunctions.On_Touch(object)
end)