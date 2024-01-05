local buildFunctions = require(game.ServerScriptService.buildFunctions)
local corridorFunctions = require(game.ServerScriptService.corridorFunctions)
local tweenService = game:GetService("TweenService")

local interactableFunctions = {}

------ CONSTANTS ------
GRAVITY_MULTIPLIER = 2.2
-----------------------

--Input: Model to turn collisions on or off, and true to turn on, false to turn off
--Output: Changes all collisions in the model
function interactableFunctions.Change_All_Collisions(model, turnOn)
	for i,part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.CanCollide = turnOn
		end
	end
end

--Input: The model of the plant item and the player/NPC it's going to
--Output: Puts the plant on top of their head
function interactableFunctions.Pick_Up(model, player)
	print("picked up")
	local weld = Instance.new("WeldConstraint")
	local pickUpFolder = player:FindFirstChild("PickUpFolder")
	local head = player:FindFirstChild("Head")
	local capacity = pickUpFolder.PickUp
	local offset = 2
	
	local folderChildren = pickUpFolder:GetChildren()
	
	--If item being picked up is a potion
	if game.ReplicatedStorage.Potions:FindFirstChild(model.Name) then
		print(model.Name)
		if #folderChildren - 1 ~= 0 then
			return
		end
		
		for i,child in model.PrimaryPart:GetChildren() do
			if child:IsA("VectorForce") then
				child:Destroy()
			end
		end
		offset = 3
	end
	
	--If there's a potion in the inventory
	for _,item in folderChildren do
		if game.ReplicatedStorage.Potions:FindFirstChild(item.Name) then
			print(model.Name)
			if #folderChildren - 1 ~= 0 then
				return
			end
			offset = 3
		end
	end
	
	
	
	if #folderChildren - 1 > capacity.Value then
		return
	end
	
	weld.Name = "PickUpWeld"
	weld.Parent = model
	weld.Enabled = false
	
	weld.Part0 = model.PrimaryPart
	weld.Part1 = head
	-- Fixed the angles but also needs to be the CFrame a distance in the direction the head is facing upwards
	model.PrimaryPart:PivotTo(CFrame.new(head.Position + Vector3.new(0, head.Size.Y + (offset * (#pickUpFolder:GetChildren() - 1)), 0)) * CFrame.Angles(math.rad(head.Orientation.X),math.rad(head.Orientation.Y),math.rad(head.Orientation.Z)))
	model.Parent = pickUpFolder
	
	interactableFunctions.Change_All_Collisions(model, false)
		
	model:FindFirstChild("ProximityPrompt").Enabled = false
	weld.Enabled = true
	
end

--Input: The model to drop and the player's character in the workspace
--Output: Drops the item
function interactableFunctions.Drop(model, player)
	print("dropping")
	model:FindFirstChild("PickUpWeld"):Destroy()
	model.PrimaryPart:PivotTo(CFrame.new(player.HumanoidRootPart.Position))
	
	model.Parent = game.Workspace
	interactableFunctions.Change_All_Collisions(model, true)
	model:FindFirstChild("ProximityPrompt").Enabled = true
end

--Input: The player (in workspace) that triggered the event, and the potion maker
--Output: Inserts the item the player has
function interactableFunctions.Insert_Ingredient(character, building)
	local reagentFolder = building.Reagents
	local firstReagent = building:FindFirstChild("Reagent1")
	local secondReagent = building:FindFirstChild("Reagent2")
	local reagentFolderContents = reagentFolder:GetChildren()
	
	local function First_Reagent(reagent)
		reagent:FindFirstChild("PickUpWeld"):Destroy()
		reagent.PrimaryPart.Anchored = true
		wait()
		reagent.PrimaryPart.CFrame = CFrame.new(building:FindFirstChild("ReagentOnePosition").Position) * CFrame.Angles(0, 0, 0)
		reagent.Parent = reagentFolder
	end
	
	local function Second_Reagent(reagent)
		reagent:FindFirstChild("PickUpWeld"):Destroy()
		reagent.PrimaryPart.Anchored = true
		wait()
		reagent.PrimaryPart.CFrame = CFrame.new(building:FindFirstChild("ReagentTwoPosition").Position) * CFrame.Angles(0, 0, 0)
		reagent.Parent = reagentFolder
	end
	
	local reagent = nil

	for i,item in character:FindFirstChild("PickUpFolder"):GetChildren() do
		if item:IsA("Model") and i == #character:FindFirstChild("PickUpFolder"):GetChildren() and not game.ReplicatedStorage.Potions:FindFirstChild(item.Name) then
			reagent = item
			break
		end
	end
	
	if reagent == nil then
		return
	end
	
	if #reagentFolderContents == 0 then
		-- Adding first ingredient
		if firstReagent.Value == "" then
			firstReagent.Value = reagent.Name
			building:FindFirstChild("ReagentColorOne").Color = buildFunctions.Find_Color(reagent)
		end
		
		if firstReagent.Value == reagent.Name then
			First_Reagent(reagent)
		elseif secondReagent.Value == reagent.Name then
			Second_Reagent(reagent)
		else
			return
		end
		
	elseif #reagentFolderContents == 1 then
		-- Adding second ingredient
		if secondReagent.Value == "" then
			secondReagent.Value = reagent.Name
			building:FindFirstChild("ReagentColorTwo").Color = buildFunctions.Find_Color(reagent)
			
			building.Potion.Value = buildFunctions.Get_Potion_Name((firstReagent.Value .. " " .. secondReagent.Value))
		end
		
		if secondReagent.Value == reagent.Name then
			Second_Reagent(reagent)
		elseif firstReagent.Value == reagent.Name then
			First_Reagent(reagent)
		else
			return
		end
		
		buildFunctions.Create_Potion(building)
		
	else
		return
	end
	
end

--Input: The player (in workspace) that triggered the event, and the catapult
--Output: Inserts the item the player has
function interactableFunctions.Insert_Potion(character, building)
	local potion = nil
	local proximityPart = building:FindFirstChild("Proximity")
	local originalPosition = proximityPart.CFrame
	
	for i,item in character:FindFirstChild("PickUpFolder"):GetChildren() do
		if item:IsA("Model") and i == #character:FindFirstChild("PickUpFolder"):GetChildren() and game.ReplicatedStorage.Potions:FindFirstChild(item.Name) then
			potion = item
			break
		end
	end
	
	if potion then
		local potionWeld = proximityPart:FindFirstChild("potionWeld")
		potion:FindFirstChild("PickUpWeld"):Destroy()
		potion.PrimaryPart.Anchored = false
		proximityPart.ProximityPrompt.Enabled = false
		
		potion.Parent = proximityPart
		potion.PrimaryPart.CFrame = proximityPart.CFrame + Vector3.new(0, 1, 0)
		potionWeld.Part1 = potion.PrimaryPart
		
		local lift = tweenService:Create(proximityPart, TweenInfo.new(4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {CFrame = CFrame.new(proximityPart.Position + Vector3.new(0, 6, 0))})
		lift:Play()
		wait(4)
		
		--Mana Crystals spray potion
		--define crystals
		local crystalRight = building:FindFirstChild("CrystalR")
		local crystalLeft = building:FindFirstChild("CrystalL")
		
		local infoCrystal = TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		
		local lowerRight = tweenService:Create(crystalRight, infoCrystal, {Color = Color3.new(0,33/255,33/255)})
		local lowerLeft = tweenService:Create(crystalLeft, infoCrystal, {Color = Color3.new(0,33/255,33/255)})
		
		crystalRight.Attachment.spray.Enabled = true
		crystalLeft.Attachment.spray.Enabled = true
		
		lowerRight:Play()
		lowerLeft:Play()
		
		wait(3)
		
		crystalRight.Attachment.spray.Enabled = false
		crystalLeft.Attachment.spray.Enabled = false
		
		
		----------------------------
		
		potion.PrimaryPart.t1.Enabled = true
		potion.PrimaryPart.t2.Enabled = true
		local readyLaunch = tweenService:Create(proximityPart, TweenInfo.new(2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {CFrame = originalPosition})
		readyLaunch:Play()
		wait(2)
		
		local Launch = tweenService:Create(proximityPart, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {CFrame = CFrame.new(proximityPart.Position + Vector3.new(0, 15, 0))})
		Launch:Play()
		wait(1)
		
		--Setting potion up to fly
		potionWeld.Part1 = nil
		local vectorForce = Instance.new("VectorForce")
		interactableFunctions.Change_All_Collisions(potion, true)
		local mass = corridorFunctions.Get_Mass(potion)
		
		local randomNum = math.random(1,100)
		
		local force = workspace.Gravity * mass * GRAVITY_MULTIPLIER

		
		if randomNum < 4 then
			vectorForce.Force = Vector3.new(math.random(-800,800), math.random(400,600), math.random(-800,800))
		else
			vectorForce.Force = Vector3.new(0, force, 0)
		end
		
		vectorForce.Parent = potion.PrimaryPart
		vectorForce.Attachment0 = potion.PrimaryPart.Attachment
		
		potion.Parent = game.Workspace
		potion:FindFirstChild("ProximityPrompt").Enabled = true
		
		--Putting in the team value of the potion
		if potion:FindFirstChild("Team") then
			potion.Team.Value = character.FindFirstChild("Team").Value
		else
			local team = character:FindFirstChild("Team"):Clone()
			team.Parent = potion
		end
		
		--Resetting catapult
		local fall = tweenService:Create(proximityPart, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {CFrame = CFrame.new(proximityPart.Position - Vector3.new(0, 7, 0))})
		fall:Play()
		wait(1)
		
		local chargeInfo = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
		
		local reset = tweenService:Create(proximityPart, chargeInfo, {CFrame = originalPosition})
		local chargeLeft = tweenService:Create(crystalLeft, chargeInfo, {Color = Color3.new(0, 1, 1)})
		local chargeRight = tweenService:Create(crystalRight, chargeInfo, {Color = Color3.new(0, 1, 1)})
		
		reset:Play()
		chargeLeft:Play()
		chargeRight:Play()
		wait(10)
		
		proximityPart.ProximityPrompt.Enabled = true
	end
end

--Input: The part that was touched by the object
--Output: Destroys potion and awards market share to the player's team
function interactableFunctions.Catch_Potion(partCaught)
	
	local potion = nil
	
	if partCaught.Parent == nil then
		return
	end
	
	if game.ReplicatedStorage.Potions:FindFirstChild(partCaught.Parent.Name) then
		potion = partCaught.Parent
	elseif game.ReplicatedStorage.Potions:FindFirstChild(partCaught.Name) then
		potion = partCaught
	end
	
	if potion then
		local team = potion:FindFirstChild("Team").Value
		local points = interactableFunctions.Get_Potion_Price(potion.Name)
		
		local market = game.Workspace.Market:FindFirstChild(team)
		
		if not market then
			market = Instance.new("IntValue")
			market.Name = team
			market.Parent = game.Workspace.Market
		end
		
		potion:Destroy()
		wait(1)
		
		for i,team in game.Workspace.Market:GetChildren() do
			if team == market then
				team.Value += points
			else
				team.Value -= points / 2
				
				if team.Value < 0 then
					team.Value = 0
				end
			end
		end
	end
end

function interactableFunctions.Get_Potion_Price(potionName)
	--TODO: Reorder these in value for readability
	if potionName == "Clear Cleaning" then
		return 2
	elseif potionName == "Cup of Chaos" then
		return 3
	elseif potionName == "Floaty Froth" then
		return 2
	elseif potionName == "Mana Mania" then
		return 2
	elseif potionName == "Meditative Molecules" then
		return 2
	elseif potionName == "Sky High Solidify" then
		return 2
	end
end

return interactableFunctions