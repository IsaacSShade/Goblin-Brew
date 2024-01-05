------ CONSTANTS ------
PUNCH_DAMAGE = 10
PUNCH_COOLDOWN = 1
-----------------------

local tool = script.Parent
local cooldown = false

--Input: N/A
--Output: Punches anything in the hitbox in front of the player
local function Punch()
	if cooldown == true then
		return
	end
	
	local punchList = {"NIL"}
	cooldown = true
	print("Punching")
	
	for i,part in pairs(game.Workspace:GetPartsInPart(tool.Handle)) do
		if part.Parent == nil then
			cooldown = false
			tool.Handle.Miss:Play()
			return
		end
		
		if part.Parent:IsA("Model") then
			part = part.Parent
		end
		
		if punchList == nil or table.find(punchList, part) == nil then
			local health = part:FindFirstChild("HP")

			if health then
				tool.Handle.Hit:Play()
				wait(0.12)
				health.Value -= PUNCH_DAMAGE
				print("Punched for ", PUNCH_DAMAGE, " | Health: ", health.Value)
				
				table.insert(punchList, part)
			else
				tool.Handle.Miss:Play()
			end
		end
		
	end
	
	wait(PUNCH_COOLDOWN)
	cooldown = false
end

script.Parent.Activated:Connect(Punch)
