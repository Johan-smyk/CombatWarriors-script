local Root = script.Parent

local Config = require(Root.Config.Settings)

local Components = require(Root.UI.Components)
local Localization = require(Root.UI.Localization)
local Themes = require(Root.UI.Themes)
local MainMenu = require(Root.UI.MainMenu)

local Aimbot = require(Root.Features.Aimbot)
local FOV = require(Root.Features.FOV)
local IgnorePlayers = require(Root.Features.IgnorePlayers)

local Helpers = require(Root.Utils.Helpers)

local Modules = {
    Config = Config,

    UI = {
        Components = Components,
        Localization = Localization,
        Themes = Themes,
        MainMenu = MainMenu
    },

    Features = {
        Aimbot = Aimbot,
        FOV = FOV,
        IgnorePlayers = IgnorePlayers
    },

    Utils = {
        Helpers = Helpers
    }
}

MainMenu:Init(Modules)

print("Combat Warriors loaded!")
