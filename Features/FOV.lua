local RunService = game:GetService("RunService")

local FOV = {}

local Circle
local Connection

function FOV.Create(Camera, Radius)
    if Circle then
        Circle:Destroy()
    end

    Circle = Instance.new("Frame")
    Circle.Name = "FOVCircle"
    Circle.BackgroundTransparency = 1
    Circle.BorderSizePixel = 0
    Circle.AnchorPoint = Vector2.new(0.5, 0.5)
    Circle.Size = UDim2.fromOffset(Radius * 2, Radius * 2)
    Circle.Position = UDim2.fromScale(0.5, 0.5)
    Circle.Parent = Camera

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Circle

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Transparency = 0
    Stroke.Parent = Circle

    return Circle
end

function FOV.SetRadius(Radius)
    if Circle then
        Circle.Size = UDim2.fromOffset(Radius * 2, Radius * 2)
    end
end

function FOV.SetVisible(Visible)
    if Circle then
        Circle.Visible = Visible
    end
end

function FOV.SetRainbow(Enabled)
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end

    if not Circle then
        return
    end

    local Stroke = Circle:FindFirstChildOfClass("UIStroke")

    if not Stroke then
        return
    end

    if Enabled then
        Connection = RunService.RenderStepped:Connect(function()
            Stroke.Color = Color3.fromHSV((tick() * 0.15) % 1, 1, 1)
        end)
    end
end

function FOV.Destroy()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end

    if Circle then
        Circle:Destroy()
        Circle = nil
    end
end

return FOV
