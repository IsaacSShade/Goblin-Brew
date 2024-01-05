------ CONSTANTS ------
PLANT = "Nut"
-----------------------

local plantFunctions = require(game.ServerScriptService.plantFunctions)
local model = script.Parent.Parent
local growth = script.Parent


--Input: N/A
--Output: Counts down an int value every second
local function Countdown() 
	while growth.Value > 0 do
		wait(1)
		growth.Value -= 1
	end
	
	plantFunctions.Change_Growth(model, PLANT)
end

model.AncestryChanged:Connect(function()
	if model:IsDescendantOf(game.Workspace) then
		Countdown()
	end
end)