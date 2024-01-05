local plantFunctions = require(game.ServerScriptService.plantFunctions)
local model = script.Parent.Parent
local HP = script.Parent

HP.Changed:Connect(function()
	if HP.Value <= 0 then
		plantFunctions.No_Harvest(model)
	end
end)