local RespawnService = {}

RespawnService.RespawnTime = 3
RespawnService.InternalConnectionList = {}

RespawnService.PlayerAddedConnection = nil


function RespawnService:Enable()
	game.Players.CharacterAutoLoads = false 
	self.Enabled = true 
	if self.PlayerAddedConnection then 
		self.PlayerAddedConnection:disconnect()
	end
	local PA = game.Players.PlayerAdded:connect(function(c)
		local conn = c.CharacterAdded:connect(function(char)
			local h = char:WaitForChild("Humanoid")
			h.Died:connect(function()
				if self.RespawnTime ~= 0 then 
					wait(self.RespawnTime)
				end 
				c:LoadCharacter()
			end)
		end)
		self.PlayerAddedConnection[c.Name] = conn
	end)
	self.PlayerAddedConnection = PA
	for i,v in pairs(self.InternalConnectionList) do 
		v:disconnect()
	end
	-- Connect all current players;
	for _, Player in pairs(game.Players:GetPlayers()) do 
		if Player.Character and Player.Character:FindFirstChild("Humanoid") then 
			Player.Character.Humanoid.Died:connect(function()
				if self.RespawnTime ~= 0 then 
					wait(self.RespawnTime)
				end 
				local conn = Player.CharacterAdded:connect(function(c)
					local h = c:WaitForChild("Humanoid")
					h.Died:connect(function() 
						if self.RespawnTime ~= 0 then 
							wait(self.RespawnTime)
						end 
						Player:LoadCharacter() 
					end)
				end)
				self.InternalConnectionList[Player.Name] = conn
				Player:LoadCharacter() 
			end)
		end
	end
end

function RespawnService:Disable()
	self.Enabled = false 
	game.Players.CharacterAutoLoads = true 
	if self.PlayerAddedConnection then 
		self.PlayerAddedConnection:disconnect()
	end
	for i,v in pairs(self.InternalConnectionList) do 
		v:disconnect()
	end
end 

CreateClass("RespawnService", RespawnService)

-- create it 

local rs = Create "RespawnService"
rs.Name = "RespawnService"
rs.Parent = System
