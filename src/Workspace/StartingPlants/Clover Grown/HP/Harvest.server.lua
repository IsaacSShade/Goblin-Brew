local plantFunctions = require(game.ServerScriptService.plantFunctions)
local model = script.Parent.Parent
local HP = script.Parent

HP.Changed:Connect(function()
	if HP.Value <= 0 then
		plantFunctions.Harvest(model, "Clover", 2)
	end
end)