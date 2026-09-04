local Players = game:GetService("Players")

local IgnorePlayers = {}

local Ignored = {}

function IgnorePlayers.IsIgnored(Player)
    return Player and Ignored[Player.UserId] == true
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

function IgnorePlayers.GetCount()
    local Count = 0

    for _ in pairs(Ignored) do
        Count += 1
    end

    return Count
end

function IgnorePlayers.Clear()
    table.clear(Ignored)
end

return IgnorePlayers
