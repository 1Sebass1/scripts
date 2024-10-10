-- Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ChatEvent = ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents").SayMessageRequest
local allowedUser = "DishyWave21613"

-- Wood types to cycle through
local woodTypes = {"wood", "woodBirch", "woodHickory", "woodMaple", "woodPine", "woodSpirit"}

-- Command responses
local function getWoodAmount(woodType, toolName)
    local tool = LocalPlayer.Backpack:FindFirstChild(toolName)
    if tool and tool:FindFirstChild("Amount") then
        local amount = tool.Amount.Value
        ChatEvent:FireServer("Amount of " .. woodType .. ": " .. tostring(amount), "All")
    else
        ChatEvent:FireServer("You don't have a " .. woodType .. " tool or it doesn't have an Amount.", "All")
    end
end

-- Function to deposit wood
local function depositWood()
    while true do
        local toolFound = false
        for _, woodType in ipairs(woodTypes) do
            local tool = LocalPlayer.Backpack:FindFirstChild(woodType)
            if tool and tool:FindFirstChild("Amount") then
                local amount = tool.Amount.Value
                local args = {
                    [1] = {
                        ["chest"] = workspace.Islands:FindFirstChild("1e7a5891-b8c9-4e6d-a5c4-d75f177dfd55-island").Blocks.securitySafe,
                        ["player_tracking_category"] = "join_from_web",
                        ["amount"] = amount,
                        ["tool"] = tool,
                        ["action"] = "deposit"
                    }
                }
                
                game:GetService("ReplicatedStorage").rbxts_include.node_modules:FindFirstChild("@rbxts").net.out._NetManaged.CLIENT_CHEST_TRANSACTION:InvokeServer(unpack(args))
                toolFound = true
                wait(0.5) -- Optional delay
                break
            end
        end
        if not toolFound then
            break
        end
    end
end

local function onCommandReceived(command)
    if command == ">help" then
        local helpMessage = "Commands: >help - Show this message, >info - Display bot info, >oakWood - Get Oak amount, >birchWood - Get Birch amount, >pineWood - Get Pine amount, >mapleWood - Get Maple amount, >hickoryWood - Get Hickory amount, >depositWood - Deposit all wood until none left"
        ChatEvent:FireServer(helpMessage, "All")
    elseif command == ">info" then
        local infoMessage = "This is a basic chat bot for Roblox!"
        ChatEvent:FireServer(infoMessage, "All")
    elseif command == ">oakwood" then
        getWoodAmount("Oak", "wood")
    elseif command == ">birchwood" then
        getWoodAmount("Birch", "woodBirch")
    elseif command == ">pinewood" then
        getWoodAmount("Pine", "woodPine")
    elseif command == ">maplewood" then
        getWoodAmount("Maple", "woodMaple")
    elseif command == ">hickorywood" then
        getWoodAmount("Hickory", "woodHickory")
    elseif command == ">depositwood" then
        depositWood()
    else
        ChatEvent:FireServer("Unknown command. Type >help for available commands.", "All")
    end
end

-- Listening for chat messages
local function onPlayerChatted(player, message)
    if player.Name ~= allowedUser then return end -- Only allow the specified user
    if string.sub(message, 1, 1) == ">" then
        onCommandReceived(string.lower(message))
    end
end

-- Hook the PlayerChatted event
for _, player in pairs(Players:GetPlayers()) do
    player.Chatted:Connect(function(message)
        onPlayerChatted(player, message)
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        onPlayerChatted(player, message)
    end)
end)

-- Inform that the bot is running
if LocalPlayer.Name == allowedUser then
    ChatEvent:FireServer("Chat bot is now active. Type >help for commands.", "All")
end
