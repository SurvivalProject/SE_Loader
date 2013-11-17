-- Uses an old SE loader. There will be a secure loader update soon --
function Import(Name)
	local CallFrom = "SurvivalEngine"
	if game.Lighting:FindFirstChild("Include") and game.Lighting.Include:FindFirstChild(CallFrom) and game.Lighting.Include[CallFrom]:FindFirstChild(Name) then 
		local Function, Data = loadstring(game.Lighting.Include[CallFrom][Name].Value)
		if Data then 
			print("There was an error loading "..Name.."!")
			print(Data)
			return
		end
		Function()
	elseif game.ServerStorage:FindFirstChild("Include") and game.ServerStorage.Include:FindFirstChild(CallFrom) and game.ServerStorage.Include[CallFrom]:FindFirstChild(Name) then 
		local Function, Data = loadstring(game.ServerStorage.Include[CallFrom][Name].Value)
		if Data then 
			print("There was an error loading "..Name.."!")
			print(Data)
			return
		end
		Function()
	elseif game.ServerScriptService:FindFirstChild("Include") and game.ServerScriptService.Include:FindFirstChild(CallFrom) and game.ServerScriptService.Include[CallFrom]:FindFirstChild(Name) then 
		local Function, Data = loadstring(game.ServerScriptService.Include[CallFrom][Name].Value)
		if Data then 
			print("There was an error loading "..Name.."!")
			print(Data)
			return
		end
		Function()
	end		
end

Import "SE_Client"