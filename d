local jumpForce = 50 -- Adjust this value for higher/lower jumps
local jumpKey = Enum.KeyCode.Space -- Change if needed

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == jumpKey then
        local Character = LocalPlayer.Character
        if Character and typeof(Character) == "Instance" then
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            if Humanoid and typeof(Humanoid) == "Instance" then
                local SeatPart = Humanoid.SeatPart
                if SeatPart and typeof(SeatPart) == "Instance" and SeatPart:IsA("VehicleSeat") then
                    -- Apply an instant upward force
                    SeatPart.AssemblyLinearVelocity += Vector3.new(0, jumpForce, 0)
                end
            end
        end
    end
end)
