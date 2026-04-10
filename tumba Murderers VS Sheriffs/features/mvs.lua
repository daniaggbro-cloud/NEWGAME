-- features/mvs.lua
-- Core features for Murderers VS Sheriffs

getgenv().Mega = getgenv().Mega or {}
local Mega = getgenv().Mega
Mega.Features = Mega.Features or {}

local Services = Mega.Services
local LocalPlayer = Services.LocalPlayer
local RunService = Services.RunService

local MVS = {}

-- ESP Logic
local highlights = {}

local function updateESP()
    if not Mega.States.MVS.ESP.Enabled then
        for _, h in pairs(highlights) do h:Destroy() end
        table.clear(highlights)
        return
    end

    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local role = player:GetAttribute("Role") or "Innocent"
            
            -- Filter
            local shown = false
            if role == "Murderer" and Mega.States.MVS.ESP.ShowMurderer then shown = true
            elseif role == "Sheriff" and Mega.States.MVS.ESP.ShowSheriff then shown = true
            elseif Mega.States.MVS.ESP.ShowInnocent then shown = true end

            if shown then
                if not highlights[player] then
                    local h = Instance.new("Highlight")
                    h.Name = "TumbaESP"
                    h.FillTransparency = 0.5
                    h.OutlineTransparency = 0
                    h.Parent = char
                    highlights[player] = h
                end
                
                local color = Color3.fromRGB(0, 255, 0) -- Green
                if role == "Murderer" then color = Color3.fromRGB(255, 0, 0)
                elseif role == "Sheriff" then color = Color3.fromRGB(0, 0, 255) end
                
                highlights[player].FillColor = color
                highlights[player].OutlineColor = color
            else
                if highlights[player] then
                    highlights[player]:Destroy()
                    highlights[player] = nil
                end
            end
        end
    end
end

-- Auto-Stab
local function doAutoStab()
    if not Mega.States.MVS.AutoStab.Enabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local role = LocalPlayer:GetAttribute("Role")
    if role ~= "Murderer" then return end
    
    local knife = char:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
    if not knife then return end

    for _, player in pairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (char.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if dist <= Mega.States.MVS.AutoStab.Range then
                -- Fire Stab Remote
                local remote = Services.ReplicatedStorage:FindFirstChild("StabEvent") -- Fallback or from packages
                if remote then
                    remote:FireServer(player.Character.HumanoidRootPart)
                end
            end
        end
    end
end

-- Loops
task.spawn(function()
    while true do
        pcall(updateESP)
        task.wait(1)
    end
end)

RunService.Heartbeat:Connect(function()
    pcall(doAutoStab)
    
    -- Speedhack
    if Mega.States.Player.Speed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Mega.States.Player.SpeedValue
    end
end)

Services.UserInputService.JumpRequest:Connect(function()
    if Mega.States.Player.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

Mega.Features.MVS = MVS
return MVS
