-- library/ui_builder.lua
-- GUI factory for MvS standalone project (TumbaHub Design)

getgenv().Mega = getgenv().Mega or {}
local Mega = getgenv().Mega
Mega.UI = {}

local GetText = Mega.GetText
local Services = Mega.Services

-- Tooltip/Notification Placeholder
local function ShowNotification(text, duration)
    print("Notification: " .. text)
end

function Mega.UI.CreateSection(parent, titleKey)
    local Section = Instance.new("Frame")
    Section.Name = titleKey .. "Section"
    Section.Size = UDim2.new(0.95, 0, 0, 45)
    Section.BackgroundColor3 = Mega.Settings.Menu.ElementColor
    Section.BackgroundTransparency = 0.5
    Section.BorderSizePixel = 0

    local SectionCorner = Instance.new("UICorner")
    SectionCorner.CornerRadius = UDim.new(0, 10)
    SectionCorner.Parent = Section
    
    local SectionStroke = Instance.new("UIStroke", Section)
    SectionStroke.Color = Mega.Settings.Menu.AccentColor
    SectionStroke.Thickness = 1.2
    SectionStroke.Transparency = 0.7
    
    local SectionGradient = Instance.new("UIGradient")
    SectionGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Mega.Settings.Menu.SectionGradient1),
        ColorSequenceKeypoint.new(1, Mega.Settings.Menu.SectionGradient2)
    }
    SectionGradient.Rotation = 45
    SectionGradient.Parent = Section

    local SectionTitle = Instance.new("TextLabel")
    SectionTitle.Name = "SectionTitle"
    SectionTitle.Size = UDim2.new(1, -20, 1, 0)
    SectionTitle.Position = UDim2.new(0, 15, 0, 0)
    SectionTitle.BackgroundTransparency = 1
    SectionTitle.Text = GetText(titleKey)
    SectionTitle.TextColor3 = Mega.Settings.Menu.TextColor
    SectionTitle.TextSize = 14
    SectionTitle.Font = Enum.Font.GothamBold
    SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    SectionTitle.Parent = Section
    
    Section.Parent = parent
    return Section
end

function Mega.UI.CreateToggle(parent, textKey, statePath, callback)
    local translatedText = GetText(textKey)
    
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = textKey .. "Toggle"
    ToggleFrame.Size = UDim2.new(0.9, 0, 0, 35)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent

    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = " " .. translatedText
    ToggleLabel.TextColor3 = Mega.Settings.Menu.TextColor
    ToggleLabel.TextSize = 13
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame

    local function getState()
        local path = statePath
        local value = Mega.States
        for part in path:gmatch("[^%.]+") do
            value = value and value[part]
        end
        return value
    end

    local initialState = getState()

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Toggle"
    ToggleButton.Size = UDim2.new(0, 44, 0, 22)
    ToggleButton.Position = UDim2.new(1, -54, 0.5, -11)
    ToggleButton.BackgroundColor3 = initialState and Mega.Settings.Menu.AccentColor or Mega.Settings.Menu.ToggleOffColor
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = ToggleFrame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleButton

    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Name = "Circle"
    ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
    ToggleCircle.Position = initialState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    ToggleCircle.BackgroundColor3 = Mega.Settings.Menu.BackgroundColor
    ToggleCircle.Parent = ToggleButton
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = ToggleCircle

    local function SetState(newState)
        local path = statePath
        local tbl = Mega.States
        local key
        for part in path:gmatch("[^%.]+") do
            key = part
            if part ~= path:match("([^%.]+)$") then
                tbl = tbl[part]
            end
        end
        tbl[key] = newState

        Services.TweenService:Create(ToggleButton, TweenInfo.new(0.2), { BackgroundColor3 = newState and Mega.Settings.Menu.AccentColor or Color3.fromRGB(60, 60, 80) }):Play()
        Services.TweenService:Create(ToggleCircle, TweenInfo.new(0.2), { Position = newState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9) }):Play()
        
        if callback then pcall(callback, newState) end
        ShowNotification(translatedText .. ": " .. (newState and GetText("notify_enabled") or GetText("notify_disabled")), 2)
    end
    
    ToggleButton.MouseButton1Click:Connect(function() SetState(not getState()) end)

    return ToggleFrame
end

