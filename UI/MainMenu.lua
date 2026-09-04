local UI = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local function GetText(Localization, Language, Key)
    local LanguageTable = Localization[Language]

    if LanguageTable and LanguageTable[Key] then
        return LanguageTable[Key]
    end

    return Key
end

function UI:Init(Modules)
    local Config = Modules.Config
    local Localization = Modules.Localization
    local Themes = Modules.Themes
    local Aimbot = Modules.Aimbot
    local FOV = Modules.FOV
    local IgnorePlayers = Modules.IgnorePlayers
    local Components = Modules.Components

    --------------------------------------------------
    -- SETTINGS
    --------------------------------------------------

    local CurrentLanguage = "English"
    local CurrentTheme = "White"

    local Settings = {
        AimbotEnabled = false,
        SelectedBow = Config.SELECTED_BOW or "Heavy bow",
        Prediction = Config.PREDICTION or 1,
        FOVRadius = Config.FOV_RADIUS or 55,
        FOVVisible = false,
        RainbowFOV = false
    }

    --------------------------------------------------
    -- GUI
    --------------------------------------------------

    local OldGui = game:GetService("CoreGui"):FindFirstChild("CombatWarriorsGUI")

    if OldGui then
        OldGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CombatWarriorsGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game:GetService("CoreGui")

    --------------------------------------------------
    -- THEME
    --------------------------------------------------

    local Theme = Themes[CurrentTheme]

    --------------------------------------------------
    -- MAIN FRAME
    --------------------------------------------------

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.fromOffset(520, 480)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Theme.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui

    Components.Corner(MainFrame, 8)

    local MainStroke = Components.Stroke(MainFrame, 1, 0)

    --------------------------------------------------
    -- TOP BAR
    --------------------------------------------------

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Theme.Sidebar
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local Title = Components.Label(
        TopBar,
        "Combat Warriors",
        UDim2.new(1, -100, 1, 0),
        UDim2.fromOffset(15, 0)
    )

    Title.TextColor3 = Theme.Text
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 15

    --------------------------------------------------
    -- CLOSE
    --------------------------------------------------

    local CloseButton = Components.Button(
        TopBar,
        "×",
        UDim2.fromOffset(30, 30),
        UDim2.new(1, -38, 0, 5)
    )

    CloseButton.BackgroundColor3 = Theme.Element
    CloseButton.TextColor3 = Theme.Text
    CloseButton.TextSize = 20

    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)

    --------------------------------------------------
    -- DRAG
    --------------------------------------------------

    local Dragging = false
    local DragStart
    local StartPosition

    TopBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            StartPosition = MainFrame.Position
        end
    end)

    TopBar.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = Input.Position - DragStart

            MainFrame.Position = UDim2.new(
                StartPosition.X.Scale,
                StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale,
                StartPosition.Y.Offset + Delta.Y
            )
        end
    end)

    --------------------------------------------------
    -- SIDEBAR
    --------------------------------------------------

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 125, 1, -40)
    Sidebar.Position = UDim2.fromOffset(0, 40)
    Sidebar.BackgroundColor3 = Theme.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local Logo = Components.Label(
        Sidebar,
        "Combat warriors",
        UDim2.new(1, -20, 0, 40),
        UDim2.fromOffset(10, 15)
    )

    Logo.TextColor3 = Theme.Text
    Logo.Font = Enum.Font.GothamBold
    Logo.TextSize = 14

    local Version = Components.Label(
        Sidebar,
        "cheat by Sweet",
        UDim2.new(1, -20, 0, 35),
        UDim2.fromOffset(10, 50)
    )

    Version.TextColor3 = Theme.Secondary
    Version.TextSize = 11

    --------------------------------------------------
    -- CONTENT
    --------------------------------------------------

    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, -135, 1, -50)
    Content.Position = UDim2.fromOffset(130, 45)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    --------------------------------------------------
    -- TABS
    --------------------------------------------------

    local AimTabButton = Components.Button(
        Sidebar,
        GetText(Localization, CurrentLanguage, "AIMBOT"),
        UDim2.new(1, -20, 0, 34),
        UDim2.fromOffset(10, 105)
    )

    local SettingsTabButton = Components.Button(
        Sidebar,
        GetText(Localization, CurrentLanguage, "SETTINGS"),
        UDim2.new(1, -20, 0, 34),
        UDim2.fromOffset(10, 145)
    )

    AimTabButton.BackgroundColor3 = Theme.Selected
    AimTabButton.TextColor3 = Theme.Text

    --------------------------------------------------
    -- PAGES
    --------------------------------------------------

    local AimPage = Instance.new("ScrollingFrame")
    AimPage.Name = "AimPage"
    AimPage.Size = UDim2.fromScale(1, 1)
    AimPage.BackgroundTransparency = 1
    AimPage.BorderSizePixel = 0
    AimPage.ScrollBarThickness = 3
    AimPage.ScrollBarImageColor3 = Theme.Secondary
    AimPage.CanvasSize = UDim2.new()
    AimPage.Parent = Content

    local AimLayout = Instance.new("UIListLayout")
    AimLayout.Padding = UDim.new(0, 8)
    AimLayout.SortOrder = Enum.SortOrder.LayoutOrder
    AimLayout.Parent = AimPage

    local SettingsPage = Instance.new("ScrollingFrame")
    SettingsPage.Name = "SettingsPage"
    SettingsPage.Size = UDim2.fromScale(1, 1)
    SettingsPage.BackgroundTransparency = 1
    SettingsPage.BorderSizePixel = 0
    SettingsPage.ScrollBarThickness = 3
    SettingsPage.ScrollBarImageColor3 = Theme.Secondary
    SettingsPage.Visible = false
    SettingsPage.Parent = Content

    local SettingsLayout = Instance.new("UIListLayout")
    SettingsLayout.Padding = UDim.new(0, 8)
    SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SettingsLayout.Parent = SettingsPage

    --------------------------------------------------
    -- HELPERS
    --------------------------------------------------

    local function Section(Parent, Text)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -5, 0, 34)
        Frame.BackgroundColor3 = Theme.Sidebar
        Frame.BorderSizePixel = 0
        Frame.Parent = Parent

        Components.Corner(Frame, 6)

        local Label = Components.Label(
            Frame,
            Text,
            UDim2.new(1, -20, 1, 0),
            UDim2.fromOffset(10, 0)
        )

        Label.TextColor3 = Theme.Text
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 13

        return Frame
    end

    local function Toggle(Parent, Text, Default, Callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -5, 0, 38)
        Frame.BackgroundColor3 = Theme.Element
        Frame.BorderSizePixel = 0
        Frame.Parent = Parent

        Components.Corner(Frame, 6)

        local Label = Components.Label(
            Frame,
            Text,
            UDim2.new(1, -65, 1, 0),
            UDim2.fromOffset(10, 0)
        )

        Label.TextColor3 = Theme.Text

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.fromOffset(38, 20)
        Button.Position = UDim2.new(1, -48, 0.5, -10)
        Button.BackgroundColor3 = Default and Theme.ToggleOn or Theme.ToggleOff
        Button.Text = ""
        Button.AutoButtonColor = false
        Button.Parent = Frame

        Components.Corner(Button, 10)

        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.fromOffset(16, 16)
        Knob.Position = Default
            and UDim2.new(1, -18, 0.5, -8)
            or UDim2.fromOffset(2, 2)
        Knob.BackgroundColor3 = Theme.Main
        Knob.BorderSizePixel = 0
        Knob.Parent = Button

        Components.Corner(Knob, 8)

        local State = Default

        Button.MouseButton1Click:Connect(function()
            State = not State

            local Position = State
                and UDim2.new(1, -18, 0.5, -8)
                or UDim2.fromOffset(2, 2)

            TweenService:Create(
                Knob,
                TweenInfo.new(0.15),
                {Position = Position}
            ):Play()

            TweenService:Create(
                Button,
                TweenInfo.new(0.15),
                {
                    BackgroundColor3 = State
                        and Theme.ToggleOn
                        or Theme.ToggleOff
                }
            ):Play()

            Callback(State)
        end)

        return Frame
    end

    local function Dropdown(Parent, Text, Options, Default, Callback)
        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(1, -5, 0, 38)
        Frame.BackgroundColor3 = Theme.Element
        Frame.BorderSizePixel = 0
        Frame.ClipsDescendants = true
        Frame.Parent = Parent

        Components.Corner(Frame, 6)

        local Label = Components.Label(
            Frame,
            Text,
            UDim2.new(0.45, 0, 0, 38),
            UDim2.fromOffset(10, 0)
        )

        Label.TextColor3 = Theme.Text

        local Button = Components.Button(
            Frame,
            Default,
            UDim2.new(0.48, 0, 0, 28),
            UDim2.new(0.50, 0, 0, 5)
        )

        Button.BackgroundColor3 = Theme.Sidebar
        Button.TextColor3 = Theme.Text
        Button.TextSize = 12

        local Open = false

        for Index, Option in ipairs(Options) do
            local OptionButton = Components.Button(
                Frame,
                Option,
                UDim2.new(0.48, 0, 0, 25),
                UDim2.new(0.50, 0, 0, 40 + ((Index - 1) * 27))
            )

            OptionButton.BackgroundColor3 = Theme.Sidebar
            OptionButton.TextColor3 = Theme.Text
            OptionButton.TextSize = 12

            OptionButton.MouseButton1Click:Connect(function()
                Button.Text = Option
                Open = false

                Frame.Size = UDim2.new(1, -5, 0, 38)

                Callback(Option)
            end)
        end

        Button.MouseButton1Click:Connect(function()
            Open = not Open

            if Open then
                Frame.Size = UDim2.new(
                    1,
                    -5,
                    0,
                    45 + (#Options * 27)
                )
            else
                Frame.Size = UDim2.new(1, -5, 0, 38)
            end
        end)

        return Frame
    end

    --------------------------------------------------
    -- AIMBOT PAGE
    --------------------------------------------------

    Section(
        AimPage,
        GetText(Localization, CurrentLanguage, "Aimbot")
    )

    Toggle(
        AimPage,
        GetText(Localization, CurrentLanguage, "Aimbot"),
        false,
        function(Value)
            Settings.AimbotEnabled = Value

            if Aimbot.SetEnabled then
                Aimbot.SetEnabled(Value)
            end
        end
    )

    Dropdown(
        AimPage,
        GetText(Localization, CurrentLanguage, "Bows"),
        {
            "None",
            "Heavy bow",
            "Crossbow",
            "Long bow"
        },
        Settings.SelectedBow,
        function(Value)
            Settings.SelectedBow = Value

            if Aimbot.SetBow then
                Aimbot.SetBow(Value)
            end
        end
    )

    Section(
        AimPage,
        GetText(Localization, CurrentLanguage, "Prediction")
    )

    Dropdown(
        AimPage,
        GetText(Localization, CurrentLanguage, "Prediction"),
        {
            "0.00",
            "0.25",
            "0.50",
            "0.75",
            "1.00",
            "1.25",
            "1.50",
            "2.00",
            "2.50",
            "3.00"
        },
        string.format("%.2f", Settings.Prediction),
        function(Value)
            Settings.Prediction = tonumber(Value)

            if Aimbot.SetPrediction then
                Aimbot.SetPrediction(Settings.Prediction)
            end
        end
    )

    Section(
        AimPage,
        GetText(Localization, CurrentLanguage, "FOV")
    )

    Toggle(
        AimPage,
        GetText(Localization, CurrentLanguage, "FOVVisibility"),
        false,
        function(Value)
            Settings.FOVVisible = Value

            if FOV then
                FOV.SetVisible(Value)
            end
        end
    )

    Toggle(
        AimPage,
        GetText(Localization, CurrentLanguage, "RainbowFOV"),
        false,
        function(Value)
            Settings.RainbowFOV = Value

            if FOV then
                FOV.SetRainbow(Value)
            end
        end
    )

    --------------------------------------------------
    -- SETTINGS PAGE
    --------------------------------------------------

    Section(
        SettingsPage,
        GetText(Localization, CurrentLanguage, "Language")
    )

    Dropdown(
        SettingsPage,
        GetText(Localization, CurrentLanguage, "Language"),
        {
            "English",
            "Русский"
        },
        CurrentLanguage,
        function(Value)
            CurrentLanguage = Value

            Title.Text = GetText(
                Localization,
                CurrentLanguage,
                "AIMBOT"
            )

            AimTabButton.Text = GetText(
                Localization,
                CurrentLanguage,
                "AIMBOT"
            )

            SettingsTabButton.Text = GetText(
                Localization,
                CurrentLanguage,
                "SETTINGS"
            )
        end
    )

    Section(
        SettingsPage,
        GetText(Localization, CurrentLanguage, "Theme")
    )

    Dropdown(
        SettingsPage,
        GetText(Localization, CurrentLanguage, "Theme"),
        {
            "White",
            "Black",
            "Gray"
        },
        CurrentTheme,
        function(Value)
            CurrentTheme = Value
            Theme = Themes[CurrentTheme]

            MainFrame.BackgroundColor3 = Theme.Main
            MainStroke.Color = Theme.Text

            TopBar.BackgroundColor3 = Theme.Sidebar
            Sidebar.BackgroundColor3 = Theme.Sidebar

            Title.TextColor3 = Theme.Text
            Logo.TextColor3 = Theme.Text
            Version.TextColor3 = Theme.Secondary

            CloseButton.BackgroundColor3 = Theme.Element
            CloseButton.TextColor3 = Theme.Text

            AimTabButton.BackgroundColor3 = Theme.Selected
            AimTabButton.TextColor3 = Theme.Text
            SettingsTabButton.BackgroundColor3 = Theme.Element
            SettingsTabButton.TextColor3 = Theme.Text
        end
    )

    --------------------------------------------------
    -- TAB SWITCHING
    --------------------------------------------------

    AimTabButton.MouseButton1Click:Connect(function()
        AimPage.Visible = true
        SettingsPage.Visible = false

        AimTabButton.BackgroundColor3 = Theme.Selected
        SettingsTabButton.BackgroundColor3 = Theme.Element
    end)

    SettingsTabButton.MouseButton1Click:Connect(function()
        AimPage.Visible = false
        SettingsPage.Visible = true

        SettingsTabButton.BackgroundColor3 = Theme.Selected
        AimTabButton.BackgroundColor3 = Theme.Element
    end)

    --------------------------------------------------
    -- INSERT KEY
    --------------------------------------------------

    UserInputService.InputBegan:Connect(function(Input, GameProcessed)
        if GameProcessed then
            return
        end

        if Input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    --------------------------------------------------
    -- FOV
    --------------------------------------------------

    if FOV and FOV.Create then
        FOV.Create(ScreenGui, Settings.FOVRadius)
        FOV.SetVisible(false)
    end

    return ScreenGui
end

return UI
