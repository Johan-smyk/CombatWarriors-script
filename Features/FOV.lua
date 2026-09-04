local FOV = {}

local Circle
local Stroke
local RainbowConnection

function FOV.Create(ScreenGui, Radius)
    FOV.Destroy()

    Circle = Instance.new("Frame")
    Circle.Name = "FOVCircle"
    Circle.BackgroundTransparency = 1
    Circle.BorderSizePixel = 0
    Circle.AnchorPoint = Vector2.new(0.5, 0.5)
    Circle.Size = UDim2.fromOffset(Radius * 2, Radius * 2)
    Circle.Position = UDim2.fromScale(0.5, 0.5)
    Circle.ZIndex = 999
    Circle.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Circle

    Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Transparency = 0
    Stroke.Color = Color3.fromRGB(25, 25, 28)
    Stroke.Parent = Circle

    Circle.Visible = false

    return Circle
end

function FOV.SetRadius(Radius)
    if not Circle then
        return
    end

    Radius = math.clamp(
        tonumber(Radius) or 55,
        10,
        300
    )

    Circle.Size = UDim2.fromOffset(
        Radius * 2,
        Radius * 2
    )
end

function FOV.SetVisible(Visible)
    if Circle then
        Circle.Visible = Visible == true
    end
end

function FOV.SetRainbow(Enabled)
    if RainbowConnection then
        RainbowConnection:Disconnect()
        RainbowConnection = nil
    end

    if not Circle or not Stroke then
        return
    end

    if Enabled then
        local RunService = game:GetService("RunService")

        RainbowConnection = RunService.RenderStepped:Connect(function()
            if Stroke then
                Stroke.Color = Color3.fromHSV(
                    (tick() * 0.15) % 1,
                    1,
                    1
                )
            end
        end)
    else
        Stroke.Color = Color3.fromRGB(
            25,
            25,
            28
        )
    end
end

function FOV.Destroy()
    if RainbowConnection then
        RainbowConnection:Disconnect()
        RainbowConnection = nil
    end

    if Circle then
        Circle:Destroy()
        Circle = nil
    end

    Stroke = nil
end

return FOV
