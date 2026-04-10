-- main.lua
-- Entry point for Murderers VS Sheriffs Standalone Cheat
-- Premium TumbaHub Design

-- Initialize Global Table
shared.Mega = {}
local Mega = shared.Mega

-- Load Core Modules
local function LoadLocal(path)
    local success, result = pcall(function()
        return loadstring(readfile("tumba Murderers VS Sheriffs/" .. path))()
    end)
    if not success then
        warn("Failed to load: " .. path .. " | " .. tostring(result))
    end
    return result
end

-- Bootstrap
LoadLocal("core/services.lua")
LoadLocal("core/settings.lua")
LoadLocal("core/localization.lua")
LoadLocal("library/ui_builder.lua")

local Services = Mega.Services
local UI = Mega.UI
local GetText = Mega.GetText

-- Load Features
LoadLocal("features/mvs.lua")

-- GUI Implementation
function Mega.InitGUI()
    local TumbaGUI = Instance.new("ScreenGui")
    TumbaGUI.Name = "MVS_Standalone"
    TumbaGUI.Parent = Services.CoreGui
    TumbaGUI.Enabled = true
    TumbaGUI.ResetOnSpawn = false
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = Mega.Settings.Menu.BackgroundColor
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = TumbaGUI
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color = Mega.Settings.Menu.AccentColor
    MainStroke.Thickness = 1.5
    MainStroke.Transparency = 0.5

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, -10)
    Sidebar.Position = UDim2.new(0, 5, 0, 5)
    Sidebar.BackgroundColor3 = Mega.Settings.Menu.SidebarColor
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

    local AppTitle = Instance.new("TextLabel")
    AppTitle.Size = UDim2.new(1, 0, 0, 40)
    AppTitle.BackgroundTransparency = 1
    AppTitle.Text = "TUMBA MVS"
    AppTitle.TextColor3 = Mega.Settings.Menu.AccentColor
    AppTitle.TextSize = 18
    AppTitle.Font = Enum.Font.GothamBlack
    AppTitle.Parent = Sidebar

    local TabButtonsContainer = Instance.new("Frame")
    TabButtonsContainer.Size = UDim2.new(1, -10, 1, -50)
    TabButtonsContainer.Position = UDim2.new(0, 5, 0, 45)
    TabButtonsContainer.BackgroundTransparency = 1
    TabButtonsContainer.Parent = Sidebar
    Instance.new("UIListLayout", TabButtonsContainer).Padding = UDim.new(0, 5)

    -- Content Area
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -175, 1, -10)
    ContentFrame.Position = UDim2.new(0, 170, 0, 5)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame

    local tabs = {}
    local function createTabContent(name)
        local frame = Instance.new("ScrollingFrame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.ScrollBarThickness = 2
        frame.Visible = false
        frame.Parent = ContentFrame
        Instance.new("UIListLayout", frame).Padding = UDim.new(0, 10)
        tabs[name] = frame
        return frame
    end

    local currentTab = nil
    local function setTab(name)
        if currentTab then tabs[currentTab].Visible = false end
        currentTab = name
        tabs[name].Visible = true
    end

    local function createTabButton(name, textKey)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundColor3 = Mega.Settings.Menu.ElementColor
        btn.Text = GetText(textKey)
        btn.TextColor3 = Mega.Settings.Menu.TextColor
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = TabButtonsContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        btn.MouseButton1Click:Connect(function() setTab(name) end)
    end

    -- Tabs Initialization
    local mvsTab = createTabContent("MVS")
    local playerTab = createTabContent("Player")
    local settingsTab = createTabContent("Settings")

    createTabButton("MVS", "tab_mvs")
    createTabButton("Player", "tab_player")
    createTabButton("Settings", "tab_settings")

    -- MVS Tab Content
    UI.CreateSection(mvsTab, "section_mvs_main")
    UI.CreateToggle(mvsTab, "toggle_mvs_esp", "MVS.ESP.Enabled")
    UI.CreateToggle(mvsTab, "toggle_mvs_silent_aim", "MVS.SilentAim.Enabled")
    UI.CreateToggle(mvsTab, "toggle_mvs_autostab", "MVS.AutoStab.Enabled")

    UI.CreateSection(mvsTab, "section_mvs_esp_settings")
    UI.CreateToggle(mvsTab, "toggle_mvs_show_murderer", "MVS.ESP.ShowMurderer")
    UI.CreateToggle(mvsTab, "toggle_mvs_show_sheriff", "MVS.ESP.ShowSheriff")
    UI.CreateToggle(mvsTab, "toggle_mvs_show_innocent", "MVS.ESP.ShowInnocent")

    -- Player Tab Content
    UI.CreateSection(playerTab, "section_player_movement")
    UI.CreateToggle(playerTab, "toggle_speed", "Player.Speed")
    UI.CreateSlider(playerTab, "slider_speed", "Player.SpeedValue", 16, 100)
    UI.CreateToggle(playerTab, "toggle_inf_jump", "Player.InfiniteJump")

    -- Settings Tab Content
    UI.CreateSection(settingsTab, "section_settings_menu")
    UI.CreateKeybindButton(settingsTab, "keybind_menu", "Keybinds.Menu", function(key)
        -- Global keybind logic handled in main loop
    end)

    -- Finalize
    setTab("MVS")
    
    -- Toggle logic
    Services.UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode.Name == Mega.States.Keybinds.Menu then
            TumbaGUI.Enabled = not TumbaGUI.Enabled
        end
    end)
    
    print("MVS Standalone Initialized!")
end

Mega.InitGUI()
