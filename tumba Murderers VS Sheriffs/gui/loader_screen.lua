-- gui/loader_screen.lua
-- MvS Project "Titan" Initialization Engine v1.0
-- Premium Loader with Terminal and Stats

getgenv().Mega = getgenv().Mega or {}
local Mega = getgenv().Mega

local Services = Mega.Services
local TweenService = Services.TweenService
local RunService = Services.RunService
local Loader = {}

-- Utility to get localized text safely
local function SafeGetText(key)
    if Mega.GetText then
        return Mega.GetText(key)
    end
    return key
end

function Loader.Create()
    local self = {}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TumbaMVSLoader"
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 2000
    ScreenGui.Parent = Services.CoreGui
    
    local Overlay = Instance.new("Frame", ScreenGui)
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
    Overlay.BorderSizePixel = 0
    Overlay.BackgroundTransparency = 1 
    
    local Blur = Instance.new("BlurEffect", Services.Lighting)
    Blur.Size = 0
    TweenService:Create(Blur, TweenInfo.new(1.5), {Size = 24}):Play()
    TweenService:Create(Overlay, TweenInfo.new(0.8), {BackgroundTransparency = 0.15}):Play()

    -- Rotating Grid Backdrop
    local Grid = Instance.new("ImageLabel", Overlay)
    Grid.Size = UDim2.new(2, 0, 2, 0)
    Grid.Position = UDim2.new(0.5, 0, 0.5, 0)
    Grid.AnchorPoint = Vector2.new(0.5, 0.5)
    Grid.BackgroundTransparency = 1
    Grid.Image = "rbxassetid://13419086708"
    Grid.ImageColor3 = Color3.fromRGB(200, 70, 255)
    Grid.ImageTransparency = 0.95
    Grid.Rotation = 0
    
    task.spawn(function()
        while ScreenGui.Parent do
            Grid.Rotation = Grid.Rotation + 0.05
            RunService.RenderStepped:Wait()
        end
    end)

    -- THE TITAN CONTAINER
    local Titan = Instance.new("CanvasGroup", Overlay)
    Titan.Size = UDim2.new(0, 550, 0, 380)
    Titan.Position = UDim2.new(0.5, 0, 0.48, 0)
    Titan.AnchorPoint = Vector2.new(0.5, 0.5)
    Titan.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    Titan.BorderSizePixel = 0
    Titan.GroupTransparency = 1
    Instance.new("UICorner", Titan).CornerRadius = UDim.new(0, 12)
    Instance.new("UIStroke", Titan).Color = Color3.fromRGB(200, 70, 255)
    
    -- Header: Stages
    local Header = Instance.new("Frame", Titan)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    Header.BorderSizePixel = 0
    
    local StageList = {
        {id = "core", name = "CORE"},
        {id = "features", name = "FEATURES"},
        {id = "library", name = "LIBRARY"},
        {id = "ui", name = "INTERFACE"}
    }
    local StageButtons = {}
    
    local HeaderLayout = Instance.new("UIListLayout", Header)
    HeaderLayout.FillDirection = Enum.FillDirection.Horizontal
    HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    HeaderLayout.Padding = UDim.new(0, 2)
    
    for _, s in ipairs(StageList) do
        local btn = Instance.new("Frame", Header)
        btn.Size = UDim2.new(0.25, -2, 1, 0)
        btn.BackgroundTransparency = 1
        
        local label = Instance.new("TextLabel", btn)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = s.name
        label.Font = Enum.Font.GothamBold
        label.TextSize = 10
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextTransparency = 0.6
        
        local line = Instance.new("Frame", btn)
        line.Size = UDim2.new(0, 0, 0, 2)
        line.Position = UDim2.new(0.5, 0, 1, -2)
        line.AnchorPoint = Vector2.new(0.5, 0)
        line.BackgroundColor3 = Color3.fromRGB(200, 70, 255)
        line.BorderSizePixel = 0
        
        StageButtons[s.id] = {label = label, line = line}
    end

    -- Stats Panel
    local StatsPanel = Instance.new("Frame", Titan)
    StatsPanel.Size = UDim2.new(0, 140, 0, 200)
    StatsPanel.Position = UDim2.new(1, -150, 0, 60)
    StatsPanel.BackgroundTransparency = 1
    
    local function CreateStat(name, valFunc)
        local f = Instance.new("TextLabel", StatsPanel)
        f.Size = UDim2.new(1, 0, 0, 20)
        f.BackgroundTransparency = 1
        f.Font = Enum.Font.Code
        f.TextSize = 12
        f.TextColor3 = Color3.fromRGB(200, 70, 255)
        f.TextXAlignment = Enum.TextXAlignment.Right
        
        task.spawn(function()
            while f.Parent do
                local success, result = pcall(valFunc)
                f.Text = name .. ": " .. (success and tostring(result) or "...")
                task.wait(0.5)
            end
        end)
    end
    
    CreateStat("PING", function() return math.floor(Services.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms" end)
    CreateStat("FPS", function() return math.floor(1 / RunService.RenderStepped:Wait()) end)
    CreateStat("MEM", function() return math.floor(Services.Stats:GetTotalMemoryUsageMb()) .. "MB" end)

    -- LOGS TERMINAL
    local Terminal = Instance.new("ScrollingFrame", Titan)
    Terminal.Size = UDim2.new(1, -30, 0, 100)
    Terminal.Position = UDim2.new(0, 15, 1, -115)
    Terminal.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    Terminal.BorderSizePixel = 0
    Terminal.ScrollBarThickness = 2
    Terminal.ScrollingEnabled = false
    Instance.new("UICorner", Terminal).CornerRadius = UDim.new(0, 6)
    local LogLayout = Instance.new("UIListLayout", Terminal)
    LogLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    LogLayout.Padding = UDim.new(0, 2)
    
    local function AddLog(msg, color)
        local l = Instance.new("TextLabel", Terminal)
        l.Size = UDim2.new(1, -10, 0, 16)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.Code
        l.TextSize = 11
        l.TextColor3 = color or Color3.fromRGB(150, 150, 170)
        l.Text = "> " .. msg
        l.TextXAlignment = Enum.TextXAlignment.Left
        Terminal.CanvasPosition = Vector2.new(0, 9999)
        local fullText = l.Text
        l.Text = "> "
        task.spawn(function()
            for i = 3, #fullText do l.Text = fullText:sub(1, i) task.wait(0.01) end
        end)
    end

    -- Centerpiece
    local Logo = Instance.new("TextLabel", Titan)
    Logo.Size = UDim2.new(0, 70, 0, 70)
    Logo.Position = UDim2.new(0, 40, 0, 100)
    Logo.BackgroundTransparency = 1
    Logo.Text = "🔪"
    Logo.TextSize = 50
    
    local TitleLabel = Instance.new("TextLabel", Titan)
    TitleLabel.Size = UDim2.new(0, 300, 0, 30)
    TitleLabel.Position = UDim2.new(0, 120, 0, 110)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBlack
    TitleLabel.TextSize = 22
    TitleLabel.TextColor3 = Color3.new(1, 1, 1)
    TitleLabel.Text = "TUMBA MVS"
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local StatusLabel = Instance.new("TextLabel", Titan)
    StatusLabel.Size = UDim2.new(0, 300, 0, 20)
    StatusLabel.Position = UDim2.new(0, 120, 0, 140)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Font = Enum.Font.GothamBold
    StatusLabel.TextSize = 13
    StatusLabel.TextColor3 = Color3.fromRGB(200, 70, 255)
    StatusLabel.TextTransparency = 0.5
    StatusLabel.Text = "WAITING..."
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Progress Bar
    local BarBase = Instance.new("Frame", Titan)
    BarBase.Size = UDim2.new(1, -60, 0, 8)
    BarBase.Position = UDim2.new(0.5, 0, 0, 240)
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

    -- Intro Transition
    TweenService:Create(Titan, TweenInfo.new(1.2, Enum.EasingStyle.Quart), {GroupTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()

    function self.SetStage(id)
        for stage, comp in pairs(StageButtons) do
            local active = stage == id
            TweenService:Create(comp.label, TweenInfo.new(0.4), {TextTransparency = active and 0 or 0.6}):Play()
            TweenService:Create(comp.line, TweenInfo.new(0.4), {Size = active and UDim2.new(0.8, 0, 0, 2) or UDim2.new(0, 0, 0, 2)}):Play()
        end
        AddLog("BOOTSTRAPPING ENVIRONMENT: " .. id:upper(), Color3.fromRGB(200, 70, 255))
    end

    function self.Update(percent, status)
        TweenService:Create(BarFill, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(percent / 100, 0, 1, 0)}):Play()
        Percent.Text = math.floor(percent) .. "%"
        if status then
            StatusLabel.Text = status:upper()
            AddLog(status)
        end
    end

    function self.Destroy()
        AddLog("INITIALIZATION COMPLETE.", Color3.new(1,1,1))
        task.wait(0.5)
        local t = TweenService:Create(Titan, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            GroupTransparency = 1,
            Position = UDim2.new(0.5, 0, 0.55, 0)
        })
        t:Play()
        TweenService:Create(Overlay, TweenInfo.new(0.8), {BackgroundTransparency = 1}):Play()
        TweenService:Create(Blur, TweenInfo.new(0.8), {Size = 0}):Play()
        t.Completed:Wait()
        ScreenGui:Destroy()
        Blur:Destroy()
    end

    return self
end

Mega.Loader = Loader
return Loader
