local buildFunctions = {}

local corridorFunctions = require(game.ServerScriptService.corridorFunctions)

--Input: Building that creates potions
--Output: Puts the correct potion where it's supposed to be
function buildFunctions.Create_Potion(building)
	local particles = building:FindFirstChild("Cauldron").Attachment.ParticleEmitter

	building.Cauldron.BubblingSound.Playing = true
	building.Cauldron.BubblingSound.Volume = 0.3

	for i = 0 , 15, 1 do
		particles.Rate += 2
		building.Cauldron.BubblingSound.Volume += 0.05
		building.Proximity.ProximityPrompt.Enabled = false
		wait(1)
	end

	for i,item in building.Reagents:GetChildren() do
		item:Destroy()
	end

	building.Cauldron.PotionSound.Playing = true
	local potion = game.ReplicatedStorage.Potions:FindFirstChild(building.Potion.Value):Clone()
	potion.Parent = game.Workspace
	potion.PrimaryPart.CFrame = CFrame.new(building:FindFirstChild("Light").Position - Vector3.new(0, 1, 0))


	particles.Rate = 0
	building.Proximity.ProximityPrompt.Enabled = true
	building.Cauldron.BubblingSound.Playing = false
end

--Input: Item to find the corresponding color of
--Output: Color for that item
function buildFunctions.Find_Color(item)
	if item.Name == "Clover" then
		return Color3.fromRGB(75/2, 151/2, 75/2)
	elseif item.Name == "Nut" then
		return Color3.fromRGB(121/2, 86/2, 46/2)
	elseif item.Name == "Mushroom" then
		return Color3.fromRGB(196/2, 40/2, 28/2)
	end
end

--Input: A string with both reagents' names
--Output: The name of the potion it will create
function buildFunctions.Get_Potion_Name(reagents)
	
	local function countSubstring(text, keyword)
		local count = 0

		for _ in text:gmatch(keyword) do
			count += 1
		end

		return count
	end

	print(reagents)
	if countSubstring(reagents, "Clover") == 2 then
		return "Clear Cleaning"
	elseif countSubstring(reagents, "Nut") == 2 then
		return "Sky High Solidify"
	elseif countSubstring(reagents, "Mushroom") == 2 then
		return "Cup of Chaos"
	elseif string.find(reagents, "Clover") and string.find(reagents, "Nut") then
		return "Meditative Molecules"
	elseif string.find(reagents, "Clover") and string.find(reagents, "Mushroom") then
		return "Mana Mania"
	elseif string.find(reagents, "Nut") and string.find(reagents, "Mushroom") then
		return "Floaty Froth"
	else
		warn("ERROR: No string found")
	end
end

--Input: The player that's triggering the event, and the building to place
--Output: Moves a ghost building to the player's mouse
function buildFunctions.Move_Ghost_Building(player, building)
	
	local lastValid = true
	local valid = true
	
	local success, response = pcall(function()
		while not building:FindFirstChild("CLICKED") do
			valid = true
			
			if game.Workspace.Blueprints:FindFirstChild(building.Name) ~= building then
				for i,model in game.Workspace.Blueprints:GetChildren() do
					
					if model:IsA("Model") then
						if string.find(model.Name, ("GHOST" .. player.Name)) then
							building = model
						end
					end
				end
			end
			
			--Finding if there's any parts that intersect
			local frame, scale = building:GetBoundingBox()
			scale -= Vector3.new(0.1, 0.1, 0.1)
			for i,part in game.Workspace:GetPartBoundsInBox(frame, scale) do
				if part:IsDescendantOf(building) == false and part.Name ~= "Barrier" then
					valid = false
				end
			end
			
			--Change colors if the valid status has changed
			if lastValid ~= valid then
				buildFunctions.Change_Ghost_Color(building, valid)
			end
			
			building:PivotTo(CFrame.new(game.ReplicatedStorage.RemoteFunctions.GetMousePosition:InvokeClient(player)))
			game:GetService("RunService").Heartbeat:Wait()
			lastValid = valid
		end
	end)
	
	if not success then
		--User has either left the game or the building is deleted
		if building then
			building:Destroy()
		end
		
		warn(response)
		return
	end
	
	--Ghost building is sitting there and user has just clicked
	--TODO: Play a buzzer soudn to inform player that placement is invalid
	if valid then
		buildFunctions.Build(string.sub(building.Name, 1, string.find(building.Name, " GHOST") - 1), building.PrimaryPart.Position)
	end
	
	building:Destroy()
