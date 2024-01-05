local player = game.Players.LocalPlayer
local tool = script.Parent

local partsHighlighted = {}
local partsNotFound = {}

--Input: N/A
--Output: The hitbox of the punch tool creates a white outline on anything punchable
local function Highlight_Hits()
	while tool.Parent == player.Character do
		wait(0.05)
		partsNotFound = table.clone(partsHighlighted)
		
		for i,part in game.Workspace:GetPartsInPart(tool.Handle) do
			if part.Parent:IsA("Model") then 
				part = part.Parent
			end
			
			if part:FindFirstChild("PunchHighlight") then
				--If the part is still within bounds it won't be deleted at the end of this while loop run-through
				local index = table.find(partsHighlighted, part)
				
				if index then
					table.remove(partsNotFound, index)
				end
			else
				--If this model is something punchable (has Health) then add it to the highlights
				if part:FindFirstChild("HP") then
					local highlight = Instance.new("Highlight")
					highlight.Name = "PunchHighlight"
					highlight.Parent = part
					highlight.FillTransparency = 1
					table.insert(partsHighlighted, part)
				end
			end
			
		end
		
		for i,part in partsNotFound do
			if part:FindFirstChild("PunchHighlight") then
				part:FindFirstChild("PunchHighlight"):Remove()
			end
			
			table.remove(partsHighlighted, table.find(partsHighlighted, part))
		end
	end
	
	for i,part in partsHighlighted do
		part:FindFirstChild("PunchHighlight"):Remove()
	end
end


tool.Equipped:Connect(Highlight_Hits)