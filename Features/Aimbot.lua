--// Clean Standalone Aimbot
--// Base logic extracted from script

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--------------------------------------------------
-- SETTINGS
--------------------------------------------------
local AimbotEnabled = true
local FOV_RADIUS = 55
local PREDICTION_MULTIPLIER = 1.00
local SelectedBow = "Heavy bow" -- Options: "None", "Heavy bow", "Crossbow", "Long bow"

local BowSpeeds = {
    ["None"] = nil,
    ["Heavy bow"] = 399.64,
    ["Crossbow"] = 280.67,
    ["Long bow"] = 216.84
}

local CurrentTarget = nil
local IgnoredPlayers = {}

--------------------------------------------------
-- CORE LOGIC
--------------------------------------------------

local function GetClosestTarget()
    local ClosestPlayer = nil
    local ClosestDistance = FOV_RADIUS
    local ScreenCenter = Vector2.new(
        Camera.ViewportSize.X / 2,
        Camera.ViewportSize.Y / 2
    )

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and not IgnoredPlayers[Player.UserId] then
            local Character = Player.Character

            if Character then
                local Head = Character:FindFirstChild("Head")
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")

                if Head and Humanoid and Humanoid.Health > 0 then
                    local ScreenPosition, Visible =
                        Camera:WorldToViewportPoint(Head.Position)

                    if Visible then
                        local Distance =
                            (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - ScreenCenter).Magnitude

                        if Distance < ClosestDistance then
                            ClosestDistance = Distance
                            ClosestPlayer = Player
                        end
                    end
                end
            end
        end
    end

    return ClosestPlayer
end

local function GetAimPosition(Player)
    local Character = Player.Character
    if not Character then
        return nil
    end

    local Head = Character:FindFirstChild("Head")
    if not Head then
        return nil
    end

    local HeadPosition = Head.Position

    if SelectedBow == "None" then
        return HeadPosition
    end

    local ArrowSpeed = BowSpeeds[SelectedBow]

    if not ArrowSpeed then
        return HeadPosition
    end

    local Origin = Camera.CFrame.Position
    local Velocity = Head.AssemblyLinearVelocity
    local Distance = (HeadPosition - Origin).Magnitude

    local FlightTime = Distance / ArrowSpeed

    for _ = 1, 3 do
        local PredictedPosition =
            HeadPosition + Velocity * FlightTime * PREDICTION_MULTIPLIER

        local NewDistance =
            (PredictedPosition - Origin).Magnitude

        FlightTime = NewDistance / ArrowSpeed
    end

    if SelectedBow == "Long bow" then
        FlightTime = FlightTime * 1.07
    end

    return HeadPosition + Velocity * FlightTime * PREDICTION_MULTIPLIER
end

--------------------------------------------------
-- INPUT HANDLERS
--------------------------------------------------

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then
        return
    end

    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        if AimbotEnabled then
            CurrentTarget = GetClosestTarget()
        end
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton2 then
        CurrentTarget = nil
    end
end)

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------

RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera

    if not Camera or not AimbotEnabled or not CurrentTarget then
        return
    end

    if IgnoredPlayers[CurrentTarget.UserId] then
        CurrentTarget = nil
        return
    end

    local Character = CurrentTarget.Character

    if not Character then
        CurrentTarget = nil
        return
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if not Humanoid or Humanoid.Health <= 0 then
        CurrentTarget = nil
        return
    end

    local AimPosition = GetAimPosition(CurrentTarget)

    if AimPosition then
        Camera.CFrame =
            CFrame.lookAt(Camera.CFrame.Position, AimPosition)
    end
end)

print("Clean Aimbot Loaded!")
