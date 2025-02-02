if not _G.SleekChat then _G.SleekChat = {} end
if _G.SleekChat.Config and _G.SleekChat.Config._loaded then
    return
end

_G.SleekChat.Config = _G.SleekChat.Config or {}
local Config = _G.SleekChat.Config
local Logger = _G.SleekChat.Logger
local Modules = _G.SleekChat.Modules or error("Modules registry missing. Check Init.lua and .toc order!")

Logger:Debug("Config Loading...")

-- Create a dummy locale table that returns the key as-is.
local function createDummyLocale()
    return setmetatable({}, {
        __index = function(_, key)
            return key
        end
    })
end

-- Use the real locale table if it exists; otherwise, fall back.
local L = _G.SleekChat.L or createDummyLocale()

function Config.generateOptions(instance, getter, setter)
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
                            local c = instance.db.profile.bgColor
                            return c.r or 0, c.g or 0, c.b or 0, c.a or 1
                        end,
                        set = function(_, r, g, b, a)
                            instance.db.profile.bgColor = { r = r, g = g, b = b, a = a }
                            if instance.UI and instance.UI.UpdateBackground then
                                instance.UI.UpdateBackground(instance)
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
    local options = configGenerator(instance, getter, setter)
    AceConfig:RegisterOptionsTable("SleekChat", options)
    AceConfigDialog:AddToBlizOptions("SleekChat", "SleekChat")
    Logger:Debug("Config.Setup completed.")
end

Logger:Debug("Config Loaded!")
Config._loaded = true
Modules:register("Config", Config)
