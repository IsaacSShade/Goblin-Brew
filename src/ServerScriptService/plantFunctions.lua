local plantFunctions = {}

--Input: model of the thing to harvest
--Output: Destroys the model, might eventually add animations
function plantFunctions.No_Harvest(model)
	model:Destroy()
end

--Input: model of the thing to harvest, and the name of the item to spawn
--Output: Destroys the model, might eventually add animations. Spawns in an item above it to pick up
function plantFunctions.Harvest(model, harvestName, quantity)
	local item = game.ReplicatedStorage.Plants:FindFirstChild(harvestName)
	
	if not item then
		warn("ERROR: No item with that name in game.ReplicatedStorage.Plants!")
	end
	
	for i = 1, quantity, 1 do
		local harvest = item:Clone()
		harvest:PivotTo(model:GetPivot() + Vector3.new(0, (2 * i), 0))
		harvest.Parent = game.Workspace
	end
	
	model:Destroy()
end

--Input: Model it's being called from, and the type of plant
--Output: Replaces the model with another model in it's next stage of growth
function plantFunctions.Change_Growth(model, harvestName)
	local plantFolder = game.ReplicatedStorage.Plants.Plantables:FindFirstChild(harvestName)
	local plantNumber = "ERROR"
	local nextPlant = nil
	
	
	print(plantFolder.Name)
	if not plantFolder then
		warn("ERROR: No folder with that name in game.ReplicatedStorage.Plants.Plantables")
	end
	
	if string.find(model.Name, "1") ~= nil then
		plantNumber = "2"
	elseif string.find(model.Name, "2") ~= nil then
		plantNumber = "Grown"
	end
	
	for i,plant in plantFolder:GetChildren() do
		print(plant.Name)
		if string.find(plant.Name, plantNumber) then
			local clone = plant:Clone()
			clone:PivotTo(model:GetPivot())
			
			clone.Parent = game.Workspace
			model:Destroy()
		end
	end
end

--Input: Model of item being consumed to plant
--Output: Plants that item at the terrain underneath the player
function plantFunctions.Plant(model)
	local player = model.Parent.Parent
	local rootPart = player:FindFirstChild("HumanoidRootPart")
	local plantables = game.ReplicatedStorage.Plants.Plantables
	local searchName = nil
	local groundPart = nil
	
	local partsInBound = game.Workspace:GetPartBoundsInBox(CFrame.new(rootPart.Position - Vector3.new(0, 3, 0)), Vector3.new(20, 1, 1))
	for i,part in partsInBound do
		print(part.Name)
		if part.Name == "Ground" then
			if searchName ~= nil then
				return
			end
			
			searchName = model.Name .. " 1"
			groundPart = part
		end
		
		if plantables:FindFirstChild(part.Name, true) then
			return
		elseif part.Parent:IsA("Model") then
			if plantables:FindFirstChild(part.Parent.Name, true) then
				return
			end
		end
	end
	
	if searchName == nil then
		return
	end
	
	local newPlant = plantables:FindFirstChild(searchName, true):Clone()
	newPlant:PivotTo(CFrame.new(groundPart.Position))
	newPlant.Parent = game.Workspace
	
	model:Destroy()
end


return plantFunctions
