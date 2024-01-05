--[[ BASE CODE BY: OtadTOAD - https://devforum.roblox.com/t/how-would-i-make-a-pie-chart/1366813/4]]--

---- Variables

-- GUI
local pieChartFrame = script.Parent

-- Folders
local chartFolder = workspace:WaitForChild("Market")
local displayFolder = pieChartFrame:WaitForChild("Display")

-- Values
LINE_COLOR = Color3.new(15/255, 15/255, 15/255)
LINE_THICKNESS = 3
LINE_Z_INDEX = 99999
START_ANGLE = 90

---- Functions

-- Calls
local function translateChart()
	local translated = {
		Sum = 0,
		Counts = {},
		Colors = {}
	}

	for index, teamPoints in pairs(chartFolder:GetChildren()) do
		local marketShare = teamPoints.Value
		translated.Sum += marketShare
		translated.Counts[ index ] = marketShare
		
		if teamPoints:FindFirstChild("teamColor") then
			translated.Colors[ index ] = teamPoints.teamColor.Value
		else
			translated.Colors[ index ] = nil
		end
	end

	return translated  --This is a dictionary
end

local function getColor(color)
	
	if typeof(color) == "Color3" then
		return color
	else
		-- Get Random
		local random = Random.new(color)
		-- Create color with given sat/lightness
		local colorNew = Color3.fromHSV(random:NextNumber(), 0.5, 1)
		-- Return Color
		return colorNew
	end
	
end

local function drawLine(point1, point2, parent, index, lineI)
	local size = parent.AbsoluteSize
	point1 *= size
	point2 *= size
	local v = (point2 - point1)
	local f = Instance.new("Frame")
	f.Name = "Line"..lineI.."#"..index
	f.Size = UDim2.new(0, v.magnitude + 1, 0, LINE_THICKNESS)
	f.Position = UDim2.new(0,(point1.x + v.x/2) - f.Size.X.Offset * 0.5, 0, (point1.y + v.y/2) - f.Size.Y.Offset * 0.5)
	f.Rotation = math.deg(math.atan2(v.y, v.x))
	f.BorderSizePixel = 0
	f.BackgroundColor3 = LINE_COLOR
	f.ZIndex = LINE_Z_INDEX
	f.Parent = displayFolder
	return f
end

local function cutSphere(sphere, r)
	local cut = Instance.new("UIGradient")
	cut.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(.5, 0),
		NumberSequenceKeypoint.new(.501, 1),
		NumberSequenceKeypoint.new(1, 1),
	})
	cut.Rotation = r
	cut.Parent = sphere
end

local function drawSpace(r1, r2, currentAngle, previousAngle, index)
	-- Create Spheres
	local i1 = Instance.new("ImageLabel")
	i1.Name = "Sphere1#".. index
	i1.Image = "http://www.roblox.com/asset/?id=7135409944"
	i1.BackgroundTransparency = 1
	i1.Size = UDim2.new(1, 0, 1, 0)
	i1.AnchorPoint = Vector2.new(.5, .5)
	i1.Position = UDim2.new(.5, 0, .5, 0)
	local i2 = i1:Clone()
	i2.Name = "Sphere2#".. index

	-- Fill Space
	local angleBetween = (currentAngle - previousAngle)
	if angleBetween < 180 then
		-- Rotate Spheres
		i2:Destroy()
		i2 = nil
		i1.Rotation = r2 + 180

		-- Cut Spheres
		local cutRotation = r1 + 90
		if cutRotation == 0 then cutRotation = 360 end
		cutSphere(i1, cutRotation - i1.Rotation)
	else
		-- Rotate Spheres
		i2.Rotation = r2 + 180
		i1.Rotation = r1
	end

	return i1, i2
end

local function draw()
	-- Get Chart In Table Form
	local chart = translateChart()

	-- Clear Display
	displayFolder:ClearAllChildren()

	-- Draw Chart
	local previousAngle = START_ANGLE
	local middle = Vector2.new(.5, .5)
	
	for index, value in pairs(chart.Counts) do
		local currentAngle = previousAngle + (value / chart.Sum) * 360
		local position1 = middle - (Vector2.new(math.cos(math.rad(currentAngle)), math.sin(math.rad(currentAngle)))/2)
		local position2 = middle - (Vector2.new(math.cos(math.rad(previousAngle)), math.sin(math.rad(previousAngle)))/2)
		
		local color = nil
		
		if chart.Colors[index] then
			color = getColor(chart.Colors[index])
		else
			color = getColor(index)
		end
		

		local line1 = drawLine(middle, position1, pieChartFrame, index, 1)		
		local line2 = drawLine(middle, position2, pieChartFrame, index, 2)

		local sphere1, sphere2 = drawSpace(line1.Rotation, line2.Rotation, currentAngle - START_ANGLE, previousAngle - START_ANGLE, index)
		sphere1.ImageColor3 = color
		sphere1.ZIndex = value
		sphere1.Parent = displayFolder
		if sphere2 then
			sphere2.ImageColor3 = color
			sphere2.ZIndex = value
			sphere2.Parent = displayFolder
		end

		previousAngle += (currentAngle - previousAngle)
	end
end

-- Events
while wait() do
	draw()
end
