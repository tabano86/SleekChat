-- config.lua
local AceLocale = LibStub("AceLocale-3.0")
local L = AceLocale:GetLocale("SleekChat", true) or AceLocale:NewLocale("SleekChat", "enUS", true)
if L then
    L["General"]           = "General"
    L["Hide Default Chat"] = "Hide Default Chat"
    L["Class Colors"]      = "Class Colors"
    L["Timestamps"]        = "Timestamps"
    L["URL Detection"]     = "URL Detection"
    L["Appearance"]        = "Appearance"
    L["Font"]              = "Font"
    L["Font Size"]         = "Font Size"
    L["Background Color"]  = "Background Color"
end

local function generateOptions(getter, setter)
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
                            ["Fonts\\ARIALN.TTF"] = "Arial Narrow",
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
                            local c = SleekChat.db.profile.bgColor
                            return c.r, c.g, c.b, c.a
                        end,
                        set = function(_, r, g, b, a)
                            SleekChat.db.profile.bgColor = { r = r, g = g, b = b, a = a }
                            if SleekChat.UI and SleekChat.UI.UpdateBackground then
                                SleekChat.UI.UpdateBackground(SleekChat)
                            end
                        end,
                        order = 3,
                    },
                },
            },
        },
    }
end

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local function Setup(instance, configGenerator)
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
end

SleekChat = SleekChat or {}
SleekChat.Config = {
    generateOptions = generateOptions,
    Setup = Setup,
}
