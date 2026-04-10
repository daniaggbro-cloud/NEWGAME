getgenv().Mega = getgenv().Mega or {}
local Mega = getgenv().Mega

Mega.Services = {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    Workspace = game:GetService("Workspace"),
    HttpService = game:GetService("HttpService"),
    Lighting = game:GetService("Lighting"),
    CoreGui = game:GetService("CoreGui"),
    Stats = game:GetService("Stats")
}

Mega.Services.LocalPlayer = Mega.Services.Players.LocalPlayer

function Mega.GetImageFromURL(url, fileName)
    local folderPath = "tumbaMVS/icons/"
    local fullPath = folderPath .. fileName
    
    if isfile and writefile and makefolder and getcustomasset then
        if not isfolder("tumbaMVS") then makefolder("tumbaMVS") end
        if not isfolder(folderPath) then makefolder(folderPath) end

        if not isfile(fullPath) then
            local success, data = pcall(function() return game:HttpGet(url) end)
            if success and data then writefile(fullPath, data) end
        end

        if isfile(fullPath) then
            local success, asset = pcall(function() return getcustomasset(fullPath) end)
            if success then return asset end
        end
    end
    return "rbxassetid://13388222306" -- Fallback
end
