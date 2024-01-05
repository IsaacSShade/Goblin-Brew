local inputService = game:GetService("UserInputService")

------ CONSTANTS ------
Z_OFFSET = -139.3
-----------------------

local player = game.Players.LocalPlayer
local character = game.Workspace:WaitForChild(player.Name)
local mouse = player:GetMouse()
local destructionMode = false
mouse.TargetFilter = game.Workspace.Bedrock.mouseFilter



--Input: The two tables to use so you can reference them later on
--Output: The hitbox of the punch tool creates a white outline on anything punchable
local function Highlight_Hits(partsHighlighted, partsNotFound)
	
	while destructionMode == true do
		wait()
		partsNotFound = table.clone(partsHighlighted)

		for i,part in game.Workspace:GetPartBoundsInBox(player.Character:GetBoundingBox()) do
			if part.Parent:IsA("Model") then 
				part = part.Parent
			end

			if part:IsDescendantOf(game.Workspace.Buildings) then
				if part:FindFirstChild("DestructionHighlight") then
					--If the part is still within bounds it won't be deleted at the end of this while loop run-through
					local index = table.find(partsHighlighted, part)

					if index then
						table.remove(partsNotFound, index)
					end
					break
				else
					--If this model is something punchable (has Health) then add it to the highlights
					if not part:FindFirstChild("Destroying") then
						local highlight = Instance.new("Highlight")
						highlight.Name = "DestructionHighlight"
						highlight.Parent = part
						highlight.FillTransparency = 1
						highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
						highlight.DepthMode = Enum.HighlightDepthMode.Occluded
						table.insert(partsHighlighted, part)
					end
					
					break
				end
			end
		end

		for i,part in partsNotFound do
			local highlight = part:FindFirstChild("DestructionHighlight")
			
			if highlight then
				highlight:Destroy()
			end
			table.remove(partsHighlighted, table.find(partsHighlighted, part))
		end
	end

	for i,part in partsHighlighted do
		local highlight = part:FindFirstChild("DestructionHighlight")

		if highlight then
			highlight:Destroy()
		end
	end
end

--Input: Any input provided by the user
--Output: Fires server events depending on what key is pressed
local function On_Input(input)
	if (inputService:GetFocusedTextBox()) then
		return
	end
	
	if input.KeyCode == Enum.KeyCode.F then
		--Dropping items
		for i,item in character:FindFirstChild("PickUpFolder"):GetChildren() do
			if item:IsA("Model") and i == #character:FindFirstChild("PickUpFolder"):GetChildren() then
				game.ReplicatedStorage.RemoteEvents.drop:FireServer(item, character)
				return
			end
		end
	elseif input.KeyCode == Enum.KeyCode.V then
		--Planting items
		for i,item in character:FindFirstChild("PickUpFolder"):GetChildren() do
			if item:IsA("Model") and i == #character:FindFirstChild("PickUpFolder"):GetChildren() then
				if game.ReplicatedStorage.Potions:FindFirstChild(item.Name) then
					return
				end
				
				game.ReplicatedStorage.RemoteEvents.plant:FireServer(item)
				return
			end
		end
	elseif input.KeyCode == Enum.KeyCode.B then
		--Opening/ build menu
		local gui = player.PlayerGui:FindFirstChild("BuildMenu")
		
		if gui.Enabled == true then
			gui.Enabled = false
		else
			gui.Enabled = true
		end
	elseif input.KeyCode == Enum.KeyCode.R then
		--Rotating a building
		for i,model in game.Workspace.Blueprints:GetChildren() do
			if model:IsA("Model") then
				if string.find(model.Name, "GHOST" .. player.Name) then
					local nextBuilding = nil
					local orientation = player:FindFirstChild("RotationSelected")
					
					if orientation.Value == 4 then
						orientation.Value = 1
					else
						orientation.Value += 1
					end
					
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
					
					if nextBuilding then
						game.ReplicatedStorage.RemoteEvents.createGhost:FireServer(nextBuilding, true)
					end
					
				end
			end
		end
	elseif input.KeyCode == Enum.KeyCode.X then
		--Toggles ability to destroy buildings
		print("pressed")
		if destructionMode then
			
			destructionMode = false
		else
			destructionMode = true
			
			local partsHighlighted = {}
			local partsNotFound = {}

			Highlight_Hits(partsHighlighted, partsNotFound)
		end
	end
	
end

--Input: N/A
--Output: User's mouse's position but modified to the snap grid.
local function Get_Mouse_Position()
	local mousePosition = mouse.Hit.Position
	return Vector3.new(26, math.round(mousePosition.Y) + 0.5, math.round(mousePosition.Z))
end

--Input: N/A
--Output: Build's a building at player's mouse position if there's a blueprint in the workspace
local function Build_Click()
	for i,model in game.Workspace.Blueprints:GetChildren() do
		if model:IsA("Model") then
			if string.find(model.Name, "GHOST" .. player.Name) then
				game.ReplicatedStorage.RemoteEvents.build:FireServer(model)
			end
		end
	end
		
end

--Input: N/A
--Output: Checks if there's a building to destroy and if so then sends a command to the server to delete it
local function Destroy_Click()
	if destructionMode then
		for i, part in game.Workspace:GetPartBoundsInBox(player.Character:GetBoundingBox()) do
			if part.Parent:IsA("Model") then
				part = part.Parent
			end
			
			local highlight = part:FindFirstChild("DestructionHighlight")
			if highlight and not part:FindFirstChild("Destroying") then

				highlight:Destroy()
				game.ReplicatedStorage.RemoteEvents.delete:FireServer(part)
			end
		end
	end
end

inputService.InputBegan:Connect(On_Input)
mouse.Button1Down:Connect(Build_Click)
mouse.Button1Down:Connect(Destroy_Click)

function game.ReplicatedStorage.RemoteFunctions.GetMousePosition.OnClientInvoke()
	return Get_Mouse_Position()
end