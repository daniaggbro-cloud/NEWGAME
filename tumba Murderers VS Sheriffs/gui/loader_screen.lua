-- gui/loader_screen.lua
-- MvS Project Loader UI (Based on TumbaHub Design)

if not Mega then Mega = {} end

local Services = Mega.Services
local TweenService = Services.TweenService
local RunService = Services.RunService
local Loader = {}

function Loader.Create()
    local self = {}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MVS_Loader"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 2000
    ScreenGui.Parent = Services.CoreGui
    
    local Overlay = Instance.new("Frame", ScreenGui)
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    Overlay.BorderSizePixel = 0
    Overlay.BackgroundTransparency = 1 
    
    TweenService:Create(Overlay, TweenInfo.new(0.8), {BackgroundTransparency = 0.15}):Play()

    -- THE LOADER CONTAINER
    local Titan = Instance.new("CanvasGroup", Overlay)
    Titan.Size = UDim2.new(0, 450, 0, 300)
    Titan.Position = UDim2.new(0.5, 0, 0.48, 0)
    Titan.AnchorPoint = Vector2.new(0.5, 0.5)
    Titan.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    Titan.BorderSizePixel = 0
    Titan.GroupTransparency = 1
    Instance.new("UICorner", Titan).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", Titan).Color = Color3.fromRGB(200, 70, 255)

    -- Centerpiece
    local Logo = Instance.new("TextLabel", Titan)
    Logo.Size = UDim2.new(0, 70, 0, 70)
    Logo.Position = UDim2.new(0, 30, 0, 30)
    Logo.BackgroundTransparency = 1
    Logo.Text = "🔪"
    Logo.TextSize = 50
    
    local PhaseLabel = Instance.new("TextLabel", Titan)
    PhaseLabel.Size = UDim2.new(0, 300, 0, 30)
    PhaseLabel.Position = UDim2.new(0, 100, 0, 40)
    PhaseLabel.BackgroundTransparency = 1
    PhaseLabel.Font = Enum.Font.GothamBlack
    PhaseLabel.TextSize = 20
    PhaseLabel.TextColor3 = Color3.new(1, 1, 1)
    PhaseLabel.Text = "INITIALIZING..."
    PhaseLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local StatusLabel = Instance.new("TextLabel", Titan)
    StatusLabel.Size = UDim2.new(0, 300, 0, 20)
    StatusLabel.Position = UDim2.new(0, 100, 0, 65)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextSize = 12
    StatusLabel.TextColor3 = Color3.fromRGB(200, 70, 255)
    StatusLabel.TextTransparency = 0.5
    StatusLabel.Text = "PREPARING SYSTEM..."
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Progress Bar
    local BarBase = Instance.new("Frame", Titan)
    BarBase.Size = UDim2.new(1, -60, 0, 6)
    BarBase.Position = UDim2.new(0.5, 0, 0, 200)
    BarBase.AnchorPoint = Vector2.new(0.5, 0.5)
    BarBase.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    BarBase.BorderSizePixel = 0
    
    local BarFill = Instance.new("Frame", BarBase)
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(200, 70, 255)
    BarFill.BorderSizePixel = 0
    
    local Percent = Instance.new("TextLabel", BarBase)
    Percent.Size = UDim2.new(0, 50, 0, 20)
    Percent.Position = UDim2.new(1, -25, 0, -15)
    Percent.BackgroundTransparency = 1
    Percent.Font = Enum.Font.Code
    Percent.TextSize = 14
    Percent.TextColor3 = Color3.new(1, 1, 1)
    Percent.Text = "0%"

    -- LOGS
    local Logs = Instance.new("TextLabel", Titan)
    Logs.Size = UDim2.new(1, -60, 0, 40)
    Logs.Position = UDim2.new(0.5, 0, 1, -50)
    Logs.AnchorPoint = Vector2.new(0.5, 0)
    Logs.BackgroundTransparency = 1
    Logs.Font = Enum.Font.Code
    Logs.TextSize = 10
    Logs.TextColor3 = Color3.fromRGB(150, 150, 170)
    Logs.Text = "> WAITING FOR CORE..."
    Logs.TextXAlignment = Enum.TextXAlignment.Left

    -- Intro Transition
    TweenService:Create(Titan, TweenInfo.new(1.2, Enum.EasingStyle.Quart), {GroupTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()

    function self.SetStage(id)
        PhaseLabel.Text = id:upper() .. " DOWNLOAD"
    end

    function self.Update(percent, status)
        TweenService:Create(BarFill, TweenInfo.new(0.4), {Size = UDim2.new(percent / 100, 0, 1, 0)}):Play()
        Percent.Text = math.floor(percent) .. "%"
        if status then
            StatusLabel.Text = status:upper()
            Logs.Text = "> " .. status
        end
    end

    function self.Destroy()
        task.wait(0.5)
        TweenService:Create(Titan, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {GroupTransparency = 1}):Play()
        TweenService:Create(Overlay, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
        task.wait(0.8)
        ScreenGui:Destroy()
    end

    return self
end

Mega.Loader = Loader
return Loader
