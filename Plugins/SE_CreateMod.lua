function Create(Where, Root)
	Root:ClearAllChildren()
	for i,v in pairs(Where:GetChildren()) do
		if not v:IsA("BaseScript") and Root:FindFirstChild(v.Name) == nil then
			local a = v:Clone()
			a:ClearAllChildren()
			a.Parent = Root
			Create(v, a)
		elseif v:IsA("BaseScript") then
			if Root:FindFirstChild(v.Name) == nil then
				Instance.new("StringValue", Root).Name = v.Name
			end
			Root[v.Name].Value = v.Source

		end
	end
end

local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "SurvivalProject"

local Button = Instance.new("TextButton", Gui)
Button.Size = UDim2.new(0,100,0,20)
Button.Text = "Update API"
Button.MouseButton1Click:connect(function() 
	if game.Lighting:FindFirstChild("Include") then 
		Create(game.Lighting.Include.Source, game.Lighting.Include.SurvivalEngine) print("SurvivalProject: Creation completed.") end
	else 
		print("Cannot create! Please move the ProjectRBXM file to game.Lighting!")
	end
end)
Button.BackgroundColor3 = Color3.new(0,127/255,0)
Button.TextScaled = true
Button.TextWrapped = true
