local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Remote function
local GetServers = ReplicatedStorage:WaitForChild("PrivateServers"):WaitForChild("GetServers")

local API_URL_STATUS = "http://157.245.80.25:5000/status"
local API_URL_INFO = "http://157.245.80.25:5000/info"

-- Detect which request function is available
local request_func = syn and syn.request or http_request or fluxus and fluxus.request or krnl_request or request

if not request_func then
    warn("No HTTP request function available in this executor.")
    return
end

-- Optional: Pretty-print for debugging
local function printServersPretty(servers)
    for serverId, serverData in pairs(servers) do
        print("Server ID:", serverId)
        for key, value in pairs(serverData) do
            print("  " .. key .. ": ", value)
        end
        print("------------------------")
    end
end

-- Anti-lag function
local function removeVisuals(parent)
    for _, obj in pairs(parent:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") then
            obj:Destroy()
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        elseif obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then
            obj:Destroy()
        end
    end
end

local function applyAntiLag()
    -- Remove heavy objects from Workspace and ReplicatedStorage
    removeVisuals(Workspace)
    removeVisuals(ReplicatedStorage)

    -- Simplify terrain
    if Workspace:FindFirstChild("Terrain") then
        local Terrain = Workspace.Terrain
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 0
        Terrain:Clear()
    end

    -- Make the screen white
    Lighting.Ambient = Color3.new(1,1,1)
    Lighting.OutdoorAmbient = Color3.new(1,1,1)
    Lighting.FogEnd = 0
    Lighting.FogStart = 0
    Lighting.FogColor = Color3.new(1,1,1)

    -- Remove all player GUIs
    for _, player in pairs(Players:GetPlayers()) do
        if player.PlayerGui then
            for _, gui in pairs(player.PlayerGui:GetChildren()) do
                gui:Destroy()
            end
        end
    end
end

-- Initial anti-lag application
applyAntiLag()

-- Continuously enforce anti-lag in case new objects appear
spawn(function()
    while true do
        wait(5)
        applyAntiLag()
    end
end)

-- Main API loop
while wait(1) do
    local success, response = pcall(function()
        return request_func({
            Url = API_URL_STATUS,
            Method = "GET"
        })
    end)

    if success and response.Success then
        local statusData = HttpService:JSONDecode(response.Body)
        
        if statusData.run_now == true then
            print("Received signal from API. Getting server list...")

            local servers = GetServers:InvokeServer()

            printServersPretty(servers)

            local json_body = HttpService:JSONEncode({ servers = servers })

            pcall(function()
                request_func({
                    Url = API_URL_INFO,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = json_body
                })
            end)
        end
    else
        warn("Failed to connect to the local API. Make sure the local_api.py script is running.")
    end
end
