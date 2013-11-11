function Import(Name)
	if not ( game.Lighting:FindFirstChild("Include") and game.Lighting.Include:FindFirstChild(CallFrom)) then
		return
	end	

	local function GetSearchRoot()
		local root = game.Lighting.Include[CallFrom]
		local find = Name
		for match in string.gmatch(Name, "[^/]+") do
			Name = match
			root = root:FindFirstChild(match)
			if not root then
				return
			end
		end
		return root
	end
		
	local root = GetSearchRoot()
	
	if root then 
		local Function, Data = loadstring(root.Value)
		if Data then 
			return
		end
		return Function()
	end	
end