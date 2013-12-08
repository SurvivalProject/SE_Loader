local Cam={}
local Camera=Workspace.Camera
function Cam:GetRotation()
	local x,y,z=Camera.CoordinateFrame:toEulerAnglesXYZ()
	return CFrame.Angles(x,y,z)
end
function Cam:GetZoomFocus()
	return (Camera.Focus.p-Camera.CoordinateFrame.p).magnitude
end

CreateClass("Cam",Cam)

--Fattycat:  I will be adding more functions in a bit just wanted to start this
