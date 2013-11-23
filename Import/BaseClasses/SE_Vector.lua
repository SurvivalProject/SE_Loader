local Vector = {}

Vector.x = 0
Vector.y = 0
Vector.z = 0

-- Need PropertyUpdate stuff

Vector.magnitude = 0

-- For now call the function

function Vector:GetMagnitude()
	self.magnitude = math.sqrt(self.x^2 + self.y^2 + self.z^2)
	return self.magnitude
end

function Vector:GetYAngle() -- returns the "height angle" (y/ground angle)
	return math.atan2(self.y, math.sqrt(self.z^2+self.x^2))
end 

function Vector:GetXAngle() -- returns ground angle.
	return math.atan2(self.z, self.x)
end 

function Vector:FromRobloxVector(rVector)
	self.x = rVector.x
	self.y = rVector.y 
	self.z = rVector.z 
	self:GetMagnitude()
end 

CreateClass("Vector", Vector)