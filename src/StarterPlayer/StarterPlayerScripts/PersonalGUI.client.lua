local player = game.Players.LocalPlayer
local buildingMaxDisplay = player.PlayerGui:WaitForChild("BuildMenu").maxBuildings
local buildingFolder = game.Workspace.Buildings
local buildingMax =  buildingFolder.maxBuildings


--Input: TextGUI to use as the display
--Output: Changes the text to reflect the number of buildings versus the maximum
function Update_Current_Count(textGUI)
	textGUI.Text = #buildingFolder:GetChildren() - 1 .. "/" .. buildingMax.Value
end


Update_Current_Count(buildingMaxDisplay)

buildingFolder.ChildAdded:Connect(function()
	Update_Current_Count(buildingMaxDisplay)
end)
buildingFolder.ChildRemoved:Connect(function()
	Update_Current_Count(buildingMaxDisplay)
end)
buildingMax.Changed:Connect(function()
	Update_Current_Count(buildingMaxDisplay)
end)