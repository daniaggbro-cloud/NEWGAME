-- core/dumper.lua
-- TumbaHub Super Dumper v2.0 (Elite Edition)
-- Purpose: Generates a massive (2M+ chars) packages.json by dumping ALL game assets and metadata

getgenv().Mega = getgenv().Mega or {}
local Mega = getgenv().Mega
local Services = Mega.Services
local HttpService = game:GetService("HttpService")

local Dumper = {}

-- Safely convert tables to strings with depth control to avoid overflow
local function safeDump(t, depth)
    depth = depth or 0
    if depth > 5 then return "{TOO_DEEP}" end
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

-- Collect IDs from any object property (SoundId, AnimationId, etc)
local function collectAssets(results)
    print("💎 Dumper: Harvesting Game Assets (Sounds, Meshes, Anims)...")
    local assets = { Sounds = {}, Anims = {}, Meshes = {}, Textures = {} }
    
    for _, obj in pairs(game:GetDescendants()) do
        pcall(function()
            if obj:IsA("Sound") and obj.SoundId ~= "" then assets.Sounds[obj.Name] = obj.SoundId end
            if obj:IsA("Animation") and obj.AnimationId ~= "" then assets.Anims[obj.Name] = obj.AnimationId end
            if obj:IsA("MeshPart") then assets.Meshes[obj.Name] = obj.MeshId end
            if obj:IsA("Decal") or obj:IsA("Texture") then assets.Textures[obj.Name] = obj.Texture end
            
            -- Harvest Attributes (Important for modern Roblox games)
            local attrs = obj:GetAttributes()
            if next(attrs) then
                local key = "ATTR__" .. obj:GetFullName():gsub("%.", "__")
                results[key] = HttpService:JSONEncode(safeDump(attrs))
            end
        end)
    end
    results["assets_manifest.json"] = HttpService:JSONEncode(assets)
end

-- Deep scan all ModuleScripts
local function scanModules(results)
    print("📂 Dumper: Deep Scanning ModuleScripts...")
    local BLACKLIST = {"Chat", "CorePackages", "RobloxGui", "DefaultChatSystemChatEvents"}
    
    for _, child in pairs(game:GetDescendants()) do
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
    end
end

function Dumper.Execute()
    local Services = Mega.Services
    if not Services then warn("❌ Dumper: Services not found!") return end

    print("🚀 Mega Super Dumper: GENERATING ELITE METADATA...")
    
    local dump = {
        _version = "2.0 (Super)",
        _universeId = game.UniverseId,
        _timestamp = os.date(),
        remotes = {}
    }

    -- 1. Scan Remotes
    for _, remote in pairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            dump.remotes[remote.Name] = remote.Name
        end
    end

    -- 2. Collect Assets and Attributes
    collectAssets(dump)

    -- 3. Scan All Modules
    scanModules(dump)

    -- 4. Finalize
    print("💾 Dumper: Compiling final JSON Payload...")
    local ok, finalJSON = pcall(function() return HttpService:JSONEncode(dump) end)
    
    if ok then
        if writefile then
            local path = "tumba Murderers VS Sheriffs/packages.json"
            writefile(path, finalJSON)
            print("👑 SUCCESS! Super Package Created.")
            print("📊 Total Size: " .. string.format("%.2f", #finalJSON / 1024 / 1024) .. " MB")
            print("📌 Characters: " .. #finalJSON)
        else
            warn("❌ writefile not supported.")
        end
    else
        warn("❌ Encoding failed: " .. tostring(finalJSON))
    end
end

Mega.DumpMVSData = Dumper.Execute
print("🔮 Super Dumper Loaded! Run 'getgenv().Mega.DumpMVSData()' to generate millions of chars!")

return Dumper