end

--Input: The building ghost to change colors of, and a boolean on whether it's a valid placement or not
--Output: Changes the entire building's colors to be blue or red
function buildFunctions.Change_Ghost_Color(building, valid)
	for i,child in pairs (building:GetDescendants()) do
		
		if string.find(child.Name, "Elavator") then
			child:Destroy()
			continue
		end
		
		local proximityPrompt = child:FindFirstChild("ProximityPrompt")
		if proximityPrompt then
			proximityPrompt.Enabled = false
		end
		
		if child:IsA("MeshPart") then
			if valid then
				child.TextureID = "rbxassetid://12044968766"
			else
				child.TextureID = "rbxassetid://12044968190"
			end

			child.Transparency = 0.2
		end

		if child:IsA("Part") then
			child.CanCollide = false
			
			if valid then
				child.Color = Color3.fromRGB(34, 80, 78)
			else
				child.Color = Color3.fromRGB(255, 25, 17)
			end
			
			if child.Transparency ~= 1 then
				child.Transparency = 0.2
			end
		end
	end
end

--Input: The player calling the function, the building name, and a true/false on if there's an old building somewhere (true if only changing orientation)
--Output: Creates a ghost of a building and removes any old ghosts
function buildFunctions.Create_Ghost_Building(player, buildingName, oldBuilding)
	--If the current maximum buildings has been reached don't make a ghost
	if #game.Workspace.Buildings:GetChildren() - 1 >= game.Workspace.Buildings.maxBuildings.Value then
		return
	end
	
	print(buildingName)
	local building = game.ReplicatedStorage.Buildings:FindFirstChild(buildingName):Clone()
	buildFunctions.Change_Ghost_Color(building, true)
	building.Name = building.Name .. " GHOST".. player.Name
	
	--If the player clicked on a new building to build, remove the ghost of the previous building
	for i,model in game.Workspace.Blueprints:GetChildren() do
		if model:IsA("Model") then
			if string.find(model.Name, "GHOST" .. player.Name) then
				model:Destroy()
			end
		end
	end
	
	building.Parent = game.Workspace.Blueprints
	
	if not oldBuilding then
		buildFunctions.Move_Ghost_Building(player, building)
	end
	
end

--Input: The name of the building to build, and the position to place it (Primary Part location)
--Output: Places a builing if not over the capacity
function buildFunctions.Build(buildingName, position)
	if #game.Workspace.Buildings:GetChildren() > game.Workspace.Buildings.maxBuildings.Value  then
		return
	end
	
	--TODO: A buzzing noise that informs the player the building limit has been reached
	print("build name is", ("!" .. buildingName .. "!"))
	local building = game.ReplicatedStorage.Buildings:FindFirstChild(buildingName):Clone()
	
	building:PivotTo(CFrame.new(position))
	building.Parent = game.Workspace.Buildings
end

--Input: The name of the building to build
--Output: Triggers the Move_Ghost_Building function to stop looping and place a building down
function buildFunctions.Trigger_Build(building)
	local stopIndicator = Instance.new("Weld")
	stopIndicator.Name = "CLICKED"
	stopIndicator.Parent = building
end

function buildFunctions.Delete_Build(player, building)
	local highlight = Instance.new("Highlight")
	highlight.Name = "Destroying"
	highlight.Parent = building
	highlight.FillTransparency = 1
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	
	local elevator = building:FindFirstChild("Elevator")
	if elevator then
		elevator.CanTouch = false
		wait(0.1)
		elevator:Destroy()
	end
	
	for i = 0, 10, 1 do
		highlight.OutlineColor = Color3.fromRGB(229, 165, 15)
		wait(0.1)
		highlight.OutlineColor = Color3.fromRGB(230, 230, 33)
		wait(0.1)
	end
	
	corridorFunctions.On_End_Touch(player.Character)
	
	for i,part in game.Workspace:GetPartBoundsInBox(building:GetBoundingBox()) do
	
		if part.Parent:IsA("Model") then
			part = part.Parent
		end
		
		if game.Players:FindFirstChild(part.Name) then
			corridorFunctions.On_End_Touch(part)
		end
	end
	
	building:Destroy()
end



return buildFunctions
