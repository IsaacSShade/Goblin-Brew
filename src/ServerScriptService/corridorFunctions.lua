local corridorFunctions = {}

------ CONSTANTS ------
GRAVITY_MULTIPLIER = 1.2
-----------------------

--Input: Object to get mass from
--Output: Mass of object
function corridorFunctions.Get_Mass(object)
	local mass = 0
	
	if object:IsA("Model") then

		for i,v in pairs(object:GetDescendants()) do
			if(v:IsA("BasePart")) then
				mass += v:GetMass()
			end
		end
	elseif object:IsA("BasePart") then
		mass = object:GetMass()
	else
		print("ERROR: Invalid Object in Reverse_Gravity")
		mass = -1	
	end
	
	return mass
end


--Input: Object to reverse gravity, and the vector force in that object. Optional argument for the part that triggered the function
--Output: Reverses gravity for the object
function corridorFunctions.Reverse_Gravity(object, vectorForce)
	local valid = true
	local mass = 0
	
	if vectorForce.Parent.GravityChange.Value == true or vectorForce.Parent.Normalizing.Value == true then
		return
	else
		vectorForce.Parent.GravityChange.Value = true
	end
	
	for i,part in pairs(vectorForce.Parent.Parent:GetTouchingParts()) do

		if part:FindFirstChild("onTouch") then
			if part.Parent:FindFirstChild("Destroying") then
				vectorForce.Parent.GravityChange.Value = false
				return
			end
		end
	end
	
	--Getting mass
	local mass = corridorFunctions.Get_Mass(object)
	
	--If object is a player
	if game.Players:FindFirstChild(object.Name) then

		
		if object.PrimaryPart.AssemblyLinearVelocity.Y < 0 then
			object.PrimaryPart.Anchored = true
			game:GetService("RunService").Heartbeat:Wait()
			object.PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			object.PrimaryPart.Anchored = false
			game:GetService("RunService").Heartbeat:Wait()
		end
	end
	
	
	local force = workspace.Gravity * mass * GRAVITY_MULTIPLIER
	vectorForce.Force = Vector3.new(0, force, 0)
	
	while valid == true do
		valid = false
		
		for i,part in pairs(vectorForce.Parent.Parent:GetTouchingParts()) do
			
			if part:FindFirstChild("onTouch") then
				if part.Parent:FindFirstChild("Destroying") then
					valid = false
				else
					valid = true
				end
			end
		end
		wait(0.01)
	end
	
	vectorForce.Parent.GravityChange.Value = false
	wait()
	corridorFunctions.Normalize_Gravity(vectorForce)
	
	print(force, mass)
end

--Input: The vector force to adjust
--Output: Normalizes gravity gradually
function corridorFunctions.Normalize_Gravity(vectorForce)
	if vectorForce.Parent.Normalizing.Value == true or vectorForce.Parent.GravityChange.Value == true then
		return
	else
		vectorForce.Parent.Normalizing.Value = true
	end
	
	vectorForce.Force = Vector3.new(0, 0, 0)
	vectorForce.Parent.Normalizing.Value = false
end

--Input: Object that touched the part
--Output: Reverses Gravity for that object if it has the vector force in it
function corridorFunctions.On_Touch(object)
	local valid = false

	if object.Parent:IsA("Model") then
		object = object.Parent
	elseif object.Parent.Parent:IsA("Model") then
		object = object.Parent.Parent
	end
	

	local vectorForce = object:FindFirstChild("CorridorPush", true)
	
	if vectorForce then
		corridorFunctions.Reverse_Gravity(object, vectorForce)
	end

end

function corridorFunctions.On_End_Touch(object)
	if object.Parent:IsA("Model") then
		object = object.Parent
	elseif object.Parent.Parent:IsA("Model") then
		object = object.Parent.Parent
	end
	
	local vectorForce = object:FindFirstChild("CorridorPush", true)
	
	if vectorForce then
		corridorFunctions.Normalize_Gravity(vectorForce)
	end
	
end

return corridorFunctions
