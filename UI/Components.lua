local Components = {}

function Components.Create(parent, className, properties)
    local object = Instance.new(className)

    for property, value in pairs(properties or {}) do
        object[property] = value
    end

    object.Parent = parent

    return object
end

function Components.Corner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = parent

    return corner
end

function Components.Stroke(parent, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0
    stroke.Parent = parent

    return stroke
end

function Components.Label(parent, text, size, position)
    return Components.Create(parent, "TextLabel", {
        BackgroundTransparency = 1,
        Text = text or "",
        Size = size or UDim2.new(1, 0, 0, 30),
        Position = position or UDim2.new(),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(25, 25, 28),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })
end

function Components.Button(parent, text, size, position)
    local button = Components.Create(parent, "TextButton", {
        BackgroundColor3 = Color3.fromRGB(240, 240, 243),
        BorderSizePixel = 0,
        Text = text or "",
        Size = size or UDim2.new(1, 0, 0, 36),
        Position = position or UDim2.new(),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(25, 25, 28),
        AutoButtonColor = false
    })

    Components.Corner(button, 6)

    return button
end

function Components.Toggle(parent, enabled)
    local toggle = Components.Create(parent, "Frame", {
        BackgroundColor3 = enabled
            and Color3.fromRGB(75, 170, 105)
            or Color3.fromRGB(190, 190, 195),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(42, 22)
    })

    Components.Corner(toggle, 11)

    local knob = Components.Create(toggle, "Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(18, 18),
        Position = enabled
            and UDim2.new(1, -20, 0, 2)
            or UDim2.new(0, 2, 0, 2)
    })

    Components.Corner(knob, 9)

    return toggle, knob
end

function Components.Slider(parent, minimum, maximum, value)
    local container = Components.Create(parent, "Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 40)
    })

    local bar = Components.Create(container, "Frame", {
        BackgroundColor3 = Color3.fromRGB(210, 210, 214),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 4)
    })

    Components.Corner(bar, 2)

    local percent = math.clamp(
        (value - minimum) / (maximum - minimum),
        0,
        1
    )

    local fill = Components.Create(bar, "Frame", {
        BackgroundColor3 = Color3.fromRGB(75, 170, 105),
        BorderSizePixel = 0,
        Size = UDim2.new(percent, 0, 1, 0)
    })

    Components.Corner(fill, 2)

    local knob = Components.Create(bar, "Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(percent, 0, 0.5, 0),
        Size = UDim2.fromOffset(12, 12)
    })

    Components.Corner(knob, 6)
    Components.Stroke(knob, 1, 0.3)

    return {
        Container = container,
        Bar = bar,
        Fill = fill,
        Knob = knob
    }
end

return Components
