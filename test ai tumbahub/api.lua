-- api.lua
-- Gemini AI API Wrapper for Roblox Experiments

local API_CONFIG = {
    KEY = "AIzaSyBY5JTSGu3VUkpWR3uj4nwQ8MzvRhwQTpo", -- INSERT KEY HERE
    MODEL = "gemini-1.5-flash",
    URL = "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s"
}

local AI_API = {}
local HttpService = game:GetService("HttpService")

-- Universal request wrapper
local function httpRequest(options)
    local request = (syn and syn.request) or (http and http.request) or http_request or request
    if not request then return nil, "Executor does not support requests" end
    
    local success, result = pcall(function()
        return request(options)
    end)
    
    if not success then return nil, "Request crashed: " .. tostring(result) end
    return result
end

function AI_API.SendMessage(prompt, context)
    if API_CONFIG.KEY == "YOUR_API_KEY_HERE" then
        return "ERROR: API Key not set in api.lua"
    end

    local fullPrompt = prompt
    if context then
        fullPrompt = "CONTEXT:\n" .. context .. "\n\nUSER QUESTION:\n" .. prompt
    end

    local endpoint = string.format(API_CONFIG.URL, API_CONFIG.MODEL, API_CONFIG.KEY)
    local payload = {
        contents = {
            {
                parts = {
                    { text = fullPrompt }
                }
            }
        },
        generationConfig = {
            temperature = 0.7,
            maxOutputTokens = 800
        }
    }

    local response, err = httpRequest({
        Url = endpoint,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(payload)
    })

    if not response then return "Network Error: " .. err end
    
    if response.Success then
        local data = HttpService:JSONDecode(response.Body)
        if data and data.candidates and data.candidates[1] and data.candidates[1].content then
            return data.candidates[1].content.parts[1].text
        else
            return "API Error: Unexpected structure. Body: " .. response.Body
        end
    else
        return "HTTP Error: " .. response.StatusCode .. " | " .. response.Body
    end
end

return AI_API
