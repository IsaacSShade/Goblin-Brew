local userInputService = game:GetService("UserInputService")
local mouseHeldDown = false

local wand = script.Parent
local player = game.Players.LocalPlayer
local character = game.Workspace:WaitForChild(player.Name)
local mouse = player:GetMouse()

--mouse.TargetFilter = game.Workspace.Bedrock.mouseFilter

local function Destroy_Beam()
	local mousePosition = mouse.Hit
	local wandPosition = wand:FindFirstChild("end").Position
	mousePosition = Vector3.new(wandPosition.X, mousePosition.Y, mousePosition.Z)
	
	local lineVector = mousePosition - wandPosition 
	
	local beamVector = nil
	if lineVector.Magnitude > 10 then
		local normalizedVector = lineVector.Unit
		beamVector = normalizedVector * Vector3.new(10, 10, 10)
	else
		beamVector = lineVector
	end
	
	local raycastParams = RaycastParams.new()
	raycastParams.CollisionGroup = "Default"
	
	local raycastResult = game.Workspace:Raycast(wandPosition, beamVector, raycastParams)
	if raycastResult then
		local hit = raycastResult.Instance
		
		if hit.Name == "Ground" or hit:FindFirstChild("HP") then
			print(hit.Name)
		end
	end
end




userInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		mouseHeldDown = true
	end
	
	while mouseHeldDown do
		Destroy_Beam()
		wait(0.5)
	end
end)

userInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		mouseHeldDown = false
	end
end)