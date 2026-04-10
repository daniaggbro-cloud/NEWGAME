-- core/settings.lua
-- Contains default settings and states for Murderers VS Sheriffs

getgenv().Mega = getgenv().Mega or {}
local Mega = getgenv().Mega

Mega.VERSION = "1.0.0"
Mega.BUILD_DATE = os.date("%Y.%m.%d")
Mega.DEVELOPER = "TumbaHub Standalone"

Mega.Themes = {
    Dark = {
        BackgroundColor = Color3.fromRGB(12, 12, 18),
        SidebarColor = Color3.fromRGB(15, 15, 22),
        ElementColor = Color3.fromRGB(20, 20, 30), 
        ElementHoverColor = Color3.fromRGB(35, 35, 45),
        ToggleOffColor = Color3.fromRGB(60, 60, 80),
        AccentColor = Color3.fromRGB(200, 70, 255),
        SecondaryColor = Color3.fromRGB(0, 255, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        TextMutedColor = Color3.fromRGB(150, 150, 170),
        IconColor = Color3.fromRGB(150, 150, 170),
        IconActiveColor = Color3.new(1, 1, 1),
        SectionGradient1 = Color3.fromRGB(15, 15, 25),
        SectionGradient2 = Color3.fromRGB(10, 10, 20)
    }
}

Mega.Settings = {
    Menu = {
        Width = 800,
        Height = 500,
        CurrentTheme = "Dark",
        Transparency = 0.1,
        CornerRadius = 12,
        AnimationSpeed = 0.25,
        AccentColor = Color3.fromRGB(200, 70, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        TextMutedColor = Color3.fromRGB(150, 150, 170),
        ElementColor = Color3.fromRGB(20, 20, 30),
        SidebarColor = Color3.fromRGB(15, 15, 22),
        BackgroundColor = Color3.fromRGB(12, 12, 18),
        SectionGradient1 = Color3.fromRGB(15, 15, 25),
        SectionGradient2 = Color3.fromRGB(10, 10, 20)
    },
    System = {
        AntiAFK = true,
        AutoSave = true,
        PerformanceMode = false,
        ShowStatusIndicator = true
    }
}

Mega.States = {
    MVS = {
        Enabled = true,
        ESP = {
            Enabled = true,
            ShowMurderer = true,
            ShowSheriff = true,
            ShowInnocent = true,
        },
        SilentAim = {
            Enabled = false,
            FOV = 150,
            Headshots = true
        },
        AutoStab = {
            Enabled = false,
            Range = 15
        }
    },
    ESP = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Distance = true,
        Health = true,
        Tracers = false,
        MaxDistance = 1000,
        TeamColor = Color3.fromRGB(0, 255, 0),
        EnemyColor = Color3.fromRGB(255, 0, 0)
    },
    AimAssist = {
        Enabled = false,
        FOV = 120,
        Smoothness = 0.4,
        Range = 100,
        TargetPart = "Head",
        ShowFOV = true,
        FOVColor = Color3.fromRGB(0, 180, 255)
    },
    Player = {
        Speed = false,
        SpeedValue = 20,
        Fly = false,
        FlySpeed = 24,
        InfiniteJump = false,
        NoClip = false
    },
    Keybinds = {
        Menu = "RightShift"
    }
}

function Mega.SetTheme(themeName)
    local theme = Mega.Themes[themeName] or Mega.Themes.Dark
    Mega.Settings.Menu.CurrentTheme = themeName
    for k, v in pairs(theme) do
        Mega.Settings.Menu[k] = v
    end
end

-- Initialize default theme
Mega.SetTheme(Mega.Settings.Menu.CurrentTheme)
