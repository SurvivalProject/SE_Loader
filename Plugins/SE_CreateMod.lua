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

function GetSEInstance(Location)
        local Inst = Location:FindFirstChild("Include")
        if not Inst then
                print("SE instance not found in "..Location.Name)
                return false
        else
                if Inst["Source"] and #Inst["Source"]:GetChildren() > 0 then
                        return Inst
                else
                        print("Found SE instance in "..Location.Name..", but structure is invalid!")
                end
        end
end

local Gui = Instance.new("ScreenGui", game.CoreGui)
Gui.Name = "SurvivalProject"

local Button = Instance.new("TextButton", Gui)
Button.Size = UDim2.new(0,100,0,50)
Button.Text = "Update SE API"
Button.MouseButton1Click:connect(function()
        if GetSEInstance(game.Lighting) ~= false then
                print("SurvivalProject: Found source in Lighting, loaded!")
                Create(GetSEInstance(game.Lighting).Source, GetSEInstance(game.Lighting).SurvivalEngine)
        elseif GetSEInstance(game.ServerStorage) ~= false then
                print("SurvivalProject: Found source in ServerStorage, loaded!")
                Create(GetSEInstance(game.ServerStorage).Source, GetSEInstance(game.ServerStorage).SurvivalEngine)
        elseif GetSEInstance(game.ServerScriptService) ~= false then
                print("SurvivalProject: Found source in ServerScriptService, loaded!")
                Create(GetSEInstance(game.ServerScriptService).Source, GetSEInstance(game.ServerScriptService).SurvivalEngine)
        else 
                print("Cannot create! Please move the ProjectRBXM file to game.Lighting, game.ServerStorage, or game.ServerScriptService!")
        end
end)
Button.BackgroundColor3 = Color3.new(0,127/255,0)
Button.TextScaled = true
Button.TextWrapped = true