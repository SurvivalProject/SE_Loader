local RGBPart = {}

function RGBPart:Constructor() 
	local new = Instance.new("Part")
	local mesh = Instance.new("FileMesh", new)
	mesh.TextureId = "http://www.roblox.com/asset/?ID=1361097"
	mesh.MeshId = "http://www.roblox.com/Asset/?id=9856898"
	mesh.Scale = new.Size*Vector3.new(2,2,2)
	new.Changed:connect(function(s) 
		if s == "Size" then
			mesh.Scale = new.Size*Vector3.new(2,2,2)
		end
	end)
	self.Part = new	
	self.Mesh = mesh
end 

function RGBPart:SetColor(r,g,b) 
	if g == nil and b == nil then 
		-- take r == Color3
		self.Mesh.VertexColor = Vector3.new(r.r, r.g, r.b)
	else 
		self.Mesh.VertexColor = Vector3.new(r/255,b/255,g/255)
	end
end

CreateClass("RGBPart", RGBPart)
