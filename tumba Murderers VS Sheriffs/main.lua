-- main.lua
-- Tumba MVS Standalone Cheat - Cloud Edition (Titan Engine)
-- Repository: https://github.com/daniaggbro-cloud/NEWGAME

getgenv().Mega = getgenv().Mega or {}
local Mega = getgenv().Mega

local baseURL = "https://raw.githubusercontent.com/daniaggbro-cloud/NEWGAME/main/tumba%20Murderers%20VS%20Sheriffs/"
local localFolder = "tumba Murderers VS Sheriffs/"

-- Universal Module Loader
function Mega.LoadModule(path)
    if not path:find("%.lua$") and not path:find("%.json$") then path = path .. ".lua" end
    
    local content = nil
    local success = false
    
    -- 1. Try Local File (Development Mode)
    if isfile and readfile then
        local fullLocalPath = localFolder .. path
        if isfile(fullLocalPath) then
            success, content = pcall(function() return readfile(fullLocalPath) end)
        end
    end
    
    -- 2. Try Cloud (Cloud Mode)
    if not success or not content then
        local url = baseURL .. path
        success, content = pcall(function() return game:HttpGet(url) end)
        if success and (content:find("404: Not Found") or content == "") then success = false; content = nil end
    end
    
    if success and content then
        if path:find("%.json$") then
            local decoded = game:GetService("HttpService"):JSONDecode(content)
            Mega.Packages = decoded
            return decoded
        end
        
        local chunk, err = loadstring(content)
        if chunk then
            local success, result = pcall(chunk)
            if not success then warn("Execution error in module:", path, "|", err) end
            return result or true
        else
            warn("Syntax error in module:", path, "|", err)
        end
    else
        warn("Failed to load module:", path)
    end
    return nil
end

-- --- INITIALIZATION START ---

-- 1. Load Core Services (Bootstrap)
Mega.LoadModule("core/services.lua")

-- 2. Load Titan Loader
Mega.LoadModule("gui/loader_screen.lua")

if not Mega.Loader then
    error("TumbaHub: Critical Error - Loader module not found! Check GitHub path or internet connection.")
end

local loaderUI = Mega.Loader.Create()

local function RunInitPhase(id, list)
    loaderUI.SetStage(id)
    local count = #list
    for i, path in ipairs(list) do
        loaderUI.Update((i / count) * 100, "Downloading: " .. path)
        Mega.LoadModule(path)
        task.wait(0.05)
    end
end

-- PHASE 1: CORE
RunInitPhase("core", {
    "core/settings.lua",
    "core/localization.lua",
    "core/dumper.lua",
    "packages.json"
})

-- PHASE 2: FEATURES
RunInitPhase("features", {
    "features/mvs.lua"
})

-- PHASE 3: LIBRARY
RunInitPhase("library", {
    "library/ui_builder.lua"
})

-- PHASE 4: UI
loaderUI.SetStage("ui")
loaderUI.Update(80, "Building GUI Components...")
task.wait(0.5)

-- Main GUI Initialization
local function startGUI()
    local Services = Mega.Services
    local UI = Mega.UI
    local GetText = Mega.GetText

    local TumbaGUI = Instance.new("ScreenGui")
    TumbaGUI.Name = "MVS_Standalone"
    TumbaGUI.Parent = Services.CoreGui
    TumbaGUI.Enabled = true
    TumbaGUI.ResetOnSpawn = false
    Mega.Objects = { GUI = TumbaGUI }

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -230) -- Slightly higher for drama
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
    AppTitle.Size = UDim2.new(1, 0, 0, 50)
    AppTitle.BackgroundTransparency = 1
    AppTitle.Text = "TUMBA MVS"
    AppTitle.TextColor3 = Mega.Settings.Menu.AccentColor
    AppTitle.TextSize = 20
    AppTitle.Font = Enum.Font.GothamBlack
    AppTitle.Parent = Sidebar

    local TabButtonsContainer = Instance.new("Frame")
    TabButtonsContainer.Size = UDim2.new(1, -10, 1, -60)
    TabButtonsContainer.Position = UDim2.new(0, 5, 0, 55)
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
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.BackgroundColor3 = Mega.Settings.Menu.ElementColor
        btn.Text = GetText(textKey) or name
        btn.TextColor3 = Mega.Settings.Menu.TextColor
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.Parent = TabButtonsContainer
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
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
    UI.CreateKeybindButton(settingsTab, "keybind_menu", "Keybinds.Menu")

    setTab("MVS")
    
    -- Menu Toggle
    Services.UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode.Name == Mega.States.Keybinds.Menu then
            TumbaGUI.Enabled = not TumbaGUI.Enabled
        end
    end)
end

startGUI()
loaderUI.Update(100, "READY FOR MURDER.")
task.wait(1)
loaderUI.Destroy()
