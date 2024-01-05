local corridorFunctions = require(game.ServerScriptService.corridorFunctions)

game:GetService("PhysicsService"):RegisterCollisionGroup("Characters")
game:GetService("PhysicsService"):CollisionGroupSetCollidable("Characters", "Characters", false)

local function Remove_Collisions(player)
	for _, part in player.Character:GetDescendants() do
		if part:IsA("MeshPart") or part:IsA("BasePart") then
			part.CollisionGroup = "Characters"
		end
	end
end

local function On_Join(player)
	print("remote event fire recieved")
	local rootPart = player.Character:WaitForChild("HumanoidRootPart")
	local startingPlants = game.Workspace:FindFirstChild("StartingPlants")
	
	Remove_Collisions(player)
	
	if startingPlants then
		if startingPlants.AlreadyMoved.Value == false then
			startingPlants.AlreadyMoved.Value = true
			startingPlants.Parent = game.ReplicatedStorage
			startingPlants.Parent = game.Workspace
		end
	end
	
	local vectorForce = Instance.new("VectorForce")
	vectorForce.Parent = rootPart.RootRigAttachment
	vectorForce.Name = "CorridorPush"
	vectorForce.Attachment0 = rootPart.RootRigAttachment
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	
	local gravityChange = Instance.new("BoolValue")
	gravityChange.Parent = rootPart.RootRigAttachment
	gravityChange.Name = "GravityChange"
	gravityChange.Value = false
	
	local normalizing = Instance.new("BoolValue")
	normalizing.Parent = rootPart.RootRigAttachment
	normalizing.Name = "Normalizing"
	normalizing.Value = false
	
	local pickUpFolder = Instance.new("Folder")
	pickUpFolder.Parent = player.Character
	pickUpFolder.Name = "PickUpFolder"
	
	local pickUp = Instance.new("IntValue")
	pickUp.Parent = pickUpFolder
	pickUp.Name = "PickUp"
	pickUp.Value = 4
	
	local team = Instance.new("StringValue")
	team.Parent = player.Character
	team.Name = "Team"
	team.Value = "team1"
	
	player.Character.Humanoid.JumpPower = 25

	
end

game.ReplicatedStorage.RemoteEvents.playerJoin.OnServerEvent:Connect(On_Join)