local UI = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

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
    local Components = Modules.Components

    local Aimbot = Modules.Aimbot
    local FOV = Modules.FOV
    local IgnorePlayers = Modules.IgnorePlayers

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
    MainFrame.Size = UDim2.fromOffset(520, 560)
    MainFrame.Position = UDim2.fromScale(0.5, 0.5)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = Theme.Main
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui

    Components.Corner(MainFrame, 8)

    local MainStroke = Components.Stroke(MainFrame, 1, 0)
    MainStroke.Color = Theme.Text

    --------------------------------------------------
    -- TOP BAR
    --------------------------------------------------

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Theme.Sidebar
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local Title = Components.Label(
        TopBar,
        "Combat Warriors",
        UDim2.new(1, -50, 1, 0),
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
        Aimbot.SetEnabled(false)
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

    --------------------------------------------------
    -- CONTENT
    --------------------------------------------------

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -135, 1, -50)
    Content.Position = UDim2.fromOffset(130, 45)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    --------------------------------------------------
    -- PAGES
    --------------------------------------------------

    local AimPage = Instance.new("ScrollingFrame")
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
    SettingsPage.Size = UDim2.fromScale(1, 1)
    SettingsPage.BackgroundTransparency = 1
    SettingsPage.BorderSizePixel = 0
    SettingsPage.ScrollBarThickness = 3
    SettingsPage.ScrollBarImageColor3 = Theme.Secondary
    SettingsPage.CanvasSize = UDim2.new()
    SettingsPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
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

        return {
            Frame = Frame,
            Label = Label
        }
    end

    --------------------------------------------------
    -- TOGGLE
    --------------------------------------------------

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
        Button.BackgroundColor3 =
            Default and Theme.ToggleOn or Theme.ToggleOff
        Button.BorderSizePixel = 0
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

        local function SetState(Value, CallCallback)

            State = Value

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
                    BackgroundColor3 =
                        State and Theme.ToggleOn or Theme.ToggleOff
                }
            ):Play()

            if CallCallback then
                Callback(State)
            end
        end

        Button.MouseButton1Click:Connect(function()
            SetState(not State, true)
        end)

        return {
            Frame = Frame,
            Label = Label,
            Button = Button,
            Knob = Knob,
            SetState = SetState
        }
    end

    --------------------------------------------------
    -- DROPDOWN
    --------------------------------------------------

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

        local OptionButtons = {}
        local Open = false

        local function Close()
            Open = false
            Frame.Size = UDim2.new(1, -5, 0, 38)
        end

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

            OptionButtons[Option] = OptionButton

            OptionButton.MouseButton1Click:Connect(function()

                Button.Text = Option

                Close()

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
                Close()
            end
        end)

        return {
            Frame = Frame,
            Label = Label,
            Button = Button,
            Options = OptionButtons
        }
    end

    --------------------------------------------------
    -- AIMBOT
    --------------------------------------------------

    local AimSection = Section(
        AimPage,
        GetText(Localization, CurrentLanguage, "Aimbot")
    )

    local AimbotToggle = Toggle(
        AimPage,
        GetText(Localization, CurrentLanguage, "Aimbot"),
        false,
        function(Value)

            Settings.AimbotEnabled = Value

            Aimbot.SetEnabled(Value)
        end
    )

    local BowDropdown = Dropdown(
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

            Aimbot.SetBow(Value)
        end
    )

    --------------------------------------------------
    -- PREDICTION
    --------------------------------------------------

    local PredictionSection = Section(
        AimPage,
        GetText(Localization, CurrentLanguage, "Prediction")
    )

    local PredictionDropdown = Dropdown(
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

            Aimbot.SetPrediction(Settings.Prediction)
        end
    )

    --------------------------------------------------
    -- FOV
    --------------------------------------------------

    local FOVSection = Section(
        AimPage,
        GetText(Localization, CurrentLanguage, "FOV")
    )

    local FOVSliderFrame = Instance.new("Frame")
    FOVSliderFrame.Size = UDim2.new(1, -5, 0, 55)
    FOVSliderFrame.BackgroundColor3 = Theme.Element
    FOVSliderFrame.BorderSizePixel = 0
    FOVSliderFrame.Parent = AimPage

    Components.Corner(FOVSliderFrame, 6)

    local FOVLabel = Components.Label(
        FOVSliderFrame,
        "FOV: " .. tostring(Settings.FOVRadius),
        UDim2.new(1, -20, 0, 25),
        UDim2.fromOffset(10, 0)
    )

    FOVLabel.TextColor3 = Theme.Text

    local FOVBar = Instance.new("Frame")
    FOVBar.Size = UDim2.new(1, -20, 0, 5)
    FOVBar.Position = UDim2.fromOffset(10, 38)
    FOVBar.BackgroundColor3 = Theme.Sidebar
    FOVBar.BorderSizePixel = 0
    FOVBar.Parent = FOVSliderFrame

    Components.Corner(FOVBar, 3)

    local FOVFill = Instance.new("Frame")
    FOVFill.BackgroundColor3 = Theme.ToggleOn
    FOVFill.BorderSizePixel = 0
    FOVFill.Size = UDim2.new(
        (Settings.FOVRadius - 10) / 190,
        0,
        1,
        0
    )
    FOVFill.Parent = FOVBar

    Components.Corner(FOVFill, 3)

    local FOVKnob = Instance.new("Frame")
    FOVKnob.Size = UDim2.fromOffset(12, 12)
    FOVKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    FOVKnob.Position = UDim2.new(
        (Settings.FOVRadius - 10) / 190,
        0,
        0.5,
        0
    )
    FOVKnob.BackgroundColor3 = Theme.Main
    FOVKnob.BorderSizePixel = 0
    FOVKnob.Parent = FOVBar

    Components.Corner(FOVKnob, 6)

    local FOVDragging = false

    local function UpdateFOV(InputX)

        local AbsolutePosition = FOVBar.AbsolutePosition.X
        local Width = FOVBar.AbsoluteSize.X

        local Percent = math.clamp(
            (InputX - AbsolutePosition) / Width,
            0,
            1
        )

        local Value = math.floor(10 + Percent * 190 + 0.5)

        Settings.FOVRadius = Value

        FOVLabel.Text = "FOV: " .. tostring(Value)

        FOVFill.Size = UDim2.new(
            Percent,
            0,
            1,
            0
        )

        FOVKnob.Position = UDim2.new(
            Percent,
            0,
            0.5,
            0
        )

        Aimbot.SetFOVRadius(Value)
        FOV.SetRadius(Value)
    end

    FOVBar.InputBegan:Connect(function(Input)

        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            FOVDragging = true
            UpdateFOV(Input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)

        if FOVDragging
            and Input.UserInputType == Enum.UserInputType.MouseMovement then

            UpdateFOV(Input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(Input)

        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            FOVDragging = false
        end
    end)

    --------------------------------------------------
    -- FOV TOGGLES
    --------------------------------------------------

    local FOVVisibilityToggle = Toggle(
        AimPage,
        GetText(Localization, CurrentLanguage, "FOVVisibility"),
        false,
        function(Value)

            Settings.FOVVisible = Value

            FOV.SetVisible(Value)
        end
    )

    local RainbowToggle = Toggle(
        AimPage,
        GetText(Localization, CurrentLanguage, "RainbowFOV"),
        false,
        function(Value)

            Settings.RainbowFOV = Value

            FOV.SetRainbow(Value)
        end
    )

    --------------------------------------------------
    -- IGNORE PLAYERS
    --------------------------------------------------

    local IgnoreSection = Section(
        AimPage,
        GetText(Localization, CurrentLanguage, "IgnorePlayers")
    )

    local IgnoreFrame = Instance.new("Frame")
    IgnoreFrame.Size = UDim2.new(1, -5, 0, 42)
    IgnoreFrame.BackgroundColor3 = Theme.Element
    IgnoreFrame.BorderSizePixel = 0
    IgnoreFrame.Parent = AimPage

    Components.Corner(IgnoreFrame, 6)

    local IgnoreButton = Components.Button(
        IgnoreFrame,
        GetText(Localization, CurrentLanguage, "IgnorePlayers"),
        UDim2.new(1, -20, 0, 28),
        UDim2.fromOffset(10, 7)
    )

    IgnoreButton.BackgroundColor3 = Theme.Sidebar
    IgnoreButton.TextColor3 = Theme.Text
    IgnoreButton.TextSize = 12

    local PlayerListFrame = Instance.new("Frame")
    PlayerListFrame.Size = UDim2.new(1, -5, 0, 0)
    PlayerListFrame.BackgroundColor3 = Theme.Element
    PlayerListFrame.BorderSizePixel = 0
    PlayerListFrame.ClipsDescendants = true
    PlayerListFrame.Visible = false
    PlayerListFrame.Parent = AimPage

    Components.Corner(PlayerListFrame, 6)

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -20, 0, 30)
    SearchBox.Position = UDim2.fromOffset(10, 8)
    SearchBox.BackgroundColor3 = Theme.Sidebar
    SearchBox.BorderSizePixel = 0
    SearchBox.Text = ""
    SearchBox.PlaceholderText =
        GetText(Localization, CurrentLanguage, "SearchPlayer")
    SearchBox.TextColor3 = Theme.Text
    SearchBox.PlaceholderColor3 = Theme.Secondary
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.TextSize = 12
    SearchBox.ClearTextOnFocus = false
    SearchBox.Parent = PlayerListFrame

    Components.Corner(SearchBox, 5)

    local PlayerList = Instance.new("ScrollingFrame")
    PlayerList.Size = UDim2.new(1, -20, 0, 180)
    PlayerList.Position = UDim2.fromOffset(10, 45)
    PlayerList.BackgroundTransparency = 1
    PlayerList.BorderSizePixel = 0
    PlayerList.ScrollBarThickness = 3
    PlayerList.ScrollBarImageColor3 = Theme.Secondary
    PlayerList.Parent = PlayerListFrame

    local PlayerLayout = Instance.new("UIListLayout")
    PlayerLayout.Padding = UDim.new(0, 4)
    PlayerLayout.Parent = PlayerList

    local PlayerRows = {}

    local function RefreshPlayers()

        for _, Row in pairs(PlayerRows) do
            Row:Destroy()
        end

        table.clear(PlayerRows)

        local Search = string.lower(SearchBox.Text)

        local Count = 0

        for _, Player in ipairs(Players:GetPlayers()) do

            if Player ~= Players.LocalPlayer then

                local Name = string.lower(Player.Name)
                local DisplayName = string.lower(Player.DisplayName)

                if Search == ""
                    or string.find(Name, Search, 1, true)
                    or string.find(DisplayName, Search, 1, true) then

                    Count += 1

                    local Row = Components.Button(
                        PlayerList,
                        Player.DisplayName .. "  @" .. Player.Name,
                        UDim2.new(1, -5, 0, 30),
                        UDim2.new()
                    )

                    Row.TextSize = 11
                    Row.TextColor3 = Theme.Text
                    Row.BackgroundColor3 = Theme.Sidebar

                    local function UpdateRow()

                        if IgnorePlayers.IsIgnored(Player) then
                            Row.Text =
                                Player.DisplayName ..
                                "  @" ..
                                Player.Name ..
                                "  ✓"
                        else
                            Row.Text =
                                Player.DisplayName ..
                                "  @" ..
                                Player.Name
                        end
                    end

                    UpdateRow()

                    Row.MouseButton1Click:Connect(function()

                        IgnorePlayers.Toggle(Player)

                        UpdateRow()

                        if IgnorePlayers.IsIgnored(Player) then
                            Aimbot.SetIgnoredPlayers(
                                {
                                    [Player.UserId] = true
                                }
                            )
                        else
                            local Ignored = {}

                            for _, IgnoredPlayer in ipairs(
                                IgnorePlayers.GetAll()
                            ) do
                                Ignored[IgnoredPlayer.UserId] = true
                            end

                            Aimbot.SetIgnoredPlayers(Ignored)
                        end
                    end)

                    PlayerRows[Player] = Row
                end
            end
        end

        if Count == 0 then

            local Empty = Components.Label(
                PlayerList,
                GetText(
                    Localization,
                    CurrentLanguage,
                    "NoPlayers"
                ),
                UDim2.new(1, -5, 0, 30),
                UDim2.new()
            )

            Empty.TextColor3 = Theme.Secondary
        end
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(
        RefreshPlayers
    )

    local PlayerListOpen = false

    IgnoreButton.MouseButton1Click:Connect(function()

        PlayerListOpen = not PlayerListOpen

        PlayerListFrame.Visible = PlayerListOpen

        if PlayerListOpen then
            PlayerListFrame.Size =
                UDim2.new(1, -5, 0, 240)
        else
            PlayerListFrame.Size =
                UDim2.new(1, -5, 0, 0)
        end

        RefreshPlayers()
    end)

    Players.PlayerAdded:Connect(function()
        if PlayerListOpen then
            RefreshPlayers()
        end
    end)

    Players.PlayerRemoving:Connect(function(Player)

        IgnorePlayers.SetIgnored(Player, false)

        if PlayerRows[Player] then
            PlayerRows[Player]:Destroy()
            PlayerRows[Player] = nil
        end

        if PlayerListOpen then
            RefreshPlayers()
        end
    end)

    --------------------------------------------------
    -- SETTINGS
    --------------------------------------------------

    local LanguageSection = Section(
        SettingsPage,
        GetText(Localization, CurrentLanguage, "Language")
    )

    local LanguageDropdown = Dropdown(
        SettingsPage,
        GetText(Localization, CurrentLanguage, "Language"),
        {
            "English",
            "Русский"
        },
        CurrentLanguage,
        function(Value)

            CurrentLanguage = Value

            -- обновим основные подписи
            AimTabButton.Text =
                GetText(Localization, CurrentLanguage, "AIMBOT")

            SettingsTabButton.Text =
                GetText(Localization, CurrentLanguage, "SETTINGS")

            AimSection.Label.Text =
                GetText(Localization, CurrentLanguage, "Aimbot")

            AimbotToggle.Label.Text =
                GetText(Localization, CurrentLanguage, "Aimbot")

            BowDropdown.Label.Text =
                GetText(Localization, CurrentLanguage, "Bows")

            PredictionSection.Label.Text =
                GetText(Localization, CurrentLanguage, "Prediction")

            PredictionDropdown.Label.Text =
                GetText(Localization, CurrentLanguage, "Prediction")

            FOVSection.Label.Text =
                GetText(Localization, CurrentLanguage, "FOV")

            FOVVisibilityToggle.Label.Text =
                GetText(
                    Localization,
                    CurrentLanguage,
                    "FOVVisibility"
                )

            RainbowToggle.Label.Text =
                GetText(
                    Localization,
                    CurrentLanguage,
                    "RainbowFOV"
                )

            IgnoreSection.Label.Text =
                GetText(
                    Localization,
                    CurrentLanguage,
                    "IgnorePlayers"
                )

            IgnoreButton.Text =
                GetText(
                    Localization,
                    CurrentLanguage,
                    "IgnorePlayers"
                )

            SearchBox.PlaceholderText =
                GetText(
                    Localization,
                    CurrentLanguage,
                    "SearchPlayer"
                )

            LanguageSection.Label.Text =
                GetText(
                    Localization,
                    CurrentLanguage,
                    "Language"
                )

            LanguageDropdown.Label.Text =
                GetText(
                    Localization,
                    CurrentLanguage,
                    "Language"
                )

            ThemeSection.Label.Text =
                GetText(
                    Localization,
                    CurrentLanguage,
                    "Theme"
                )

            ThemeDropdown.Label.Text =
                GetText(
                    Localization,
                    CurrentLanguage,
                    "Theme"
                )

            RefreshPlayers()
        end
    )

    --------------------------------------------------
    -- THEME
    --------------------------------------------------

    local ThemeSection = Section(
        SettingsPage,
        GetText(Localization, CurrentLanguage, "Theme")
    )

    local ThemeDropdown

    ThemeDropdown = Dropdown(
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

            --------------------------------------------------
            -- MAIN
            --------------------------------------------------

            MainFrame.BackgroundColor3 = Theme.Main
            MainStroke.Color = Theme.Text

            TopBar.BackgroundColor3 = Theme.Sidebar
            Sidebar.BackgroundColor3 = Theme.Sidebar

            Title.TextColor3 = Theme.Text
            Logo.TextColor3 = Theme.Text
            Version.TextColor3 = Theme.Secondary

            CloseButton.BackgroundColor3 = Theme.Element
            CloseButton.TextColor3 = Theme.Text

            --------------------------------------------------
            -- TABS
            --------------------------------------------------

            AimTabButton.BackgroundColor3 = Theme.Selected
            AimTabButton.TextColor3 = Theme.Text

            SettingsTabButton.BackgroundColor3 =
                Theme.Element

            SettingsTabButton.TextColor3 =
                Theme.Text

            --------------------------------------------------
            -- FOV
            --------------------------------------------------

            FOVBar.BackgroundColor3 = Theme.Sidebar
            FOVFill.BackgroundColor3 = Theme.ToggleOn
            FOVKnob.BackgroundColor3 = Theme.Main

            --------------------------------------------------
            -- PLAYERS
            --------------------------------------------------

            SearchBox.BackgroundColor3 = Theme.Sidebar
            SearchBox.TextColor3 = Theme.Text
            SearchBox.PlaceholderColor3 = Theme.Secondary

            RefreshPlayers()
        end
    )

    --------------------------------------------------
    -- TABS
    --------------------------------------------------

    AimTabButton.BackgroundColor3 = Theme.Selected
    AimTabButton.TextColor3 = Theme.Text

    SettingsTabButton.BackgroundColor3 = Theme.Element
    SettingsTabButton.TextColor3 = Theme.Text

    AimTabButton.MouseButton1Click:Connect(function()

        AimPage.Visible = true
        SettingsPage.Visible = false

        AimTabButton.BackgroundColor3 =
            Theme.Selected

        SettingsTabButton.BackgroundColor3 =
            Theme.Element
    end)

    SettingsTabButton.MouseButton1Click:Connect(function()

        AimPage.Visible = false
        SettingsPage.Visible = true

        SettingsTabButton.BackgroundColor3 =
            Theme.Selected

        AimTabButton.BackgroundColor3 =
            Theme.Element
    end)

    --------------------------------------------------
    -- FOV CREATE
    --------------------------------------------------

    FOV.Create(
        ScreenGui,
        Settings.FOVRadius
    )

    FOV.SetVisible(false)

    Aimbot.SetBow(Settings.SelectedBow)
    Aimbot.SetPrediction(Settings.Prediction)
    Aimbot.SetFOVRadius(Settings.FOVRadius)
    Aimbot.SetEnabled(false)

    --------------------------------------------------
    -- INSERT
    --------------------------------------------------

    UserInputService.InputBegan:Connect(function(
        Input,
        GameProcessed
    )

        if GameProcessed then
            return
        end

        if Input.KeyCode == Enum.KeyCode.Insert then

            MainFrame.Visible =
                not MainFrame.Visible
        end
    end)

    print("Combat Warriors GUI loaded")
    print("Press INSERT to open menu")

    return ScreenGui
end

return UI
