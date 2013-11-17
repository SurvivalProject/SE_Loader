function Import(Name)
	local CallFrom = "SurvivalEngine"
	if not ( game.Lighting:FindFirstChild("Include") and game.Lighting.Include:FindFirstChild(CallFrom)) then
		return
	end	

	local function GetSearchRootLighting()
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

	local function GetSearchRootServerStorage()
		local root = game.ServerStorage.Include[CallFrom]
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

	local function GetSearchRootServerScriptService()
		local root = game.ServerScriptService.Include[CallFrom]
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
		
	local root = GetSearchRootLighting()
	if not root then
		root = GetSearchRootServerStorage()
	end
	if not root then
		root = GetSearchRootServerScriptService()
	end
	
	if root then 
		local Function, Data = loadstring(root.Value)
		if Data then 
			return
		end
		return Function()
	end	
end