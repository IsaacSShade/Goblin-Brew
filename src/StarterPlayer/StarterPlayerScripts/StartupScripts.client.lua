local runservice = game:GetService("RunService")
local Players = game:GetService("Players")

local camera = game.Workspace.CurrentCamera
local player = game.Players.LocalPlayer
local x_pos = game.Workspace.Bedrock:WaitForChild("Bedrock Root").Position.X




--Input: N/A
--Output: Puts in essential things on the player for other functions to work
local function OnJoin()

	camera.CameraType = Enum.CameraType.Scriptable
	game.ReplicatedStorage.RemoteEvents.playerJoin:FireServer()
	
	local rotationSelected = Instance.new("IntValue")
	rotationSelected.Name = "RotationSelected"
	rotationSelected.Value = 1
	rotationSelected.Parent = player
	
	
	
end

--Input: N/A
--Output: Puts Camera 2D centered on the player's Humanoid Root Part
local function Fix_Camera_In_Place()
	
	pcall(function()
		local root = player.Character.HumanoidRootPart
		
		camera.CFrame = CFrame.new(Vector3.new((x_pos - 90), root.Position.Y, root.Position.Z)) * CFrame.Angles(0, (-math.pi / 2), 0)
		camera.FieldOfView = 30
	end)
	
end

game.Players.PlayerAdded:Connect(OnJoin)
for i,v in next,game.Players:GetPlayers() do
	if camera.CameraType ~= Enum.CameraType.Scriptable then
		OnJoin()
	end
end

runservice.RenderStepped:Connect(Fix_Camera_In_Place)

player.CharacterAdded:Connect(function()
	game.ReplicatedStorage.RemoteEvents.playerJoin:FireServer()
end)