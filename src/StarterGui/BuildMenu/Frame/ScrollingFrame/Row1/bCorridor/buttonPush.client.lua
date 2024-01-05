local button = script.Parent
local baseModel = button.ViewportFrame:GetChildren()[1]
local player = game.Players.LocalPlayer

local function Get_Orientation_Name(model)
	local nextBuilding = nil
	local orientation = player:FindFirstChild("RotationSelected")

	if string.find(model.Name, "I Corridor") then
		if orientation.Value == 1 or orientation.Value == 3 then
			nextBuilding = "I Corridor - V1"
		else
			nextBuilding = "I Corridor - V2"
		end
	elseif string.find(model.Name, "V Corridor") then
		if orientation.Value == 1 then
			nextBuilding = "V Corridor - V1"
		elseif orientation.Value == 2 then
			nextBuilding = "V Corridor - V2"
		elseif orientation.Value == 3 then
			nextBuilding = "V Corridor - V3"
		else
			nextBuilding = "V Corridor - V4"
		end
	elseif string.find(model.Name, "T Corridor") then
		if orientation.Value == 1 then
			nextBuilding = "T Corridor - V1"
		elseif orientation.Value == 2 then
			nextBuilding = "T Corridor - V2"
		elseif orientation.Value == 3 then
			nextBuilding = "T Corridor - V3"
		else
			nextBuilding = "T Corridor - V4"
		end
	end
	
	return nextBuilding
end

button.Activated:Connect(function()
	local modelName = Get_Orientation_Name(baseModel)
	if modelName ~= nil then
		game.ReplicatedStorage.RemoteEvents.createGhost:FireServer(modelName, false)
	else
		game.ReplicatedStorage.RemoteEvents.createGhost:FireServer(baseModel.Name, false)
	end
	
end)
