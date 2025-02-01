-- config.lua
if not _G.SleekChat then _G.SleekChat = {} end
if _G.SleekChat.Config and _G.SleekChat.Config._loaded then return end
_G.SleekChat.Config = _G.SleekChat.Config or {}
local Config = _G.SleekChat.Config
local Logger = _G.SleekChat.Logger
local Util = _G.SleekChat.Util
local L = _G.SleekChat.L or error("Locale not loaded; check .toc order!")

Logger:Debug("Config Loading...")

function Config.generateOptions(getter, setter)
    return {
        name = "SleekChat",
        type = "group",
        args = {
            general = {
                name = L["General"],
                type = "group",
                args = {
                    hideDefault = {
                        type = "toggle",
                        name = L["Hide Default Chat"],
                        get = getter,
                        set = setter,
                        order = 1,
                    },
                    classColors = {
                        type = "toggle",
                        name = L["Class Colors"],
                        get = getter,
                        set = setter,
                        order = 2,
                    },
                    timestamps = {
                        type = "toggle",
                        name = L["Timestamps"],
                        get = getter,
                        set = setter,
                        order = 3,
                    },
                    urlDetection = {
                        type = "toggle",
                        name = L["URL Detection"],
                        get = getter,
                        set = setter,
                        order = 4,
                    },
                },
            },
            appearance = {
                name = L["Appearance"],
                type = "group",
                args = {
                    font = {
                        type = "select",
                        name = L["Font"],
                        values = {
                            ["Fonts\\FRIZQT__.TTF"] = "Friz Quadrata",
                            ["Fonts\\ARIALN.TTF"]   = "Arial Narrow",
                            ["Fonts\\MORPHEUS.TTF"] = "Morpheus",
                        },
                        get = getter,
                        set = setter,
                        order = 1,
                    },
                    fontSize = {
                        type = "range",
                        name = L["Font Size"],
                        min = 8,
                        max = 24,
                        step = 1,
                        get = getter,
                        set = setter,
                        order = 2,
                    },
                    bgColor = {
                        type = "color",
                        name = L["Background Color"],
                        hasAlpha = true,
                        get = function()
                            local c = _G.SleekChat.db.profile.bgColor
                            return c.r or 0, c.g or 0, c.b or 0, c.a or 1
                        end,
                        set = function(_, r, g, b, a)
                            _G.SleekChat.db.profile.bgColor = { r = r, g = g, b = b, a = a }
                            if _G.SleekChat.UI and _G.SleekChat.UI.UpdateBackground then
                                _G.SleekChat.UI.UpdateBackground(_G.SleekChat)
                            end
                        end,
                        order = 3,
                    },
                },
            },
        },
    }
end

function Config.Setup(instance, configGenerator)
    local AceConfig       = LibStub("AceConfig-3.0")
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local function getter(info)
        return instance.db.profile[info[#info]]
    end
    local function setter(info, value)
        instance.db.profile[info[#info]] = value
        if instance.ApplySettings then
            instance:ApplySettings()
        end
    end
    local options = configGenerator(getter, setter)
    AceConfig:RegisterOptionsTable("SleekChat", options)
    AceConfigDialog:AddToBlizOptions("SleekChat", "SleekChat")
    Logger:Debug("Config.Setup completed.")
end

Logger:Debug("Config Loaded!")
Config._loaded = true
local registry = _G.SleekChat.Modules
registry:register("Config", Config)
