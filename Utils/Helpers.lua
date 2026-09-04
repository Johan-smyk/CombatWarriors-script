local Helpers = {}

function Helpers.Round(Number, Decimals)
    local Multiplier = 10 ^ (Decimals or 0)
    return math.floor(Number * Multiplier + 0.5) / Multiplier
end

function Helpers.Clamp(Number, Minimum, Maximum)
    return math.clamp(Number, Minimum, Maximum)
end

function Helpers.GetScreenCenter(Camera)
    return Vector2.new(
        Camera.ViewportSize.X / 2,
        Camera.ViewportSize.Y / 2
    )
end

function Helpers.IsAlive(Player)
    if not Player or not Player.Character then
        return false
    end

    local Humanoid = Player.Character:FindFirstChildOfClass("Humanoid")

    return Humanoid ~= nil and Humanoid.Health > 0
end

function Helpers.GetHead(Player)
    if not Player or not Player.Character then
        return nil
    end

    return Player.Character:FindFirstChild("Head")
end

return Helpers
