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

    local CoreGui = game:GetService("CoreGui")

    local OldGui = CoreGui:FindFirstChild("CombatWarriorsGUI")

    if OldGui then
        OldGui:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CombatWarriorsGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

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
        "Combat Warriors",
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
    AimPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
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
    SettingsPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SettingsPage.Visible = false
    SettingsPage.Parent = Content

    local SettingsLayout = Instance.new("UIListLayout")
    SettingsLayout.Padding = UDim.new(0, 8)
    SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    SettingsLayout.Parent = SettingsPage

    --------------------------------------------------
    -- ELEMENT REGISTRY
    --------------------------------------------------

    local ThemeElements = {}

    local LanguageElements = {}

    local function RegisterTheme(Object, Property, ThemeKey)

        table.insert(ThemeElements, {
            Object = Object,
            Property = Property,
            ThemeKey = ThemeKey
        })

    end

    local function RegisterLanguage(Object, Key)

        table.insert(LanguageElements, {
            Object = Object,
            Key = Key
        })

    end

    local function ApplyTheme()

        Theme = Themes[CurrentTheme]

        for _, Item in ipairs(ThemeElements) do

            if Item.Object and Item.Object.Parent then

                local Value = Theme[Item.ThemeKey]

                if Value ~= nil then
                    Item.Object[Item.Property] = Value
                end

            end

        end

        if FOV and FOV.SetRainbow then

            if Settings.RainbowFOV then
                FOV.SetRainbow(true)
            else
                FOV.SetRainbow(false)
            end

        end

    end

    local function ApplyLanguage()

        for _, Item in ipairs(LanguageElements) do

            if Item.Object and Item.Object.Parent then

                Item.Object.Text =
                    GetText(
                        Localization,
                        CurrentLanguage,
                        Item.Key
                    )

            end

        end

    end

    --------------------------------------------------
    -- HELPERS
    --------------------------------------------------

    local function Section(Parent, Text, LanguageKey)

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

        RegisterTheme(Frame, "BackgroundColor3", "Sidebar")
        RegisterTheme(Label, "TextColor3", "Text")

        if LanguageKey then
            RegisterLanguage(Label, LanguageKey)
        end

        return Frame

    end

    local function Toggle(Parent, Text, Default, Callback, LanguageKey)

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
        Button.BackgroundColor3 =
            Default and Theme.ToggleOn or Theme.ToggleOff
        Button.Text = ""
        Button.AutoButtonColor = false
        Button.Parent = Frame

        Components.Corner(Button, 10)

        local Knob = Instance.new("Frame")
        Knob.Size = UDim2.fromOffset(16, 16)
        Knob.Position =
            Default
            and UDim2.new(1, -18, 0.5, -8)
            or UDim2.fromOffset(2, 2)

        Knob.BackgroundColor3 = Theme.Main
        Knob.BorderSizePixel = 0
        Knob.Parent = Button

        Components.Corner(Knob, 8)

        local State = Default

        RegisterTheme(Frame, "BackgroundColor3", "Element")
        RegisterTheme(Label, "TextColor3", "Text")
        RegisterTheme(Knob, "BackgroundColor3", "Main")

        table.insert(ThemeElements, {
            Object = Button,
            Property = "BackgroundColor3",
            Dynamic = function()
                return State and Theme.ToggleOn or Theme.ToggleOff
            end
        })

        if LanguageKey then
            RegisterLanguage(Label, LanguageKey)
        end

        Button.MouseButton1Click:Connect(function()

            State = not State

            local Position =
                State
                and UDim2.new(1, -18, 0.5, -8)
                or UDim2.fromOffset(2, 2)

            TweenService:Create(
                Knob,
                TweenInfo.new(0.15),
                {
                    Position = Position
                }
            ):Play()

            TweenService:Create(
                Button,
                TweenInfo.new(0.15),
                {
                    BackgroundColor3 =
                        State
                        and Theme.ToggleOn
                        or Theme.ToggleOff
                }
            ):Play()

            Callback(State)

        end)

        return Frame

    end

    local function Dropdown(
        Parent,
        Text,
        Options,
        Default,
        Callback,
        LanguageKey,
        OptionKeys
    )

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

        RegisterTheme(Frame, "BackgroundColor3", "Element")
        RegisterTheme(Label, "TextColor3", "Text")

        if LanguageKey then
            RegisterLanguage(Label, LanguageKey)
        end

        local Button = Components.Button(
            Frame,
            Default,
            UDim2.new(0.48, 0, 0, 28),
            UDim2.new(0.50, 0, 0, 5)
        )

        Button.BackgroundColor3 = Theme.Sidebar
        Button.TextColor3 = Theme.Text
        Button.TextSize = 12

        RegisterTheme(Button, "BackgroundColor3", "Sidebar")
        RegisterTheme(Button, "TextColor3", "Text")

        local Open = false
        local OptionButtons = {}

        local function GetOptionText(Index, Option)

            if OptionKeys and OptionKeys[Index] then

                return GetText(
                    Localization,
                    CurrentLanguage,
                    OptionKeys[Index]
                )

            end

            return Option

        end

        local function RefreshOptions()

            for Index, OptionButton in ipairs(OptionButtons) do

                local Option = Options[Index]

                OptionButton.Text =
                    GetOptionText(Index, Option)

                OptionButton.BackgroundColor3 =
                    Theme.Sidebar

                OptionButton.TextColor3 =
                    Theme.Text

            end

            local SelectedIndex

            for Index, Option in ipairs(Options) do

                if Option == Default then
                    SelectedIndex = Index
                    break
                end

            end

            if SelectedIndex then
                Button.Text =
                    GetOptionText(
                        SelectedIndex,
                        Default
                    )
            end

        end

        for Index, Option in ipairs(Options) do

            local OptionButton = Components.Button(
                Frame,
                GetOptionText(Index, Option),
                UDim2.new(0.48, 0, 0, 25),
                UDim2.new(
                    0.50,
                    0,
                    0,
                    40 + ((Index - 1) * 27)
                )
            )

            OptionButton.BackgroundColor3 = Theme.Sidebar
            OptionButton.TextColor3 = Theme.Text
            OptionButton.TextSize = 12

            RegisterTheme(
                OptionButton,
                "BackgroundColor3",
                "Sidebar"
            )

            RegisterTheme(
                OptionButton,
                "TextColor3",
                "Text"
            )

            OptionButtons[Index] = OptionButton

            OptionButton.MouseButton1Click:Connect(function()

                Default = Option

                Button.Text =
                    GetOptionText(Index, Option)

                Open = false

                Frame.Size =
                    UDim2.new(
                        1,
                        -5,
                        0,
                        38
                    )

                Callback(Option)

            end)

        end

        Button.MouseButton1Click:Connect(function()

            Open = not Open

            if Open then

                Frame.Size =
                    UDim2.new(
                        1,
                        -5,
                        0,
                        45 + (#Options * 27)
                    )

            else

                Frame.Size =
                    UDim2.new(
                        1,
                        -5,
                        0,
                        38
                    )

            end

        end)

        table.insert(LanguageElements, {
            Object = Button,
            Custom = RefreshOptions
        })

        return Frame

    end

    --------------------------------------------------
    -- AIMBOT PAGE
    --------------------------------------------------

    Section(
        AimPage,
        GetText(Localization, CurrentLanguage, "Aimbot"),
        "Aimbot"
    )

    Toggle(
        AimPage,
        GetText(Localization, CurrentLanguage, "Aimbot"),
        false,
        function(Value)

            Settings.AimbotEnabled = Value

            if Aimbot and Aimbot.SetEnabled then
                Aimbot.SetEnabled(Value)
            end

        end,
        "Aimbot"
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

            if Aimbot and Aimbot.SetBow then
                Aimbot.SetBow(Value)
            end

        end,
        "Bows",
        {
            "None",
            "HeavyBow",
            "Crossbow",
            "LongBow"
        }
    )

    Section(
        AimPage,
        GetText(Localization, CurrentLanguage, "Prediction"),
        "Prediction"
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
        string.format(
            "%.2f",
            Settings.Prediction
        ),
        function(Value)

            Settings.Prediction =
                tonumber(Value)

            if Aimbot and Aimbot.SetPrediction then
                Aimbot.SetPrediction(
                    Settings.Prediction
                )
            end

        end,
        "Prediction"
    )

    Section(
        AimPage,
        GetText(Localization, CurrentLanguage, "FOV"),
        "FOV"
    )

    --------------------------------------------------
    -- FOV SLIDER
    --------------------------------------------------

    local FOVFrame = Instance.new("Frame")
    FOVFrame.Size = UDim2.new(1, -5, 0, 55)
    FOVFrame.BackgroundColor3 = Theme.Element
    FOVFrame.BorderSizePixel = 0
    FOVFrame.Parent = AimPage

    Components.Corner(FOVFrame, 6)

    RegisterTheme(
        FOVFrame,
        "BackgroundColor3",
        "Element"
    )

    local FOVLabel = Components.Label(
        FOVFrame,
        "FOV: " .. tostring(Settings.FOVRadius),
        UDim2.new(1, -20, 0, 25),
        UDim2.fromOffset(10, 2)
    )

    FOVLabel.TextColor3 = Theme.Text
    FOVLabel.Font = Enum.Font.Gotham
    FOVLabel.TextSize = 13

    RegisterTheme(
        FOVLabel,
        "TextColor3",
        "Text"
    )

    local Slider = Components.Slider(
        FOVFrame,
        10,
        200,
        Settings.FOVRadius
    )

    Slider.Container.Position =
        UDim2.fromOffset(10, 25)

    Slider.Container.Size =
        UDim2.new(1, -20, 0, 25)

    Slider.Bar.BackgroundColor3 =
        Theme.Secondary

    RegisterTheme(
        Slider.Bar,
        "BackgroundColor3",
        "Secondary"
    )

    RegisterTheme(
        Slider.Fill,
        "BackgroundColor3",
        "ToggleOn"
    )

    RegisterTheme(
        Slider.Knob,
        "BackgroundColor3",
        "Main"
    )

    local SliderDragging = false

    local function UpdateFOVFromMouse()

        local MousePosition =
            UserInputService:GetMouseLocation()

        local AbsolutePosition =
            Slider.Bar.AbsolutePosition

        local AbsoluteSize =
            Slider.Bar.AbsoluteSize

        local Percent =
            math.clamp(
                (
                    MousePosition.X
                    - AbsolutePosition.X
                ) / AbsoluteSize.X,
                0,
                1
            )

        local Value =
            math.floor(
                10
                + ((200 - 10) * Percent)
                + 0.5
            )

        Settings.FOVRadius = Value

        local NewPercent =
            (Value - 10) / 190

        Slider.Fill.Size =
            UDim2.new(
                NewPercent,
                0,
                1,
                0
            )

        Slider.Knob.Position =
            UDim2.new(
                NewPercent,
                0,
                0.5,
                0
            )

        FOVLabel.Text =
            "FOV: " .. tostring(Value)

        if Aimbot and Aimbot.SetFOVRadius then
            Aimbot.SetFOVRadius(Value)
        end

        if FOV and FOV.SetRadius then
            FOV.SetRadius(Value)
        end

    end

    Slider.Bar.InputBegan:Connect(function(Input)

        if Input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            SliderDragging = true
            UpdateFOVFromMouse()

        end

    end)

    UserInputService.InputEnded:Connect(function(Input)

        if Input.UserInputType ==
            Enum.UserInputType.MouseButton1 then

            SliderDragging = false

        end

    end)

    UserInputService.InputChanged:Connect(function(Input)

        if SliderDragging
            and Input.UserInputType ==
                Enum.UserInputType.MouseMovement then

            UpdateFOVFromMouse()

        end

    end)

    --------------------------------------------------
    -- FOV VISIBILITY
    --------------------------------------------------

    Toggle(
        AimPage,
        GetText(
            Localization,
            CurrentLanguage,
            "FOVVisibility"
        ),
        false,
        function(Value)

            Settings.FOVVisible = Value

            if FOV and FOV.SetVisible then
                FOV.SetVisible(Value)
            end

        end,
        "FOVVisibility"
    )

    --------------------------------------------------
    -- RAINBOW FOV
    --------------------------------------------------

    Toggle(
        AimPage,
        GetText(
            Localization,
            CurrentLanguage,
            "RainbowFOV"
        ),
        false,
        function(Value)

            Settings.RainbowFOV = Value

            if FOV and FOV.SetRainbow then
                FOV.SetRainbow(Value)
            end

        end,
        "RainbowFOV"
    )

    --------------------------------------------------
    -- IGNORE PLAYERS
    --------------------------------------------------

    Section(
        AimPage,
        GetText(
            Localization,
            CurrentLanguage,
            "IgnorePlayers"
        ),
        "IgnorePlayers"
    )

    local IgnoreFrame = Instance.new("Frame")
    IgnoreFrame.Size = UDim2.new(1, -5, 0, 180)
    IgnoreFrame.BackgroundColor3 = Theme.Element
    IgnoreFrame.BorderSizePixel = 0
    IgnoreFrame.ClipsDescendants = true
    IgnoreFrame.Parent = AimPage

    Components.Corner(IgnoreFrame, 6)

    RegisterTheme(
        IgnoreFrame,
        "BackgroundColor3",
        "Element"
    )

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -20, 0, 30)
    SearchBox.Position = UDim2.fromOffset(10, 10)
    SearchBox.BackgroundColor3 = Theme.Sidebar
    SearchBox.BorderSizePixel = 0
    SearchBox.TextColor3 = Theme.Text
    SearchBox.PlaceholderColor3 = Theme.Secondary
    SearchBox.PlaceholderText =
        GetText(
            Localization,
            CurrentLanguage,
            "SearchPlayer"
        )
    SearchBox.Text = ""
    SearchBox.ClearTextOnFocus = false
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 12
    SearchBox.Parent = IgnoreFrame

    Components.Corner(SearchBox, 6)

    RegisterTheme(
        SearchBox,
        "BackgroundColor3",
        "Sidebar"
    )

    RegisterTheme(
        SearchBox,
        "TextColor3",
        "Text"
    )

    RegisterTheme(
        SearchBox,
        "PlaceholderColor3",
        "Secondary"
    )

    local PlayerList = Instance.new("ScrollingFrame")
    PlayerList.Size = UDim2.new(1, -20, 0, 125)
    PlayerList.Position = UDim2.fromOffset(10, 45)
    PlayerList.BackgroundTransparency = 1
    PlayerList.BorderSizePixel = 0
    PlayerList.ScrollBarThickness = 3
    PlayerList.ScrollBarImageColor3 = Theme.Secondary
    PlayerList.CanvasSize = UDim2.new()
    PlayerList.AutomaticCanvasSize =
        Enum.AutomaticSize.Y
    PlayerList.Parent = IgnoreFrame

    RegisterTheme(
        PlayerList,
        "ScrollBarImageColor3",
        "Secondary"
    )

    local PlayerLayout = Instance.new("UIListLayout")
    PlayerLayout.Padding = UDim.new(0, 4)
    PlayerLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PlayerLayout.Parent = PlayerList

    local function RefreshPlayerList()

        for _, Child in ipairs(PlayerList:GetChildren()) do

            if Child:IsA("Frame") then
                Child:Destroy()
            end

        end

        local Search =
            string.lower(
                SearchBox.Text or ""
            )

        for _, Player in ipairs(Players:GetPlayers()) do

            if Player ~= LocalPlayer then

                local Name =
                    string.lower(
                        Player.Name
                    )

                local DisplayName =
                    string.lower(
                        Player.DisplayName
                    )

                if Search == ""
                    or string.find(Name, Search, 1, true)
                    or string.find(
                        DisplayName,
                        Search,
                        1,
                        true
                    ) then

                    local Row = Instance.new("Frame")
                    Row.Size =
                        UDim2.new(1, -5, 0, 30)
                    Row.BackgroundColor3 =
                        Theme.Sidebar
                    Row.BorderSizePixel = 0
                    Row.Parent = PlayerList

                    Components.Corner(Row, 5)

                    local PlayerLabel =
                        Components.Label(
                            Row,
                            Player.DisplayName
                                .. "  @"
                                .. Player.Name,
                            UDim2.new(
                                1,
                                -100,
                                1,
                                0
                            ),
                            UDim2.fromOffset(
                                8,
                                0
                            )
                        )

                    PlayerLabel.TextColor3 =
                        Theme.Text

                    PlayerLabel.TextSize = 11

                    local IgnoreButton =
                        Components.Button(
                            Row,
                            IgnorePlayers.IsIgnored(Player)
                                and GetText(
                                    Localization,
                                    CurrentLanguage,
                                    "Ignored"
                                )
                                or "Ignore",
                            UDim2.fromOffset(
                                70,
                                24
                            ),
                            UDim2.new(
                                1,
                                -78,
                                0,
                                3
                            )
                        )

                    IgnoreButton.BackgroundColor3 =
                        Theme.Element

                    IgnoreButton.TextColor3 =
                        Theme.Text

                    IgnoreButton.TextSize = 10

                    RegisterTheme(
                        Row,
                        "BackgroundColor3",
                        "Sidebar"
                    )

                    RegisterTheme(
                        PlayerLabel,
                        "TextColor3",
                        "Text"
                    )

                    RegisterTheme(
                        IgnoreButton,
                        "BackgroundColor3",
                        "Element"
                    )

                    RegisterTheme(
                        IgnoreButton,
                        "TextColor3",
                        "Text"
                    )

                    IgnoreButton.MouseButton1Click:Connect(
                        function()

                            IgnorePlayers.Toggle(Player)

                            if Aimbot
                                and Aimbot.SetIgnoredPlayers then

                                Aimbot.SetIgnoredPlayers(
                                    IgnorePlayers.GetTable()
                                )

                            end

                            RefreshPlayerList()

                        end
                    )

                end

            end

        end

    end

    SearchBox:GetPropertyChangedSignal(
        "Text"
    ):Connect(RefreshPlayerList)

    Players.PlayerAdded:Connect(
        RefreshPlayerList
    )

    Players.PlayerRemoving:Connect(
        RefreshPlayerList
    )

    RefreshPlayerList()

    --------------------------------------------------
    -- SETTINGS PAGE
    --------------------------------------------------

    Section(
        SettingsPage,
        GetText(
            Localization,
            CurrentLanguage,
            "Language"
        ),
        "Language"
    )

    Dropdown(
        SettingsPage,
        GetText(
            Localization,
            CurrentLanguage,
            "Language"
        ),
        {
            "English",
            "Русский"
        },
        CurrentLanguage,
        function(Value)

            CurrentLanguage = Value

            ApplyLanguage()

            SearchBox.PlaceholderText =
                GetText(
                    Localization,
                    CurrentLanguage,
                    "SearchPlayer"
                )

            RefreshPlayerList()

        end,
        "Language"
    )

    Section(
        SettingsPage,
        GetText(
            Localization,
            CurrentLanguage,
            "Theme"
        ),
        "Theme"
    )

    Dropdown(
        SettingsPage,
        GetText(
            Localization,
            CurrentLanguage,
            "Theme"
        ),
        {
            "White",
            "Black",
            "Gray"
        },
        CurrentTheme,
        function(Value)

            CurrentTheme = Value

            ApplyTheme()

            RefreshPlayerList()

        end,
        "Theme",
        {
            "White",
            "Black",
            "Gray"
        }
    )

    --------------------------------------------------
    -- LANGUAGE REFRESH SUPPORT
    --------------------------------------------------

    for _, Item in ipairs(LanguageElements) do

        if Item.Custom then

            local OldCustom = Item.Custom

            Item.Custom = function()
                OldCustom()
            end

        end

    end

    local OldApplyLanguage = ApplyLanguage

    ApplyLanguage = function()

        for _, Item in ipairs(LanguageElements) do

            if Item.Object
                and Item.Object.Parent then

                if Item.Custom then
                    Item.Custom()
                elseif Item.Key then

                    Item.Object.Text =
                        GetText(
                            Localization,
                            CurrentLanguage,
                            Item.Key
                        )

                end

            end

        end

    end

    --------------------------------------------------
    -- TAB SWITCHING
    --------------------------------------------------

    AimTabButton.MouseButton1Click:Connect(
        function()

            AimPage.Visible = true
            SettingsPage.Visible = false

            AimTabButton.BackgroundColor3 =
                Theme.Selected

            SettingsTabButton.BackgroundColor3 =
                Theme.Element

        end
    )

    SettingsTabButton.MouseButton1Click:Connect(
        function()

            AimPage.Visible = false
            SettingsPage.Visible = true

            SettingsTabButton.BackgroundColor3 =
                Theme.Selected

            AimTabButton.BackgroundColor3 =
                Theme.Element

        end
    )

    --------------------------------------------------
    -- INSERT KEY
    --------------------------------------------------

    UserInputService.InputBegan:Connect(
        function(Input, GameProcessed)

            if GameProcessed then
                return
            end

            if Input.KeyCode ==
                Enum.KeyCode.Insert then

                MainFrame.Visible =
                    not MainFrame.Visible

            end

        end
    )

    --------------------------------------------------
    -- INITIAL FOV
    --------------------------------------------------

    if FOV and FOV.Create then

        FOV.Create(
            ScreenGui,
            Settings.FOVRadius
        )

        FOV.SetVisible(
            Settings.FOVVisible
        )

        FOV.SetRainbow(
            Settings.RainbowFOV
        )

    end

    --------------------------------------------------
    -- INITIAL MODULE SETTINGS
    --------------------------------------------------

    if Aimbot then

        if Aimbot.SetBow then
            Aimbot.SetBow(
                Settings.SelectedBow
            )
        end

        if Aimbot.SetPrediction then
            Aimbot.SetPrediction(
                Settings.Prediction
            )
        end

        if Aimbot.SetFOVRadius then
            Aimbot.SetFOVRadius(
                Settings.FOVRadius
            )
        end

        if Aimbot.SetEnabled then
            Aimbot.SetEnabled(false)
        end

        if Aimbot.SetIgnoredPlayers then
            Aimbot.SetIgnoredPlayers(
                IgnorePlayers.GetTable()
            )
        end

    end

    --------------------------------------------------
    -- APPLY INITIAL THEME
    --------------------------------------------------

    ApplyTheme()

    return ScreenGui

end

return UI
