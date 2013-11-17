function Import(Name)
	local CallFrom = "SurvivalEngine"
		
	local function Spider(root, Name)
		if not (root:FindFirstChild("Include") and root.Include:FindFirstChild(CallFrom)) then
			return
		end			
		local find = Name
		-- Start name finding loop "Class/Client/Game/Player"
		for match in string.gmatch(Name, "[^/]+") do 
			Name = match
			root = root.Include[CallFrom]:FindFirstChild(match)
			if not root then
				return
			end
		end
		return root
	end

	local Spy = {game.Lighting, game.ServerScriptService, game.ServerStorage}
	local root 
	for _, SpyDir in pairs(Spy) do
		print(SpyDir.Name)
		root = Spider(SpyDir, Name)
		print(root)
		if root then
			break
		end
	end
	print(root, "loader")

	if root then 
		local Function, Data = loadstring(root.Value)
		if Data then 
			print("ERR: "..Data)
			return
		end
		return Function()
	end	
end