function Mega.UI.CreateSlider(parent, textKey, statePath, min, max, callback)
    local translatedText = GetText(textKey)
    
    local function getState()
        local path = statePath
        local value = Mega.States
        local parts = {}
        for part in path:gmatch("[^%.]+") do table.insert(parts, part) end
        
        for i, part in ipairs(parts) do
            if value and value[part] ~= nil then
                value = value[part]
            else
                value = nil
                break
            end
        end
        return value or min
    end

    local currentValue = getState()

    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0.9, 0, 0, 60)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = parent

    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = GetText("slider_label", translatedText, currentValue)
    SliderLabel.TextColor3 = Mega.Settings.Menu.TextColor
    SliderLabel.TextSize = 12
    SliderLabel.Font = Enum.Font.Gotham
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame

    local SliderTrack = Instance.new("Frame")
    SliderTrack.Name = "Track"
    SliderTrack.Size = UDim2.new(1, 0, 0, 6)
    SliderTrack.Position = UDim2.new(0, 0, 0, 35)
    SliderTrack.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = SliderFrame

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Mega.Settings.Menu.AccentColor
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack

    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 16, 0, 16)
    SliderButton.Position = UDim2.new(SliderFill.Size.X.Scale, -8, 0.5, -8)
    SliderButton.BackgroundColor3 = Mega.Settings.Menu.AccentColor
    SliderButton.Text = ""
    SliderButton.Parent = SliderTrack
    Instance.new("UICorner", SliderButton).CornerRadius = UDim.new(1, 0)

    local dragging = false
    SliderButton.MouseButton1Down:Connect(function() dragging = true end)
    Services.UserInputService.InputEnded:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end 
    end)

    Services.RunService.RenderStepped:Connect(function()
        if dragging then
            local mousePos = Services.UserInputService:GetMouseLocation()
            local framePos = SliderTrack.AbsolutePosition
            local frameSize = SliderTrack.AbsoluteSize
            local relativeX = math.clamp((mousePos.X - framePos.X) / frameSize.X, 0, 1)
            local newValue = math.floor(min + relativeX * (max - min) + 0.5)

            local path = statePath
            local tbl = Mega.States
            local key
            for part in path:gmatch("[^%.]+") do
                key = part
                if part ~= path:match("([^%.]+)$") then tbl = tbl[part] end
            end
            tbl[key] = newValue

            SliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            SliderButton.Position = UDim2.new(relativeX, -8, 0.5, -8)
            SliderLabel.Text = GetText("slider_label", translatedText, newValue)
            if callback then pcall(callback, newValue) end
        end
    end)

    return SliderFrame
end

function Mega.UI.CreateKeybindButton(parent, textKey, statePath, callback)
    local function getState()
        local path = statePath
        local value = Mega.States
        for part in path:gmatch("[^%.]+") do value = value and value[part] end
        return value
    end

    local currentKey = getState()

    local KeybindFrame = Instance.new("Frame")
    KeybindFrame.Size = UDim2.new(0.9, 0, 0, 35)
    KeybindFrame.BackgroundTransparency = 1
    KeybindFrame.Parent = parent

    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Size = UDim2.new(0.6, 0, 1, 0)
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.Text = " " .. GetText(textKey)
    KeybindLabel.TextColor3 = Mega.Settings.Menu.TextColor
    KeybindLabel.TextSize = 13
    KeybindLabel.Font = Enum.Font.Gotham
    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeybindLabel.Parent = KeybindFrame

    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Size = UDim2.new(0.3, 0, 0, 25)
    KeybindButton.Position = UDim2.new(0.65, 0, 0.5, -12.5)
    KeybindButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    KeybindButton.Text = currentKey or GetText("keybind_none")
    KeybindButton.TextColor3 = Mega.Settings.Menu.TextColor
    KeybindButton.TextSize = 11
    KeybindButton.Font = Enum.Font.GothamBold
    KeybindButton.Parent = KeybindFrame
    Instance.new("UICorner", KeybindButton).CornerRadius = UDim.new(0, 6)

    local listening = false
    KeybindButton.MouseButton1Click:Connect(function()
        listening = true
        KeybindButton.Text = GetText("keybind_listening")
    end)

    Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed or not listening then return end
        local key = input.KeyCode.Name
        if key == "Unknown" then return end
        listening = false
        
        if key == currentKey then key = "None" end
        currentKey = key
        KeybindButton.Text = key
        
        local path = statePath
        local tbl = Mega.States
        for part in path:gmatch("[^%.]+") do
            if part ~= path:match("([^%.]+)$") then tbl = tbl[part] else tbl[part] = key end
        end

        if callback then pcall(callback, key) end
    end)
    return KeybindFrame
end
