-- features/mvs.lua
-- TumbaHub MVS Features (Elite Edition)
-- Implements ESP, Speed, Silent Aim, Kill Aura, and Skin Changer

getgenv().Mega = getgenv().Mega or {}
local Mega = getgenv().Mega
local Services = Mega.Services
local Packages = Mega.Packages or {}

local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- // SETTINGS (Initialize if not present)
Mega.Settings = Mega.Settings or {
    ESP = false,
    AutoStab = false,
    KillAura = false,
    SilentAim = false,
    SilentAimFOV = 150,
    Speed = 16,
    JumpPower = 50,
    EquippedSkin = "Default"
}

-- // UTILS
local function GetClosestPlayerToCursor()
    local target = nil
    local dist = Mega.Settings.SilentAimFOV or 150
    
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local magnitude = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if magnitude < dist then
                    dist = magnitude
                    target = player
                end
            end
        end
    end
    return target
end

-- // COMBAT: SILENT AIM
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1

game:GetService("RunService").RenderStepped:Connect(function()
    FOVCircle.Visible = Mega.Settings.SilentAim
    FOVCircle.Radius = Mega.Settings.SilentAimFOV
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
end)

-- Metatable Hook for Silent Aim
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if Mega.Settings.SilentAim and method == "FireServer" and self.Name == (Packages.remotes and Packages.remotes.Shoot or "fire") then
        local target = GetClosestPlayerToCursor()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            -- Redirect shot to target's head
            args[1] = target.Character.Head.Position
            return oldNamecall(self, table.unpack(args))
        end
    end
    
    return oldNamecall(self, ...)
end)

-- // COMBAT: KILL AURA (Aura Stab)
spawn(function()
    while task.wait(0.1) do
        if Mega.Settings.KillAura then
            local reach = 15
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local p_distance = (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    if p_distance <= reach then
                        local remoteName = Packages.remotes and Packages.remotes.Stab or "KnifeKill"
                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild(remoteName, true)
                        if remote then
                            remote:FireServer(player)
                        end
                    end
                end
            end
        end
    end
end)

-- // CUSTOMIZATION: SKIN CHANGER
Mega.Skins = {}
function Mega.Skins.Equip(skinName)
    local remoteName = Packages.remotes and Packages.remotes.Equip or "EquipItem"
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild(remoteName, true)
    if remote then
        remote:FireServer(skinName)
        print("🎭 Skin Changer: Equipped " .. tostring(skinName))
    else
        warn("🎭 Skin Changer: Remote not found!")
    end
end

-- // MOVEMENT FEATURES
game:GetService("RunService").Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Mega.Settings.Speed
        LocalPlayer.Character.Humanoid.JumpPower = Mega.Settings.JumpPower
    end
end)

-- // VISUALS: ESP
spawn(function()
    while task.wait(1) do
        if Mega.Settings.ESP then
            for _, player in pairs(game:GetService("Players"):GetPlayers()) do
                if player ~= LocalPlayer and player.Character and not player.Character:FindFirstChild("MegaESP") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "MegaESP"
                    highlight.Parent = player.Character
                    highlight.FillColor = Color3.fromRGB(255, 255, 255)
                    highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
                    
                    -- Dynamic coloring from metadata
                    task.spawn(function()
                        while player.Character and player.Character:FindFirstChild("MegaESP") do
                            if player.TeamColor == LocalPlayer.TeamColor then
                                highlight.FillColor = Color3.fromRGB(0, 255, 0)
                            else
                                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                            end
                            task.wait(2)
                        end
                    end)
                end
            end
        end
    end
end)

print("🛡️ MVS Elite Features Loaded!")
