-- TumbaHub STANDALONE Super Dumper v2.1
-- Purpose: Independent metadata & asset extractor for any Roblox game.
-- Usage: Inject and run. Generates 'packages_standalone.json'.

-- 1. Initialize Services
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 2. Configuration
local MAX_DEPTH = 8
local BLACKLIST = {"Chat", "CorePackages", "RobloxGui", "DefaultChatSystemChatEvents", "ChatService", "VoiceChat"}

-- 3. Utility Functions
local function safeDump(t, depth)
    depth = depth or 0
    if depth > 4 then return "{DEPTH_LIMIT}" end
    local res = {}
    for k, v in pairs(t) do
        local vt = type(v)
        if vt == "string" or vt == "number" or vt == "boolean" then
            res[tostring(k)] = v
        elseif vt == "table" then
            res[tostring(k)] = safeDump(v, depth + 1)
        end
    end
    return res
end

-- 4. The Super Scanner
local function scanMetadata(parent, results, depth)
    depth = depth or 0
    if depth > MAX_DEPTH then return end
    
    for _, name in ipairs(BLACKLIST) do
        if parent.Name == name then return end
    end

    for _, child in pairs(parent:GetChildren()) do
        if child:IsA("ModuleScript") then
            local skip = false
            for _, b in ipairs(BLACKLIST) do if child:GetFullName():find(b) then skip = true break end end
            
            if not skip then
                local success, data = pcall(function() return require(child) end)
                if success and type(data) == "table" then
                    local path = child:GetFullName():gsub("%.", "__"):gsub("%:", "__") .. ".json"
                    local ok, encoded = pcall(function() return HttpService:JSONEncode(safeDump(data)) end)
                    if ok and #encoded > 20 then
                        results[path] = encoded
                    end
                end
            end
        end
        if child:IsA("Folder") or child:IsA("Model") or child:IsA("Configuration") or child:IsA("Tool") then
            pcall(function() scanMetadata(child, results, depth + 1) end)
        end
    end
end

-- 5. Asset Manifest Harvest
local function collectAssets(results)
    local assets = { Sounds = {}, Anims = {}, Meshes = {}, Textures = {} }
    for _, obj in pairs(game:GetDescendants()) do
        pcall(function()
            if obj:IsA("Sound") and obj.SoundId ~= "" then assets.Sounds[obj.Name] = obj.SoundId end
            if obj:IsA("Animation") and obj.AnimationId ~= "" then assets.Anims[obj.Name] = obj.AnimationId end
            if obj:IsA("MeshPart") then assets.Meshes[obj.Name] = obj.MeshId end
            if obj:IsA("Decal") or obj:IsA("Texture") then assets.Textures[obj.Name] = obj.Texture end
            
            -- Attributes leak
            local attrs = obj:GetAttributes()
            if next(attrs) then
                local key = "ATTR__" .. obj:GetFullName():gsub("%.", "__")
                results[key] = HttpService:JSONEncode(safeDump(attrs))
            end
        end)
    end
    results["assets_manifest.json"] = HttpService:JSONEncode(assets)
end

-- 6. Main Execution Loop
local function RunDumper()
    print("🚀 Standalone Super Dumper: STARTING...")
    
    local dump = {
        _info = {
            game = game.Name,
            placeId = game.PlaceId,
            timestamp = os.date(),
            author = "TumbaHub Elite"
        },
        remotes = {}
    }

    -- Scan Remotes
    for _, remote in pairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            dump.remotes[remote.Name] = remote.Name
            
            -- Intelligent common remote mapping
            local n = remote.Name:lower()
            if n:find("stab") or n:find("attack") or n:find("knife") or n:find("kill") then dump.remotes["Stab"] = remote.Name end
            if n:find("shoot") or n:find("fire") or n:find("gun") then dump.remotes["Shoot"] = remote.Name end
        end
    end

    -- Collect Assets
    collectAssets(dump)

    -- Deep Scan Data
    pcall(function() scanMetadata(ReplicatedStorage, dump) end)
    pcall(function() scanMetadata(LocalPlayer:WaitForChild("PlayerScripts"), dump) end)

    -- Save File
    print("💾 Finalizing JSON Payload...")
    local ok, finalJSON = pcall(function() return HttpService:JSONEncode(dump) end)
    
    if ok then
        if writefile then
            local fileName = "packages_standalone.json"
            writefile(fileName, finalJSON)
            print("👑 SUCCESS! Standalone Dump Complete.")
            print("📊 Size: " .. string.format("%.2f", #finalJSON / 1024 / 1024) .. " MB")
            print("📁 File saved as: " .. fileName)
        else
            warn("❌ writefile failed. Is your executor supported?")
        end
    else
        warn("❌ Serialization Error.")
    end
end

-- GO!
RunDumper()
