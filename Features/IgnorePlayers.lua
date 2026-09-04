local Players = game:GetService("Players")

local IgnorePlayers = {}

local Ignored = {}

function IgnorePlayers.IsIgnored(Player)
    if not Player then
        return false
    end

    return Ignored[Player.UserId] == true
end

function IgnorePlayers.SetIgnored(Player, Value)
    if not Player then
        return
    end

    if Value then
        Ignored[Player.UserId] = true
    else
        Ignored[Player.UserId] = nil
    end
end

function IgnorePlayers.Toggle(Player)
    if not Player then
        return false
    end

    local NewValue = not IgnorePlayers.IsIgnored(Player)

    IgnorePlayers.SetIgnored(Player, NewValue)

    return NewValue
end

function IgnorePlayers.GetAll()
    local Result = {}

    for _, Player in ipairs(Players:GetPlayers()) do
        if IgnorePlayers.IsIgnored(Player) then
            table.insert(Result, Player)
        end
    end

    return Result
end

function IgnorePlayers.GetTable()
    local Result = {}

    for UserId, Value in pairs(Ignored) do
        if Value then
            Result[UserId] = true
        end
    end

    return Result
end

function IgnorePlayers.GetCount()
    local Count = 0

    for _, Value in pairs(Ignored) do
        if Value then
            Count += 1
        end
    end

    return Count
end

function IgnorePlayers.Clear()
    table.clear(Ignored)
end

Players.PlayerRemoving:Connect(function(Player)
    if Player then
        Ignored[Player.UserId] = nil
    end
end)

return IgnorePlayers
